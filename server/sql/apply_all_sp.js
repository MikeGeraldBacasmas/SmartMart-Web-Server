const { pool } = require('../db');

async function main() {
  const conn = await pool.getConnection();
  try {
    console.log("Applying updated stored procedures to database...");

    // ─── AUTH & USERS ──────────────────────────────────────────
    await conn.query("DROP PROCEDURE IF EXISTS sp_get_user_by_id");
    await conn.query(`
      CREATE PROCEDURE sp_get_user_by_id(IN p_id INT UNSIGNED)
      BEGIN
        SELECT u.id, u.username, u.password, u.role, u.is_active,
               s.full_name, s.staff_code,
               c.first_name, c.last_name, c.customer_code, c.account_status
        FROM users u
        LEFT JOIN staff    s ON s.user_id = u.id
        LEFT JOIN customers c ON c.user_id = u.id
        WHERE u.id = p_id
        LIMIT 1;
      END
    `);

    await conn.query("DROP PROCEDURE IF EXISTS sp_update_user_password");
    await conn.query(`
      CREATE PROCEDURE sp_update_user_password(
        IN p_id INT UNSIGNED,
        IN p_new_password VARCHAR(255)
      )
      BEGIN
        UPDATE users SET password = p_new_password WHERE id = p_id;
      END
    `);

    // ─── CATEGORIES ────────────────────────────────────────────
    await conn.query("DROP PROCEDURE IF EXISTS sp_create_category");
    await conn.query(`
      CREATE PROCEDURE sp_create_category(
        IN p_name VARCHAR(100)
      )
      BEGIN
        DECLARE v_count INT;
        SELECT COUNT(*) INTO v_count FROM categories WHERE name = p_name;
        IF v_count > 0 THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category already exists';
        END IF;

        INSERT INTO categories (name) VALUES (p_name);
        SELECT LAST_INSERT_ID() AS category_id, p_name AS name;
      END
    `);

    // ─── PRODUCTS ──────────────────────────────────────────────
    await conn.query("DROP PROCEDURE IF EXISTS sp_get_best_sellers");
    await conn.query(`
      CREATE PROCEDURE sp_get_best_sellers(IN p_limit INT)
      BEGIN
        DECLARE v_limit INT;
        SET v_limit = IF(p_limit IS NULL OR p_limit <= 0, 8, p_limit);
        SELECT 
          p.id,
          p.name,
          c.name AS category,
          c.id AS category_id,
          p.price,
          p.stock,
          p.image_url,
          CAST(IFNULL(SUM(ti.quantity), 0) AS UNSIGNED) AS total_sold,
          CAST(IFNULL(SUM(ti.subtotal), 0) AS DECIMAL(10,2)) AS total_revenue
        FROM products p
        JOIN categories c ON c.id = p.category_id
        LEFT JOIN transaction_items ti ON ti.product_id = p.id
        WHERE p.is_active = 1
        GROUP BY p.id, p.name, c.name, c.id, p.price, p.stock, p.image_url
        ORDER BY total_sold DESC, p.id ASC
        LIMIT v_limit;
      END
    `);

    await conn.query("DROP PROCEDURE IF EXISTS sp_create_product");
    await conn.query(`
      CREATE PROCEDURE sp_create_product(
        IN p_name        VARCHAR(200),
        IN p_category_id INT UNSIGNED,
        IN p_price       DECIMAL(10,2),
        IN p_stock       INT
      )
      BEGIN
        INSERT INTO products (name, category_id, price, stock)
        VALUES (p_name, p_category_id, p_price, p_stock);
        SELECT LAST_INSERT_ID() AS product_id, p_name AS name, p_category_id AS category_id, p_price AS price, p_stock AS stock;
      END
    `);

    await conn.query("DROP PROCEDURE IF EXISTS sp_update_product_image");
    await conn.query(`
      CREATE PROCEDURE sp_update_product_image(
        IN p_id INT UNSIGNED,
        IN p_image_url VARCHAR(500)
      )
      BEGIN
        UPDATE products SET image_url = p_image_url WHERE id = p_id;
      END
    `);

    // ─── STAFF ─────────────────────────────────────────────────
    await conn.query("DROP PROCEDURE IF EXISTS sp_create_staff");
    await conn.query(`
      CREATE PROCEDURE sp_create_staff(
        IN p_username      VARCHAR(100),
        IN p_password      VARCHAR(255),
        IN p_full_name     VARCHAR(150),
        IN p_role          VARCHAR(50),
        IN p_temp_password VARCHAR(255)
      )
      BEGIN
        DECLARE v_user_id    INT UNSIGNED;
        DECLARE v_count      INT;
        DECLARE v_staff_code VARCHAR(20);
        DECLARE v_staff_id   INT UNSIGNED;

        SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
        IF v_count > 0 THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
        END IF;

        INSERT INTO users (username, password, full_name, role)
        VALUES (p_username, p_password, p_full_name, 'staff');
        SET v_user_id = LAST_INSERT_ID();

        SELECT CONCAT('STF', LPAD(COUNT(*) + 1, 3, '0')) INTO v_staff_code FROM staff;

        INSERT INTO staff (user_id, staff_code, full_name, role)
        VALUES (v_user_id, v_staff_code, p_full_name, p_role);
        SET v_staff_id = LAST_INSERT_ID();

        SELECT v_staff_id AS id,
               v_staff_code AS staff_code,
               p_full_name AS full_name,
               p_username AS username,
               p_role AS role,
               'Active' AS status,
               DATE_FORMAT(NOW(), '%b %d, %Y') AS joined,
               p_temp_password AS temp_password;
      END
    `);

    // ─── CUSTOMERS ─────────────────────────────────────────────
    await conn.query("DROP PROCEDURE IF EXISTS sp_submit_customer_registration");
    await conn.query(`
      CREATE PROCEDURE sp_submit_customer_registration(
        IN p_last_name    VARCHAR(100),
        IN p_first_name   VARCHAR(100),
        IN p_middle_name  VARCHAR(100),
        IN p_address      TEXT,
        IN p_dob          DATE,
        IN p_civil_status ENUM('Single','Married','Widowed','Separated'),
        IN p_gender       ENUM('Male','Female','Prefer not to say'),
        IN p_phone        VARCHAR(20)
      )
      BEGIN
        DECLARE v_code VARCHAR(20);
        SELECT CONCAT('PND', LPAD(COUNT(*) + 1, 5, '0')) INTO v_code FROM customers;

        INSERT INTO customers
          (customer_code, last_name, first_name, middle_name, address,
           date_of_birth, civil_status, gender, phone, account_status)
        VALUES
          (v_code, p_last_name, p_first_name, p_middle_name, p_address,
           p_dob, p_civil_status, p_gender, p_phone, 'Pending');

        SELECT LAST_INSERT_ID() AS customer_id, 'Registration submitted' AS message;
      END
    `);

    // ─── TRANSACTIONS ──────────────────────────────────────────
    await conn.query("DROP PROCEDURE IF EXISTS sp_get_customer_purchase_history");
    await conn.query(`
      CREATE PROCEDURE sp_get_customer_purchase_history(IN p_user_id INT UNSIGNED)
      BEGIN
        SELECT t.id, t.receipt_no,
               IFNULL(CONCAT(c.last_name, ', ', c.first_name), 'Customer') AS customer,
               s.full_name AS cashier,
               t.total_amount, t.cash_tendered, t.change_amount,
               DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS date
        FROM transactions t
        JOIN customers c ON c.id = t.customer_id
        JOIN staff s ON s.id = t.cashier_id
        WHERE c.user_id = p_user_id
        ORDER BY t.created_at DESC;
      END
    `);

    await conn.query("DROP PROCEDURE IF EXISTS sp_create_transaction_header");
    await conn.query(`
      CREATE PROCEDURE sp_create_transaction_header(
        IN p_customer_id    INT UNSIGNED,
        IN p_cashier_id     INT UNSIGNED,
        IN p_cash_tendered  DECIMAL(10,2),
        IN p_payment_method VARCHAR(50)
      )
      BEGIN
        DECLARE v_seq INT;
        DECLARE v_receipt_no VARCHAR(30);
        DECLARE v_payment VARCHAR(50);
        DECLARE v_resolved_cashier INT UNSIGNED;

        -- Resolve staff_id if user_id was passed
        SELECT id INTO v_resolved_cashier FROM staff WHERE user_id = p_cashier_id LIMIT 1;
        IF v_resolved_cashier IS NULL THEN
          SELECT id INTO v_resolved_cashier FROM staff WHERE id = p_cashier_id LIMIT 1;
        END IF;

        IF v_resolved_cashier IS NULL THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid cashier: no staff record found';
        END IF;

        SET v_payment = IF(p_payment_method IS NULL OR p_payment_method = '', 'Cash', p_payment_method);
        SELECT COUNT(*) + 1 INTO v_seq FROM transactions WHERE YEAR(created_at) = YEAR(NOW());
        SET v_receipt_no = CONCAT('TRX-', YEAR(NOW()), '-', LPAD(v_seq, 4, '0'));

        INSERT INTO transactions (receipt_no, customer_id, cashier_id, total_amount, cash_tendered, change_amount, payment_method)
        VALUES (v_receipt_no, p_customer_id, v_resolved_cashier, 0, p_cash_tendered, 0, v_payment);

        SELECT LAST_INSERT_ID() AS transaction_id, v_receipt_no AS receipt_no;
      END
    `);

    console.log("All stored procedures created/updated successfully!");
  } catch (err) {
    console.error("Error executing SP update script:", err);
  } finally {
    conn.release();
    process.exit(0);
  }
}

main();
