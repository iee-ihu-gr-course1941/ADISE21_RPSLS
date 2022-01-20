-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 20, 2022 at 06:52 PM
-- Server version: 10.4.22-MariaDB
-- PHP Version: 8.1.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rpsls`
--

DELIMITER $$
--
-- Procedure clean_board: We initialize the board through replace with board_empty
--
DROP PROCEDURE IF EXISTS `clean_board`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_board` ()  BEGIN
		TRUNCATE TABLE board;
		REPLACE INTO `board` SELECT * FROM `board_empty`;
        UPDATE `players` SET username=NULL, token=NULL, last_action=NULL;
		UPDATE `game_status` SET `status`='not active', `player_turn`=NULL, `result_text`=NULL ,`result`=NULL;
	END$$

--
-- Procedure play_again: We initialize the board through replace with board_empty while keeping current players in game
--
DROP PROCEDURE IF EXISTS `play_again`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `play_again` ()  BEGIN


	If (SELECT `status` FROM `game_status`) LIKE 'ended' THEN
		TRUNCATE TABLE board;
		IF (SELECT result FROM `game_status`)='D' THEN
		UPDATE `game_status` SET `player_turn`='p' + FLOOR( 1 + RAND( ) *2 );
		ELSE UPDATE `game_status` SET `player_turn`=(SELECT result FROM `game_status`);
		END IF;
		REPLACE INTO `board` SELECT * FROM `board_empty`;
		UPDATE `board` SET `p1_choice`=null, `p1_choice`=NULL, `winner`=NULL WHERE match_id=1;
		
		UPDATE `game_status` SET `status`='started', `result`=NULL;
	END IF;
		
	END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `board`
--
DROP TABLE IF EXISTS board;
CREATE TABLE `board` (
  `match_id` mediumint(9) NOT NULL,
  `p1_choice` char(10) DEFAULT NULL,
  `p2_choice` char(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `board`
--

INSERT INTO `board` (`match_id`, `p1_choice`, `p2_choice`) VALUES
(1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `board_empty`
--
DROP TABLE IF EXISTS board_empty;
CREATE TABLE `board_empty` (
  `match_id` mediumint(9) NOT NULL,
  `p1_choice` char(10) DEFAULT NULL,
  `p2_choice` char(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `board_empty`
--

INSERT INTO `board_empty` (`match_id`, `p1_choice`, `p2_choice`) VALUES
(1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `game_status`
--
DROP TABLE IF EXISTS game_status;
CREATE TABLE `game_status` (
  `status` enum('not active','initialized','started','ended','aborded') NOT NULL DEFAULT 'not active',
  `player_turn` enum('p1','p2') DEFAULT NULL,
  `result` enum('p1','p2','D') DEFAULT NULL,
  `result_text` char(50) DEFAULT NULL,
  `last_change` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `game_status`
--

INSERT INTO `game_status` (`status`, `player_turn`, `result`, `result_text`, `last_change`) VALUES
('not active', NULL, NULL, NULL, '2022-01-20 17:38:27');

--
-- Triggers `game_status`: Before each game_status table update, update the last_change column with the current time
--
DELIMITER $$
DROP TRIGGER IF EXISTS game_status_update;
CREATE TRIGGER `game_status_update` BEFORE UPDATE ON `game_status` FOR EACH ROW BEGIN
		SET NEW.last_change=NOW();
	END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--
DROP TABLE IF EXISTS players;
CREATE TABLE `players` (
  `username` varchar(50) DEFAULT NULL,
  `player_number` enum('p1','p2') NOT NULL,
  `token` varchar(100) NOT NULL,
  `last_action` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`username`, `player_number`, `token`, `last_action`) VALUES
(NULL, 'p1', '', NULL),
(NULL, 'p2', '', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `board`
--
ALTER TABLE `board`
  ADD PRIMARY KEY (`match_id`);

--
-- Indexes for table `board_empty`
--
ALTER TABLE `board_empty`
  ADD PRIMARY KEY (`match_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `board`
--
ALTER TABLE `board`
  MODIFY `match_id` mediumint(9) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `board_empty`
--
ALTER TABLE `board_empty`
  MODIFY `match_id` mediumint(9) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
