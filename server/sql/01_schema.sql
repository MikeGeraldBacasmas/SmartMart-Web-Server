-- ============================================================
-- SmartMart Database Schema
-- Compatible with: MySQL 8.0+ / SQLyog
-- Run this file first before stored procedures
-- ============================================================

CREATE DATABASE IF NOT EXISTS sm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sm;

-- ─── USERS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(100) NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,          -- bcrypt hash
  role        ENUM('admin','staff','customer') NOT NULL DEFAULT 'customer',
  is_active   TINYINT(1) NOT NULL DEFAULT 1,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ─── STAFF ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS staff (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL UNIQUE,
  staff_code  VARCHAR(20) NOT NULL UNIQUE,    -- e.g. STF001
  full_name   VARCHAR(150) NOT NULL,
  role        VARCHAR(50) NOT NULL DEFAULT 'Cashier',
  status      ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
  joined_at   DATE DEFAULT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ─── CUSTOMERS ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       INT UNSIGNED UNIQUE,           -- NULL until account approved
  customer_code VARCHAR(20) NOT NULL UNIQUE,   -- e.g. CUS001
  last_name     VARCHAR(100) NOT NULL,
  first_name    VARCHAR(100) NOT NULL,
  middle_name   VARCHAR(100),
  address       TEXT NOT NULL,
  date_of_birth DATE NOT NULL,
  civil_status  ENUM('Single','Married','Widowed','Separated') NOT NULL,
  gender        ENUM('Male','Female','Prefer not to say') NOT NULL,
  phone         VARCHAR(20) NOT NULL,
  account_status ENUM('Pending','Approved','Denied') NOT NULL DEFAULT 'Pending',
  submitted_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  approved_at   DATETIME,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ─── CATEGORIES ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL UNIQUE,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ─── PRODUCTS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(200) NOT NULL,
  category_id   INT UNSIGNED NOT NULL,
  price         DECIMAL(10,2) NOT NULL,
  stock         INT NOT NULL DEFAULT 0,
  low_stock_threshold INT NOT NULL DEFAULT 10,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ─── TRANSACTIONS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  receipt_no    VARCHAR(30) NOT NULL UNIQUE,   -- e.g. TRX-2026-0001
  customer_id   INT UNSIGNED,                  -- NULL = walk-in
  cashier_id    INT UNSIGNED NOT NULL,
  total_amount  DECIMAL(10,2) NOT NULL,
  cash_tendered DECIMAL(10,2) NOT NULL,
  change_amount DECIMAL(10,2) NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  FOREIGN KEY (cashier_id)  REFERENCES staff(id)     ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ─── TRANSACTION ITEMS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transaction_items (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  transaction_id  INT UNSIGNED NOT NULL,
  product_id      INT UNSIGNED NOT NULL,
  product_name    VARCHAR(200) NOT NULL,   -- snapshot at time of sale
  unit_price      DECIMAL(10,2) NOT NULL,
  quantity        INT NOT NULL,
  subtotal        DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id)     REFERENCES products(id)     ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ─── STORE SETTINGS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS store_settings (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  setting_key   VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ─── SEED: DEFAULT ADMIN USER ─────────────────────────────────
-- Password: admin123  (bcrypt hash — replace with actual hash from server)
INSERT IGNORE INTO users (username, password, role) VALUES
  ('admin',    '$2b$10$examplehashforadmin000000000000000000000000000', 'admin'),
  ('staff',    '$2b$10$examplehashforstaff000000000000000000000000000', 'staff'),
  ('customer', '$2b$10$examplehashforcustomer0000000000000000000000000', 'customer');

-- ─── SEED: DEFAULT SETTINGS ──────────────────────────────────
INSERT IGNORE INTO store_settings (setting_key, setting_value) VALUES
  ('store_name',       'SmartMart'),
  ('store_address',    'Zamora, Bilar, Bohol'),
  ('store_contact',    '09704972414'),
  ('store_email',      'hello@smartmart.ph'),
  ('store_hours',      '8:00 AM – 10:00 PM'),
  ('tax_rate',         '12'),
  ('low_stock_threshold', '10'),
  ('receipt_footer',   'Thank you for shopping at SmartMart!');

-- ─── SEED: CATEGORIES ────────────────────────────────────────
INSERT IGNORE INTO categories (name) VALUES
  ('Snacks'), ('Beverages'), ('Instant Foods'), ('Canned Goods'),
  ('Bread & Bakery'), ('Candies & Chocolates'), ('Dairy Products'),
  ('Cooking Essentials'), ('Personal Care'), ('Health & Wellness'),
  ('Household Essentials'), ('Baby Products'), ('Pet Supplies'),
  ('School & Office Supplies'), ('Electronics & Accessories'),
  ('Frozen Foods'), ('Miscellaneous');
