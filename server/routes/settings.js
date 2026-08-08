const router = require("express").Router();
const { call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/settings
router.get("/", authenticate, requireRole("admin"), async (_req, res) => {
  try {
    const rows = await call("sp_get_settings");
    const settings = Object.fromEntries(rows.map(r => [r.setting_key, r.setting_value]));
    res.json(settings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/settings  — body: { key: value, ... }
router.patch("/", authenticate, requireRole("admin"), async (req, res) => {
  try {
    for (const [key, value] of Object.entries(req.body)) {
      await call("sp_update_setting", [key, String(value)]);
    }
    res.json({ message: "Settings updated" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
