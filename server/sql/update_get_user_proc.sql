USE sm;

DROP PROCEDURE IF EXISTS sp_get_user_by_username;

DELIMITER //
CREATE PROCEDURE sp_get_user_by_username(IN p_username VARCHAR(100))
BEGIN
  SELECT u.id, u.username, u.password, u.role, u.is_active, u.created_at,
         COALESCE(u.full_name, s.full_name, CONCAT(c.first_name, ' ', c.last_name)) AS full_name,
         s.staff_code,
         DATE_FORMAT(COALESCE(s.joined_at, u.created_at), '%b %d, %Y') AS joined,
         c.first_name, c.last_name, c.customer_code, c.account_status
  FROM users u
  LEFT JOIN staff    s ON s.user_id = u.id
  LEFT JOIN customers c ON c.user_id = u.id
  WHERE u.username = p_username
  LIMIT 1;
END //
DELIMITER ;
