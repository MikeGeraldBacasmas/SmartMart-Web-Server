USE sm;

-- Sync any existing inactive staff users to is_active = 0
UPDATE users u
JOIN staff s ON s.user_id = u.id
SET u.is_active = IF(s.status = 'Active', 1, 0);

DROP PROCEDURE IF EXISTS sp_toggle_staff_status;

DELIMITER //
CREATE PROCEDURE sp_toggle_staff_status(IN p_staff_id INT UNSIGNED)
BEGIN
  DECLARE v_user_id INT UNSIGNED;
  DECLARE v_new_status VARCHAR(20);

  SELECT user_id, IF(status = 'Active', 'Inactive', 'Active')
  INTO v_user_id, v_new_status
  FROM staff WHERE id = p_staff_id;

  UPDATE staff SET status = v_new_status WHERE id = p_staff_id;
  UPDATE users SET is_active = IF(v_new_status = 'Active', 1, 0) WHERE id = v_user_id;

  SELECT status FROM staff WHERE id = p_staff_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_get_user_by_username;

DELIMITER //
CREATE PROCEDURE sp_get_user_by_username(IN p_username VARCHAR(100))
BEGIN
  SELECT u.id, u.username, u.password, u.role, u.is_active, u.created_at,
         COALESCE(u.full_name, s.full_name, CONCAT(c.first_name, ' ', c.last_name)) AS full_name,
         s.staff_code, s.status AS staff_status,
         DATE_FORMAT(COALESCE(s.joined_at, u.created_at), '%b %d, %Y') AS joined,
         c.first_name, c.last_name, c.customer_code, c.account_status
  FROM users u
  LEFT JOIN staff    s ON s.user_id = u.id
  LEFT JOIN customers c ON c.user_id = u.id
  WHERE u.username = p_username
  LIMIT 1;
END //
DELIMITER ;
