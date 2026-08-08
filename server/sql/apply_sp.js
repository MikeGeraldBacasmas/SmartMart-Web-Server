const { pool } = require('../db');

async function main() {
  const conn = await pool.getConnection();
  try {
    await conn.query('DROP PROCEDURE IF EXISTS sp_approve_customer');
    await conn.query(`
      CREATE PROCEDURE sp_approve_customer(
        IN p_customer_id INT UNSIGNED,
        IN p_username    VARCHAR(100),
        IN p_password    VARCHAR(255)
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
            approved_at    = NOW()
        WHERE id = p_customer_id;
      END
    `);
    console.log("sp_approve_customer updated successfully!");

    // Clean up orphaned customer users if any
    const [result] = await conn.query(`
      DELETE FROM users 
      WHERE role = 'customer' 
        AND id NOT IN (SELECT user_id FROM customers WHERE user_id IS NOT NULL)
    `);
    console.log(`Cleaned up ${result.affectedRows} orphaned customer user record(s).`);

  } catch (err) {
    console.error("Error updating stored procedure:", err);
  } finally {
    conn.release();
    process.exit(0);
  }
}

main();
