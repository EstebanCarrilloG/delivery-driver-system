-- Players Table
CREATE TABLE IF NOT EXISTS `players` 
(
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(24) NOT NULL,
    `money` INT NOT NULL DEFAULT 0,
    `password` CHAR(64) NOT NULL,
    `salt` CHAR(16) NOT NULL,
    `kills` MEDIUMINT(8) NOT NULL DEFAULT 0,
    `deaths` MEDIUMINT(8) NOT NULL DEFAULT 0,
    `deliveries_completed` INT DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB;


ALTER TABLE `players` ADD COLUMN `score` INT UNSIGNED DEFAULT 0;
