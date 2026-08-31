const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });
const mysql = require("mysql2/promise");

const pool = mysql.createPool({
  host:     process.env.DB_HOST     || "localhost",
  port:     process.env.DB_PORT     || 3306,
  user:     process.env.DB_USER     || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME     || "smartmart",
  waitForConnections: true,
  connectionLimit:    10,
});

// Helper: call a stored procedure and return its result rows
async function call(procedure, params = []) {
  const placeholders = params.map(() => "?").join(", ");
  const sql = `CALL ${procedure}(${placeholders})`;
  const [rows] = await pool.execute(sql, params);
  return rows[0]; // first result set
}

module.exports = { pool, call };
