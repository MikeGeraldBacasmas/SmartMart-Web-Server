const fs = require("fs");
const path = require("path");
const mysql = require("mysql2/promise");
require("dotenv").config({ path: path.join(__dirname, ".env") });

const DB_NAME = process.env.DB_NAME || "u463580331_sm";

async function main() {
  const sqlPath = path.join(__dirname, "sql", "smartmart_backup.sql");
  const hostingerSqlPath = path.join(__dirname, "sql", "smartmart_hostinger.sql");

  console.log("Reading:", sqlPath);
  let raw = fs.readFileSync(sqlPath, "utf8");

  // 1. Remove CREATE DATABASE sm
  raw = raw.replace(/CREATE DATABASE\s+[\s\S]*?`sm`[\s\S]*?;\s*/i, "");

  // 2. Change USE `sm` to USE `u463580331_sm` (or the configured DB_NAME)
  raw = raw.replace(/USE\s+`sm`;/gi, `USE \`${DB_NAME}\`;`);

  // 3. Remove DEFINER=`sm`@`localhost` from all procedures
  raw = raw.replace(/DEFINER\s*=\s*`[^`]+`@`[^`]+`/gi, "");

  // 4. Save to smartmart_hostinger.sql
  fs.writeFileSync(hostingerSqlPath, raw, "utf8");
  console.log("Saved converted SQL to:", hostingerSqlPath);

  // 5. Connect and migrate to Hostinger database
  console.log(`Connecting to Hostinger DB ${process.env.DB_HOST} (${DB_NAME})...`);
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: DB_NAME,
    multipleStatements: true,
  });

  console.log("Connected successfully. Parsing SQL statements...");

  // To execute safely via mysql2, we split table DDL/DML and stored procedures.
  // Stored procedures are bounded by DELIMITER $$ and DELIMITER ;
  const sections = raw.split(/DELIMITER\s+\$\$/i);
  
  // Section 0 is all the tables + data up to the first DELIMITER $$
  const initialSql = sections[0];
  console.log("Executing initial tables and seed data...");
  await conn.query(initialSql);
  console.log("Tables and data created successfully!");

  // Remaining sections contain stored procedures
  let procCount = 0;
  for (let i = 1; i < sections.length; i++) {
    const chunk = sections[i];
    // Each chunk looks like:
    // "\n/*!50003 CREATE PROCEDURE ... END */$$\nDELIMITER ;\n/* next stuff ... */"
    const subParts = chunk.split(/\$\$\s*DELIMITER\s*;/i);
    const procBodyRaw = subParts[0];

    // Clean up SQLyog comment wrappers if present: /*!50003 ... */
    let procSql = procBodyRaw.trim();
    if (procSql.startsWith("/*!50003")) {
      procSql = procSql.replace(/^\/\*!50003\s*/i, "").replace(/\s*\*\/$/i, "");
    }
    procSql = procSql.trim();

    if (procSql) {
      const match = procSql.match(/CREATE\s+PROCEDURE\s+`?([a-zA-Z0-9_]+)`?/i);
      if (match && match[1]) {
        await conn.query(`DROP PROCEDURE IF EXISTS \`${match[1]}\``);
      }
      await conn.query(procSql);
      procCount++;
    }

    // If there's SQL after DELIMITER ; before next DELIMITER $$, execute it (e.g. DROP PROCEDURE, or tail SQL)
    if (subParts[1] && subParts[1].trim()) {
      const remainingSql = subParts[1].trim();
      await conn.query(remainingSql);
    }
  }

  console.log(`Successfully created ${procCount} stored procedures!`);

  // Verify tables
  const [tables] = await conn.query("SHOW TABLES");
  console.log("Tables in database:", tables.map(r => Object.values(r)[0]));

  // Verify sample count
  const [userCount] = await conn.query("SELECT COUNT(*) AS c FROM users");
  const [prodCount] = await conn.query("SELECT COUNT(*) AS c FROM products");
  const [procList] = await conn.query("SHOW PROCEDURE STATUS WHERE Db = ?", [DB_NAME]);

  console.log(`Users: ${userCount[0].c}, Products: ${prodCount[0].c}`);
  console.log(`Total Stored Procedures in ${DB_NAME}: ${procList.length}`);

  // Test calling one procedure
  const [dashRes] = await conn.query("CALL sp_get_dashboard_summary()");
  console.log("Sample procedure test (sp_get_dashboard_summary):", dashRes[0]);

  await conn.end();
  console.log("Migration complete!");
}

main().catch(err => {
  console.error("Migration error:", err);
  process.exit(1);
});
