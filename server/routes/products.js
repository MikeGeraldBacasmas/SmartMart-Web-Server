const router  = require("express").Router();
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/products
router.get("/", authenticate, async (_req, res) => {
  try {
    res.json(await call("sp_get_all_products"));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/products/low-stock
router.get("/low-stock", authenticate, requireRole("admin", "staff"), async (_req, res) => {
  try {
    res.json(await call("sp_get_low_stock_products"));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/products
router.post("/", authenticate, requireRole("admin"), async (req, res) => {
  const { name, category_id, price, stock } = req.body;
  if (!name || !category_id || price == null || stock == null)
    return res.status(400).json({ error: "name, category_id, price and stock are required" });

  try {
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL sp_create_product(?,?,?,?,@pid)",
        [name, category_id, price, stock]);
      const [[r]] = await conn.query("SELECT @pid AS product_id");
      res.status(201).json({ product_id: r.product_id, name, category_id, price, stock });
    } finally {
      conn.release();
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/products/:id/stock
router.patch("/:id/stock", authenticate, requireRole("admin"), async (req, res) => {
  const { stock } = req.body;
  if (stock == null) return res.status(400).json({ error: "stock is required" });

  try {
    await call("sp_update_product_stock", [req.params.id, stock]);
    res.json({ message: "Stock updated" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
