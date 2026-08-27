USE sm;

-- ─── Add image_url column to products ───────────────────────────
ALTER TABLE products
  ADD COLUMN image_url VARCHAR(500) DEFAULT NULL AFTER is_active;

-- ─── Update sp_get_all_products to include image_url ────────────
DROP PROCEDURE IF EXISTS sp_get_all_products;

DELIMITER //
CREATE PROCEDURE sp_get_all_products()
BEGIN
  SELECT p.id, p.name, c.name AS category, c.id AS category_id, p.price, p.stock,
         p.low_stock_threshold,
         IF(p.stock <= p.low_stock_threshold, 1, 0) AS low_stock,
         p.is_active,
         p.image_url
  FROM products p
  JOIN categories c ON c.id = p.category_id
  WHERE p.is_active = 1
  ORDER BY c.name, p.name;
END //
DELIMITER ;

-- ─── Create sp_update_product stored procedure ──────────────────
DROP PROCEDURE IF EXISTS sp_update_product;

DELIMITER //
CREATE PROCEDURE sp_update_product(
  IN p_id          INT UNSIGNED,
  IN p_name        VARCHAR(200),
  IN p_category_id INT UNSIGNED,
  IN p_price       DECIMAL(10,2),
  IN p_stock       INT,
  IN p_image_url   VARCHAR(500)
)
BEGIN
  UPDATE products
  SET name        = p_name,
      category_id = p_category_id,
      price       = p_price,
      stock       = p_stock,
      image_url   = p_image_url
  WHERE id = p_id;
END //
DELIMITER ;
