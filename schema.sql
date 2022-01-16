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
DROP PROCEDURE IF EXISTS `clean_board`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_board` ()  BEGIN
		TRUNCATE TABLE board;
		REPLACE INTO `board` SELECT * FROM `board_empty`;
        UPDATE `players` SET username=NULL, token=NULL, last_action=NULL;
		UPDATE `game_status` SET `status`='not active', `player_turn`=NULL, `result_text`=NULL , `result`=NULL;
	END$$


DROP PROCEDURE IF EXISTS `make_move`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `make_move`(IN `choice` TINYINT, IN `player_number` VARCHAR(10))
BEGIN
        DECLARE player1 INT;
        DECLARE player2 INT;
        
		IF (player_number LIKE 'p1') THEN
		UPDATE `board` SET p1_choice=choice WHERE match_id=(SELECT MAX(match_id) FROM board);
		END IF;
		
		IF (player_number LIKE 'p2') THEN
		UPDATE `board` SET p2_choice=choice WHERE match_id=(SELECT MAX(match_id) FROM board);
		END IF;
		
		UPDATE game_status SET player_turn=IF(player_number='p1','p2','p1');
		
        
		SELECT p1_choice INTO player1 FROM `board`;
		SELECT p2_choice INTO player2 FROM `board`;

    IF (player1 IS NOT NULL AND player2 IS NOT NULL) THEN
    
    	IF player1=1 THEN
			IF player2=3 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Rock crushes Scissors', `status`='ended';
			ELSEIF player2=4 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Rock crushes Lizard', `status`='ended';
			
			ELSEIF player2=2 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Paper covers Rock', `status`='ended';
			
			ELSEIF player2=5 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Spock vaporizes Rock', `status`='ended';
			END IF;
    	END IF;
        
    	IF player1=2 THEN
			IF player2=3 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Scissors cuts Paper', `status`='ended';
			
			ELSEIF player2=4 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Lizard eats Paper', `status`='ended';
			
			ELSEIF player2=1 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Paper covers Rock', `status`='ended';
			END IF;
    	END IF;
        
        IF player1=3 THEN
			IF player2=2 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Scissors cuts Paper', `status`='ended';
			
			ELSEIF player2=4 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Scissors decapitates Lizard', `status`='ended';
			
			ELSEIF player2=1 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Rock crushes Scissors', `status`='ended';
			
			ELSEIF player2=5 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Spock smashes Scissors', `status`='ended';
			END IF;
    	END IF;
        
        IF player1=4 THEN
			IF player2=1 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Rock crushes Lizard', `status`='ended';
			
			ELSEIF player2=3 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Scissors decapitates Lizard', `status`='ended';
			
			ELSEIF player2=2 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Lizard eats Paper', `status`='ended';
			
			ELSEIF player2=5 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Lizard poisons Spock', `status`='ended';
			END IF;
    	END IF;
        
	IF player1=5 THEN
			IF player2=1 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Spock vaporizes Rock', `status`='ended';
			
			ELSEIF player2=3 THEN
				UPDATE `game_status` SET `result`='p1', result_text='Spock smashes Scissors', `status`='ended';
			
			ELSEIF player2=2 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Paper disproves Spock', `status`='ended';
			
			ELSEIF player2=4 THEN
				UPDATE `game_status` SET `result`='p2', result_text='Lizard poisons Spock', `status`='ended';
			END IF;
    	END IF;
        
	IF player1=player2 THEN
		UPDATE `game_status` SET `result`='D', `status`='ended';
	END IF;
        
    END IF;
    END$$


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
  `result_text` CHAR(50) DEFAULT NULL,
  `last_change` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `game_status`
--

INSERT INTO `game_status` (`status`, `player_turn`, `result`, `result_text`, `last_change`) VALUES
('not active', NULL, NULL, NULL, '2022-01-15 19:11:09');

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
