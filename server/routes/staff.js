const router  = require("express").Router();
const bcrypt  = require("bcryptjs");
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/staff
router.get("/", authenticate, requireRole("admin"), async (_req, res) => {
  try {
    const rows = await call("sp_get_all_staff");
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/staff
router.post("/", authenticate, requireRole("admin"), async (req, res) => {
  const { username, password, full_name, role = "Cashier" } = req.body;
  if (!username || !password || !full_name)
    return res.status(400).json({ error: "username, password and full_name are required" });

  try {
    const hash = await bcrypt.hash(password, 10);
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL sp_create_staff(?, ?, ?, ?, ?, @staff_id, @staff_code)",
        [username, hash, full_name, role, password]);
      const [[result]] = await conn.query(
        "SELECT @staff_id AS staff_id, @staff_code AS staff_code"
      );
      // Return the full staff object so the frontend can display it immediately
      const joined = new Date().toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
      res.status(201).json({
        id: result.staff_id,
        staff_code: result.staff_code,
        full_name,
        username,
        role,
        status: "Active",
        joined,
        temp_password: password,
      });
    } finally {
      conn.release();
    }
  } catch (err) {
    if (err.message.includes("Username already exists"))
      return res.status(409).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/staff/:id/toggle-status
router.patch("/:id/toggle-status", authenticate, requireRole("admin"), async (req, res) => {
  try {
    const rows = await call("sp_toggle_staff_status", [req.params.id]);
    res.json({ status: rows?.[0]?.status });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
