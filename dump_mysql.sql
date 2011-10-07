-- MySQL dump 10.13  Distrib 5.1.58, for Win64 (unknown)
--
-- Host: localhost    Database: test
-- ------------------------------------------------------
-- Server version	5.1.58-community

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
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routes` (
  `id_route` numeric NOT NULL,
  `description` char(30) DEFAULT NULL,
  `cost` double DEFAULT NULL,
  primary key (id_route)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES ('1','Sights', '0,0'),('2','Impressionism', '0,0'),('3','French_Revolution', '5,0');
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES; TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routevalues`
--

DROP TABLE IF EXISTS `routevalues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `routevalues` (
  `id_route` numeric NOT NULL,
  `pos` numeric NOT NULL,
  `x` double DEFAULT NULL,
  `y` double DEFAULT NULL,
  primary key (id_route, pos)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routevalues`
--

LOCK TABLES `routevalues` WRITE;
/*!40000 ALTER TABLE `routevalues` DISABLE KEYS */;
INSERT INTO `routevalues` VALUES ('1','1',48.8599222529277,2.26814031600952),('1','2',48.8556022493488,2.31493949890137),('1','3',48.8606422172774,2.32556104660034),('1','4',48.8601481252111,2.35296249389648),('1','5',48.8591316919089,2.36218929290771),('2','1',48.8573281778591,2.35216856002808),('2','2',48.8562128607169,2.34656810760498),('2','3',48.8626044204773,2.32481002807617),('2','4',48.8538056675187,2.31239676475525),('2','5',48.8047224161093,2.12388038635254),('3','1',48.8328949266473,2.31626987457275),('3','2',48.8561528587707,2.29768753051758),('3','3',48.8627773447719,2.33527064323425),('3','4',48.874337213534,2.29540228843689),('3','5',48.8874288205875,2.33974456787109);
/*!40000 ALTER TABLE `routevalues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userroutes`
--

DROP TABLE IF EXISTS `userroutes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userroutes` (
  `id_user` numeric NOT NULL,
  `id_route` numeric NOT NULL,
  primary key (id_user, id_route)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userroutes`
--

LOCK TABLES `userroutes` WRITE;
/*!40000 ALTER TABLE `userroutes` DISABLE KEYS */;
/*!40000 ALTER TABLE `userroutes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id_user` numeric NOT NULL,
  `first_name` char(30) DEFAULT NULL,
  `last_name` char(30) DEFAULT NULL,
  `e_mail` char(30) DEFAULT NULL,
  primary key (id_user)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-10-05 15:08:28
