-- ============================================================
-- SmartMart Stored Procedures
-- Run this file AFTER 01_schema.sql
-- ============================================================
USE sm;

DELIMITER $$

-- ─── AUTH ─────────────────────────────────────────────────────

-- Get user by username for login
DROP PROCEDURE IF EXISTS sp_get_user_by_username $$
CREATE PROCEDURE sp_get_user_by_username(IN p_username VARCHAR(100))
BEGIN
  SELECT u.id, u.username, u.password, u.role, u.is_active,
         s.full_name, s.staff_code,
         c.first_name, c.last_name, c.customer_code, c.account_status
  FROM users u
  LEFT JOIN staff    s ON s.user_id = u.id
  LEFT JOIN customers c ON c.user_id = u.id
  WHERE u.username = p_username
  LIMIT 1;
END $$

-- ─── STAFF ─────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_get_all_staff $$
CREATE PROCEDURE sp_get_all_staff()
BEGIN
  SELECT s.id, s.staff_code, s.full_name, s.role, s.status,
         DATE_FORMAT(s.joined_at, '%b %d, %Y') AS joined,
         u.username, u.is_active
  FROM staff s
  JOIN users u ON u.id = s.user_id
  ORDER BY s.id;
END $$

DROP PROCEDURE IF EXISTS sp_create_staff $$
CREATE PROCEDURE sp_create_staff(
  IN p_username   VARCHAR(100),
  IN p_password   VARCHAR(255),   -- pre-hashed
  IN p_full_name  VARCHAR(150),
  IN p_role       VARCHAR(50),
  OUT p_staff_id  INT UNSIGNED,
  OUT p_staff_code VARCHAR(20)
)
BEGIN
  DECLARE v_user_id   INT UNSIGNED;
  DECLARE v_count     INT;

  SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;

  INSERT INTO users (username, password, role) VALUES (p_username, p_password, 'staff');
  SET v_user_id = LAST_INSERT_ID();

  SELECT CONCAT('STF', LPAD(COUNT(*) + 1, 3, '0')) INTO p_staff_code FROM staff;

  INSERT INTO staff (user_id, staff_code, full_name, role)
  VALUES (v_user_id, p_staff_code, p_full_name, p_role);

  SET p_staff_id = LAST_INSERT_ID();
END $$

DROP PROCEDURE IF EXISTS sp_toggle_staff_status $$
CREATE PROCEDURE sp_toggle_staff_status(IN p_staff_id INT UNSIGNED)
BEGIN
  UPDATE staff
  SET status = IF(status = 'Active', 'Inactive', 'Active')
  WHERE id = p_staff_id;

  SELECT status FROM staff WHERE id = p_staff_id;
END $$

-- ─── CUSTOMERS ─────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_get_registered_customers $$
CREATE PROCEDURE sp_get_registered_customers()
BEGIN
  SELECT c.id, c.customer_code,
         CONCAT(c.last_name, ', ', c.first_name, ' ', IFNULL(c.middle_name,'')) AS full_name,
         c.phone, c.address, c.gender, c.civil_status,
         DATE_FORMAT(c.date_of_birth, '%Y-%m-%d') AS date_of_birth,
         DATE_FORMAT(c.approved_at, '%b %d, %Y') AS joined,
         u.username,
         COUNT(t.id) AS total_purchases
  FROM customers c
  JOIN users u ON u.id = c.user_id
  LEFT JOIN transactions t ON t.customer_id = c.id
  WHERE c.account_status = 'Approved'
  GROUP BY c.id
  ORDER BY c.approved_at DESC;
END $$

DROP PROCEDURE IF EXISTS sp_get_pending_customers $$
CREATE PROCEDURE sp_get_pending_customers()
BEGIN
  SELECT id, last_name, first_name, middle_name, address,
         DATE_FORMAT(date_of_birth, '%Y-%m-%d') AS date_of_birth,
         civil_status, gender, phone,
         DATE_FORMAT(submitted_at, '%b %d, %Y') AS submitted_at
  FROM customers
  WHERE account_status = 'Pending'
  ORDER BY submitted_at ASC;
END $$

DROP PROCEDURE IF EXISTS sp_submit_customer_registration $$
CREATE PROCEDURE sp_submit_customer_registration(
  IN p_last_name    VARCHAR(100),
  IN p_first_name   VARCHAR(100),
  IN p_middle_name  VARCHAR(100),
  IN p_address      TEXT,
  IN p_dob          DATE,
  IN p_civil_status ENUM('Single','Married','Widowed','Separated'),
  IN p_gender       ENUM('Male','Female','Prefer not to say'),
  IN p_phone        VARCHAR(20),
  OUT p_customer_id INT UNSIGNED
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

  SET p_customer_id = LAST_INSERT_ID();
END $$

DROP PROCEDURE IF EXISTS sp_approve_customer $$
CREATE PROCEDURE sp_approve_customer(
  IN p_customer_id INT UNSIGNED,
  IN p_username    VARCHAR(100),
  IN p_password    VARCHAR(255)    -- pre-hashed
)
BEGIN
  DECLARE v_user_id    INT UNSIGNED;
  DECLARE v_count      INT;
  DECLARE v_cust_code  VARCHAR(20);

  SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;

  INSERT INTO users (username, password, role) VALUES (p_username, p_password, 'customer');
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
END $$

DROP PROCEDURE IF EXISTS sp_deny_customer $$
CREATE PROCEDURE sp_deny_customer(IN p_customer_id INT UNSIGNED)
BEGIN
  UPDATE customers SET account_status = 'Denied' WHERE id = p_customer_id;
END $$

-- ─── CATEGORIES ────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_get_all_categories $$
CREATE PROCEDURE sp_get_all_categories()
BEGIN
  SELECT c.id, c.name, COUNT(p.id) AS product_count
  FROM categories c
  LEFT JOIN products p ON p.category_id = c.id AND p.is_active = 1
  GROUP BY c.id
  ORDER BY c.name;
END $$

DROP PROCEDURE IF EXISTS sp_create_category $$
CREATE PROCEDURE sp_create_category(
  IN  p_name        VARCHAR(100),
  OUT p_category_id INT UNSIGNED
)
BEGIN
  DECLARE v_count INT;
  SELECT COUNT(*) INTO v_count FROM categories WHERE name = p_name;
  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category already exists';
  END IF;
  INSERT INTO categories (name) VALUES (p_name);
  SET p_category_id = LAST_INSERT_ID();
END $$

-- ─── PRODUCTS ──────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_get_all_products $$
CREATE PROCEDURE sp_get_all_products()
BEGIN
  SELECT p.id, p.name, c.name AS category, p.price, p.stock,
         p.low_stock_threshold,
         IF(p.stock <= p.low_stock_threshold, 1, 0) AS low_stock,
         p.is_active
  FROM products p
  JOIN categories c ON c.id = p.category_id
  WHERE p.is_active = 1
  ORDER BY c.name, p.name;
END $$

DROP PROCEDURE IF EXISTS sp_create_product $$
CREATE PROCEDURE sp_create_product(
  IN  p_name        VARCHAR(200),
  IN  p_category_id INT UNSIGNED,
  IN  p_price       DECIMAL(10,2),
  IN  p_stock       INT,
  OUT p_product_id  INT UNSIGNED
)
BEGIN
  INSERT INTO products (name, category_id, price, stock)
  VALUES (p_name, p_category_id, p_price, p_stock);
  SET p_product_id = LAST_INSERT_ID();
END $$

DROP PROCEDURE IF EXISTS sp_update_product_stock $$
CREATE PROCEDURE sp_update_product_stock(
  IN p_product_id INT UNSIGNED,
  IN p_new_stock  INT
)
BEGIN
  UPDATE products SET stock = p_new_stock WHERE id = p_product_id;
END $$

DROP PROCEDURE IF EXISTS sp_get_low_stock_products $$
CREATE PROCEDURE sp_get_low_stock_products()
BEGIN
  SELECT p.id, p.name, c.name AS category, p.stock, p.low_stock_threshold
  FROM products p
  JOIN categories c ON c.id = p.category_id
  WHERE p.stock <= p.low_stock_threshold AND p.is_active = 1
  ORDER BY p.stock ASC;
END $$

-- ─── TRANSACTIONS ───────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_create_transaction $$
CREATE PROCEDURE sp_create_transaction(
  IN  p_customer_id   INT UNSIGNED,   -- NULL for walk-in
  IN  p_cashier_id    INT UNSIGNED,
  IN  p_cash_tendered DECIMAL(10,2),
  OUT p_transaction_id INT UNSIGNED,
  OUT p_receipt_no    VARCHAR(30)
)
BEGIN
  DECLARE v_seq INT;
  SELECT COUNT(*) + 1 INTO v_seq FROM transactions WHERE YEAR(created_at) = YEAR(NOW());
  SET p_receipt_no = CONCAT('TRX-', YEAR(NOW()), '-', LPAD(v_seq, 4, '0'));

  INSERT INTO transactions (receipt_no, customer_id, cashier_id, total_amount, cash_tendered, change_amount)
  VALUES (p_receipt_no, p_customer_id, p_cashier_id, 0, p_cash_tendered, 0);

  SET p_transaction_id = LAST_INSERT_ID();
END $$

DROP PROCEDURE IF EXISTS sp_add_transaction_item $$
CREATE PROCEDURE sp_add_transaction_item(
  IN p_transaction_id INT UNSIGNED,
  IN p_product_id     INT UNSIGNED,
  IN p_quantity       INT
)
BEGIN
  DECLARE v_price      DECIMAL(10,2);
  DECLARE v_name       VARCHAR(200);
  DECLARE v_subtotal   DECIMAL(10,2);
  DECLARE v_stock      INT;

  SELECT price, name, stock INTO v_price, v_name, v_stock
  FROM products WHERE id = p_product_id FOR UPDATE;

  IF v_stock < p_quantity THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
  END IF;

  SET v_subtotal = v_price * p_quantity;

  INSERT INTO transaction_items
    (transaction_id, product_id, product_name, unit_price, quantity, subtotal)
  VALUES
    (p_transaction_id, p_product_id, v_name, v_price, p_quantity, v_subtotal);

  -- Deduct stock
  UPDATE products SET stock = stock - p_quantity WHERE id = p_product_id;
END $$

DROP PROCEDURE IF EXISTS sp_finalize_transaction $$
CREATE PROCEDURE sp_finalize_transaction(IN p_transaction_id INT UNSIGNED)
BEGIN
  DECLARE v_total      DECIMAL(10,2);
  DECLARE v_tendered   DECIMAL(10,2);

  SELECT SUM(subtotal) INTO v_total
  FROM transaction_items WHERE transaction_id = p_transaction_id;

  SELECT cash_tendered INTO v_tendered
  FROM transactions WHERE id = p_transaction_id;

  UPDATE transactions
  SET total_amount  = v_total,
      change_amount = v_tendered - v_total
  WHERE id = p_transaction_id;

  SELECT t.id, t.receipt_no, t.total_amount, t.cash_tendered, t.change_amount,
         t.created_at, s.full_name AS cashier
  FROM transactions t
  JOIN staff s ON s.id = t.cashier_id
  WHERE t.id = p_transaction_id;
END $$

DROP PROCEDURE IF EXISTS sp_get_transactions $$
CREATE PROCEDURE sp_get_transactions(
  IN p_date_from DATE,
  IN p_date_to   DATE
)
BEGIN
  SELECT t.id, t.receipt_no,
         IFNULL(CONCAT(c.last_name, ', ', c.first_name), 'Walk-in') AS customer,
         s.full_name AS cashier,
         t.total_amount, t.cash_tendered, t.change_amount,
         DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS date
  FROM transactions t
  LEFT JOIN customers c ON c.id = t.customer_id
  JOIN staff s ON s.id = t.cashier_id
  WHERE DATE(t.created_at) BETWEEN p_date_from AND p_date_to
  ORDER BY t.created_at DESC;
END $$

DROP PROCEDURE IF EXISTS sp_get_transaction_items $$
CREATE PROCEDURE sp_get_transaction_items(IN p_transaction_id INT UNSIGNED)
BEGIN
  SELECT product_name, unit_price, quantity, subtotal
  FROM transaction_items
  WHERE transaction_id = p_transaction_id;
END $$

-- ─── STORE SETTINGS ─────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_get_settings $$
CREATE PROCEDURE sp_get_settings()
BEGIN
  SELECT setting_key, setting_value FROM store_settings;
END $$

DROP PROCEDURE IF EXISTS sp_update_setting $$
CREATE PROCEDURE sp_update_setting(
  IN p_key   VARCHAR(100),
  IN p_value TEXT
)
BEGIN
  INSERT INTO store_settings (setting_key, setting_value)
  VALUES (p_key, p_value)
  ON DUPLICATE KEY UPDATE setting_value = p_value;
END $$

-- ─── DASHBOARD SUMMARY ──────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_get_dashboard_summary $$
CREATE PROCEDURE sp_get_dashboard_summary()
BEGIN
  SELECT
    (SELECT COUNT(*) FROM products WHERE is_active = 1) AS total_products,
    (SELECT COUNT(*) FROM categories)                    AS total_categories,
    (SELECT COUNT(*) FROM customers WHERE account_status = 'Approved') AS total_customers,
    (SELECT COUNT(*) FROM staff WHERE status = 'Active') AS active_staff,
    (SELECT COUNT(*) FROM products WHERE stock <= low_stock_threshold AND is_active = 1) AS low_stock_count,
    (SELECT IFNULL(SUM(total_amount),0) FROM transactions WHERE DATE(created_at) = CURDATE()) AS today_sales,
    (SELECT COUNT(*) FROM transactions WHERE DATE(created_at) = CURDATE()) AS today_transactions,
    (SELECT COUNT(*) FROM customers WHERE account_status = 'Pending') AS pending_registrations;
END $$

DELIMITER ;
