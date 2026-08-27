const { pool } = require('../db');

async function main() {
  const conn = await pool.getConnection();
  try {
    // 1. Add temp_password column to customers table if it doesn't exist
    const [cols] = await conn.query(
      "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'customers' AND COLUMN_NAME = 'temp_password'"
    );
    if (cols.length === 0) {
      await conn.query("ALTER TABLE customers ADD COLUMN temp_password VARCHAR(255) DEFAULT NULL AFTER phone");
      console.log("Added temp_password column to customers table.");
    } else {
      console.log("temp_password column already exists.");
    }

    // 2. Update sp_approve_customer to accept and store plain-text temp password
    await conn.query('DROP PROCEDURE IF EXISTS sp_approve_customer');
    await conn.query(`
      CREATE PROCEDURE sp_approve_customer(
        IN p_customer_id INT UNSIGNED,
        IN p_username    VARCHAR(100),
        IN p_password    VARCHAR(255),
        IN p_temp_password VARCHAR(255)
      )
      BEGIN
        DECLARE v_user_id     INT UNSIGNED;
        DECLARE v_count       INT;
        DECLARE v_cust_code   VARCHAR(20);
        DECLARE v_first_name  VARCHAR(100);
        DECLARE v_middle_name VARCHAR(100);
        DECLARE v_last_name   VARCHAR(100);
        DECLARE v_full_name   VARCHAR(255);

        SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
        IF v_count > 0 THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
        END IF;

        SELECT first_name, middle_name, last_name
        INTO   v_first_name, v_middle_name, v_last_name
        FROM   customers
        WHERE  id = p_customer_id AND account_status = 'Pending';

        IF v_first_name IS NULL THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pending customer record not found';
        END IF;

        SET v_full_name = TRIM(CONCAT(v_first_name, IF(v_middle_name IS NOT NULL AND v_middle_name != '', CONCAT(' ', v_middle_name), ''), ' ', v_last_name));

        INSERT INTO users (username, password, full_name, role)
        VALUES (p_username, p_password, v_full_name, 'customer');

        SET v_user_id = LAST_INSERT_ID();

        SELECT CONCAT('CUS', LPAD(
          (SELECT COUNT(*) FROM customers WHERE account_status = 'Approved') + 1, 3, '0'
        )) INTO v_cust_code;

        UPDATE customers
        SET user_id        = v_user_id,
            customer_code  = v_cust_code,
            account_status = 'Approved',
            approved_at    = NOW(),
            temp_password  = p_temp_password
        WHERE id = p_customer_id;
      END
    `);
    console.log("sp_approve_customer updated (now accepts p_temp_password).");

    // 3. Update sp_get_registered_customers to return temp_password
    await conn.query('DROP PROCEDURE IF EXISTS sp_get_registered_customers');
    await conn.query(`
      CREATE PROCEDURE sp_get_registered_customers()
      BEGIN
        SELECT c.id, c.customer_code,
               CONCAT(c.last_name, ', ', c.first_name, ' ', IFNULL(c.middle_name,'')) AS full_name,
               c.phone, c.address, c.gender, c.civil_status,
               DATE_FORMAT(c.date_of_birth, '%Y-%m-%d') AS date_of_birth,
               DATE_FORMAT(c.approved_at, '%b %d, %Y') AS joined,
               u.username,
               c.temp_password,
               COUNT(t.id) AS total_purchases
        FROM customers c
        JOIN users u ON u.id = c.user_id
        LEFT JOIN transactions t ON t.customer_id = c.id
        WHERE c.account_status = 'Approved'
        GROUP BY c.id
        ORDER BY c.approved_at DESC;
      END
    `);
    console.log("sp_get_registered_customers updated (now returns temp_password).");

    console.log("\nAll migrations applied successfully!");
  } catch (err) {
    console.error("Migration error:", err);
  } finally {
    conn.release();
    process.exit(0);
  }
}

main();
