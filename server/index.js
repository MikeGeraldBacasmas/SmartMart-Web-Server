const path    = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });
const express = require("express");
const cors    = require("cors");

// ─── Required environment variables ───────────────────────────
if (!process.env.JWT_SECRET) {
  console.error("FATAL: JWT_SECRET is not set. Add it to your environment (Render → Environment) or server/.env");
  process.exit(1);
}

const app = express();

// Render (and most PaaS hosts) sit behind a reverse proxy
app.set("trust proxy", 1);

// ─── CORS ─────────────────────────────────────────────────────
// CORS_ORIGIN: comma-separated list of allowed frontend origins,
// e.g. "https://smartmart.com,https://www.smartmart.com".
// If unset, all origins are allowed (handy for local development).
const allowedOrigins = (process.env.CORS_ORIGIN || "")
  .split(",")
  .map((o) => o.trim().replace(/\/$/, ""))
  .filter(Boolean);

app.use(
  cors({
    origin: (origin, cb) => {
      // Allow non-browser requests (curl, health checks) and any origin when no allowlist is configured
      if (
        !origin ||
        allowedOrigins.length === 0 ||
        allowedOrigins.includes(origin) ||
        origin.includes("bscs4b.com") ||
        origin.includes("localhost")
      ) {
        return cb(null, true);
      }
      return cb(new Error(`Origin ${origin} not allowed by CORS`));
    },
    credentials: true,
  })
);
app.use(express.json({ limit: "2mb" }));

// ─── Serve uploaded images ────────────────────────────────────
// UPLOAD_DIR lets you point uploads at a persistent disk on Render (e.g. /var/data/uploads)
const uploadRoot = process.env.UPLOAD_DIR || path.join(__dirname, "uploads");
app.use("/uploads", express.static(uploadRoot));

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
app.use("/api/damages",      require("./routes/damages"));

// ─── Health check ─────────────────────────────────────────────
app.get("/", (_req, res) => res.json({ status: "ok", app: "SmartMart API" }));
app.get("/api/health", (_req, res) => res.json({ status: "ok", app: "SmartMart API" }));

app.get("/api/db-diagnostics", async (_req, res) => {
  const host = process.env.DB_HOST || "localhost (default)";
  const port = process.env.DB_PORT || "3306 (default)";
  const user = process.env.DB_USER || "root (default)";
  const database = process.env.DB_NAME || "smartmart (default)";
  const ssl = process.env.DB_SSL || "false (default)";

  let renderOutboundIp = "unknown";
  try {
    const ipRes = await fetch("https://api.ipify.org?format=json");
    const ipData = await ipRes.json();
    renderOutboundIp = ipData.ip;
  } catch (e) {
    renderOutboundIp = e.message;
  }

  try {
    const { pool } = require("./db");
    const [rows] = await pool.query("SELECT 1 AS ok");
    return res.json({
      status: "connected",
      renderOutboundIp,
      dbConfig: { host, port, user, database, ssl },
      queryResult: rows,
    });
  } catch (err) {
    return res.status(500).json({
      status: "error",
      renderOutboundIp,
      dbConfig: { host, port, user, database, ssl },
      error: {
        code: err.code,
        errno: err.errno,
        syscall: err.syscall,
        address: err.address,
        port: err.port,
        message: err.message,
      },
    });
  }
});

// ─── 404 ──────────────────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ error: "Route not found" }));

// ─── Error handler ────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error(err);
  if (err && /not allowed by CORS/.test(err.message)) {
    return res.status(403).json({ error: err.message });
  }
  res.status(500).json({ error: "Internal server error" });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, "0.0.0.0", () => console.log(`SmartMart API running on port ${PORT}`));
