const router = require("express").Router();
const { pool } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// Helper to compute previous period dates
function getPreviousPeriod(fromDate, toDate) {
  const from = new Date(fromDate);
  const to = new Date(toDate);
  const diffTime = Math.abs(to.getTime() - from.getTime());
  const diffDays = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1);

  const prevTo = new Date(from);
  prevTo.setDate(prevTo.getDate() - 1);

  const prevFrom = new Date(prevTo);
  prevFrom.setDate(prevFrom.getDate() - diffDays + 1);

  const format = (d) => d.toISOString().split("T")[0];
  return {
    prevFrom: format(prevFrom),
    prevTo: format(prevTo),
  };
}

// ─── 1. Summary Statistics ──────────────────────────────────────────────────
// GET /api/reports/summary?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/summary", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";

  const { prevFrom, prevTo } = req.query.prevFrom && req.query.prevTo
    ? { prevFrom: req.query.prevFrom, prevTo: req.query.prevTo }
    : getPreviousPeriod(from, to);

  try {
    const conn = await pool.getConnection();
    try {
      // Current period stats
      const [currentRows] = await conn.query(
        `SELECT 
           (SELECT IFNULL(SUM(total_amount), 0) FROM transactions WHERE (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS total_sales,
           (SELECT COUNT(id) FROM transactions WHERE (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS total_transactions,
           (SELECT IFNULL(SUM(ti.quantity), 0) FROM transaction_items ti JOIN transactions t ON t.id = ti.transaction_id WHERE (t.status = 'Completed' OR t.status IS NULL) AND DATE(t.created_at) BETWEEN ? AND ?) AS products_sold,
           (SELECT COUNT(DISTINCT IFNULL(customer_id, CONCAT('walkin_', id))) FROM transactions WHERE (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS total_customers_served,
           (SELECT COUNT(DISTINCT customer_id) FROM transactions WHERE customer_id IS NOT NULL AND (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS registered_customers_served`,
        [from, to, from, to, from, to, from, to, from, to]
      );

      // Previous period stats for comparison
      const [prevRows] = await conn.query(
        `SELECT 
           (SELECT IFNULL(SUM(total_amount), 0) FROM transactions WHERE (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS total_sales,
           (SELECT COUNT(id) FROM transactions WHERE (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS total_transactions,
           (SELECT IFNULL(SUM(ti.quantity), 0) FROM transaction_items ti JOIN transactions t ON t.id = ti.transaction_id WHERE (t.status = 'Completed' OR t.status IS NULL) AND DATE(t.created_at) BETWEEN ? AND ?) AS products_sold,
           (SELECT COUNT(DISTINCT IFNULL(customer_id, CONCAT('walkin_', id))) FROM transactions WHERE (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS total_customers_served,
           (SELECT COUNT(DISTINCT customer_id) FROM transactions WHERE customer_id IS NOT NULL AND (status = 'Completed' OR status IS NULL) AND DATE(created_at) BETWEEN ? AND ?) AS registered_customers_served`,
        [prevFrom, prevTo, prevFrom, prevTo, prevFrom, prevTo, prevFrom, prevTo, prevFrom, prevTo]
      );

      const current = currentRows[0] || {};
      const previous = prevRows[0] || {};

      const calcPctChange = (cur, prev) => {
        const c = Number(cur || 0);
        const p = Number(prev || 0);
        if (p === 0) return c > 0 ? 100 : 0;
        return Number((((c - p) / p) * 100).toFixed(1));
      };

      res.json({
        period: { from, to, prevFrom, prevTo },
        current: {
          total_sales: Number(current.total_sales || 0),
          total_transactions: Number(current.total_transactions || 0),
          products_sold: Number(current.products_sold || 0),
          customers_served: Number(current.total_customers_served || 0),
          registered_customers_served: Number(current.registered_customers_served || 0),
        },
        previous: {
          total_sales: Number(previous.total_sales || 0),
          total_transactions: Number(previous.total_transactions || 0),
          products_sold: Number(previous.products_sold || 0),
          customers_served: Number(previous.total_customers_served || 0),
          registered_customers_served: Number(previous.registered_customers_served || 0),
        },
        growth: {
          sales_pct: calcPctChange(current.total_sales, previous.total_sales),
          transactions_pct: calcPctChange(current.total_transactions, previous.total_transactions),
          products_sold_pct: calcPctChange(current.products_sold, previous.products_sold),
          customers_served_pct: calcPctChange(current.total_customers_served, previous.total_customers_served),
        },
      });
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/summary:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 2. Sales Overview (Time Series Chart) ──────────────────────────────────
// GET /api/reports/sales-overview?from=YYYY-MM-DD&to=YYYY-MM-DD&groupBy=daily|weekly|monthly|yearly
router.get("/sales-overview", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";
  const groupBy = req.query.groupBy || "daily";

  let dateFormatSql = "%b %d, %Y";
  let groupBySql = "DATE(t.created_at)";

  if (groupBy === "daily") {
    dateFormatSql = "%b %d, %Y";
    groupBySql = "DATE(t.created_at)";
  } else if (groupBy === "weekly") {
    dateFormatSql = "Week %v, %Y";
    groupBySql = "YEARWEEK(t.created_at, 1)";
  } else if (groupBy === "monthly") {
    dateFormatSql = "%b %Y";
    groupBySql = "DATE_FORMAT(t.created_at, '%Y-%m')";
  } else if (groupBy === "yearly") {
    dateFormatSql = "%Y";
    groupBySql = "YEAR(t.created_at)";
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(
        `SELECT 
           ${groupBySql} AS grp,
           DATE_FORMAT(MIN(t.created_at), ?) AS label,
           DATE(MIN(t.created_at)) AS raw_date,
           IFNULL(SUM(t.total_amount), 0) AS total_sales,
           COUNT(t.id) AS total_transactions
         FROM transactions t
         WHERE (t.status = 'Completed' OR t.status IS NULL)
           AND DATE(t.created_at) BETWEEN ? AND ?
         GROUP BY ${groupBySql}
         ORDER BY MIN(t.created_at) ASC`,
        [dateFormatSql, from, to]
      );

      const points = rows.map(r => ({
        label: r.label,
        raw_date: r.raw_date,
        total_sales: Number(r.total_sales || 0),
        total_transactions: Number(r.total_transactions || 0),
      }));

      res.json(points);
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/sales-overview:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 3. Sales by Product Category ───────────────────────────────────────────
// GET /api/reports/sales-by-category?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/sales-by-category", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";

  try {
    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(
        `SELECT 
           IFNULL(c.name, 'Uncategorized') AS category,
           IFNULL(SUM(ti.quantity), 0) AS items_sold,
           IFNULL(SUM(ti.subtotal), 0) AS revenue
         FROM transaction_items ti
         JOIN transactions t ON t.id = ti.transaction_id
         JOIN products p ON p.id = ti.product_id
         LEFT JOIN categories c ON c.id = p.category_id
         WHERE (t.status = 'Completed' OR t.status IS NULL)
           AND DATE(t.created_at) BETWEEN ? AND ?
         GROUP BY c.id, c.name
         HAVING items_sold > 0
         ORDER BY revenue DESC`,
        [from, to]
      );

      const totalRevenue = rows.reduce((s, r) => s + Number(r.revenue || 0), 0);

      const results = rows.map(r => {
        const rev = Number(r.revenue || 0);
        const pct = totalRevenue > 0 ? Number(((rev / totalRevenue) * 100).toFixed(1)) : 0;
        return {
          category: r.category,
          items_sold: Number(r.items_sold || 0),
          revenue: rev,
          percentage: pct,
        };
      });

      res.json({
        total_revenue: totalRevenue,
        categories: results,
      });
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/sales-by-category:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 4. Best-Selling Products ────────────────────────────────────────────────
// GET /api/reports/best-sellers?from=YYYY-MM-DD&to=YYYY-MM-DD&sortBy=quantity|revenue&limit=10
router.get("/best-sellers", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";
  const sortBy = req.query.sortBy === "revenue" ? "total_revenue" : "quantity_sold";
  const limit = Math.min(100, Math.max(1, parseInt(req.query.limit, 10) || 20));

  try {
    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(
        `SELECT 
           p.id,
           p.name,
           IFNULL(c.name, 'Uncategorized') AS category,
           p.image_url,
           p.price,
           p.stock,
           p.low_stock_threshold,
           IFNULL(SUM(ti.quantity), 0) AS quantity_sold,
           IFNULL(SUM(ti.subtotal), 0) AS total_revenue
         FROM transaction_items ti
         JOIN transactions t ON t.id = ti.transaction_id
         JOIN products p ON p.id = ti.product_id
         LEFT JOIN categories c ON c.id = p.category_id
         WHERE (t.status = 'Completed' OR t.status IS NULL)
           AND DATE(t.created_at) BETWEEN ? AND ?
         GROUP BY p.id, p.name, c.name, p.image_url, p.price, p.stock, p.low_stock_threshold
         HAVING quantity_sold > 0
         ORDER BY ${sortBy} DESC, p.name ASC
         LIMIT ?`,
        [from, to, limit]
      );

      res.json(rows.map(r => ({
        id: r.id,
        name: r.name,
        category: r.category,
        image_url: r.image_url,
        price: Number(r.price),
        stock: Number(r.stock),
        low_stock_threshold: Number(r.low_stock_threshold),
        quantity_sold: Number(r.quantity_sold),
        total_revenue: Number(r.total_revenue),
      })));
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/best-sellers:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 5. Inventory Status Report ──────────────────────────────────────────────
// GET /api/reports/inventory-status
router.get("/inventory-status", authenticate, requireRole("admin"), async (req, res) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [products] = await conn.query(
        `SELECT 
           p.id,
           p.name,
           IFNULL(c.name, 'Uncategorized') AS category,
           p.price,
           p.stock,
           p.low_stock_threshold,
           p.is_active,
           CASE 
             WHEN p.stock <= 0 THEN 'Out of Stock'
             WHEN p.stock <= p.low_stock_threshold THEN 'Low Stock'
             ELSE 'In Stock'
           END AS status
         FROM products p
         LEFT JOIN categories c ON c.id = p.category_id
         WHERE p.is_active = 1
         ORDER BY 
           CASE 
             WHEN p.stock <= 0 THEN 1
             WHEN p.stock <= p.low_stock_threshold THEN 2
             ELSE 3
           END,
           p.stock ASC,
           p.name ASC`
      );

      const totalProducts = products.length;
      const outOfStock = products.filter(p => p.stock <= 0).length;
      const lowStock = products.filter(p => p.stock > 0 && p.stock <= p.low_stock_threshold).length;
      const inStock = products.filter(p => p.stock > p.low_stock_threshold).length;

      res.json({
        summary: {
          total_products: totalProducts,
          in_stock: inStock,
          low_stock: lowStock,
          out_of_stock: outOfStock,
        },
        products: products.map(p => ({
          id: p.id,
          name: p.name,
          category: p.category,
          price: Number(p.price),
          stock: Number(p.stock),
          low_stock_threshold: Number(p.low_stock_threshold),
          status: p.status,
        })),
      });
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/inventory-status:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 6. Customer Purchase Activity & Top Customers ──────────────────────────
// GET /api/reports/customer-activity?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/customer-activity", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";

  try {
    const conn = await pool.getConnection();
    try {
      // 1. Total registered approved customers
      const [[{ total_registered }]] = await conn.query(
        "SELECT COUNT(*) AS total_registered FROM customers WHERE account_status = 'Approved'"
      );

      // 2. Customers who purchased in this period
      const [[{ purchased_in_period }]] = await conn.query(
        `SELECT COUNT(DISTINCT customer_id) AS purchased_in_period
         FROM transactions
         WHERE customer_id IS NOT NULL 
           AND (status = 'Completed' OR status IS NULL)
           AND DATE(created_at) BETWEEN ? AND ?`,
        [from, to]
      );

      // 3. Returning customers (> 1 lifetime POS transaction)
      const [[{ returning_customers }]] = await conn.query(
        `SELECT COUNT(*) AS returning_customers FROM (
           SELECT customer_id
           FROM transactions
           WHERE customer_id IS NOT NULL 
             AND (status = 'Completed' OR status IS NULL)
           GROUP BY customer_id
           HAVING COUNT(id) > 1
         ) AS sub`
      );

      // 4. New customers (first ever recorded POS transaction occurred during this period)
      const [[{ new_customers }]] = await conn.query(
        `SELECT COUNT(*) AS new_customers FROM (
           SELECT customer_id, MIN(DATE(created_at)) AS first_purchase
           FROM transactions
           WHERE customer_id IS NOT NULL 
             AND (status = 'Completed' OR status IS NULL)
           GROUP BY customer_id
           HAVING first_purchase BETWEEN ? AND ?
         ) AS sub`,
        [from, to]
      );

      // 5. Top customers in this period
      const [topCustomers] = await conn.query(
        `SELECT 
           c.id,
           c.customer_code,
           CONCAT(c.first_name, ' ', c.last_name) AS full_name,
           c.phone,
           COUNT(DISTINCT t.id) AS transactions_count,
           (SELECT IFNULL(SUM(ti2.quantity), 0) 
            FROM transaction_items ti2 
            WHERE ti2.transaction_id IN (
              SELECT t2.id FROM transactions t2 
              WHERE t2.customer_id = c.id 
                AND (t2.status = 'Completed' OR t2.status IS NULL) 
                AND DATE(t2.created_at) BETWEEN ? AND ?
            )) AS items_purchased,
           IFNULL(SUM(t.total_amount), 0) AS total_spent,
           DATE_FORMAT(MAX(t.created_at), '%b %d, %Y') AS last_purchase_date
         FROM transactions t
         JOIN customers c ON c.id = t.customer_id
         WHERE (t.status = 'Completed' OR t.status IS NULL)
           AND DATE(t.created_at) BETWEEN ? AND ?
         GROUP BY c.id, c.customer_code, c.first_name, c.last_name, c.phone
         ORDER BY total_spent DESC, transactions_count DESC
         LIMIT 20`,
        [from, to, from, to]
      );

      res.json({
        summary: {
          total_registered: Number(total_registered || 0),
          purchased_in_period: Number(purchased_in_period || 0),
          returning_customers: Number(returning_customers || 0),
          new_customers: Number(new_customers || 0),
        },
        top_customers: topCustomers.map(c => ({
          id: c.id,
          customer_code: c.customer_code,
          name: c.full_name,
          phone: c.phone,
          transactions_count: Number(c.transactions_count || 0),
          items_purchased: Number(c.items_purchased || 0),
          total_spent: Number(c.total_spent || 0),
          last_purchase_date: c.last_purchase_date,
        })),
      });
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/customer-activity:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 7. Staff POS Performance ───────────────────────────────────────────────
// GET /api/reports/staff-performance?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/staff-performance", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";

  try {
    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(
        `SELECT 
           s.id,
           s.staff_code,
           s.full_name,
           s.role,
           s.status,
           COUNT(t.id) AS transactions_count,
           IFNULL(SUM(t.total_amount), 0) AS total_sales,
           IFNULL(AVG(t.total_amount), 0) AS avg_transaction_value,
           DATE_FORMAT(MAX(t.created_at), '%b %d, %Y %h:%i %p') AS last_transaction
         FROM staff s
         LEFT JOIN transactions t ON t.cashier_id = s.id 
           AND (t.status = 'Completed' OR t.status IS NULL)
           AND DATE(t.created_at) BETWEEN ? AND ?
         GROUP BY s.id, s.staff_code, s.full_name, s.role, s.status
         ORDER BY total_sales DESC, transactions_count DESC`,
        [from, to]
      );

      res.json(rows.map(r => ({
        id: r.id,
        staff_code: r.staff_code,
        name: r.full_name,
        role: r.role,
        status: r.status,
        transactions_count: Number(r.transactions_count || 0),
        total_sales: Number(r.total_sales || 0),
        avg_transaction_value: Number(Number(r.avg_transaction_value || 0).toFixed(2)),
        last_transaction: r.last_transaction || "No transactions in period",
      })));
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/staff-performance:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 8. Payment Method Report ────────────────────────────────────────────────
// GET /api/reports/payment-methods?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/payment-methods", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";

  try {
    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(
        `SELECT 
           IFNULL(payment_method, 'Cash') AS method,
           COUNT(id) AS transactions_count,
           IFNULL(SUM(total_amount), 0) AS total_amount
         FROM transactions
         WHERE (status = 'Completed' OR status IS NULL)
           AND DATE(created_at) BETWEEN ? AND ?
         GROUP BY IFNULL(payment_method, 'Cash')
         ORDER BY total_amount DESC`,
        [from, to]
      );

      const overallTotal = rows.reduce((s, r) => s + Number(r.total_amount || 0), 0);

      const methods = rows.map(r => {
        const amount = Number(r.total_amount || 0);
        const pct = overallTotal > 0 ? Number(((amount / overallTotal) * 100).toFixed(1)) : 0;
        return {
          method: r.method,
          transactions_count: Number(r.transactions_count || 0),
          total_amount: amount,
          percentage: pct,
        };
      });

      res.json({
        overall_total: overallTotal,
        methods,
      });
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/payment-methods:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 9. Filterable Receipt & Transaction History ────────────────────────────
// GET /api/reports/transactions?from=YYYY-MM-DD&to=YYYY-MM-DD&search=&payment_method=&staff_id=
router.get("/transactions", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to = req.query.to || "2099-12-31";
  const search = req.query.search ? `%${req.query.search.trim()}%` : null;
  const paymentMethod = req.query.payment_method || null;
  const staffId = req.query.staff_id ? Number(req.query.staff_id) : null;

  try {
    const conn = await pool.getConnection();
    try {
      let query = `
        SELECT 
          t.id,
          t.receipt_no,
          IFNULL(CONCAT(c.first_name, ' ', c.last_name), 'Walk-in Customer') AS customer,
          c.customer_code,
          s.full_name AS cashier,
          s.staff_code,
          t.total_amount,
          t.cash_tendered,
          t.change_amount,
          IFNULL(t.payment_method, 'Cash') AS payment_method,
          IFNULL(t.status, 'Completed') AS status,
          DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS formatted_date,
          t.created_at,
          (SELECT COUNT(*) FROM transaction_items WHERE transaction_id = t.id) AS items_count
        FROM transactions t
        LEFT JOIN customers c ON c.id = t.customer_id
        JOIN staff s ON s.id = t.cashier_id
        WHERE DATE(t.created_at) BETWEEN ? AND ?
      `;
      const params = [from, to];

      if (paymentMethod && paymentMethod !== "All") {
        query += " AND (t.payment_method = ? OR (t.payment_method IS NULL AND ? = 'Cash'))";
        params.push(paymentMethod, paymentMethod);
      }

      if (staffId) {
        query += " AND t.cashier_id = ?";
        params.push(staffId);
      }

      if (search) {
        query += ` AND (
          t.receipt_no LIKE ? OR 
          CONCAT(c.first_name, ' ', c.last_name) LIKE ? OR 
          c.customer_code LIKE ? OR 
          s.full_name LIKE ? OR 
          s.staff_code LIKE ?
        )`;
        params.push(search, search, search, search, search);
      }

      query += " ORDER BY t.created_at DESC";

      const [rows] = await conn.query(query, params);

      res.json(rows.map(r => ({
        id: r.id,
        receipt_no: r.receipt_no,
        customer: r.customer,
        customer_code: r.customer_code,
        cashier: r.cashier,
        staff_code: r.staff_code,
        items_count: Number(r.items_count || 0),
        total_amount: Number(r.total_amount || 0),
        cash_tendered: Number(r.cash_tendered || 0),
        change_amount: Number(r.change_amount || 0),
        payment_method: r.payment_method,
        status: r.status,
        date: r.formatted_date,
        raw_created_at: r.created_at,
      })));
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/transactions:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── 8. Returns & Refunds Analytics ──────────────────────────────────────────
// GET /api/reports/returns-analytics?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/returns-analytics", authenticate, requireRole("admin"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to   = req.query.to   || "2099-12-31";

  try {
    const conn = await pool.getConnection();
    try {
      // 1. Overall Summary
      const [summaryRows] = await conn.query(
        `SELECT
           COUNT(DISTINCT r.id) AS total_returns,
           SUM(IF(r.status = 'Pending', 1, 0)) AS pending_count,
           SUM(IF(r.status IN ('Approved', 'Completed'), 1, 0)) AS approved_count,
           SUM(IF(r.status = 'Rejected', 1, 0)) AS rejected_count,
           IFNULL(SUM(IF(r.status IN ('Approved', 'Completed'), r.refund_amount, 0)), 0) AS total_refunded,
           IFNULL(SUM(IF(r.status IN ('Approved', 'Completed'), ri.quantity, 0)), 0) AS items_returned_count
         FROM returns r
         LEFT JOIN return_items ri ON ri.return_id = r.id
         WHERE DATE(r.created_at) BETWEEN ? AND ?`,
        [from, to]
      );

      // 2. Reason Breakdown
      const [reasonRows] = await conn.query(
        `SELECT
           r.reason,
           COUNT(DISTINCT r.id) AS count,
           IFNULL(SUM(IF(r.status IN ('Approved', 'Completed'), r.refund_amount, 0)), 0) AS refund_amount,
           IFNULL(SUM(ri.quantity), 0) AS items_count
         FROM returns r
         LEFT JOIN return_items ri ON ri.return_id = r.id
         WHERE DATE(r.created_at) BETWEEN ? AND ?
         GROUP BY r.reason
         ORDER BY count DESC`,
        [from, to]
      );

      // 3. Top Returned Products
      const [topProductRows] = await conn.query(
        `SELECT
           ri.product_id,
           ri.product_name,
           IFNULL(c.name, 'Uncategorized') AS category,
           COUNT(DISTINCT r.id) AS return_occurrences,
           SUM(ri.quantity) AS total_quantity_returned,
           SUM(ri.refund_amount) AS total_refund_amount,
           SUM(IF(ri.restock = 1, ri.quantity, 0)) AS total_restocked_quantity
         FROM return_items ri
         JOIN returns r ON r.id = ri.return_id
         LEFT JOIN products p ON p.id = ri.product_id
         LEFT JOIN categories c ON c.id = p.category_id
         WHERE DATE(r.created_at) BETWEEN ? AND ? AND r.status IN ('Approved', 'Completed')
         GROUP BY ri.product_id, ri.product_name, c.name
         ORDER BY total_quantity_returned DESC
         LIMIT 10`,
        [from, to]
      );

      // 4. Detailed returns list in range
      const [recentRows] = await conn.query(
        `SELECT
           r.id,
           r.return_no,
           t.receipt_no,
           CONCAT(cust.last_name, ', ', cust.first_name) AS customer_name,
           cust.customer_code,
           r.status,
           r.reason,
           r.customer_notes,
           r.admin_notes,
           r.refund_amount,
           DATE_FORMAT(r.created_at, '%b %d, %Y %h:%i %p') AS formatted_date,
           r.created_at,
           COUNT(ri.id) AS items_count,
           IFNULL(SUM(ri.quantity), 0) AS total_items_quantity,
           GROUP_CONCAT(CONCAT(ri.product_name, ' (x', ri.quantity, ')') SEPARATOR ', ') AS returned_items_summary
         FROM returns r
         JOIN transactions t ON t.id = r.transaction_id
         JOIN customers cust ON cust.id = r.customer_id
         LEFT JOIN return_items ri ON ri.return_id = r.id
         WHERE DATE(r.created_at) BETWEEN ? AND ?
         GROUP BY r.id
         ORDER BY r.created_at DESC`,
        [from, to]
      );

      res.json({
        summary: {
          total_returns: Number(summaryRows[0]?.total_returns || 0),
          pending_count: Number(summaryRows[0]?.pending_count || 0),
          approved_count: Number(summaryRows[0]?.approved_count || 0),
          rejected_count: Number(summaryRows[0]?.rejected_count || 0),
          total_refunded: Number(summaryRows[0]?.total_refunded || 0),
          items_returned_count: Number(summaryRows[0]?.items_returned_count || 0),
        },
        reasons: reasonRows.map(row => ({
          reason: row.reason,
          count: Number(row.count),
          refund_amount: Number(row.refund_amount),
          items_count: Number(row.items_count),
        })),
        top_returned_products: topProductRows.map(row => ({
          product_id: row.product_id,
          product_name: row.product_name,
          category: row.category,
          return_occurrences: Number(row.return_occurrences),
          total_quantity_returned: Number(row.total_quantity_returned),
          total_refund_amount: Number(row.total_refund_amount),
          total_restocked_quantity: Number(row.total_restocked_quantity),
        })),
        returns_list: recentRows.map(row => ({
          id: row.id,
          return_no: row.return_no,
          receipt_no: row.receipt_no,
          customer_name: row.customer_name,
          customer_code: row.customer_code,
          status: row.status,
          reason: row.reason,
          customer_notes: row.customer_notes,
          admin_notes: row.admin_notes,
          refund_amount: Number(row.refund_amount),
          date: row.formatted_date,
          items_count: Number(row.items_count),
          total_items_quantity: Number(row.total_items_quantity),
          returned_items_summary: row.returned_items_summary || "None",
        })),
      });
    } finally {
      conn.release();
    }
  } catch (err) {
    console.error("Error in /api/reports/returns-analytics:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
