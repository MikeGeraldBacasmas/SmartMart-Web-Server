const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });
const mysql = require("mysql2/promise");

// DB_SSL=true enables TLS (required by most cloud MySQL providers, e.g. Aiven, PlanetScale, TiDB, Azure).
// DB_SSL_REJECT_UNAUTHORIZED=false allows self-signed certs if your provider needs it.
const useSSL = String(process.env.DB_SSL || "").toLowerCase() === "true";

const pool = mysql.createPool({
  host:     process.env.DB_HOST     || "localhost",
  port:     Number(process.env.DB_PORT) || 3306,
  user:     process.env.DB_USER     || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME     || "smartmart",
  waitForConnections: true,
  connectionLimit:    Number(process.env.DB_CONNECTION_LIMIT) || 10,
  enableKeepAlive:    true,
  keepAliveInitialDelay: 10000,
  ...(useSSL && {
    ssl: { rejectUnauthorized: String(process.env.DB_SSL_REJECT_UNAUTHORIZED || "true").toLowerCase() !== "false" },
  }),
});

// Helper: call a stored procedure and return its result rows
async function call(procedure, params = []) {
  const placeholders = params.map(() => "?").join(", ");
  const sql = `CALL ${procedure}(${placeholders})`;
  const [rows] = await pool.execute(sql, params);
  return rows[0]; // first result set
}

module.exports = { pool, call };
