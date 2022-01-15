-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 01, 2021 at 04:29 PM
-- Server version: 10.4.14-MariaDB
-- PHP Version: 7.4.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--https://1941.iee.ihu.gr/site/index.php?p=Projects2021
-- Database: `rpsls`
--

DELIMITER $$

DROP PROCEDURE IF EXISTS `clean_board`$$
--
-- Procedure clean_board: Αρχικοποιω την board μέσο της replace με την board_empty
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_board` ()  BEGIN
		TRUNCATE TABLE board;
		REPLACE INTO `board` SELECT * FROM `board_empty`;
        UPDATE `players` SET username=NULL, token=NULL, last_action=NULL;
		UPDATE `game_status` SET `status`='not active', `player_turn`=NULL, `result`=NULL;
	END$$
	

-- --------------------------------------------------------

-- 
-- Η δομή του πίνακα board
-- 
DROP TABLE IF EXISTS board;
CREATE TABLE `board` (
  `match_id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `p1_choice` CHAR(10) NULL,
  `p2_choice` CHAR(10) NULL,
  `winner` enum('p1','p2','D') DEFAULT NULL,
    PRIMARY KEY (match_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `board` (`match_id`, `p1_choice`, `p2_choice`) VALUES (0, NULL, NULL);



--
-- Η δομή του πίνακα board_empty
--
DROP TABLE IF EXISTS board_empty;
CREATE TABLE `board_empty` (
  `match_id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `p1_choice` CHAR(10) NULL,
  `p2_choice` CHAR(10) NULL,
  `winner` enum('p1','p2','D') DEFAULT NULL,
    PRIMARY KEY (match_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `board_empty` (`match_id`, `p1_choice`, `p2_choice`) VALUES (0, NULL, NULL);




--
-- Η δομή του πίνακα game_status
--
DROP TABLE IF EXISTS game_status;
CREATE TABLE `game_status` (
  `status` enum('not active','initialized','started','ended','aborded') NOT NULL DEFAULT 'not active',
  `player_turn` enum('p1','p2') DEFAULT NULL,
  `result` enum('p1','p2','D') DEFAULT NULL,
  `last_change` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `game_status` (`status`, `player_turn`, `result`, `last_change`) VALUES
('not active', NULL, NULL, '2021-01-03 14:02:43');

--
-- Ενημερώσει την στήλη last_change με τωρινή ώρα πριν απο κάθε update του game_status
--
DELIMITER $$
CREATE TRIGGER `game_status_update` BEFORE UPDATE ON `game_status` FOR EACH ROW BEGIN
		SET NEW.last_change=NOW();
	END
$$
DELIMITER ;

-- --------------------------------------------------------


DROP TABLE IF EXISTS players;
--
-- Η δομή του πίνακα players
--
CREATE TABLE `players` (
  `username` varchar(50) DEFAULT NULL,
  `player_number` enum('p1','p2') NOT NULL,
  `token` varchar(100) NOT NULL,
  `last_action` timestamp NULL DEFAULT NULL,
  `score` INT NOT NULL,
   PRIMARY KEY (player_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Τα δεδομένα του players
--
INSERT INTO `players` (`username`, `player_number`, `token`, `last_action`, `score`) VALUES
(NULL, 'p1', '', '2021-01-03 13:55:59', 0),
(NULL, 'p2', '', '2021-01-03 13:56:35', 0);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
