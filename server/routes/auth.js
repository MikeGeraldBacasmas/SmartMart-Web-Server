const router  = require("express").Router();
const bcrypt  = require("bcryptjs");
const jwt     = require("jsonwebtoken");
const { call } = require("../db");

// POST /api/auth/login
router.post("/login", async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ error: "Username and password are required" });

  try {
    const rows = await call("sp_get_user_by_username", [username]);
    const user = rows?.[0];
    if (!user) return res.status(401).json({ error: "Invalid username or password" });
    if (!user.is_active || (user.role === "staff" && user.staff_status === "Inactive")) {
      return res.status(403).json({ error: "Account is deactivated" });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ error: "Invalid username or password" });

    // Customer must be approved
    if (user.role === "customer" && user.account_status !== "Approved")
      return res.status(403).json({ error: "Account pending approval" });

    const payload = {
      id:         user.id,
      username:   user.username,
      role:       user.role,
      name:       user.full_name || `${user.first_name} ${user.last_name}`,
      staff_code: user.staff_code || `STF${String(user.id).padStart(3, "0")}`,
      joined:     user.joined || new Date().toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }),
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || "8h",
    });

    res.json({ token, user: payload });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/auth/change-password
const { authenticate } = require("../middleware/auth");

router.post("/change-password", authenticate, async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) {
    return res.status(400).json({ error: "Current password and new password are required" });
  }

  try {
    const rows = await call("sp_get_user_by_id", [req.user.id]);
    const user = rows?.[0];
    if (!user) return res.status(404).json({ error: "User not found" });

    const match = await bcrypt.compare(currentPassword, user.password);
    if (!match) return res.status(400).json({ error: "Incorrect current password" });

    const hash = await bcrypt.hash(newPassword, 10);
    await call("sp_update_user_password", [req.user.id, hash]);

    res.json({ message: "Password updated successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
