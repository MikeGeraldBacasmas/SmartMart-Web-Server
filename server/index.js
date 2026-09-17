require("dotenv").config();
const express = require("express");
const cors    = require("cors");
const path    = require("path");

const app = express();
app.use(cors());
app.use(express.json());

// ─── Serve uploaded images ────────────────────────────────────
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// ─── Routes ───────────────────────────────────────────────────
app.use("/api/auth",         require("./routes/auth"));
app.use("/api/staff",        require("./routes/staff"));
app.use("/api/customers",    require("./routes/customers"));
app.use("/api/categories",   require("./routes/categories"));
app.use("/api/products",     require("./routes/products"));
app.use("/api/transactions", require("./routes/transactions"));
app.use("/api/settings",     require("./routes/settings"));
app.use("/api/dashboard",    require("./routes/dashboard"));
app.use("/api/reports",      require("./routes/reports"));
app.use("/api/returns",      require("./routes/returns"));

// ─── Health check ─────────────────────────────────────────────
app.get("/api/health", (_req, res) => res.json({ status: "ok", app: "SmartMart API" }));

// ─── 404 ──────────────────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ error: "Route not found" }));

// ─── Error handler ────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: "Internal server error" });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`SmartMart API running on port ${PORT}`));
