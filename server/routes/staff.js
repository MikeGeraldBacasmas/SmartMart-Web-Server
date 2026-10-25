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
    const newStaff = rows?.[0];
    if (newStaff && newStaff.id) {
      await pool.query("UPDATE staff SET temp_password = ? WHERE id = ?", [password, newStaff.id]);
      newStaff.temp_password = password;
    }
    res.status(201).json(newStaff);
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

// POST /api/staff/:id/reset-password — admin resets staff password
router.post("/:id/reset-password", authenticate, requireRole("admin"), async (req, res) => {
  const { newPassword } = req.body;
  if (!newPassword || newPassword.trim().length < 6)
    return res.status(400).json({ error: "New password must be at least 6 characters" });

  try {
    const [staffRows] = await pool.query(
      `SELECT s.id, s.user_id, s.staff_code, s.full_name, s.temp_password, u.username
       FROM staff s
       LEFT JOIN users u ON u.id = s.user_id
       WHERE s.id = ?`,
      [req.params.id]
    );

    if (!staffRows.length) {
      return res.status(404).json({ error: "Staff account not found" });
    }

    const staff = staffRows[0];
    if (!staff.user_id) {
      return res.status(400).json({ error: "Staff does not have an active user account" });
    }

    const cleanPw = newPassword.trim();
    const hash = await bcrypt.hash(cleanPw, 10);

    // Update password in users table
    await pool.query("UPDATE users SET password = ? WHERE id = ?", [hash, staff.user_id]);

    // Keep the initial creation password intact in staff.temp_password
    // If no initial password was previously stored, save it now
    if (!staff.temp_password) {
      await pool.query("UPDATE staff SET temp_password = ? WHERE id = ?", [cleanPw, staff.id]);
    }

    res.json({
      message: `Password for ${staff.full_name} reset successfully`,
      new_password: cleanPw,
      initial_temp_password: staff.temp_password || cleanPw,
      staff_id: staff.id,
      username: staff.username,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

