USE sm;

SET @cat_id = 18;

INSERT INTO products (name, category_id, price, stock) VALUES
('San Miguel Pale Pilsen',             @cat_id, 53.00,  50),
('San Miguel Pale Pilsen Can',         @cat_id, 72.00,  50),
('San Miguel Grande',                  @cat_id, 145.00, 50),
('San Mig Light',                      @cat_id, 62.00,  50),
('San Mig Light Can',                  @cat_id, 72.00,  50),
('Red Horse Stallion',                 @cat_id, 56.00,  50),
('Red Horse Can',                      @cat_id, 69.00,  50),
('Red Horse',                          @cat_id, 72.00,  50),
('Red Horse Can 1L',                   @cat_id, 98.00,  50),
('Red Horse 1L',                       @cat_id, 136.00, 50),
('Red Horse Super Extra Strong',       @cat_id, 145.00, 50),
('San Miguel Super Dry',               @cat_id, 85.00,  50),
('San Miguel Premium All-Malt',        @cat_id, 89.00,  50),
('San Miguel Cerveza Blanca',          @cat_id, 92.00,  50),
('San Miguel Cerveza Negra',           @cat_id, 92.00,  50),
('San Miguel Chocolate Lager',         @cat_id, 92.00,  50),
('San Miguel Apple Flavored Beer',     @cat_id, 51.00,  50),
('San Miguel Apple Flavored Beer Can', @cat_id, 66.00,  50),
('San Miguel Lemon Flavored Beer',     @cat_id, 51.00,  50),
('San Miguel Lemon Flavored Beer Can', @cat_id, 66.00,  50),
('San Mig Lychee',                     @cat_id, 51.00,  50),
('San Mig Lychee Can',                 @cat_id, 66.00,  50),
('San Miguel Mango Yuzu',              @cat_id, 92.00,  50),
('Kirin Beer',                         @cat_id, 103.00, 50),
('Kirin Ichiban',                      @cat_id, 103.00, 50),
('Asahi Super Dry',                    @cat_id, 102.00, 50);
