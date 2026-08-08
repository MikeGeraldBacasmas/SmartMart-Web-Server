USE sm;

DROP PROCEDURE IF EXISTS sp_create_staff;

DELIMITER //
CREATE PROCEDURE sp_create_staff(
  IN p_username      VARCHAR(100),
  IN p_password      VARCHAR(255),
  IN p_full_name     VARCHAR(150),
  IN p_role          VARCHAR(50),
  IN p_temp_password VARCHAR(255),
  OUT p_staff_id     INT UNSIGNED,
  OUT p_staff_code   VARCHAR(20)
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

  INSERT INTO staff (user_id, staff_code, full_name, role, temp_password, joined_at)
  VALUES (v_user_id, p_staff_code, p_full_name, p_role, p_temp_password, CURDATE());

  SET p_staff_id = LAST_INSERT_ID();
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_get_all_staff;

DELIMITER //
CREATE PROCEDURE sp_get_all_staff()
BEGIN
  SELECT s.id, s.staff_code, s.full_name, s.role, s.status, s.temp_password,
         DATE_FORMAT(s.joined_at, '%b %d, %Y') AS joined,
         u.username, u.is_active
  FROM staff s
  JOIN users u ON u.id = s.user_id
  ORDER BY s.id;
END //
DELIMITER ;
