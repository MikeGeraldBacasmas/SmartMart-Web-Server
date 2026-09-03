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
    const rows = await call("sp_create_staff", [username, hash, full_name, role, password]);
    res.status(201).json(rows?.[0]);
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

// GET /api/staff/my-profile — staff fetches own profile
router.get("/my-profile", authenticate, requireRole("staff"), async (req, res) => {
  try {
    const rows = await call("sp_get_staff_profile", [req.user.id]);
    if (!rows || rows.length === 0)
      return res.status(404).json({ error: "Staff profile not found" });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/staff/my-profile — staff updates own profile info & credentials
router.put("/my-profile", authenticate, requireRole("staff"), async (req, res) => {
  const { full_name, username } = req.body;
  if (!full_name || !username)
    return res.status(400).json({ error: "Full name and username are required" });

  try {
    const rows = await call("sp_update_staff_profile", [req.user.id, full_name.trim(), username.trim()]);
    const updated = rows?.[0];
    if (!updated)
      return res.status(404).json({ error: "Staff profile not found" });
    res.json({ message: "Profile updated successfully", profile: updated });
  } catch (err) {
    if (err.message.includes("Username already exists"))
      return res.status(409).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
