-- MySQL dump 10.13  Distrib 5.7.43, for Win64 (x86_64)
--
-- Host: localhost    Database: sm
-- ------------------------------------------------------
-- Server version	5.7.43-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `sm`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `sm` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `sm`;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Snacks','2026-08-05 13:11:23'),(2,'Non-Alcoholic Bevera','2026-08-05 13:11:23'),(3,'Instant Foods','2026-08-05 13:11:23'),(4,'Canned Goods','2026-08-05 13:11:23'),(5,'Bread & Bakery','2026-08-05 13:11:23'),(6,'Candies & Chocolates','2026-08-05 13:11:23'),(7,'Dairy Products','2026-08-05 13:11:23'),(8,'Cooking Essentials','2026-08-05 13:11:23'),(9,'Personal Care','2026-08-05 13:11:23'),(10,'Health & Wellness','2026-08-05 13:11:23'),(11,'Household Essentials','2026-08-05 13:11:23'),(12,'Baby Products','2026-08-05 13:11:23'),(13,'School & Office Supp','2026-08-05 13:11:23'),(14,'Frozen Foods','2026-08-05 13:11:23'),(15,'Miscellaneous','2026-08-05 13:11:23'),(16,'Alcoholic Beverages','2026-08-05 16:04:25');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `customer_code` varchar(20) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `address` text NOT NULL,
  `date_of_birth` date NOT NULL,
  `civil_status` enum('Single','Married','Widowed','Separated') NOT NULL,
  `gender` enum('Male','Female','Prefer not to say') NOT NULL,
  `phone` varchar(20) NOT NULL,
  `temp_password` varchar(255) DEFAULT NULL,
  `account_status` enum('Pending','Approved','Denied') NOT NULL DEFAULT 'Pending',
  `submitted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_code` (`customer_code`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (22,16,'CUS001','Igcalinos','Jhonel','Budlat','Oac, Dimiao, Bohol','2000-04-02','Single','Male','09435127563','jhonel143','Approved','2026-08-05 18:56:55','2026-08-05 18:57:30'),(23,17,'CUS002','Manla','Mark','Jaime','Cambacay, Batuan, Bohol','2005-04-04','Single','Male','09876541231','mark123','Approved','2026-08-13 18:25:31','2026-08-13 18:26:30'),(24,18,'CUS003','Bacasmas','Mike Gerald','Sericon','Santa Filomena, Alburquerque, Bohol','2005-08-12','Single','Male','09424508820','mike123','Approved','2026-08-18 09:15:34','2026-08-18 09:16:52'),(25,19,'CUS004','Dump','Diplo',NULL,'Jagna, Bohol','2000-08-31','Single','Male','09511317558','diplo123','Approved','2026-08-31 12:54:10','2026-08-31 12:54:45'),(26,21,'CUS005','Tuba','CJ','Manla','Batuan, Bohol','2004-11-30','Married','Male','09453673624','cj12345','Approved','2026-09-02 10:57:18','2026-09-02 10:58:00');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `category_id` int(10) unsigned NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT '0',
  `low_stock_threshold` int(11) NOT NULL DEFAULT '10',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `image_url` varchar(500) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Piattos',1,25.00,45,10,1,'/uploads/products/product_1787848634019.jpg','2026-08-05 13:47:13','2026-08-28 00:37:14'),(2,'Nova',1,15.00,38,10,1,'/uploads/products/product_1787848426988.jpg','2026-08-05 13:47:13','2026-08-28 00:33:46'),(3,'Clover Chips',1,12.00,60,10,1,'/uploads/products/product_1787848186941.jpg','2026-08-05 13:47:13','2026-08-28 00:29:46'),(4,'Oishi Onion Rings',1,20.00,42,10,1,'/uploads/products/product_1787848931459.jpg','2026-08-05 13:47:13','2026-08-28 00:42:11'),(5,'Oishi Potato Fries',1,10.00,55,10,1,'/uploads/products/product_1787848527243.jpg','2026-08-05 13:47:13','2026-08-28 00:35:27'),(6,'Oishi Prawn Crackers',1,12.00,5,10,1,'/uploads/products/product_1787848587513.jpg','2026-08-05 13:47:13','2026-08-31 14:08:02'),(7,'Ding Dong Mixed Nuts',1,18.00,29,10,1,'/uploads/products/product_1787848219850.jpg','2026-08-05 13:47:13','2026-08-31 14:08:02'),(8,'Nagaraya Peanuts',1,15.00,38,10,1,'/uploads/products/product_1787848381240.jpg','2026-08-05 13:47:13','2026-08-28 11:53:50'),(9,'Chippy',1,10.00,62,10,1,'/uploads/products/product_1787848144893.jpg','2026-08-05 13:47:13','2026-08-28 00:29:04'),(10,'Oishi Cracklings',1,25.00,28,10,1,'/uploads/products/product_1787848793443.jpg','2026-08-05 13:47:13','2026-08-28 00:39:53'),(11,'Mr. Chips',1,12.00,50,10,1,'/uploads/products/product_1787848339058.jpg','2026-08-05 13:47:13','2026-08-28 00:32:19'),(12,'Pringles',1,110.00,17,10,1,'/uploads/products/product_1787848673434.jpg','2026-08-05 13:47:13','2026-08-31 14:06:37'),(13,'Cheetos',1,30.00,35,10,1,'/uploads/products/product_1787848076661.jpg','2026-08-05 13:47:13','2026-08-28 00:27:56'),(14,'Lay\'s',1,55.00,6,10,1,'/uploads/products/product_1787848301058.jpg','2026-08-05 13:47:13','2026-08-28 00:31:41'),(15,'Doritos',1,60.00,22,10,1,'/uploads/products/product_1787848257861.jpg','2026-08-05 13:47:13','2026-08-28 00:30:57'),(16,'Coca-Cola',2,40.00,30,10,1,'/uploads/products/product_1787845158143.jpg','2026-08-05 13:47:13','2026-08-27 23:39:18'),(17,'Pepsi',2,38.00,26,10,1,'/uploads/products/product_1787845644505.jpg','2026-08-05 13:47:13','2026-08-27 23:47:24'),(18,'Sprite',2,40.00,34,10,1,'/uploads/products/product_1787845837760.jpg','2026-08-05 13:47:13','2026-08-27 23:50:37'),(19,'Royal',2,35.00,5,10,1,'/uploads/products/product_1787845737888.jpg','2026-08-05 13:47:13','2026-08-27 23:48:57'),(20,'Mountain Dew',2,40.00,28,10,1,'/uploads/products/product_1787845566322.jpg','2026-08-05 13:47:13','2026-08-27 23:46:06'),(21,'Summit Water',2,20.00,80,10,1,'/uploads/products/product_1787845908463.jpg','2026-08-05 13:47:13','2026-08-27 23:51:48'),(22,'Wilkins Water',2,25.00,65,10,1,'/uploads/products/product_1787845988328.jpg','2026-08-05 13:47:13','2026-08-27 23:53:08'),(23,'Absolute Water',2,20.00,70,10,1,'/uploads/products/product_1787845014949.jpg','2026-08-05 13:47:13','2026-08-27 23:36:54'),(24,'C2 Green Tea',2,25.00,40,10,1,'/uploads/products/product_1787845094080.jpg','2026-08-05 13:47:13','2026-08-27 23:38:14'),(25,'Nestea',2,25.00,32,10,1,'/uploads/products/product_1787845606852.jpg','2026-08-05 13:47:13','2026-08-27 23:46:46'),(26,'Gatorade',2,45.00,24,10,1,'/uploads/products/product_1787845364635.jpg','2026-08-05 13:47:13','2026-08-27 23:42:44'),(27,'Sting Energy Drink',2,30.00,9,10,1,'/uploads/products/product_1787845869828.jpg','2026-08-05 13:47:13','2026-08-27 23:51:09'),(28,'Red Bull',2,55.00,20,10,1,'/uploads/products/product_1787845678889.jpg','2026-08-05 13:47:13','2026-08-27 23:47:58'),(29,'Monster Energy',2,65.00,15,10,1,'/uploads/products/product_1787845517393.jpg','2026-08-05 13:47:13','2026-08-27 23:45:17'),(30,'Coffee (3-in-1)',2,9.00,100,10,1,'/uploads/products/product_1787845321609.jpg','2026-08-05 13:47:13','2026-08-27 23:42:01'),(31,'Milk Tea Bottles',2,65.00,18,10,1,'/uploads/products/product_1787845424073.jpg','2026-08-05 13:47:13','2026-08-27 23:43:44'),(32,'Lucky Me Pancit Canton',3,15.00,53,10,1,'/uploads/products/product_1787843593387.jpg','2026-08-05 13:47:13','2026-08-28 12:01:35'),(33,'Lucky Me Beef Noodle',3,13.00,48,10,1,'/uploads/products/product_1787843549279.jpg','2026-08-05 13:47:13','2026-08-27 23:12:29'),(34,'Nissin Cup Noodles',3,30.00,36,10,1,'/uploads/products/product_1787843629889.jpg','2026-08-05 13:47:13','2026-08-27 23:13:49'),(35,'Payless Xtra Big',3,25.00,40,10,1,'/uploads/products/product_1787843737065.jpg','2026-08-05 13:47:13','2026-08-27 23:15:37'),(36,'Samyang Noodles',3,85.00,9,10,1,'/uploads/products/product_1787843776087.jpg','2026-08-05 13:47:13','2026-08-31 13:31:57'),(37,'Jin Ramen',3,55.00,7,10,1,'/uploads/products/product_1787843465020.jpg','2026-08-05 13:47:13','2026-08-27 23:11:05'),(38,'Oatmeal',3,95.00,20,10,1,'/uploads/products/product_1787843689892.jpg','2026-08-05 13:47:13','2026-08-27 23:14:49'),(39,'Instant Soup',3,18.00,44,10,1,'/uploads/products/product_1787843417048.jpg','2026-08-05 13:47:13','2026-08-27 23:10:17'),(40,'Century Tuna',4,48.00,30,10,1,'/uploads/products/product_1787839183919.jpg','2026-08-05 13:47:13','2026-08-27 21:59:43'),(41,'555 Sardines',4,22.00,44,10,1,'/uploads/products/product_1787838991607.jpg','2026-08-05 13:47:13','2026-08-31 14:45:08'),(42,'Mega Sardines',4,24.00,40,10,1,'/uploads/products/product_1787839361193.jpg','2026-08-05 13:47:13','2026-08-27 22:02:41'),(43,'Argentina Corned Beef',4,55.00,18,10,1,'/uploads/products/product_1787839062488.jpg','2026-08-05 13:47:13','2026-08-27 21:57:42'),(44,'Purefoods Corned Beef',4,58.00,9,10,1,'/uploads/products/product_1787839394137.jpg','2026-08-05 13:47:13','2026-08-27 22:03:14'),(45,'Spam',4,145.00,14,10,1,'/uploads/products/product_1787839454988.jpg','2026-08-05 13:47:13','2026-08-27 22:04:14'),(46,'Luncheon Meat',4,65.00,22,10,1,'/uploads/products/product_1787839236405.jpg','2026-08-05 13:47:13','2026-08-27 22:00:36'),(47,'Meat Loaf',4,35.00,26,10,1,'/uploads/products/product_1787839293680.jpg','2026-08-05 13:47:13','2026-08-27 22:01:33'),(48,'Baked Beans',4,48.00,30,10,1,'/uploads/products/product_1787839140677.jpg','2026-08-05 13:47:13','2026-08-27 21:59:00'),(49,'Vienna Sausage',4,42.00,8,10,1,'/uploads/products/product_1787839540970.jpg','2026-08-05 13:47:13','2026-08-27 22:05:40'),(50,'Gardenia Bread',5,65.00,21,10,1,'/uploads/products/product_1787837593510.jpg','2026-08-05 13:47:13','2026-09-15 10:05:47'),(51,'Pandesal',5,3.00,120,10,1,'/uploads/products/product_1787837852405.jpg','2026-08-05 13:47:13','2026-08-27 21:37:32'),(52,'Monay',5,8.00,60,10,1,'/uploads/products/product_1787837669295.jpg','2026-08-05 13:47:13','2026-08-27 21:34:29'),(53,'Ensaymada',5,25.00,30,10,1,'/uploads/products/product_1787837555049.jpg','2026-08-05 13:47:13','2026-08-27 21:32:35'),(54,'Muffins',5,20.00,28,10,1,'/uploads/products/product_1787837735578.jpg','2026-08-05 13:47:13','2026-08-27 21:35:35'),(55,'Doughnuts',5,18.00,6,10,1,'/uploads/products/product_1787837504826.jpg','2026-08-05 13:47:13','2026-08-27 21:31:44'),(56,'Cupcakes',5,15.00,40,10,1,'/uploads/products/product_1787837451295.jpg','2026-08-05 13:47:13','2026-08-27 21:30:51'),(57,'Sliced Bread',5,55.00,24,10,1,'/uploads/products/product_1787837980787.jpg','2026-08-05 13:47:13','2026-08-27 21:39:40'),(58,'Cheese Bread',5,10.00,50,10,1,'/uploads/products/product_1787837390176.jpg','2026-08-05 13:47:13','2026-08-27 21:29:50'),(59,'Spanish Bread',5,10.00,48,10,1,'/uploads/products/product_1787838103442.jpg','2026-08-05 13:47:13','2026-08-27 21:41:43'),(60,'KitKat',6,35.00,30,10,1,'/uploads/products/product_1787838428810.jpg','2026-08-05 13:47:13','2026-08-27 21:47:08'),(61,'Snickers',6,45.00,26,10,1,'/uploads/products/product_1787838755265.jpg','2026-08-05 13:47:13','2026-08-27 21:52:35'),(62,'Twix',6,45.00,24,10,1,'/uploads/products/product_1787838902951.jpg','2026-08-05 13:47:13','2026-08-27 21:55:02'),(63,'M&M\'s',6,55.00,20,10,1,'/uploads/products/product_1787838579747.jpg','2026-08-05 13:47:13','2026-08-27 21:49:39'),(64,'Toblerone',6,95.00,7,10,1,'/uploads/products/product_1787838861688.jpg','2026-08-05 13:47:13','2026-08-31 12:50:38'),(65,'Cadbury Dairy Milk',6,75.00,16,10,1,'/uploads/products/product_1787838211783.jpg','2026-08-05 13:47:13','2026-08-27 21:43:31'),(66,'Cloud 9',6,12.00,60,10,1,'/uploads/products/product_1787838299343.jpg','2026-08-05 13:47:13','2026-08-27 21:44:59'),(67,'Chocnut',6,5.00,90,10,1,'/uploads/products/product_1787838257124.jpg','2026-08-05 13:47:13','2026-08-27 21:44:17'),(68,'Hany',6,5.00,85,10,1,'/uploads/products/product_1787838397827.jpg','2026-08-05 13:47:13','2026-08-27 21:46:37'),(69,'Mentos',6,20.00,40,10,1,'/uploads/products/product_1787838707441.jpg','2026-08-05 13:47:13','2026-08-27 21:51:47'),(70,'Maxx Candy',6,2.00,150,10,1,'/uploads/products/product_1787838654933.jpg','2026-08-05 13:47:13','2026-08-27 21:50:54'),(71,'White Rabbit',6,30.00,99,10,1,'/uploads/products/product_1787838956184.jpg','2026-08-05 13:47:13','2026-09-15 10:05:47'),(72,'Lollipops',6,3.00,120,10,1,'/uploads/products/product_1787838547610.jpg','2026-08-05 13:47:13','2026-08-27 21:49:07'),(73,'Bubble Gum',6,2.00,109,10,1,'/uploads/products/product_1787838176117.jpg','2026-08-05 13:47:13','2026-08-27 21:42:56'),(74,'Gummies',6,25.00,9,10,1,'/uploads/products/product_1787838342595.jpg','2026-08-05 13:47:13','2026-08-27 21:45:42'),(75,'Fresh Milk',7,85.00,20,10,1,'/uploads/products/product_1787840880300.jpg','2026-08-05 13:47:13','2026-08-27 22:28:00'),(76,'Chocolate Milk',7,45.00,26,10,1,'/uploads/products/product_1787840681491.jpg','2026-08-05 13:47:13','2026-08-27 22:24:41'),(77,'Yogurt',7,35.00,30,10,1,'/uploads/products/product_1787840995896.jpg','2026-08-05 13:47:13','2026-08-27 22:29:55'),(78,'Yakult',7,55.00,24,10,1,'/uploads/products/product_1787840943420.jpg','2026-08-05 13:47:13','2026-08-27 22:29:03'),(79,'Cheese',7,95.00,9,10,1,'/uploads/products/product_1787840573394.jpg','2026-08-05 13:47:13','2026-08-27 22:22:53'),(80,'Butter',7,75.00,15,10,1,'/uploads/products/product_1787840534019.jpg','2026-08-05 13:47:13','2026-08-27 22:22:14'),(81,'Evaporated Milk',7,32.00,40,10,1,'/uploads/products/product_1787840810437.jpg','2026-08-05 13:47:13','2026-08-27 22:26:50'),(82,'Condensed Milk',7,38.00,6,10,1,'/uploads/products/product_1787840743370.jpg','2026-08-05 13:47:13','2026-08-27 22:25:43'),(83,'Sugar',8,65.00,30,10,1,'/uploads/products/product_1787840391139.jpg','2026-08-05 13:47:13','2026-08-27 22:19:51'),(84,'Salt',8,20.00,45,10,1,'/uploads/products/product_1787840071570.jpg','2026-08-05 13:47:13','2026-08-27 22:14:31'),(85,'Cooking Oil',8,95.00,20,10,1,'/uploads/products/product_1787839735015.jpg','2026-08-05 13:47:13','2026-08-27 22:08:55'),(86,'Soy Sauce',8,20.00,35,10,1,'/uploads/products/product_1787840129835.jpg','2026-08-05 13:47:13','2026-08-27 22:15:29'),(87,'Vinegar',8,38.00,34,10,1,'/uploads/products/product_1787840482992.jpg','2026-08-05 13:47:13','2026-08-27 22:21:22'),(88,'Fish Sauce',8,22.00,28,10,1,'/uploads/products/product_1787839776913.jpg','2026-08-05 13:47:13','2026-08-27 22:09:36'),(89,'Oyster Sauce',8,45.00,9,10,1,'/uploads/products/product_1787840017138.jpg','2026-08-05 13:47:13','2026-08-27 22:13:37'),(90,'Banana Ketchup',8,30.00,32,10,1,'/uploads/products/product_1787839646404.jpg','2026-08-05 13:47:13','2026-08-27 22:07:26'),(91,'Tomato Ketchup',8,35.00,26,10,1,'/uploads/products/product_1787840443984.jpg','2026-08-05 13:47:13','2026-08-27 22:20:43'),(92,'Mayonnaise',8,75.00,14,10,1,'/uploads/products/product_1787839959340.jpg','2026-08-05 13:47:13','2026-08-27 22:12:39'),(93,'Black Pepper',8,15.00,40,10,1,'/uploads/products/product_1787839699786.jpg','2026-08-05 13:47:13','2026-08-27 22:08:19'),(94,'Flour',8,55.00,7,10,1,'/uploads/products/product_1787839858870.jpg','2026-08-05 13:47:13','2026-08-27 22:10:58'),(95,'Shampoo',9,8.00,100,10,1,'/uploads/products/product_1787846767291.jpg','2026-08-05 13:47:13','2026-08-28 00:06:07'),(96,'Conditioner',9,8.00,90,10,1,'/uploads/products/product_1787846162176.jpg','2026-08-05 13:47:13','2026-08-27 23:56:02'),(97,'Bath Soap',9,45.00,40,10,1,'/uploads/products/product_1787846061041.jpg','2026-08-05 13:47:13','2026-08-27 23:54:21'),(98,'Facial Soap',9,55.00,28,10,1,'/uploads/products/product_1787846241466.jpg','2026-08-05 13:47:13','2026-08-27 23:57:21'),(99,'Toothpaste',9,175.00,22,10,1,'/uploads/products/product_1787847003054.jpg','2026-08-05 13:47:13','2026-08-28 00:10:08'),(100,'Toothbrush',9,45.00,30,10,1,'/uploads/products/product_1787846911208.jpg','2026-08-05 13:47:13','2026-08-28 00:08:31'),(101,'Mouthwash',9,95.00,8,10,1,'/uploads/products/product_1787846535374.jpg','2026-08-05 13:47:13','2026-08-28 00:02:15'),(102,'Lotion',9,855.00,18,10,1,'/uploads/products/product_1787846495474.jpg','2026-08-05 13:47:13','2026-08-28 00:01:35'),(103,'Deodorant',9,65.00,24,10,1,'/uploads/products/product_1787846204494.jpg','2026-08-05 13:47:13','2026-08-27 23:56:44'),(104,'Facial Tissue',9,35.00,40,10,1,'/uploads/products/product_1787846337614.jpg','2026-08-05 13:47:13','2026-08-27 23:58:57'),(105,'Wet Wipes',9,45.00,32,10,1,'/uploads/products/product_1787847072808.jpg','2026-08-05 13:47:13','2026-08-28 00:11:12'),(106,'Hair Gel',9,55.00,9,10,1,'/uploads/products/product_1787846452143.jpg','2026-08-05 13:47:13','2026-08-28 00:00:52'),(107,'Hair Comb',9,20.00,50,10,1,'/uploads/products/product_1787846419229.jpg','2026-08-05 13:47:13','2026-08-28 00:00:19'),(108,'Shave',9,25.00,44,10,1,'/uploads/products/product_1787846721747.jpg','2026-08-05 13:47:13','2026-08-28 00:05:21'),(109,'Shaving Cream',9,85.00,12,10,1,'/uploads/products/product_1787846874324.jpg','2026-08-05 13:47:13','2026-08-28 00:07:54'),(110,'Paracetamol',10,5.00,60,10,1,'/uploads/products/product_1787842253254.jpg','2026-08-05 13:47:13','2026-08-27 22:50:53'),(111,'Ibuprofen',10,8.00,40,10,1,'/uploads/products/product_1787842162099.jpg','2026-08-05 13:47:13','2026-08-27 22:49:22'),(112,'Bioflu',10,10.00,6,10,1,'/uploads/products/product_1787841886494.jpg','2026-08-05 13:47:13','2026-08-27 22:44:46'),(113,'Neozep',10,8.00,45,10,1,'/uploads/products/product_1787842203739.jpg','2026-08-05 13:47:13','2026-08-27 22:50:03'),(114,'Enervon',10,12.00,30,10,1,'/uploads/products/product_1787842524770.jpg','2026-08-05 13:47:13','2026-08-27 22:55:24'),(115,'Ascorbic Acid',10,15.00,34,10,1,'/uploads/products/product_1787842443671.jpg','2026-08-05 13:47:13','2026-08-27 22:54:03'),(116,'Alcohol',10,55.00,19,10,1,'/uploads/products/product_1787841726821.jpg','2026-08-05 13:47:13','2026-08-31 13:30:15'),(117,'Hand Sanitizer',10,45.00,26,10,1,'/uploads/products/product_1787842121232.jpg','2026-08-05 13:47:13','2026-08-27 22:48:41'),(118,'Cotton Balls',10,35.00,40,10,1,'/uploads/products/product_1787841974027.jpg','2026-08-05 13:47:13','2026-08-27 22:46:14'),(119,'Cotton Buds',10,25.00,50,10,1,'/uploads/products/product_1787842010954.jpg','2026-08-05 13:47:13','2026-08-27 22:46:50'),(120,'Bandages',10,45.00,9,10,1,'/uploads/products/product_1787841810151.jpg','2026-08-05 13:47:13','2026-08-27 22:43:30'),(121,'Face Masks',10,3.00,200,10,1,'/uploads/products/product_1787842050853.jpg','2026-08-05 13:47:13','2026-08-27 22:47:30'),(122,'Pregnancy Test Kit',10,65.00,15,10,1,'/uploads/products/product_1787842352871.jpg','2026-08-05 13:47:13','2026-08-27 22:52:32'),(123,'Condoms',10,85.00,2,10,1,'/uploads/products/product_1787841929935.jpg','2026-08-05 13:47:13','2026-09-17 08:14:10'),(124,'Personal Lubricants',10,120.00,9,10,1,'/uploads/products/product_1787842302838.jpg','2026-08-05 13:47:13','2026-08-28 00:46:12'),(125,'Laundry Detergent',11,20.00,60,10,1,'/uploads/products/product_1787843040694.jpg','2026-08-05 13:47:13','2026-08-27 23:04:00'),(126,'Fabric Conditioner',11,12.00,55,10,1,'/uploads/products/product_1787842821138.jpg','2026-08-05 13:47:13','2026-08-27 23:00:21'),(127,'Dishwashing Liquid',11,25.00,38,10,1,'/uploads/products/product_1787842725022.jpg','2026-08-05 13:47:13','2026-08-27 22:58:45'),(128,'Bleach',11,45.00,24,10,1,'/uploads/products/product_1787842670730.jpg','2026-08-05 13:47:13','2026-08-27 22:57:50'),(129,'Floor Cleaner',11,165.00,9,10,1,'/uploads/products/product_1787842872808.jpg','2026-08-05 13:47:13','2026-08-27 23:01:12'),(130,'Air Freshener',11,85.00,16,10,1,'/uploads/products/product_1787842560741.jpg','2026-08-05 13:47:13','2026-08-27 22:56:00'),(131,'Tissue Paper',11,45.00,40,10,1,'/uploads/products/product_1787843238693.jpg','2026-08-05 13:47:13','2026-08-27 23:07:18'),(132,'Paper Towels',11,55.00,28,10,1,'/uploads/products/product_1787843089454.jpg','2026-08-05 13:47:13','2026-08-27 23:04:49'),(133,'Trash Bags',11,35.00,34,10,1,'/uploads/products/product_1787843339545.jpg','2026-08-05 13:47:13','2026-08-27 23:08:59'),(134,'Sponges',11,20.00,50,10,1,'/uploads/products/product_1787843176506.jpg','2026-08-05 13:47:13','2026-08-27 23:06:16'),(135,'Toilet Cleaner',11,175.00,8,10,1,'/uploads/products/product_1787843287058.jpg','2026-08-05 13:47:13','2026-08-27 23:08:07'),(136,'Insect Spray',11,145.00,14,10,1,'/uploads/products/product_1787842971902.jpg','2026-08-05 13:47:13','2026-08-27 23:02:51'),(137,'Baby Diapers',12,120.00,20,10,1,'/uploads/products/product_1787836919220.jpg','2026-08-05 13:47:13','2026-08-27 21:21:59'),(138,'Baby Wipes',12,65.00,26,10,1,'/uploads/products/product_1787837162101.jpg','2026-08-05 13:47:13','2026-08-27 21:26:02'),(139,'Baby Powder',12,55.00,24,10,1,'/uploads/products/product_1787837038991.jpg','2026-08-05 13:47:13','2026-08-27 21:23:58'),(140,'Baby Lotion',12,75.00,50,10,1,'/uploads/products/product_1787836959411.jpg','2026-08-05 13:47:13','2026-08-28 12:20:02'),(141,'Baby Shampoo',12,85.00,18,10,1,'/uploads/products/product_1787837078674.jpg','2026-08-05 13:47:13','2026-08-27 21:24:38'),(142,'Baby Soap',12,45.00,30,10,1,'/uploads/products/product_1787837113215.jpg','2026-08-05 13:47:13','2026-08-27 21:25:13'),(143,'Baby Milk Formula',12,285.00,12,10,1,'/uploads/products/product_1787836999900.jpg','2026-08-05 13:47:13','2026-08-27 21:23:19'),(144,'Feeding Bottles',12,145.00,58,10,1,'/uploads/products/product_1787837206583.jpg','2026-08-05 13:47:13','2026-08-28 12:20:19'),(145,'Ballpen',13,12.00,100,10,1,'/uploads/products/product_1787847201923.jpg','2026-08-05 13:47:13','2026-08-28 00:13:21'),(146,'Pencil',13,8.00,90,10,1,'/uploads/products/product_1787847824779.jpg','2026-08-05 13:47:13','2026-08-28 00:23:44'),(147,'Eraser',13,5.00,80,10,1,'/uploads/products/product_1787847355430.jpg','2026-08-05 13:47:13','2026-08-28 00:15:55'),(148,'Sharpener',13,10.00,60,10,1,'/uploads/products/product_1787847935827.jpg','2026-08-05 13:47:13','2026-08-28 00:25:35'),(149,'Notebook',13,25.00,40,10,1,'/uploads/products/product_1787847755062.jpg','2026-08-05 13:47:13','2026-08-28 00:22:35'),(150,'Bond Paper',13,185.00,15,10,1,'/uploads/products/product_1787847243979.jpg','2026-08-05 13:47:13','2026-08-28 00:14:03'),(151,'Marker',13,35.00,30,10,1,'/uploads/products/product_1787847709811.jpg','2026-08-05 13:47:13','2026-08-28 00:21:49'),(152,'Highlighter',13,40.00,9,10,1,'/uploads/products/product_1787847550268.jpg','2026-08-05 13:47:13','2026-08-28 00:19:10'),(153,'Glue',13,25.00,44,10,1,'/uploads/products/product_1787847501399.jpg','2026-08-05 13:47:13','2026-08-28 00:18:21'),(154,'Scissors',13,45.00,28,10,1,'/uploads/products/product_1787847896341.jpg','2026-08-05 13:47:13','2026-08-28 00:24:56'),(155,'Tape',13,20.00,50,10,1,'/uploads/products/product_1787848041371.jpg','2026-08-05 13:47:13','2026-08-28 00:27:21'),(156,'Envelope',13,15.00,120,10,1,'/uploads/products/product_1787847322607.jpg','2026-08-05 13:47:13','2026-08-28 00:15:22'),(157,'Stapler',13,85.00,6,10,1,'/uploads/products/product_1787847986979.jpg','2026-08-05 13:47:13','2026-08-28 00:26:26'),(158,'Ice Cream',14,185.00,10,10,1,'/uploads/products/product_1787841646705.jpg','2026-08-05 13:47:13','2026-08-27 22:40:46'),(159,'Ice Pops',14,8.00,80,10,1,'/uploads/products/product_1787841685111.jpg','2026-08-05 13:47:13','2026-08-27 22:41:25'),(160,'Frozen Hotdog',14,75.00,22,10,1,'/uploads/products/product_1787841280660.jpg','2026-08-05 13:47:13','2026-08-27 22:34:40'),(161,'Frozen Nuggets',14,145.00,16,10,1,'/uploads/products/product_1787841457651.jpg','2026-08-05 13:47:13','2026-08-27 22:37:37'),(162,'Frozen Fries',14,95.00,9,10,1,'/uploads/products/product_1787841185051.jpg','2026-08-05 13:47:13','2026-08-27 22:33:05'),(163,'Frozen Siomai',14,120.00,18,10,1,'/uploads/products/product_1787841522637.jpg','2026-08-05 13:47:13','2026-08-27 22:38:42'),(164,'Frozen Tocino',14,85.00,24,10,1,'/uploads/products/product_1787841580624.jpg','2026-08-05 13:47:13','2026-08-27 22:39:40'),(165,'Frozen Longanisa',14,90.00,7,10,1,'/uploads/products/product_1787841393531.jpg','2026-08-05 13:47:13','2026-08-27 22:36:33'),(166,'Frozen Burger Pattie',14,165.00,14,10,1,'/uploads/products/product_1787841113801.jpg','2026-08-05 13:47:13','2026-08-27 22:31:53'),(167,'AA Batteries',15,45.00,40,10,1,'/uploads/products/product_1787843832922.jpg','2026-08-05 13:47:13','2026-08-27 23:17:12'),(168,'AAA Batteries',15,45.00,8,10,1,'/uploads/products/product_1787843871457.jpg','2026-08-05 13:47:13','2026-08-27 23:17:51'),(169,'Phone Charger Type C',15,185.00,20,10,1,'/uploads/products/product_1787844643300.jpg','2026-08-05 13:47:13','2026-08-27 23:30:43'),(170,'USB Cable',15,195.00,26,10,1,'/uploads/products/product_1787844921703.jpg','2026-08-05 13:47:13','2026-08-27 23:35:28'),(171,'Earphones',15,145.00,18,10,1,'/uploads/products/product_1787844171027.jpg','2026-08-05 13:47:13','2026-08-27 23:22:51'),(172,'Flash Drive',15,285.00,12,10,1,'/uploads/products/product_1787844368848.jpg','2026-08-05 13:47:13','2026-08-27 23:26:08'),(173,'Lighter',15,15.00,60,10,1,'/uploads/products/product_1787844498507.jpg','2026-08-05 13:47:13','2026-08-27 23:28:18'),(174,'Umbrella',15,165.00,9,10,1,'/uploads/products/product_1787844862162.jpg','2026-08-05 13:47:13','2026-08-27 23:34:22'),(175,'Diving Mask',15,300.00,150,10,1,'/uploads/products/product_1787844331366.jpg','2026-08-05 13:47:13','2026-08-27 23:25:31'),(176,'Disposable Plastic Gloves',15,65.00,30,10,1,'/uploads/products/product_1787844122959.jpg','2026-08-05 13:47:13','2026-08-27 23:22:02'),(177,'Gift Wrap',15,25.00,40,10,1,'/uploads/products/product_1787844452913.jpg','2026-08-05 13:47:13','2026-08-27 23:27:32'),(178,'Balloons',15,15.00,50,10,1,'/uploads/products/product_1787843979864.jpg','2026-08-05 13:47:13','2026-08-27 23:19:39'),(179,'Candles',15,20.00,44,10,1,'/uploads/products/product_1787844038107.jpg','2026-08-05 13:47:13','2026-08-27 23:20:38'),(180,'Matches',15,3.00,100,10,1,'/uploads/products/product_1787844577444.jpg','2026-08-05 13:47:13','2026-08-27 23:29:37'),(181,'Power Bank',15,375.00,200,10,1,'/uploads/products/product_1787844751825.jpg','2026-08-05 13:47:13','2026-08-27 23:32:47'),(182,'555 Tuna',4,40.00,20,10,1,'/uploads/products/product_1787839019491.jpg','2026-08-05 13:56:54','2026-08-27 21:56:59'),(183,'Tattoos Chips',1,15.00,20,10,1,'/uploads/products/product_1787848840818.jpg','2026-08-05 15:50:04','2026-08-28 00:40:40'),(184,'San Miguel Pale Pilsen Can',16,53.00,50,10,1,'/uploads/products/product_1787836722145.jpg','2026-08-05 16:12:55','2026-08-27 21:18:42'),(185,'San Miguel Pale Pilsen',16,72.00,50,10,1,'/uploads/products/product_1787836674506.jpg','2026-08-05 16:12:55','2026-08-27 21:17:54'),(186,'San Miguel Grande',16,145.00,35,10,1,'/uploads/products/product_1787828844180.jpg','2026-08-05 16:12:55','2026-09-17 08:20:49'),(187,'San Mig Light',16,62.00,49,10,1,'/uploads/products/product_1787827966760.jpg','2026-08-05 16:12:55','2026-08-27 18:52:46'),(188,'San Mig Light Can',16,72.00,50,10,1,'/uploads/products/product_1787828029754.jpg','2026-08-05 16:12:55','2026-08-27 18:53:49'),(189,'Red Horse Stallion',16,56.00,49,10,1,'/uploads/products/product_1787827846747.jpg','2026-08-05 16:12:55','2026-08-27 18:50:46'),(190,'Red Horse Can',16,69.00,50,10,1,'/uploads/products/product_1787827286876.jpg','2026-08-05 16:12:55','2026-08-27 18:41:26'),(191,'Red Horse',16,72.00,50,10,1,'/uploads/products/product_1787827797037.png','2026-08-05 16:12:55','2026-08-27 18:49:57'),(192,'Red Horse Can 1L',16,98.00,50,10,1,'/uploads/products/product_1787827675396.jpg','2026-08-05 16:12:55','2026-08-27 18:47:55'),(193,'Red Horse 1L',16,136.00,31,10,1,'/uploads/products/product_1787797392959.jpg','2026-08-05 16:12:55','2026-09-15 10:05:47'),(194,'Red Horse Super Extr',16,145.00,50,10,1,'/uploads/products/product_1787827907546.jpg','2026-08-05 16:12:55','2026-08-27 18:51:47'),(195,'San Miguel Super Dry',16,85.00,50,10,1,'/uploads/products/product_1787836867264.jpg','2026-08-05 16:12:55','2026-08-27 21:21:07'),(196,'San Miguel Premium All Malt',16,89.00,50,10,1,'/uploads/products/product_1787836806972.jpg','2026-08-05 16:12:55','2026-08-27 21:20:06'),(197,'San Miguel Cerveza Blanca',16,92.00,50,10,1,'/uploads/products/product_1787828615525.jpg','2026-08-05 16:12:55','2026-08-27 19:03:35'),(198,'San Miguel Cerveza Negra',16,92.00,50,10,1,'/uploads/products/product_1787828534303.jpg','2026-08-05 16:12:55','2026-08-27 19:02:14'),(199,'San Miguel Chocolate Lager Can',16,92.00,50,10,1,'/uploads/products/product_1787828735645.jpg','2026-08-05 16:12:55','2026-08-27 19:05:35'),(200,'San Miguel Apple Flavor',16,51.00,50,10,1,'/uploads/products/product_1787829019405.jpg','2026-08-05 16:12:55','2026-08-27 19:10:19'),(201,'San Miguel Apple Flavor Can',16,66.00,50,10,1,'/uploads/products/product_1787828397050.jpg','2026-08-05 16:12:55','2026-08-27 18:59:57'),(202,'San Miguel Lemon Flavor',16,51.00,50,10,1,'/uploads/products/product_1787828933211.png','2026-08-05 16:12:55','2026-08-27 19:08:53'),(203,'San Miguel Lemon Flavor Can',16,66.00,50,10,1,'/uploads/products/product_1787829101614.jpg','2026-08-05 16:12:55','2026-08-27 19:11:41'),(204,'San Mig Lychee',16,51.00,50,10,1,'/uploads/products/product_1787828116881.png','2026-08-05 16:12:55','2026-08-27 18:55:16'),(205,'San Mig Lychee Can',16,66.00,50,10,1,'/uploads/products/product_1787828172504.jpg','2026-08-05 16:12:55','2026-08-27 18:56:12'),(206,'San Miguel Mango Yuzu',16,92.00,50,10,1,'/uploads/products/product_1787836551731.jpg','2026-08-05 16:12:55','2026-08-27 21:15:51'),(207,'Kirin Beer',16,103.00,50,10,1,'/uploads/products/product_1787797175455.jpg','2026-08-05 16:12:55','2026-08-27 10:19:35'),(208,'Kirin Ichiban',16,103.00,50,10,1,'/uploads/products/product_1787797182680.jpg','2026-08-05 16:12:55','2026-08-27 10:19:42'),(209,'Asahi Super Dry',16,102.00,70,10,1,'/uploads/products/product_1787796952239.jpg','2026-08-05 16:12:55','2026-08-28 11:37:30'),(210,'Oishi Crispy Patata',1,15.00,28,10,1,'/uploads/products/product_1787848478887.jpg','2026-08-05 16:30:44','2026-08-31 14:08:02'),(211,'Cheese Ring',1,15.00,45,10,1,'/uploads/products/product_1788154133102.jpg','2026-08-31 13:28:53','2026-08-31 13:29:43'),(212,'Super Crunch',1,18.00,65,10,1,'/uploads/products/product_1788158438679.jpg','2026-08-31 14:40:14','2026-08-31 14:41:44');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `return_items`
--

DROP TABLE IF EXISTS `return_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `return_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `return_id` int(10) unsigned NOT NULL,
  `transaction_item_id` int(10) unsigned NOT NULL,
  `product_id` int(10) unsigned NOT NULL,
  `product_name` varchar(200) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `refund_amount` decimal(10,2) NOT NULL,
  `restock` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `return_id` (`return_id`),
  KEY `transaction_item_id` (`transaction_item_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `return_items_ibfk_1` FOREIGN KEY (`return_id`) REFERENCES `returns` (`id`) ON DELETE CASCADE,
  CONSTRAINT `return_items_ibfk_2` FOREIGN KEY (`transaction_item_id`) REFERENCES `transaction_items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `return_items_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `return_items`
--

LOCK TABLES `return_items` WRITE;
/*!40000 ALTER TABLE `return_items` DISABLE KEYS */;
INSERT INTO `return_items` VALUES (2,2,25,186,'San Miguel Grande',1,145.00,145.00,1),(3,3,27,193,'Red Horse 1L',1,136.00,136.00,1),(4,4,4,123,'Condoms',1,85.00,85.00,1);
/*!40000 ALTER TABLE `return_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `returns`
--

DROP TABLE IF EXISTS `returns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `returns` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `return_no` varchar(30) NOT NULL,
  `transaction_id` int(10) unsigned NOT NULL,
  `customer_id` int(10) unsigned NOT NULL,
  `status` enum('Pending','Approved','Rejected','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  `reason` varchar(100) NOT NULL,
  `customer_notes` text,
  `admin_notes` text,
  `refund_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `processed_by` int(10) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `return_no` (`return_no`),
  KEY `transaction_id` (`transaction_id`),
  KEY `customer_id` (`customer_id`),
  KEY `processed_by` (`processed_by`),
  CONSTRAINT `returns_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `returns_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `returns_ibfk_3` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `returns`
--

LOCK TABLES `returns` WRITE;
/*!40000 ALTER TABLE `returns` DISABLE KEYS */;
INSERT INTO `returns` VALUES (2,'RET-2026-0001',39,22,'Completed','Defective / Damaged','Opened bottle, broken safety seal.','Inspected at counter, refund released in cash.',145.00,1,'2026-09-17 08:20:49','2026-09-17 08:20:49'),(3,'RET-2026-0002',41,23,'Completed','Changed Mind / Dissatisfied','Namali og Palit','Thanks',136.00,20,'2026-09-17 08:23:09','2026-09-17 08:24:26'),(4,'RET-2026-0003',2,22,'Rejected','Expired Product','Expired','Fake',85.00,20,'2026-09-17 08:44:12','2026-09-17 08:48:17');
/*!40000 ALTER TABLE `returns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `staff` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `staff_code` varchar(20) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `role` varchar(50) NOT NULL DEFAULT 'Cashier',
  `temp_password` varchar(255) DEFAULT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `joined_at` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `staff_code` (`staff_code`),
  CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (1,2,'STF001','Misa Amane','Cashier','cashier143','Active','2026-08-05','2026-08-05 14:57:06'),(2,20,'STF002','Light Yagami','Cashier',NULL,'Active',NULL,'2026-08-31 14:44:12');
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_settings`
--

DROP TABLE IF EXISTS `store_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `store_settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_settings`
--

LOCK TABLES `store_settings` WRITE;
/*!40000 ALTER TABLE `store_settings` DISABLE KEYS */;
INSERT INTO `store_settings` VALUES (1,'store_name','SmartMart','2026-08-05 13:11:23'),(2,'store_address','Zamora, Bilar, Bohol','2026-08-05 13:11:23'),(3,'store_contact','09704972414','2026-08-05 13:11:23'),(4,'store_email','mikegamingfromyt@gmail.com','2026-09-09 09:18:39'),(5,'store_hours','8:00 AM  - 10:00 PM','2026-08-31 13:35:07'),(6,'tax_rate','12','2026-08-05 13:11:23'),(7,'low_stock_threshold','10','2026-08-05 13:11:23'),(8,'receipt_footer','Thank you for shopping at SmartMart!','2026-08-05 13:11:23');
/*!40000 ALTER TABLE `store_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_items`
--

DROP TABLE IF EXISTS `transaction_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` int(10) unsigned NOT NULL,
  `product_id` int(10) unsigned NOT NULL,
  `product_name` varchar(200) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `transaction_items_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transaction_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_items`
--

LOCK TABLES `transaction_items` WRITE;
/*!40000 ALTER TABLE `transaction_items` DISABLE KEYS */;
INSERT INTO `transaction_items` VALUES (1,1,209,'Asahi Super Dry',102.00,1,102.00),(2,1,189,'Red Horse Stallion',56.00,1,56.00),(3,1,187,'San Mig Light',62.00,1,62.00),(4,2,123,'Condoms',85.00,5,425.00),(5,3,73,'Bubble Gum',2.00,1,2.00),(6,4,123,'Condoms',85.00,5,425.00),(7,4,124,'Personal Lubricants',120.00,1,120.00),(8,5,123,'Condoms',85.00,1,85.00),(9,6,8,'Nagaraya Peanuts',15.00,2,30.00),(10,7,32,'Lucky Me Pancit Canton',15.00,2,30.00),(11,13,64,'Toblerone',95.00,1,95.00),(12,14,211,'Cheese Ring',15.00,5,75.00),(13,15,116,'Alcohol',55.00,1,55.00),(14,16,193,'Red Horse 1L',136.00,6,816.00),(15,17,36,'Samyang Noodles',85.00,3,255.00),(16,18,12,'Pringles',110.00,1,110.00),(17,19,7,'Ding Dong Mixed Nuts',18.00,1,18.00),(18,19,210,'Oishi Crispy Patata',15.00,2,30.00),(19,19,6,'Oishi Prawn Crackers',12.00,3,36.00),(20,20,212,'Super Crunch',18.00,5,90.00),(21,21,212,'Super Crunch',18.00,10,180.00),(22,22,41,'555 Sardines',22.00,1,22.00),(23,23,186,'San Miguel Grande',145.00,10,1450.00),(24,38,123,'Condoms',85.00,9,765.00),(25,39,186,'San Miguel Grande',145.00,6,870.00),(26,40,193,'Red Horse 1L',136.00,12,1632.00),(27,41,193,'Red Horse 1L',136.00,1,136.00),(28,41,50,'Gardenia Bread',65.00,1,65.00),(29,41,71,'White Rabbit',30.00,1,30.00);
/*!40000 ALTER TABLE `transaction_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `receipt_no` varchar(30) NOT NULL,
  `customer_id` int(10) unsigned DEFAULT NULL,
  `cashier_id` int(10) unsigned NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `cash_tendered` decimal(10,2) NOT NULL,
  `change_amount` decimal(10,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_method` varchar(50) NOT NULL DEFAULT 'Cash',
  `status` enum('Completed','Cancelled','Voided') NOT NULL DEFAULT 'Completed',
  PRIMARY KEY (`id`),
  UNIQUE KEY `receipt_no` (`receipt_no`),
  KEY `customer_id` (`customer_id`),
  KEY `cashier_id` (`cashier_id`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`cashier_id`) REFERENCES `staff` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,'TRX-2026-0001',NULL,1,220.00,500.00,280.00,'2026-08-13 18:01:04','Cash','Completed'),(2,'TRX-2026-0002',22,1,425.00,500.00,75.00,'2026-08-13 18:01:55','Cash','Completed'),(3,'TRX-2026-0003',24,1,2.00,5.00,3.00,'2026-08-18 11:25:14','Cash','Completed'),(4,'TRX-2026-0004',22,1,545.00,1000.00,455.00,'2026-08-28 00:46:12','Cash','Completed'),(5,'TRX-2026-0005',23,1,85.00,100.00,15.00,'2026-08-28 00:46:33','Cash','Completed'),(6,'TRX-2026-0006',24,1,30.00,50.00,20.00,'2026-08-28 11:53:50','Cash','Completed'),(7,'TRX-2026-0007',24,1,30.00,50.00,20.00,'2026-08-28 12:01:35','Cash','Completed'),(13,'TRX-2026-0008',24,1,95.00,100.00,5.00,'2026-08-31 12:50:38','Cash','Completed'),(14,'TRX-2026-0009',25,1,75.00,100.00,25.00,'2026-08-31 13:29:43','Cash','Completed'),(15,'TRX-2026-0010',24,1,55.00,100.00,45.00,'2026-08-31 13:30:15','Cash','Completed'),(16,'TRX-2026-0011',22,1,816.00,1000.00,184.00,'2026-08-31 13:30:46','Cash','Completed'),(17,'TRX-2026-0012',23,1,255.00,300.00,45.00,'2026-08-31 13:31:57','Cash','Completed'),(18,'TRX-2026-0013',NULL,1,110.00,150.00,40.00,'2026-08-31 14:06:37','Cash','Completed'),(19,'TRX-2026-0014',24,1,84.00,100.00,16.00,'2026-08-31 14:08:02','Cash','Completed'),(20,'TRX-2026-0015',NULL,1,90.00,100.00,10.00,'2026-08-31 14:41:27','Cash','Completed'),(21,'TRX-2026-0016',24,1,180.00,500.00,320.00,'2026-08-31 14:41:44','Cash','Completed'),(22,'TRX-2026-0017',23,2,22.00,50.00,28.00,'2026-08-31 14:45:08','Cash','Completed'),(23,'TRX-2026-0018',23,2,1450.00,1500.00,50.00,'2026-09-09 09:13:04','Cash','Completed'),(38,'TRX-2026-0019',NULL,2,765.00,1000.00,235.00,'2026-09-09 09:15:11','Cash','Completed'),(39,'TRX-2026-0020',22,2,870.00,1000.00,130.00,'2026-09-09 09:16:15','Cash','Completed'),(40,'TRX-2026-0021',24,2,1632.00,2000.00,368.00,'2026-09-09 09:17:15','Cash','Completed'),(41,'TRX-2026-0022',23,2,231.00,500.00,269.00,'2026-09-15 10:05:47','Cash','Completed');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `full_name` varchar(150) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','staff','customer') NOT NULL DEFAULT 'customer',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','Administrator','$2a$10$mbsY9o8ziOzY4g0HY73fAOaRYL8/neefl5qxg4FNSdx4H7uADi9Sy','admin',1,'2026-08-05 13:11:23','2026-08-13 17:38:39'),(2,'misaamane','Misa Amane','$2a$10$onVbi98aM1ldsrE0sxtTKeygvQXrUkvyEY8/dDh9YjF0f04JnYOEe','staff',1,'2026-08-05 14:57:06','2026-08-31 15:01:28'),(16,'jhoneligcalinos','Jhonel Budlat Igcalinos','$2a$10$xCjOQdteMwLxUYr..G8eWeLvLLB1kAc1yjVlFahrtfVMtRLupCMhW','customer',1,'2026-08-05 18:57:30','2026-08-13 17:38:39'),(17,'markmanla','Mark Jaime Manla','$2a$10$8O8Db0edq1OUXy8SPbLRLeB/88EKYqESGZY3biL7PVypWI2fdYA9O','customer',1,'2026-08-13 18:26:30','2026-08-13 18:27:13'),(18,'mikegerald','Mike Gerald Sericon Bacasmas','$2a$10$ksZnwozrNOCzLznt0t13Se5hX0jUsa.mNN0JyNfrldwMMyDDUFdjS','customer',1,'2026-08-18 09:16:52','2026-08-18 11:24:01'),(19,'diplodump','Diplo Dump','$2a$10$N/FfipgI38x3hX8YWImSWODVkGJfOjdyTOMuChz3LwHsOFVNxefqO','customer',1,'2026-08-31 12:54:45','2026-08-31 12:54:45'),(20,'lightyagami','Light Yagami','$2a$10$tZ4UuWXSgK7.50DA65fDHeQkgdtWKn5Txp/3MCBS1JaRroHzGiEIe','staff',1,'2026-08-31 14:44:12','2026-08-31 15:02:03'),(21,'cjtuba','CJ Manla Tuba','$2a$10$rCkCNaWG.tyfJWfGd4KOGemF4VzovOi8e8BVEys78mTqPyiMF1L42','customer',1,'2026-09-02 10:58:00','2026-09-02 11:04:00');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'sm'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_add_transaction_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_add_transaction_item`(
  IN p_transaction_id INT UNSIGNED,
  IN p_product_id     INT UNSIGNED,
  IN p_quantity       INT
)
BEGIN
  DECLARE v_price      DECIMAL(10,2);
  DECLARE v_name       VARCHAR(200);
  DECLARE v_subtotal   DECIMAL(10,2);
  DECLARE v_stock      INT;

  SELECT price, name, stock INTO v_price, v_name, v_stock
  FROM products WHERE id = p_product_id FOR UPDATE;

  IF v_stock < p_quantity THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
  END IF;

  SET v_subtotal = v_price * p_quantity;

  INSERT INTO transaction_items
    (transaction_id, product_id, product_name, unit_price, quantity, subtotal)
  VALUES
    (p_transaction_id, p_product_id, v_name, v_price, p_quantity, v_subtotal);

  
  UPDATE products SET stock = stock - p_quantity WHERE id = p_product_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_approve_customer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_approve_customer`(
        IN p_customer_id INT UNSIGNED,
        IN p_username    VARCHAR(100),
        IN p_password    VARCHAR(255),
        IN p_temp_password VARCHAR(255)
      )
BEGIN
        DECLARE v_user_id     INT UNSIGNED;
        DECLARE v_count       INT;
        DECLARE v_cust_code   VARCHAR(20);
        DECLARE v_first_name  VARCHAR(100);
        DECLARE v_middle_name VARCHAR(100);
        DECLARE v_last_name   VARCHAR(100);
        DECLARE v_full_name   VARCHAR(255);

        SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
        IF v_count > 0 THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
        END IF;

        SELECT first_name, middle_name, last_name
        INTO   v_first_name, v_middle_name, v_last_name
        FROM   customers
        WHERE  id = p_customer_id AND account_status = 'Pending';

        IF v_first_name IS NULL THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pending customer record not found';
        END IF;

        SET v_full_name = TRIM(CONCAT(v_first_name, IF(v_middle_name IS NOT NULL AND v_middle_name != '', CONCAT(' ', v_middle_name), ''), ' ', v_last_name));

        INSERT INTO users (username, password, full_name, role)
        VALUES (p_username, p_password, v_full_name, 'customer');

        SET v_user_id = LAST_INSERT_ID();

        SELECT CONCAT('CUS', LPAD(
          (SELECT COUNT(*) FROM customers WHERE account_status = 'Approved') + 1, 3, '0'
        )) INTO v_cust_code;

        UPDATE customers
        SET user_id        = v_user_id,
            customer_code  = v_cust_code,
            account_status = 'Approved',
            approved_at    = NOW(),
            temp_password  = p_temp_password
        WHERE id = p_customer_id;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_category` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_create_category`(
        IN p_name VARCHAR(100)
      )
BEGIN
        DECLARE v_count INT;
        SELECT COUNT(*) INTO v_count FROM categories WHERE name = p_name;
        IF v_count > 0 THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category already exists';
        END IF;

        INSERT INTO categories (name) VALUES (p_name);
        SELECT LAST_INSERT_ID() AS category_id, p_name AS name;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_product` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_create_product`(
        IN p_name        VARCHAR(200),
        IN p_category_id INT UNSIGNED,
        IN p_price       DECIMAL(10,2),
        IN p_stock       INT
      )
BEGIN
        INSERT INTO products (name, category_id, price, stock)
        VALUES (p_name, p_category_id, p_price, p_stock);
        SELECT LAST_INSERT_ID() AS product_id, p_name AS name, p_category_id AS category_id, p_price AS price, p_stock AS stock;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_staff` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_create_staff`(
        IN p_username      VARCHAR(100),
        IN p_password      VARCHAR(255),
        IN p_full_name     VARCHAR(150),
        IN p_role          VARCHAR(50),
        IN p_temp_password VARCHAR(255)
      )
BEGIN
        DECLARE v_user_id    INT UNSIGNED;
        DECLARE v_count      INT;
        DECLARE v_staff_code VARCHAR(20);
        DECLARE v_staff_id   INT UNSIGNED;

        SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username;
        IF v_count > 0 THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
        END IF;

        INSERT INTO users (username, password, full_name, role)
        VALUES (p_username, p_password, p_full_name, 'staff');
        SET v_user_id = LAST_INSERT_ID();

        SELECT CONCAT('STF', LPAD(COUNT(*) + 1, 3, '0')) INTO v_staff_code FROM staff;

        INSERT INTO staff (user_id, staff_code, full_name, role)
        VALUES (v_user_id, v_staff_code, p_full_name, p_role);
        SET v_staff_id = LAST_INSERT_ID();

        SELECT v_staff_id AS id,
               v_staff_code AS staff_code,
               p_full_name AS full_name,
               p_username AS username,
               p_role AS role,
               'Active' AS status,
               DATE_FORMAT(NOW(), '%b %d, %Y') AS joined,
               p_temp_password AS temp_password;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_transaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_create_transaction`(
  IN  p_customer_id   INT UNSIGNED,   
  IN  p_cashier_id    INT UNSIGNED,
  IN  p_cash_tendered DECIMAL(10,2),
  OUT p_transaction_id INT UNSIGNED,
  OUT p_receipt_no    VARCHAR(30)
)
BEGIN
  DECLARE v_seq INT;
  SELECT COUNT(*) + 1 INTO v_seq FROM transactions WHERE YEAR(created_at) = YEAR(NOW());
  SET p_receipt_no = CONCAT('TRX-', YEAR(NOW()), '-', LPAD(v_seq, 4, '0'));

  INSERT INTO transactions (receipt_no, customer_id, cashier_id, total_amount, cash_tendered, change_amount)
  VALUES (p_receipt_no, p_customer_id, p_cashier_id, 0, p_cash_tendered, 0);

  SET p_transaction_id = LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_transaction_header` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_create_transaction_header`(
        IN p_customer_id    INT UNSIGNED,
        IN p_cashier_id     INT UNSIGNED,
        IN p_cash_tendered  DECIMAL(10,2),
        IN p_payment_method VARCHAR(50)
      )
BEGIN
        DECLARE v_seq INT;
        DECLARE v_receipt_no VARCHAR(30);
        DECLARE v_payment VARCHAR(50);
        DECLARE v_resolved_cashier INT UNSIGNED;

        -- Resolve staff_id if user_id was passed
        SELECT id INTO v_resolved_cashier FROM staff WHERE user_id = p_cashier_id LIMIT 1;
        IF v_resolved_cashier IS NULL THEN
          SELECT id INTO v_resolved_cashier FROM staff WHERE id = p_cashier_id LIMIT 1;
        END IF;

        IF v_resolved_cashier IS NULL THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid cashier: no staff record found';
        END IF;

        SET v_payment = IF(p_payment_method IS NULL OR p_payment_method = '', 'Cash', p_payment_method);
        SELECT COUNT(*) + 1 INTO v_seq FROM transactions WHERE YEAR(created_at) = YEAR(NOW());
        SET v_receipt_no = CONCAT('TRX-', YEAR(NOW()), '-', LPAD(v_seq, 4, '0'));

        INSERT INTO transactions (receipt_no, customer_id, cashier_id, total_amount, cash_tendered, change_amount, payment_method)
        VALUES (v_receipt_no, p_customer_id, v_resolved_cashier, 0, p_cash_tendered, 0, v_payment);

        SELECT LAST_INSERT_ID() AS transaction_id, v_receipt_no AS receipt_no;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_deny_customer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_deny_customer`(IN p_customer_id INT UNSIGNED)
BEGIN
  UPDATE customers SET account_status = 'Denied' WHERE id = p_customer_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_finalize_transaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_finalize_transaction`(IN p_transaction_id INT UNSIGNED)
BEGIN
  DECLARE v_total      DECIMAL(10,2);
  DECLARE v_tendered   DECIMAL(10,2);

  SELECT SUM(subtotal) INTO v_total
  FROM transaction_items WHERE transaction_id = p_transaction_id;

  SELECT cash_tendered INTO v_tendered
  FROM transactions WHERE id = p_transaction_id;

  UPDATE transactions
  SET total_amount  = v_total,
      change_amount = v_tendered - v_total
  WHERE id = p_transaction_id;

  SELECT t.id, t.receipt_no, t.total_amount, t.cash_tendered, t.change_amount,
         t.created_at, s.full_name AS cashier
  FROM transactions t
  JOIN staff s ON s.id = t.cashier_id
  WHERE t.id = p_transaction_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_all_categories` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_all_categories`()
BEGIN
  SELECT c.id, c.name, COUNT(p.id) AS product_count
  FROM categories c
  LEFT JOIN products p ON p.category_id = c.id AND p.is_active = 1
  GROUP BY c.id
  ORDER BY c.name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_all_products` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_all_products`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_all_staff` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_all_staff`()
BEGIN
  SELECT s.id, s.staff_code, s.full_name, s.role, s.status, s.temp_password,
         DATE_FORMAT(s.joined_at, '%b %d, %Y') AS joined,
         u.username, u.is_active
  FROM staff s
  JOIN users u ON u.id = s.user_id
  ORDER BY s.id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_best_sellers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_best_sellers`(IN p_limit INT)
BEGIN
        DECLARE v_limit INT;
        SET v_limit = IF(p_limit IS NULL OR p_limit <= 0, 8, p_limit);
        SELECT 
          p.id,
          p.name,
          c.name AS category,
          c.id AS category_id,
          p.price,
          p.stock,
          p.image_url,
          CAST(IFNULL(SUM(ti.quantity), 0) AS UNSIGNED) AS total_sold,
          CAST(IFNULL(SUM(ti.subtotal), 0) AS DECIMAL(10,2)) AS total_revenue
        FROM products p
        JOIN categories c ON c.id = p.category_id
        LEFT JOIN transaction_items ti ON ti.product_id = p.id
        WHERE p.is_active = 1
        GROUP BY p.id, p.name, c.name, c.id, p.price, p.stock, p.image_url
        ORDER BY total_sold DESC, p.id ASC
        LIMIT v_limit;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_customer_profile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_customer_profile`(IN p_user_id INT UNSIGNED)
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
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_customer_purchase_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_customer_purchase_history`(IN p_user_id INT UNSIGNED)
BEGIN
        SELECT t.id, t.receipt_no,
               IFNULL(CONCAT(c.last_name, ', ', c.first_name), 'Customer') AS customer,
               s.full_name AS cashier,
               t.total_amount, t.cash_tendered, t.change_amount,
               DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS date
        FROM transactions t
        JOIN customers c ON c.id = t.customer_id
        JOIN staff s ON s.id = t.cashier_id
        WHERE c.user_id = p_user_id
        ORDER BY t.created_at DESC;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_dashboard_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_dashboard_summary`()
BEGIN
  SELECT
    (SELECT COUNT(*) FROM products WHERE is_active = 1) AS total_products,
    (SELECT COUNT(*) FROM categories)                    AS total_categories,
    (SELECT COUNT(*) FROM customers WHERE account_status = 'Approved') AS total_customers,
    (SELECT COUNT(*) FROM staff WHERE status = 'Active') AS active_staff,
    (SELECT COUNT(*) FROM products WHERE stock <= low_stock_threshold AND is_active = 1) AS low_stock_count,
    (SELECT IFNULL(SUM(total_amount),0) FROM transactions WHERE DATE(created_at) = CURDATE()) AS today_sales,
    (SELECT COUNT(*) FROM transactions WHERE DATE(created_at) = CURDATE()) AS today_transactions,
    (SELECT COUNT(*) FROM customers WHERE account_status = 'Pending') AS pending_registrations;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_low_stock_products` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_low_stock_products`()
BEGIN
  SELECT p.id, p.name, c.name AS category, p.stock, p.low_stock_threshold
  FROM products p
  JOIN categories c ON c.id = p.category_id
  WHERE p.stock <= p.low_stock_threshold AND p.is_active = 1
  ORDER BY p.stock ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_pending_customers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_pending_customers`()
BEGIN
  SELECT id, last_name, first_name, middle_name, address,
         DATE_FORMAT(date_of_birth, '%Y-%m-%d') AS date_of_birth,
         civil_status, gender, phone,
         DATE_FORMAT(submitted_at, '%b %d, %Y') AS submitted_at
  FROM customers
  WHERE account_status = 'Pending'
  ORDER BY submitted_at ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_registered_customers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_registered_customers`()
BEGIN
        SELECT c.id, c.customer_code,
               CONCAT(c.last_name, ', ', c.first_name, ' ', IFNULL(c.middle_name,'')) AS full_name,
               c.phone, c.address, c.gender, c.civil_status,
               DATE_FORMAT(c.date_of_birth, '%Y-%m-%d') AS date_of_birth,
               DATE_FORMAT(c.approved_at, '%b %d, %Y') AS joined,
               u.username,
               c.temp_password,
               COUNT(t.id) AS total_purchases
        FROM customers c
        JOIN users u ON u.id = c.user_id
        LEFT JOIN transactions t ON t.customer_id = c.id
        WHERE c.account_status = 'Approved'
        GROUP BY c.id
        ORDER BY c.approved_at DESC;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_settings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_settings`()
BEGIN
  SELECT setting_key, setting_value FROM store_settings;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_staff_profile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_staff_profile`(IN p_user_id INT UNSIGNED)
BEGIN
        SELECT s.id, s.user_id, s.staff_code, s.full_name, s.role, s.status,
               DATE_FORMAT(s.joined_at, '%b %d, %Y') AS joined,
               u.username
        FROM staff s
        JOIN users u ON u.id = s.user_id
        WHERE s.user_id = p_user_id
        LIMIT 1;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_transactions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_transactions`(
  IN p_date_from DATE,
  IN p_date_to   DATE
)
BEGIN
  SELECT t.id, t.receipt_no,
         IFNULL(CONCAT(c.last_name, ', ', c.first_name), 'Walk-in') AS customer,
         s.full_name AS cashier,
         t.total_amount, t.cash_tendered, t.change_amount,
         DATE_FORMAT(t.created_at, '%b %d, %Y %h:%i %p') AS date
  FROM transactions t
  LEFT JOIN customers c ON c.id = t.customer_id
  JOIN staff s ON s.id = t.cashier_id
  WHERE DATE(t.created_at) BETWEEN p_date_from AND p_date_to
  ORDER BY t.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_transaction_items` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_transaction_items`(IN p_transaction_id INT UNSIGNED)
BEGIN
        SELECT id, product_id, product_name, unit_price, quantity, subtotal
        FROM transaction_items
        WHERE transaction_id = p_transaction_id;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_user_by_id`(IN p_id INT UNSIGNED)
BEGIN
        SELECT u.id, u.username, u.password, u.role, u.is_active,
               s.full_name, s.staff_code,
               c.first_name, c.last_name, c.customer_code, c.account_status
        FROM users u
        LEFT JOIN staff    s ON s.user_id = u.id
        LEFT JOIN customers c ON c.user_id = u.id
        WHERE u.id = p_id
        LIMIT 1;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_by_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_get_user_by_username`(IN p_username VARCHAR(100))
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_submit_customer_registration` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_submit_customer_registration`(
        IN p_last_name    VARCHAR(100),
        IN p_first_name   VARCHAR(100),
        IN p_middle_name  VARCHAR(100),
        IN p_address      TEXT,
        IN p_dob          DATE,
        IN p_civil_status ENUM('Single','Married','Widowed','Separated'),
        IN p_gender       ENUM('Male','Female','Prefer not to say'),
        IN p_phone        VARCHAR(20)
      )
BEGIN
        DECLARE v_code VARCHAR(20);
        SELECT CONCAT('PND', LPAD(COUNT(*) + 1, 5, '0')) INTO v_code FROM customers;

        INSERT INTO customers
          (customer_code, last_name, first_name, middle_name, address,
           date_of_birth, civil_status, gender, phone, account_status)
        VALUES
          (v_code, p_last_name, p_first_name, p_middle_name, p_address,
           p_dob, p_civil_status, p_gender, p_phone, 'Pending');

        SELECT LAST_INSERT_ID() AS customer_id, 'Registration submitted' AS message;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_toggle_staff_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_toggle_staff_status`(IN p_staff_id INT UNSIGNED)
BEGIN
  DECLARE v_user_id INT UNSIGNED;
  DECLARE v_new_status VARCHAR(20);

  SELECT user_id, IF(status = 'Active', 'Inactive', 'Active')
  INTO v_user_id, v_new_status
  FROM staff WHERE id = p_staff_id;

  UPDATE staff SET status = v_new_status WHERE id = p_staff_id;
  UPDATE users SET is_active = IF(v_new_status = 'Active', 1, 0) WHERE id = v_user_id;

  SELECT status FROM staff WHERE id = p_staff_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_customer_profile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_update_customer_profile`(
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
        DECLARE v_full_name VARCHAR(255);

        SELECT id INTO v_customer_id
        FROM customers
        WHERE user_id = p_user_id AND account_status = 'Approved'
        LIMIT 1;

        IF v_customer_id IS NULL THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer profile not found';
        END IF;

        UPDATE customers
        SET first_name   = p_first_name,
            last_name    = p_last_name,
            middle_name  = p_middle_name,
            address      = p_address,
            phone        = p_phone,
            gender       = p_gender,
            civil_status = p_civil_status,
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
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_product` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_update_product`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_product_image` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_update_product_image`(
        IN p_id INT UNSIGNED,
        IN p_image_url VARCHAR(500)
      )
BEGIN
        UPDATE products SET image_url = p_image_url WHERE id = p_id;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_product_stock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_update_product_stock`(
  IN p_product_id INT UNSIGNED,
  IN p_new_stock  INT
)
BEGIN
  UPDATE products SET stock = p_new_stock WHERE id = p_product_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_setting` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_update_setting`(
  IN p_key   VARCHAR(100),
  IN p_value TEXT
)
BEGIN
  INSERT INTO store_settings (setting_key, setting_value)
  VALUES (p_key, p_value)
  ON DUPLICATE KEY UPDATE setting_value = p_value;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_staff_profile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_update_staff_profile`(
        IN p_user_id   INT UNSIGNED,
        IN p_full_name  VARCHAR(150),
        IN p_username   VARCHAR(100)
      )
BEGIN
        DECLARE v_count INT;
        SELECT COUNT(*) INTO v_count FROM users WHERE username = p_username AND id != p_user_id;
        IF v_count > 0 THEN
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists';
        END IF;

        UPDATE users
        SET username = p_username,
            full_name = p_full_name
        WHERE id = p_user_id;

        UPDATE staff
        SET full_name = p_full_name
        WHERE user_id = p_user_id;

        SELECT s.id, s.user_id, s.staff_code, s.full_name, s.role, s.status,
               DATE_FORMAT(s.joined_at, '%b %d, %Y') AS joined,
               u.username
        FROM staff s
        JOIN users u ON u.id = s.user_id
        WHERE s.user_id = p_user_id
        LIMIT 1;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sm`@`localhost` PROCEDURE `sp_update_user_password`(
        IN p_id INT UNSIGNED,
        IN p_new_password VARCHAR(255)
      )
BEGIN
        UPDATE users SET password = p_new_password WHERE id = p_id;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-17  9:13:31
