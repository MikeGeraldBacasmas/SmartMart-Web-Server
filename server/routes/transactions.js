const router  = require("express").Router();
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/transactions?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const from = req.query.from || "2000-01-01";
  const to   = req.query.to   || "2099-12-31";
  try {
    res.json(await call("sp_get_transactions", [from, to]));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/transactions/my-history  — customer purchase history
router.get("/my-history", authenticate, async (req, res) => {
  try {
    const rows = await call("sp_get_customer_purchase_history", [req.user.id]);
    res.json(rows || []);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/transactions/my-analytics — customer purchase & item-level analytics
router.get("/my-analytics", authenticate, async (req, res) => {
  try {
    const [items] = await pool.query(
      `SELECT
         ti.id AS item_id,
         t.id AS transaction_id,
         t.receipt_no,
         t.created_at,
         DATE_FORMAT(t.created_at, '%Y-%m-%d') AS date_ymd,
         DATE_FORMAT(t.created_at, '%Y-%m') AS \`year_month\`,
         DATE_FORMAT(t.created_at, '%Y') AS \`year\`,
         DATE_FORMAT(t.created_at, '%b %Y') AS month_label,
         DATE_FORMAT(t.created_at, '%b') AS month_short,
         DATE_FORMAT(t.created_at, '%c') AS month_num,
         DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS formatted_date,
         ti.product_id,
         ti.product_name,
         p.category_id,
         IFNULL(cat.name, 'General') AS category,
         ti.quantity,
         CAST(ti.unit_price AS DECIMAL(10, 2)) AS unit_price,
         CAST(ti.subtotal AS DECIMAL(10, 2)) AS line_total,
         IFNULL(ret_sub.returned_quantity, 0) AS returned_quantity,
         IFNULL(ret_sub.refund_amount, 0) AS item_refund_amount
       FROM transaction_items ti
       JOIN transactions t ON t.id = ti.transaction_id
       JOIN customers c ON c.id = t.customer_id
       LEFT JOIN products p ON p.id = ti.product_id
       LEFT JOIN categories cat ON cat.id = p.category_id
       LEFT JOIN (
         SELECT ri.transaction_item_id,
                SUM(CASE WHEN r.status IN ('Approved', 'Completed') THEN ri.quantity ELSE 0 END) AS returned_quantity,
                SUM(CASE WHEN r.status IN ('Approved', 'Completed') THEN ri.refund_amount ELSE 0 END) AS refund_amount
         FROM return_items ri
         JOIN returns r ON r.id = ri.return_id
         GROUP BY ri.transaction_item_id
       ) ret_sub ON ret_sub.transaction_item_id = ti.id
       WHERE c.user_id = ?
       ORDER BY t.created_at DESC`,
      [req.user.id]
    );

    const [txSummary] = await pool.query(
      `SELECT
         t.id,
         t.receipt_no,
         CAST(t.total_amount AS DECIMAL(10, 2)) AS total_amount,
         DATE_FORMAT(t.created_at, '%Y-%m-%d') AS date_ymd,
         DATE_FORMAT(t.created_at, '%Y-%m') AS \`year_month\`,
         DATE_FORMAT(t.created_at, '%Y') AS \`year\`,
         DATE_FORMAT(t.created_at, '%b %Y') AS month_label,
         DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS date
       FROM transactions t
       JOIN customers c ON c.id = t.customer_id
       WHERE c.user_id = ?
       ORDER BY t.created_at DESC`,
      [req.user.id]
    );

    const [returnItems] = await pool.query(
      `SELECT
         ri.id AS return_item_id,
         ri.return_id,
         ri.transaction_item_id,
         r.return_no,
         r.status,
         r.reason,
         r.customer_notes,
         r.admin_notes,
         r.created_at,
         DATE_FORMAT(r.created_at, '%Y-%m-%d') AS date_ymd,
         DATE_FORMAT(r.created_at, '%Y-%m') AS \`year_month\`,
         DATE_FORMAT(r.created_at, '%Y') AS \`year\`,
         DATE_FORMAT(r.created_at, '%b %Y') AS month_label,
         DATE_FORMAT(r.created_at, '%b') AS month_short,
         DATE_FORMAT(r.created_at, '%c') AS month_num,
         DATE_FORMAT(r.created_at, '%b %d, %Y %h:%i %p') AS formatted_date,
         ri.product_id,
         ri.product_name,
         p.category_id,
         IFNULL(cat.name, 'General') AS category,
         ri.quantity,
         CAST(ri.unit_price AS DECIMAL(10, 2)) AS unit_price,
         CAST(ri.refund_amount AS DECIMAL(10, 2)) AS refund_amount,
         t.receipt_no,
         r.transaction_id
       FROM return_items ri
       JOIN returns r ON r.id = ri.return_id
       JOIN transactions t ON t.id = r.transaction_id
       JOIN customers c ON c.id = r.customer_id
       LEFT JOIN products p ON p.id = ri.product_id
       LEFT JOIN categories cat ON cat.id = p.category_id
       WHERE c.user_id = ?
       ORDER BY r.created_at DESC`,
      [req.user.id]
    );

    const [returnSummary] = await pool.query(
      `SELECT
         r.id,
         r.return_no,
         r.transaction_id,
         t.receipt_no,
         r.status,
         r.reason,
         r.customer_notes,
         r.admin_notes,
         CAST(r.refund_amount AS DECIMAL(10, 2)) AS refund_amount,
         DATE_FORMAT(r.created_at, '%Y-%m-%d') AS date_ymd,
         DATE_FORMAT(r.created_at, '%Y-%m') AS \`year_month\`,
         DATE_FORMAT(r.created_at, '%Y') AS \`year\`,
         DATE_FORMAT(r.created_at, '%b %Y') AS month_label,
         DATE_FORMAT(r.created_at, '%b %d, %Y %h:%i %p') AS created_at,
         COUNT(ri.id) AS item_count,
         IFNULL(SUM(ri.quantity), 0) AS total_items_quantity
       FROM returns r
       JOIN transactions t ON t.id = r.transaction_id
       JOIN customers c ON c.id = r.customer_id
       LEFT JOIN return_items ri ON ri.return_id = r.id
       WHERE c.user_id = ?
       GROUP BY r.id
       ORDER BY r.created_at DESC`,
      [req.user.id]
    );

    res.json({
      items: (items || []).map(i => ({
        ...i,
        quantity: Number(i.quantity),
        unit_price: Number(i.unit_price),
        line_total: Number(i.line_total),
        returned_quantity: Number(i.returned_quantity || 0),
        item_refund_amount: Number(i.item_refund_amount || 0),
      })),
      transactions: (txSummary || []).map(t => ({
        ...t,
        total_amount: Number(t.total_amount),
      })),
      return_items: (returnItems || []).map(ri => ({
        ...ri,
        quantity: Number(ri.quantity),
        unit_price: Number(ri.unit_price),
        refund_amount: Number(ri.refund_amount),
      })),
      returns: (returnSummary || []).map(r => ({
        ...r,
        refund_amount: Number(r.refund_amount),
        item_count: Number(r.item_count || 0),
        total_items_quantity: Number(r.total_items_quantity || 0),
      }))
    });
  } catch (err) {
    console.error("Error in /api/transactions/my-analytics:", err);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/transactions/:id/items
router.get("/:id/items", authenticate, requireRole("admin", "staff", "customer"), async (req, res) => {
  try {
    res.json(await call("sp_get_transaction_items", [req.params.id]));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/transactions  — create + add items + finalize in one call
// Body: { customer_id?, cashier_id, cash_tendered, items: [{product_id, quantity}], payment_method?, discount_type?, discount_id_no?, discount_amount?, save_customer_discount? }
router.post("/", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const {
    customer_id,
    cashier_id,
    cash_tendered,
    items,
    payment_method,
    discount_type,
    discount_id_no,
    discount_amount,
    save_customer_discount
  } = req.body;

  if (!cashier_id || cash_tendered == null || !items?.length)
    return res.status(400).json({ error: "cashier_id, cash_tendered and items are required" });

  const conn = await pool.getConnection();
  try {
    // Validate available stock for each requested item before proceeding
    for (const item of items) {
      const [prodRows] = await conn.query("SELECT id, name, stock FROM products WHERE id = ?", [item.product_id]);
      if (!prodRows.length) {
        conn.release();
        return res.status(404).json({ error: `Product ID ${item.product_id} not found.` });
      }
      const prod = prodRows[0];
      if (Number(prod.stock) < Number(item.quantity)) {
        conn.release();
        return res.status(422).json({
          error: `Insufficient stock for "${prod.name}". Only ${prod.stock} left in stock, but ${item.quantity} requested.`
        });
      }
    }

    await conn.beginTransaction();

    // 1. Create transaction shell via stored procedure
    const [headerRows] = await conn.query(
      "CALL sp_create_transaction_header(?,?,?,?)",
      [customer_id || null, cashier_id, cash_tendered, payment_method || "Cash"]
    );
    const tid = headerRows[0][0].transaction_id;

    // 2. Add each item via stored procedure
    for (const item of items) {
      await conn.query("CALL sp_add_transaction_item(?,?,?)",
        [tid, item.product_id, item.quantity]);
    }

    // 2b. Calculate subtotal from items
    const [subRows] = await conn.query(
      "SELECT IFNULL(SUM(subtotal), 0) AS subtotal FROM transaction_items WHERE transaction_id = ?",
      [tid]
    );
    const subtotal = Number(subRows[0].subtotal || 0);

    const isDiscounted = (discount_type === "Senior Citizen" || discount_type === "PWD") && Boolean(discount_id_no?.trim());
    const finalDiscountType = isDiscounted ? discount_type : "None";
    const finalDiscountId = isDiscounted ? discount_id_no.trim() : null;
    const finalDiscountAmt = isDiscounted
      ? (discount_amount != null ? Number(discount_amount) : Math.round(subtotal * 0.05 * 100) / 100)
      : 0;

    // Update discount details in transaction record before finalize
    await conn.query(
      "UPDATE transactions SET subtotal_amount = ?, discount_type = ?, discount_id_no = ?, discount_amount = ? WHERE id = ?",
      [subtotal, finalDiscountType, finalDiscountId, finalDiscountAmt, tid]
    );

    // If customer is linked and discounted, update their customer profile if requested or if not registered yet
    if (customer_id && isDiscounted) {
      await conn.query(
        "UPDATE customers SET discount_type = ?, discount_id_no = ? WHERE id = ? AND (discount_type = 'None' OR discount_type IS NULL OR discount_id_no IS NULL OR ? = 1)",
        [finalDiscountType, finalDiscountId, customer_id, save_customer_discount ? 1 : 0]
      );
    }

    // 3. Finalize via stored procedure (calculate total + change)
    const [result] = await conn.query("CALL sp_finalize_transaction(?)", [tid]);
    await conn.commit();

    const finalRow = result[0][0];
    finalRow.payment_method = payment_method || "Cash";
    finalRow.subtotal_amount = subtotal;
    finalRow.discount_type = finalDiscountType;
    finalRow.discount_id_no = finalDiscountId;
    finalRow.discount_amount = finalDiscountAmt;
    res.status(201).json(finalRow);
  } catch (err) {
    await conn.rollback();
    if (err.message.includes("Insufficient stock"))
      return res.status(422).json({ error: err.message });
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

// GET /api/transactions/customer/:customerId — staff looks up a customer's transactions for walk-in returns
router.get("/customer/:customerId", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const customerId = req.params.customerId;
  try {
    const [transactions] = await pool.query(
      `SELECT t.id, t.receipt_no,
              CONCAT(c.last_name, ', ', c.first_name) AS customer,
              CONCAT(s.full_name) AS cashier,
              t.subtotal_amount, t.discount_type, t.discount_id_no, t.discount_amount,
              t.total_amount, t.cash_tendered, t.change_amount,
              TIMESTAMPDIFF(MINUTE, t.created_at, NOW()) AS elapsed_minutes,
              DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS date
       FROM transactions t
       LEFT JOIN customers c ON c.id = t.customer_id
       LEFT JOIN staff s ON s.id = t.cashier_id
       WHERE t.customer_id = ?
       ORDER BY t.created_at DESC`,
      [customerId]
    );

    if (transactions.length === 0) {
      return res.json([]);
    }

    const txIds = transactions.map(t => t.id);
    const [items] = await pool.query(
      `SELECT transaction_id, id, product_id, product_name, unit_price, quantity
       FROM transaction_items
       WHERE transaction_id IN (?)`,
      [txIds]
    );

    const itemIds = items.map(i => i.id);
    let returnedMap = {};
    if (itemIds.length > 0) {
      const [returnedRows] = await pool.query(
        `SELECT ri.transaction_item_id, SUM(ri.quantity) AS total_returned
         FROM return_items ri
         JOIN returns r ON r.id = ri.return_id
         WHERE ri.transaction_item_id IN (?) AND r.status NOT IN ('Rejected', 'Cancelled')
         GROUP BY ri.transaction_item_id`,
        [itemIds]
      );
      for (const row of returnedRows) {
        returnedMap[row.transaction_item_id] = Number(row.total_returned);
      }
    }

    const itemsByTx = {};
    for (const item of items) {
      if (!itemsByTx[item.transaction_id]) itemsByTx[item.transaction_id] = [];
      const alreadyReturned = returnedMap[item.id] || 0;
      const availableQuantity = Math.max(0, item.quantity - alreadyReturned);
      itemsByTx[item.transaction_id].push({
        id: item.id,
        product_id: item.product_id,
        product_name: item.product_name,
        unit_price: Number(item.unit_price),
        purchased_quantity: item.quantity,
        quantity: item.quantity,
        already_returned: alreadyReturned,
        available_quantity: availableQuantity,
        is_returnable: availableQuantity > 0,
        is_fully_returned: alreadyReturned >= item.quantity
      });
    }

    const result = transactions.map(t => {
      const elapsedMinutes = Number(t.elapsed_minutes) || 0;
      const isReturnWindowExpired = elapsedMinutes > 1440; // > 24 hours
      const elapsedHours = Math.round((elapsedMinutes / 60) * 10) / 10;
      const rawTxItems = itemsByTx[t.id] || [];

      const txItems = rawTxItems.map(i => {
        const canReturn = !isReturnWindowExpired && i.available_quantity > 0;
        let ineligibleReason = null;
        if (isReturnWindowExpired) {
          ineligibleReason = "Past 24-hour return period";
        } else if (i.available_quantity <= 0) {
          ineligibleReason = "Item has already been fully returned";
        }
        return {
          ...i,
          is_returnable: canReturn,
          return_ineligible_reason: ineligibleReason
        };
      });

      const returnableItems = txItems.filter(i => i.is_returnable);
      const isFullyReturned = txItems.length > 0 && txItems.every(i => i.is_fully_returned);
      const hasReturnedItems = txItems.some(i => i.already_returned > 0);

      return {
        ...t,
        elapsed_minutes: elapsedMinutes,
        elapsed_hours: elapsedHours,
        return_window_hours: 24,
        is_return_window_expired: isReturnWindowExpired,
        return_window_error: isReturnWindowExpired
          ? "Items can only be returned within 24 hours of purchase."
          : null,
        items: txItems,
        returnable_items: returnableItems,
        is_fully_returned: isFullyReturned,
        has_returned_items: hasReturnedItems,
        items_summary: txItems.map(i => `${i.product_name} (×${i.quantity})`).join(", "),
        returnable_items_summary: returnableItems.map(i => `${i.product_name} (×${i.available_quantity})`).join(", ")
      };
    });

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

