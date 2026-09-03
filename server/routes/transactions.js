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

module.exports = router;

