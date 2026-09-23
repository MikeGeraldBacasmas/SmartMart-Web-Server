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

// GET /api/transactions/:id/items
router.get("/:id/items", authenticate, requireRole("admin", "staff", "customer"), async (req, res) => {
  try {
    res.json(await call("sp_get_transaction_items", [req.params.id]));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/transactions  — create + add items + finalize in one call
// Body: { customer_id?, cashier_id, cash_tendered, items: [{product_id, quantity}], payment_method? }
router.post("/", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const { customer_id, cashier_id, cash_tendered, items, payment_method } = req.body;

  if (!cashier_id || !cash_tendered || !items?.length)
    return res.status(400).json({ error: "cashier_id, cash_tendered and items are required" });

  const conn = await pool.getConnection();
  try {
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

    // 3. Finalize via stored procedure (calculate total + change)
    const [result] = await conn.query("CALL sp_finalize_transaction(?)", [tid]);
    await conn.commit();

    const finalRow = result[0][0];
    finalRow.payment_method = payment_method || "Cash";
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
              t.total_amount, t.cash_tendered, t.change_amount,
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
      const txItems = itemsByTx[t.id] || [];
      const returnableItems = txItems.filter(i => i.is_returnable);
      const isFullyReturned = txItems.length > 0 && txItems.every(i => i.is_fully_returned);
      const hasReturnedItems = txItems.some(i => i.already_returned > 0);

      return {
        ...t,
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

