USE sm;

-- Retroactively populate full_name for existing customer users
UPDATE users u
JOIN customers c ON c.user_id = u.id
SET u.full_name = TRIM(CONCAT(c.first_name, IF(c.middle_name IS NOT NULL AND c.middle_name != '', CONCAT(' ', c.middle_name), ''), ' ', c.last_name))
WHERE u.role = 'customer';

DROP PROCEDURE IF EXISTS sp_approve_customer;

DELIMITER //
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

  -- Check if username already exists
  SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
  END IF;

  -- Check if pending customer exists
  SELECT first_name, middle_name, last_name
  INTO   v_first_name, v_middle_name, v_last_name
  FROM   customers
  WHERE  id = p_customer_id AND account_status = 'Pending';

  IF v_first_name IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pending customer record not found';
  END IF;

  -- Build full name combining first_name, middle_name (if present), and last_name
  SET v_full_name = TRIM(CONCAT(v_first_name, IF(v_middle_name IS NOT NULL AND v_middle_name != '', CONCAT(' ', v_middle_name), ''), ' ', v_last_name));

  -- Create user with username, password, full_name, and role 'customer'
  INSERT INTO users (username, password, full_name, role)
  VALUES (p_username, p_password, v_full_name, 'customer');

  SET v_user_id = LAST_INSERT_ID();

  -- Generate Customer Code (e.g. CUS001)
  SELECT CONCAT('CUS', LPAD(
    (SELECT COUNT(*) FROM customers WHERE account_status = 'Approved') + 1, 3, '0'
  )) INTO v_cust_code;

  -- Update customer record
  UPDATE customers
  SET user_id        = v_user_id,
      customer_code  = v_cust_code,
      account_status = 'Approved',
      approved_at    = NOW()
  WHERE id = p_customer_id;
END //
DELIMITER ;
