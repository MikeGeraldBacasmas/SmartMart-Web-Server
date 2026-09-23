const router = require("express").Router();
const { pool } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// ─── GET /api/returns/transaction/:id/returnable-items ────────────────────────
// Get items from a transaction with computed available return quantities
router.get("/transaction/:id/returnable-items", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const transactionId = req.params.id;
  try {
    // Check transaction exists
    const [txRows] = await pool.query(
      `SELECT t.id, t.receipt_no, t.customer_id, t.total_amount,
              DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS date,
              c.user_id AS customer_user_id,
              CONCAT(c.last_name, ', ', c.first_name) AS customer_name,
              COALESCE(s.full_name, cu.username, 'Cashier') AS cashier_name
       FROM transactions t
       LEFT JOIN customers c ON c.id = t.customer_id
       LEFT JOIN staff s ON s.id = t.cashier_id
       LEFT JOIN users cu ON cu.id = s.user_id
       WHERE t.id = ?`,
      [transactionId]
    );

    if (txRows.length === 0) {
      return res.status(404).json({ error: "Transaction not found" });
    }

    const tx = txRows[0];

    // Get items from transaction_items with current stock
    const [items] = await pool.query(
      `SELECT ti.id AS transaction_item_id, ti.product_id, ti.product_name, ti.unit_price, ti.quantity AS purchased_quantity, ti.subtotal,
              p.stock AS current_stock
       FROM transaction_items ti
       LEFT JOIN products p ON p.id = ti.product_id
       WHERE ti.transaction_id = ?`,
      [transactionId]
    );

    // Get already returned quantity for each item (Approved or Completed returns)
    const [returnedRows] = await pool.query(
      `SELECT ri.transaction_item_id, SUM(ri.quantity) AS total_returned
       FROM return_items ri
       JOIN returns r ON r.id = ri.return_id
       WHERE r.transaction_id = ? AND r.status IN ('Completed', 'Approved')
       GROUP BY ri.transaction_item_id`,
      [transactionId]
    );

    const returnedMap = {};
    for (const row of returnedRows) {
      returnedMap[row.transaction_item_id] = Number(row.total_returned);
    }

    const returnableItems = items.map(item => {
      const alreadyReturned = returnedMap[item.transaction_item_id] || 0;
      const availableQuantity = Math.max(0, item.purchased_quantity - alreadyReturned);
      return {
        ...item,
        already_returned: alreadyReturned,
        available_quantity: availableQuantity,
        is_returnable: availableQuantity > 0
      };
    });

    res.json({
      transaction: tx,
      items: returnableItems
    });
  } catch (err) {
    console.error("Error fetching returnable items:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── POST /api/returns ────────────────────────────────────────────────────────
// Staff creates a return for a walk-in customer with immediate review options
router.post("/", authenticate, requireRole("staff"), async (req, res) => {
  const {
    transaction_id,
    reason,
    customer_notes,
    admin_notes,
    status = "Completed",
    restock = true,
    items
  } = req.body;

  if (!transaction_id || !reason || !items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: "transaction_id, reason, and items array are required" });
  }

  const validStatuses = ["Completed", "Approved", "Rejected", "Pending"];
  const finalStatus = validStatuses.includes(status) ? status : "Completed";

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // Get the customer from the transaction
    const [tx] = await conn.query("SELECT customer_id FROM transactions WHERE id = ?", [transaction_id]);
    if (tx.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: "Transaction not found" });
    }
    const customerId = tx[0].customer_id;
    if (!customerId) {
      await conn.rollback();
      return res.status(400).json({ error: "Cannot process return for a transaction without a customer record" });
    }

    // Validate each item and calculate refund total
    let totalRefund = 0;
    const validatedItems = [];

    for (const item of items) {
      const { transaction_item_id, quantity } = item;
      const qty = parseInt(quantity, 10);

      if (!transaction_item_id || isNaN(qty) || qty <= 0) {
        await conn.rollback();
        return res.status(400).json({ error: "Invalid item or quantity in return request" });
      }

      // Fetch transaction item
      const [tItemRows] = await conn.query(
        "SELECT id, product_id, product_name, unit_price, quantity FROM transaction_items WHERE id = ? AND transaction_id = ?",
        [transaction_item_id, transaction_id]
      );

      if (tItemRows.length === 0) {
        await conn.rollback();
        return res.status(400).json({ error: `Item ${transaction_item_id} does not belong to this transaction` });
      }

      const tItem = tItemRows[0];

      // Check past returned quantity (Approved or Completed returns)
      const [prevReturns] = await conn.query(
        `SELECT IFNULL(SUM(ri.quantity), 0) AS returned_qty
         FROM return_items ri
         JOIN returns r ON r.id = ri.return_id
         WHERE ri.transaction_item_id = ? AND r.status IN ('Completed', 'Approved')`,
        [transaction_item_id]
      );

      const alreadyReturned = Number(prevReturns[0].returned_qty);
      const remaining = tItem.quantity - alreadyReturned;

      if (qty > remaining) {
        await conn.rollback();
        return res.status(400).json({
          error: `Cannot return ${qty} of "${tItem.product_name}". Only ${remaining} item(s) eligible for return.`
        });
      }

      const itemRefund = Number(tItem.unit_price) * qty;
      totalRefund += itemRefund;

      validatedItems.push({
        transaction_item_id,
        product_id: tItem.product_id,
        product_name: tItem.product_name,
        quantity: qty,
        unit_price: Number(tItem.unit_price),
        refund_amount: itemRefund
      });
    }

    // Generate return_no (e.g. RET-2026-0001)
    const currentYear = new Date().getFullYear();
    const [countRows] = await conn.query(
      "SELECT COUNT(*) + 1 AS seq FROM returns WHERE YEAR(created_at) = ?",
      [currentYear]
    );
    const seq = String(countRows[0].seq).padStart(4, "0");
    const returnNo = `RET-${currentYear}-${seq}`;

    const isProcessedNow = finalStatus !== "Pending";

    // Insert returns record
    const [retResult] = await conn.query(
      `INSERT INTO returns (return_no, transaction_id, customer_id, status, reason, customer_notes, admin_notes, refund_amount, processed_by, processed_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ${isProcessedNow ? "NOW()" : "NULL"})`,
      [returnNo, transaction_id, customerId, finalStatus, reason, customer_notes || null, admin_notes || null, totalRefund, req.user.id]
    );

    const returnId = retResult.insertId;
    const shouldRestock = (finalStatus === "Completed" || finalStatus === "Approved") && Boolean(restock);

    // Insert return_items records and optionally restock
    for (const vItem of validatedItems) {
      await conn.query(
        `INSERT INTO return_items (return_id, transaction_item_id, product_id, product_name, quantity, unit_price, refund_amount, restock)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [returnId, vItem.transaction_item_id, vItem.product_id, vItem.product_name, vItem.quantity, vItem.unit_price, vItem.refund_amount, shouldRestock ? 1 : 0]
      );

      if (shouldRestock) {
        await conn.query("UPDATE products SET stock = stock + ? WHERE id = ?", [vItem.quantity, vItem.product_id]);
      }
    }

    await conn.commit();

    const successMsg = finalStatus === "Rejected"
      ? "Return rejected successfully"
      : (finalStatus === "Completed" || finalStatus === "Approved")
      ? "Walk-in return approved & refund completed successfully!"
      : "Walk-in return submitted successfully";

    res.status(201).json({
      message: successMsg,
      return_id: returnId,
      return_no: returnNo,
      status: finalStatus,
      refund_amount: totalRefund
    });
  } catch (err) {
    await conn.rollback();
    console.error("Error creating return:", err);
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

// ─── GET /api/returns ─────────────────────────────────────────────────────────
// Admin & Staff get all returns with optional filtering
router.get("/", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const { status, from, to, search } = req.query;

  try {
    let query = `
      SELECT r.id, r.return_no, r.transaction_id, t.receipt_no, r.customer_id,
             CONCAT(c.last_name, ', ', c.first_name) AS customer_name,
             c.customer_code, c.phone AS customer_phone,
             COALESCE(s.full_name, cu.username, 'Cashier') AS cashier_name,
             r.status, r.reason, r.customer_notes, r.admin_notes, r.refund_amount,
             DATE_FORMAT(r.created_at, '%b %d, %Y %h:%i %p') AS created_at,
             DATE_FORMAT(r.processed_at, '%b %d, %Y %h:%i %p') AS processed_at,
             u.username AS processed_by_username,
             COUNT(ri.id) AS item_count,
             IFNULL(SUM(ri.quantity), 0) AS total_items_quantity
      FROM returns r
      JOIN transactions t ON t.id = r.transaction_id
      JOIN customers c ON c.id = r.customer_id
      LEFT JOIN staff s ON s.id = t.cashier_id
      LEFT JOIN users cu ON cu.id = s.user_id
      LEFT JOIN users u ON u.id = r.processed_by
      LEFT JOIN return_items ri ON ri.return_id = r.id
      WHERE 1=1
    `;
    const params = [];

    if (status && status !== "All") {
      if (status === "Approved") {
        query += " AND r.status IN ('Approved', 'Completed')";
      } else {
        query += " AND r.status = ?";
        params.push(status);
      }
    }

    if (from) {
      query += " AND DATE(r.created_at) >= ?";
      params.push(from);
    }

    if (to) {
      query += " AND DATE(r.created_at) <= ?";
      params.push(to);
    }

    if (search) {
      query += ` AND (
        r.return_no LIKE ? OR
        t.receipt_no LIKE ? OR
        c.first_name LIKE ? OR
        c.last_name LIKE ? OR
        c.customer_code LIKE ? OR
        s.full_name LIKE ?
      )`;
      const s = `%${search}%`;
      params.push(s, s, s, s, s, s);
    }

    query += ` GROUP BY r.id ORDER BY r.created_at DESC`;

    const [rows] = await pool.query(query, params);

    // Also get summary counts
    const [counts] = await pool.query(`
      SELECT
        COUNT(*) AS total_returns,
        SUM(IF(status = 'Pending', 1, 0)) AS pending_count,
        SUM(IF(status = 'Approved', 1, 0)) AS approved_count,
        SUM(IF(status = 'Completed', 1, 0)) AS completed_count,
        SUM(IF(status = 'Rejected', 1, 0)) AS rejected_count,
        IFNULL(SUM(IF(status IN ('Approved', 'Completed'), refund_amount, 0)), 0) AS total_refunded
      FROM returns
    `);

    res.json({
      returns: rows,
      summary: counts[0]
    });
  } catch (err) {
    console.error("Error fetching returns:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── GET /api/returns/my-history ─────────────────────────────────────────────
// Customer gets their own return history
router.get("/my-history", authenticate, async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT r.id, r.return_no, r.transaction_id, t.receipt_no,
              CONCAT(c.last_name, ', ', c.first_name) AS customer_name,
              c.customer_code,
              COALESCE(s.full_name, 'Cashier') AS cashier_name,
              r.status, r.reason, r.customer_notes, r.admin_notes, r.refund_amount,
              DATE_FORMAT(r.created_at, '%b %d, %Y %h:%i %p') AS created_at,
              DATE_FORMAT(r.processed_at, '%b %d, %Y %h:%i %p') AS processed_at,
              COUNT(ri.id) AS item_count,
              IFNULL(SUM(ri.quantity), 0) AS total_items_quantity
       FROM returns r
       JOIN transactions t ON t.id = r.transaction_id
       JOIN customers c ON c.id = r.customer_id
       LEFT JOIN staff s ON s.id = t.cashier_id
       LEFT JOIN return_items ri ON ri.return_id = r.id
       WHERE c.user_id = ?
       GROUP BY r.id
       ORDER BY r.created_at DESC`,
      [req.user.id]
    );

    res.json(rows || []);
  } catch (err) {
    console.error("Error fetching customer return history:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── GET /api/returns/customer/:customerId ───────────────────────────────────
// Staff/Admin gets all returns of a specific customer
router.get("/customer/:customerId", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const customerId = req.params.customerId;
  try {
    const [rows] = await pool.query(
      `SELECT r.id, r.return_no, r.transaction_id, t.receipt_no,
              CONCAT(c.last_name, ', ', c.first_name) AS customer_name,
              c.customer_code,
              COALESCE(s.full_name, 'Cashier') AS cashier_name,
              r.status, r.reason, r.customer_notes, r.admin_notes, r.refund_amount,
              DATE_FORMAT(r.created_at, '%b %d, %Y %h:%i %p') AS created_at,
              DATE_FORMAT(r.processed_at, '%b %d, %Y %h:%i %p') AS processed_at,
              COUNT(ri.id) AS item_count,
              IFNULL(SUM(ri.quantity), 0) AS total_items_quantity
       FROM returns r
       JOIN transactions t ON t.id = r.transaction_id
       JOIN customers c ON c.id = r.customer_id
       LEFT JOIN staff s ON s.id = t.cashier_id
       LEFT JOIN return_items ri ON ri.return_id = r.id
       WHERE r.customer_id = ?
       GROUP BY r.id
       ORDER BY r.created_at DESC`,
      [customerId]
    );

    res.json(rows || []);
  } catch (err) {
    console.error("Error fetching returns for customer:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── GET /api/returns/:id ─────────────────────────────────────────────────────
// Get details of a single return record (staff/admin or return owner)
router.get("/:id", authenticate, async (req, res) => {
  try {
    const [rRows] = await pool.query(
      `SELECT r.id, r.return_no, r.transaction_id, t.receipt_no, r.customer_id,
              CONCAT(c.last_name, ', ', c.first_name) AS customer_name,
              c.customer_code, c.phone AS customer_phone,
              COALESCE(s.full_name, cu.username, 'Cashier') AS cashier_name,
              r.status, r.reason, r.customer_notes, r.admin_notes, r.refund_amount,
              DATE_FORMAT(r.created_at, '%b %d, %Y %h:%i %p') AS created_at,
              DATE_FORMAT(r.processed_at, '%b %d, %Y %h:%i %p') AS processed_at,
              u.username AS processed_by_username,
              c.user_id AS customer_user_id
       FROM returns r
       JOIN transactions t ON t.id = r.transaction_id
       JOIN customers c ON c.id = r.customer_id
       LEFT JOIN staff s ON s.id = t.cashier_id
       LEFT JOIN users cu ON cu.id = s.user_id
       LEFT JOIN users u ON u.id = r.processed_by
       WHERE r.id = ?`,
      [req.params.id]
    );

    if (rRows.length === 0) {
      return res.status(404).json({ error: "Return record not found" });
    }

    const ret = rRows[0];

    if (req.user.role === "customer" && ret.customer_user_id !== req.user.id) {
      return res.status(403).json({ error: "Access denied" });
    }

    const [items] = await pool.query(
      `SELECT ri.id, ri.return_id, ri.transaction_item_id, ri.product_id,
              ri.product_name, ri.quantity, ri.unit_price, ri.refund_amount, ri.restock,
              p.stock AS current_stock
       FROM return_items ri
       LEFT JOIN products p ON p.id = ri.product_id
       WHERE ri.return_id = ?`,
      [req.params.id]
    );

    ret.items = items;
    res.json(ret);
  } catch (err) {
    console.error("Error fetching return details:", err);
    res.status(500).json({ error: err.message });
  }
});

// ─── PATCH /api/returns/:id/status ───────────────────────────────────────────
// Staff updates return status (Approved, Rejected, Completed) - Admin is view only
router.patch("/:id/status", authenticate, requireRole("staff"), async (req, res) => {
  const { status, admin_notes, restock = true } = req.body;

  const validStatuses = ["Approved", "Completed", "Rejected"];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: `Invalid status. Must be one of: ${validStatuses.join(", ")}` });
  }

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const [rRows] = await conn.query("SELECT * FROM returns WHERE id = ? FOR UPDATE", [req.params.id]);
    if (rRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ error: "Return record not found" });
    }

    const currentReturn = rRows[0];
    if (currentReturn.status === "Cancelled") {
      await conn.rollback();
      return res.status(400).json({ error: "Cannot change status of a cancelled return" });
    }

    const [items] = await conn.query("SELECT * FROM return_items WHERE return_id = ?", [req.params.id]);

    // If approving or completing for the first time, and restock is requested:
    const isNowApprovedOrCompleted = (status === "Approved" || status === "Completed");
    const wasAlreadyApprovedOrCompleted = (currentReturn.status === "Approved" || currentReturn.status === "Completed");

    if (isNowApprovedOrCompleted && !wasAlreadyApprovedOrCompleted && restock) {
      for (const item of items) {
        await conn.query("UPDATE products SET stock = stock + ? WHERE id = ?", [item.quantity, item.product_id]);
        await conn.query("UPDATE return_items SET restock = 1 WHERE id = ?", [item.id]);
      }
    }

    // Update return record
    await conn.query(
      `UPDATE returns
       SET status = ?, admin_notes = ?, processed_by = ?, processed_at = NOW()
       WHERE id = ?`,
      [status, admin_notes || null, req.user.id, req.params.id]
    );

    await conn.commit();

    res.json({
      message: `Return ${status.toLowerCase()} successfully`,
      id: req.params.id,
      status
    });
  } catch (err) {
    await conn.rollback();
    console.error("Error updating return status:", err);
    res.status(500).json({ error: err.message });
  } finally {
    conn.release();
  }
});

module.exports = router;
