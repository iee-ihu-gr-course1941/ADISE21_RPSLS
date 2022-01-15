-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 15, 2022 at 08:11 PM
-- Server version: 10.4.20-MariaDB
-- PHP Version: 7.3.29

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
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_board` ()  BEGIN
		TRUNCATE TABLE board;
		REPLACE INTO `board` SELECT * FROM `board_empty`;
        UPDATE `players` SET username=NULL, token=NULL, last_action=NULL;
		UPDATE `game_status` SET `status`='not active', `player_turn`=NULL, `result`=NULL;
	END$$


DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `board`
--

CREATE TABLE `board` (
  `match_id` mediumint(9) NOT NULL,
  `p1_choice` char(10) DEFAULT NULL,
  `p2_choice` char(10) DEFAULT NULL,
  `winner` enum('p1','p2','D') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `board`
--

INSERT INTO `board` (`match_id`, `p1_choice`, `p2_choice`, `winner`) VALUES
(1, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `board_empty`
--

CREATE TABLE `board_empty` (
  `match_id` mediumint(9) NOT NULL,
  `p1_choice` char(10) DEFAULT NULL,
  `p2_choice` char(10) DEFAULT NULL,
  `winner` enum('p1','p2','D') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `board_empty`
--

INSERT INTO `board_empty` (`match_id`, `p1_choice`, `p2_choice`, `winner`) VALUES
(1, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `game_status`
--

CREATE TABLE `game_status` (
  `status` enum('not active','initialized','started','ended','aborded') NOT NULL DEFAULT 'not active',
  `player_turn` enum('p1','p2') DEFAULT NULL,
  `result` enum('p1','p2','D') DEFAULT NULL,
  `last_change` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `game_status`
--

INSERT INTO `game_status` (`status`, `player_turn`, `result`, `last_change`) VALUES
('not active', NULL, NULL, '2022-01-15 19:11:09');

--
-- Triggers `game_status`
--
DELIMITER $$
CREATE TRIGGER `game_status_update` BEFORE UPDATE ON `game_status` FOR EACH ROW BEGIN
		SET NEW.last_change=NOW();
	END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `username` varchar(50) DEFAULT NULL,
  `player_number` enum('p1','p2') NOT NULL,
  `token` varchar(100) NOT NULL,
  `last_action` timestamp NULL DEFAULT NULL,
  `score` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`username`, `player_number`, `token`, `last_action`, `score`) VALUES
(NULL, 'p1', '', NULL, 0),
(NULL, 'p2', '', NULL, 0);

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
