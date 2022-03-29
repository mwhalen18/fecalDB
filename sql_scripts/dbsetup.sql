DROP schema if exists `krspfecalsDEV`;
CREATE SCHEMA IF NOT EXISTS `krspfecalsDEV`;

USE `krspfecalsDEV`;

CREATE TABLE IF NOT EXISTS `krspfecalsDEV`.`Poop` (
  poop_id VARCHAR(255) NOT NULL PRIMARY KEY,
  trapping_id INT,
  squirrel_id INT,
  `year` INT,
  poop_time INT,
  comments VARCHAR(255) NULL
);

CREATE TABLE IF NOT EXISTS `krspfecalsDEV`.`PoopDupl` 
LIKE `krspfecalsDEV`.`Poop`;

ALTER TABLE `krspfecalsDEV`.`PoopDupl`
DROP PRIMARY KEY;

CREATE TABLE IF NOT EXISTS `krspfecalsDEV`.`Extract` (
  extract_id INT NOT NULL PRIMARY KEY,
  poop_id VARCHAR(255),
  extraction_date DATE,
  extraction_observer_id VARCHAR(5),
  extraction_volume FLOAT,
  weight_date DATE,
  weight_observer_id VARCHAR(5),
  hair TINYINT,
  contaminants_removed VARCHAR(255),
  mass_g FLOAT,
  extra TINYINT,
  FOREIGN KEY (poop_id) REFERENCES `krspfecalsDEV`.`Poop` (poop_id)
		ON DELETE NO ACTION
		ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `krspfecalsDEV`.`Protocol` (
	protocol_id VARCHAR(45) NOT NULL PRIMARY KEY,
    eia_lab VARCHAR(45),
	dilution FLOAT,
	volume_used FLOAT,
	hormone VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS `krspfecalsDEV`.`Assay` (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  extract_id INT,
  plate_id VARCHAR(45),
  protocol_id VARCHAR(45),
  date DATE,
  observer_id VARCHAR(5),
  concentration FLOAT,
  cv FLOAT,
  FOREIGN KEY (extract_id) REFERENCES `krspfecalsDEV`.`Extract` (extract_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  FOREIGN KEY (protocol_id) REFERENCES `krspfecalsDEV`.`Protocol` (protocol_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
)