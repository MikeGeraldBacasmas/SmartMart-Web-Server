const router  = require("express").Router();
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/categories
router.get("/", authenticate, async (_req, res) => {
  try {
    res.json(await call("sp_get_all_categories"));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/categories
router.post("/", authenticate, requireRole("admin"), async (req, res) => {
  const { name } = req.body;
  if (!name) return res.status(400).json({ error: "Category name is required" });

  try {
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL sp_create_category(?, @cat_id)", [name]);
      const [[r]] = await conn.query("SELECT @cat_id AS category_id");
      res.status(201).json({ category_id: r.category_id, name });
    } finally {
      conn.release();
    }
  } catch (err) {
    if (err.message.includes("already exists"))
      return res.status(409).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
