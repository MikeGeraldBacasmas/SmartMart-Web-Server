const router = require("express").Router();
const { call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/dashboard
router.get("/", authenticate, requireRole("admin"), async (_req, res) => {
  try {
    const summaryRows = await call("sp_get_dashboard_summary");
    const bestSellers = await call("sp_get_best_sellers", [5]);
    const summary = summaryRows?.[0] || {};
    summary.best_sellers = bestSellers || [];
    res.json(summary);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
