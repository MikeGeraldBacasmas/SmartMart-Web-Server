const { pool } = require("../db");

async function migrate() {
  try {
    const [cols] = await pool.query("SHOW COLUMNS FROM transactions");
    const names = cols.map(c => c.Field);
    
    if (!names.includes("payment_method")) {
      await pool.query("ALTER TABLE transactions ADD COLUMN payment_method VARCHAR(50) NOT NULL DEFAULT 'Cash'");
      console.log("Added payment_method column to transactions");
    }
    
    if (!names.includes("status")) {
      await pool.query("ALTER TABLE transactions ADD COLUMN status ENUM('Completed','Cancelled','Voided') NOT NULL DEFAULT 'Completed'");
      console.log("Added status column to transactions");
    }
    
    console.log("Schema update completed successfully!");
    process.exit(0);
  } catch (err) {
    console.error("Migration error:", err);
    process.exit(1);
  }
}

migrate();
