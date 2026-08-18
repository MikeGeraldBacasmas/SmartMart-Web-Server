-- ============================================================
-- Customer Profile Self-Service Stored Procedures
-- Run AFTER 02_stored_procedures.sql
-- ============================================================
USE sm;

DELIMITER $$

-- Get a customer's full profile by their user_id (from JWT)
DROP PROCEDURE IF EXISTS sp_get_customer_profile $$
CREATE PROCEDURE sp_get_customer_profile(IN p_user_id INT UNSIGNED)
BEGIN
  SELECT c.id, c.customer_code, c.first_name, c.last_name, c.middle_name,
         c.address, c.phone, c.gender, c.civil_status,
         DATE_FORMAT(c.date_of_birth, '%Y-%m-%d') AS date_of_birth,
         DATE_FORMAT(c.approved_at, '%b %d, %Y') AS joined,
         u.username
  FROM customers c
  JOIN users u ON u.id = c.user_id
  WHERE c.user_id = p_user_id
    AND c.account_status = 'Approved'
  LIMIT 1;
END $$

-- Update a customer's editable profile fields by their user_id
DROP PROCEDURE IF EXISTS sp_update_customer_profile $$
CREATE PROCEDURE sp_update_customer_profile(
  IN p_user_id      INT UNSIGNED,
  IN p_first_name   VARCHAR(100),
  IN p_last_name    VARCHAR(100),
  IN p_middle_name  VARCHAR(100),
  IN p_address      TEXT,
  IN p_phone        VARCHAR(20),
  IN p_gender       ENUM('Male','Female','Prefer not to say'),
  IN p_civil_status ENUM('Single','Married','Widowed','Separated'),
  IN p_dob          DATE
)
BEGIN
  DECLARE v_customer_id INT UNSIGNED;
  DECLARE v_full_name   VARCHAR(255);

  SELECT id INTO v_customer_id
  FROM customers
  WHERE user_id = p_user_id AND account_status = 'Approved'
  LIMIT 1;

  IF v_customer_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer profile not found';
  END IF;

  UPDATE customers
  SET first_name    = p_first_name,
      last_name     = p_last_name,
      middle_name   = p_middle_name,
      address       = p_address,
      phone         = p_phone,
      gender        = p_gender,
      civil_status  = p_civil_status,
      date_of_birth = p_dob
  WHERE id = v_customer_id;

  SET v_full_name = TRIM(CONCAT(p_first_name, IF(p_middle_name IS NOT NULL AND p_middle_name != '', CONCAT(' ', p_middle_name), ''), ' ', p_last_name));
  
  UPDATE users
  SET full_name = v_full_name
  WHERE id = p_user_id;

  -- Return the updated profile
  SELECT c.id, c.customer_code, c.first_name, c.last_name, c.middle_name,
         c.address, c.phone, c.gender, c.civil_status,
         DATE_FORMAT(c.date_of_birth, '%Y-%m-%d') AS date_of_birth,
         DATE_FORMAT(c.approved_at, '%b %d, %Y') AS joined,
         u.username
  FROM customers c
  JOIN users u ON u.id = c.user_id
  WHERE c.id = v_customer_id;
END $$

DELIMITER ;
