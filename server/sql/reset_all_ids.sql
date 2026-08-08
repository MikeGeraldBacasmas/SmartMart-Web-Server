USE sm;

SET FOREIGN_KEY_CHECKS = 0;

-- ══════════════════════════════════════════════════════════════
-- 1. RESET categories IDs
--    Gaps: 13 and 15 missing
--    Changes needed: 14→13, 16→14, 17→15, 18→16
-- ══════════════════════════════════════════════════════════════

-- Update products.category_id FIRST (FK checks off)
UPDATE products SET category_id = 13 WHERE category_id = 14;
UPDATE products SET category_id = 14 WHERE category_id = 16;
UPDATE products SET category_id = 15 WHERE category_id = 17;
UPDATE products SET category_id = 16 WHERE category_id = 18;

-- Now update categories.id (done in ascending order to avoid conflicts)
UPDATE categories SET id = 13 WHERE id = 14;
UPDATE categories SET id = 14 WHERE id = 16;
UPDATE categories SET id = 15 WHERE id = 17;
UPDATE categories SET id = 16 WHERE id = 18;

ALTER TABLE categories AUTO_INCREMENT = 17;

-- ══════════════════════════════════════════════════════════════
-- 2. RESET products IDs
--    Only 1 gap: ID 183 missing
--    Changes: 184→183, 185→184, ..., 210→209
-- ══════════════════════════════════════════════════════════════

-- No transaction_items rows so no FK updates needed
-- Update products in ascending order (183 is free, so 184→183 is safe)
UPDATE products SET id = id - 1 WHERE id >= 184 ORDER BY id ASC;

ALTER TABLE products AUTO_INCREMENT = 210;

-- ══════════════════════════════════════════════════════════════
-- 3. RESET users IDs
--    Current: 1 (admin), 9 (cashier1) → New: 1, 2
-- ══════════════════════════════════════════════════════════════

UPDATE staff SET user_id = 2 WHERE user_id = 9;
UPDATE users  SET id = 2      WHERE id = 9;
ALTER TABLE users AUTO_INCREMENT = 3;

-- ══════════════════════════════════════════════════════════════
-- 4. RESET staff IDs
--    Current: id=6 → New: id=1
-- ══════════════════════════════════════════════════════════════

UPDATE staff SET id = 1 WHERE id = 6;
ALTER TABLE staff AUTO_INCREMENT = 2;

SET FOREIGN_KEY_CHECKS = 1;

-- ── Verification ──────────────────────────────────────────────
SELECT 'categories' AS tbl, MIN(id) AS min_id, MAX(id) AS max_id, COUNT(*) AS total FROM categories
UNION ALL
SELECT 'products',   MIN(id), MAX(id), COUNT(*) FROM products
UNION ALL
SELECT 'users',      MIN(id), MAX(id), COUNT(*) FROM users
UNION ALL
SELECT 'staff',      MIN(id), MAX(id), COUNT(*) FROM staff;

SELECT id, name FROM categories ORDER BY id;
SELECT id, username, role FROM users ORDER BY id;
SELECT id, user_id, staff_code FROM staff ORDER BY id;
