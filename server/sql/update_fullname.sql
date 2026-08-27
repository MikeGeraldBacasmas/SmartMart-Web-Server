USE sm;

DROP PROCEDURE IF EXISTS sp_create_staff;

DELIMITER //
CREATE PROCEDURE sp_create_staff(
  IN p_username   VARCHAR(100),
  IN p_password   VARCHAR(255),
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

  INSERT INTO users (username, full_name, password, role) VALUES (p_username, p_full_name, p_password, 'staff');
  SET v_user_id = LAST_INSERT_ID();

  SELECT CONCAT('STF', LPAD(COUNT(*) + 1, 3, '0')) INTO p_staff_code FROM staff;

  INSERT INTO staff (user_id, staff_code, full_name, role)
  VALUES (v_user_id, p_staff_code, p_full_name, p_role);

  SET p_staff_id = LAST_INSERT_ID();
END //
DELIMITER ;

-- Update sp_get_user_by_username to prefer users.full_name
DROP PROCEDURE IF EXISTS sp_get_user_by_username;

DELIMITER //
CREATE PROCEDURE sp_get_user_by_username(IN p_username VARCHAR(100))
BEGIN
  SELECT u.id, u.username, u.password, u.role, u.is_active,
         COALESCE(u.full_name, s.full_name, CONCAT(c.first_name, ' ', c.last_name)) AS full_name,
         s.staff_code,
         c.first_name, c.last_name, c.customer_code, c.account_status
  FROM users u
  LEFT JOIN staff    s ON s.user_id = u.id
  LEFT JOIN customers c ON c.user_id = u.id
  WHERE u.username = p_username
  LIMIT 1;
END //
DELIMITER ;
