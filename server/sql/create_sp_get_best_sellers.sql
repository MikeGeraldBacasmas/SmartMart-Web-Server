USE sm;

DROP PROCEDURE IF EXISTS sp_get_best_sellers;

DELIMITER //
CREATE PROCEDURE sp_get_best_sellers()
BEGIN
  SELECT p.id, p.name, p.price,
         CAST(IFNULL(SUM(ti.quantity), 0) AS UNSIGNED) AS total_sold,
         CAST(IFNULL(SUM(ti.subtotal), 0) AS DECIMAL(10,2)) AS total_revenue
  FROM products p
  JOIN transaction_items ti ON ti.product_id = p.id
  WHERE p.is_active = 1
  GROUP BY p.id, p.name, p.price
  HAVING total_sold > 0
  ORDER BY total_sold DESC, total_revenue DESC
  LIMIT 5;
END //
DELIMITER ;
