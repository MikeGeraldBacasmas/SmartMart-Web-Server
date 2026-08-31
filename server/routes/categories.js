const router  = require("express").Router();
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/categories (Public)
router.get("/", async (_req, res) => {
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
    const rows = await call("sp_create_category", [name]);
    const result = rows?.[0] || { category_id: null, name };
    res.status(201).json(result);
  } catch (err) {
    if (err.message.includes("already exists"))
      return res.status(409).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
