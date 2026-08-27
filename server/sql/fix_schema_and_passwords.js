const { pool } = require('../db');
const bcrypt = require('bcryptjs');

async function main() {
  const conn = await pool.getConnection();
  try {
    console.log('Starting database schema and password restoration...');

    // 1. Alter table column definitions to proper capacities
    const alterQueries = [
      "ALTER TABLE users MODIFY username VARCHAR(100) NOT NULL",
      "ALTER TABLE users MODIFY password VARCHAR(255) NOT NULL",
      "ALTER TABLE users MODIFY full_name VARCHAR(150) NULL",

      "ALTER TABLE staff MODIFY full_name VARCHAR(150) NOT NULL",
      "ALTER TABLE staff MODIFY role VARCHAR(50) NOT NULL DEFAULT 'Cashier'",
      "ALTER TABLE staff MODIFY temp_password VARCHAR(255) NULL",

      "ALTER TABLE customers MODIFY last_name VARCHAR(100) NOT NULL",
      "ALTER TABLE customers MODIFY first_name VARCHAR(100) NOT NULL",
      "ALTER TABLE customers MODIFY middle_name VARCHAR(100) NULL",
      "ALTER TABLE customers MODIFY phone VARCHAR(20) NOT NULL",
      "ALTER TABLE customers MODIFY temp_password VARCHAR(255) NULL",

      "ALTER TABLE categories MODIFY name VARCHAR(100) NOT NULL",

      "ALTER TABLE products MODIFY name VARCHAR(200) NOT NULL",

      "ALTER TABLE transaction_items MODIFY product_name VARCHAR(200) NOT NULL"
    ];

    for (const query of alterQueries) {
      await conn.query(query);
      console.log(`Executed: ${query}`);
    }

    // 2. Hash passwords for existing user accounts
    const adminHash = await bcrypt.hash('admin123', 10);
    const cashierHash = await bcrypt.hash('cashier143', 10);
    const customerHash = await bcrypt.hash('jhonel143', 10);

    // Update users table with valid 60-character bcrypt hashes
    await conn.query("UPDATE users SET password = ? WHERE username = 'admin'", [adminHash]);
    console.log("Updated password for user 'admin' (admin123)");

    await conn.query("UPDATE users SET password = ? WHERE username = 'cashier1'", [cashierHash]);
    console.log("Updated password for user 'cashier1' (cashier143)");

    await conn.query("UPDATE users SET password = ? WHERE username = 'jhoneligcalinos'", [customerHash]);
    console.log("Updated password for user 'jhoneligcalinos' (jhonel143)");

    console.log('\nAll schema alterations and password hash updates completed successfully!');
  } catch (err) {
    console.error('Error fixing database schema/passwords:', err);
  } finally {
    conn.release();
    process.exit(0);
  }
}

main();
