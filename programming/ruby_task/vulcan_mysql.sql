SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `vulcan` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `vulcan`;

-- -----------------------------------------------------
-- Table `vulcan`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`users` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`users` (
  `id` INT NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  `updated_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`source_groups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`source_groups` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`source_groups` (
  `id` INT NOT NULL ,
  `source_group` VARCHAR(45) NOT NULL ,
  `group_order` INT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`source_types`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`source_types` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`source_types` (
  `id` INT NOT NULL ,
  `source_group_id` INT NOT NULL ,
  `source_type` VARCHAR(45) NOT NULL ,
  `type_order` INT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_source_types_source_groups1`
    FOREIGN KEY (`source_group_id` )
    REFERENCES `vulcan`.`source_groups` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_source_types_source_groups1` ON `vulcan`.`source_types` (`source_group_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`click_sources`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`click_sources` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`click_sources` (
  `id` INT NOT NULL ,
  `click_source` VARCHAR(45) NOT NULL ,
  `click_source_order` INT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`linksources`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`linksources` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`linksources` (
  `id` INT NOT NULL ,
  `source_type_id` INT NOT NULL ,
  `click_source_id` INT NULL ,
  `source_code` VARCHAR(3) NOT NULL ,
  `source_name` VARCHAR(45) NOT NULL ,
  `source_order` INT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_linksources_source_types1`
    FOREIGN KEY (`source_type_id` )
    REFERENCES `vulcan`.`source_types` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_linksources_click_sources1`
    FOREIGN KEY (`click_source_id` )
    REFERENCES `vulcan`.`click_sources` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_linksources_source_types1` ON `vulcan`.`linksources` (`source_type_id` ASC) ;

CREATE INDEX `fk_linksources_click_sources1` ON `vulcan`.`linksources` (`click_source_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`geo_locations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`geo_locations` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`geo_locations` (
  `id` INT NOT NULL ,
  `ip_low` INT UNSIGNED NOT NULL ,
  `ip_high` INT UNSIGNED NOT NULL ,
  `country_code` VARCHAR(45) NOT NULL ,
  `country` VARCHAR(45) NOT NULL ,
  `region` VARCHAR(45) NOT NULL ,
  `city` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`path_categories`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`path_categories` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`path_categories` (
  `id` INT NOT NULL ,
  `category` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`paths`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`paths` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`paths` (
  `id` INT NOT NULL ,
  `path` VARCHAR(255) NOT NULL ,
  `path_category_id` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_paths_path_categories1`
    FOREIGN KEY (`path_category_id` )
    REFERENCES `vulcan`.`path_categories` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_paths_path_categories1` ON `vulcan`.`paths` (`path_category_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`foci`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`foci` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`foci` (
  `id` INT NOT NULL ,
  `name` VARCHAR(64) NOT NULL ,
  `url` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`campaign_categories`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`campaign_categories` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`campaign_categories` (
  `id` INT NOT NULL ,
  `focus_id` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_campaign_categories_foci1`
    FOREIGN KEY (`focus_id` )
    REFERENCES `vulcan`.`foci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_campaign_categories_foci1` ON `vulcan`.`campaign_categories` (`focus_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`campaigns`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`campaigns` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`campaigns` (
  `id` INT NOT NULL ,
  `campaign_category_id` INT NOT NULL ,
  `campaign` VARCHAR(45) NULL ,
  `status` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_campaigns_campaign_categories1`
    FOREIGN KEY (`campaign_category_id` )
    REFERENCES `vulcan`.`campaign_categories` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_campaigns_campaign_categories1` ON `vulcan`.`campaigns` (`campaign_category_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`adgroups`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`adgroups` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`adgroups` (
  `id` INT NOT NULL ,
  `campaign_id` INT NOT NULL ,
  `title` VARCHAR(45) NOT NULL ,
  `short_description` VARCHAR(45) NOT NULL ,
  `long_description` VARCHAR(255) NOT NULL ,
  `elements` VARCHAR(45) NULL ,
  `status` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_adgroups_campaigns1`
    FOREIGN KEY (`campaign_id` )
    REFERENCES `vulcan`.`campaigns` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_adgroups_campaigns1` ON `vulcan`.`adgroups` (`campaign_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`adcodes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`adcodes` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`adcodes` (
  `id` INT NOT NULL ,
  `adgroup_id` INT NOT NULL ,
  `adcode` VARCHAR(32) NOT NULL ,
  `target` VARCHAR(255) NOT NULL ,
  `match_type` VARCHAR(45) NULL ,
  `initial_desired_position` INT NULL ,
  `current_desired_position` INT NULL ,
  `destination_url` VARCHAR(255) NULL ,
  `created_at` DATETIME NULL ,
  `shortduration_class` VARCHAR(4) NULL ,
  `longduration_class` VARCHAR(4) NULL ,
  `status` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_ads_adgroups`
    FOREIGN KEY (`adgroup_id` )
    REFERENCES `vulcan`.`adgroups` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_ads_adgroups` ON `vulcan`.`adcodes` (`adgroup_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`domain_redirects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`domain_redirects` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`domain_redirects` (
  `id` INT NOT NULL ,
  `domain` VARCHAR(45) NOT NULL ,
  `url_id` INT NOT NULL ,
  `owner` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`visits`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`visits` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`visits` (
  `id` INT NOT NULL ,
  `user_id` INT NOT NULL ,
  `linksource_id` INT NOT NULL ,
  `path_id` INT NOT NULL ,
  `adcode_id` INT NULL ,
  `domain_redirect_id` INT NULL ,
  `geo_location_id` INT NULL ,
  `created_at` DATETIME NOT NULL ,
  `ip` INT UNSIGNED NOT NULL ,
  `searchterm` VARCHAR(255) NULL ,
  `user_agent` VARCHAR(512) NOT NULL ,
  `referer` VARCHAR(1024) NOT NULL ,
  `refdomain` VARCHAR(45) NOT NULL ,
  `refpath` VARCHAR(255) NOT NULL ,
  `refparam` VARCHAR(45) NULL ,
  `refsource` VARCHAR(64) NULL ,
  `refdata` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_visits_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `vulcan`.`users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_visits_linksources`
    FOREIGN KEY (`linksource_id` )
    REFERENCES `vulcan`.`linksources` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_visits_geo_locations1`
    FOREIGN KEY (`geo_location_id` )
    REFERENCES `vulcan`.`geo_locations` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_visits_paths1`
    FOREIGN KEY (`path_id` )
    REFERENCES `vulcan`.`paths` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_visits_adcodes1`
    FOREIGN KEY (`adcode_id` )
    REFERENCES `vulcan`.`adcodes` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_visits_domain_redirects1`
    FOREIGN KEY (`domain_redirect_id` )
    REFERENCES `vulcan`.`domain_redirects` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_visits_users` ON `vulcan`.`visits` (`user_id` ASC) ;

CREATE INDEX `fk_visits_linksources` ON `vulcan`.`visits` (`linksource_id` ASC) ;

CREATE INDEX `fk_visits_geo_locations1` ON `vulcan`.`visits` (`geo_location_id` ASC) ;

CREATE INDEX `fk_visits_paths1` ON `vulcan`.`visits` (`path_id` ASC) ;

CREATE INDEX `fk_visits_adcodes1` ON `vulcan`.`visits` (`adcode_id` ASC) ;

CREATE INDEX `fk_visits_domain_redirects1` ON `vulcan`.`visits` (`domain_redirect_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`views`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`views` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`views` (
  `id` INT NOT NULL ,
  `visit_id` INT NOT NULL ,
  `user_id` INT NOT NULL ,
  `geo_location_id` INT NOT NULL ,
  `path_id` INT NOT NULL ,
  `ip` INT UNSIGNED NOT NULL ,
  `querystring` VARCHAR(512) NOT NULL ,
  `referer` VARCHAR(1024) NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_views_visits`
    FOREIGN KEY (`visit_id` )
    REFERENCES `vulcan`.`visits` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_views_geo_locations1`
    FOREIGN KEY (`geo_location_id` )
    REFERENCES `vulcan`.`geo_locations` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_views_urls1`
    FOREIGN KEY (`path_id` )
    REFERENCES `vulcan`.`paths` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_views_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `vulcan`.`users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_views_visits` ON `vulcan`.`views` (`visit_id` ASC) ;

CREATE INDEX `fk_views_geo_locations1` ON `vulcan`.`views` (`geo_location_id` ASC) ;

CREATE INDEX `fk_views_urls1` ON `vulcan`.`views` (`path_id` ASC) ;

CREATE INDEX `fk_views_users1` ON `vulcan`.`views` (`user_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`affiliates`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`affiliates` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`affiliates` (
  `id` INT NOT NULL ,
  `affiliate` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`companies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`companies` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`companies` (
  `id` INT NOT NULL ,
  `focus_id` INT NOT NULL ,
  `company_name` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_companies_foci1`
    FOREIGN KEY (`focus_id` )
    REFERENCES `vulcan`.`foci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_companies_foci1` ON `vulcan`.`companies` (`focus_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`offers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`offers` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`offers` (
  `id` INT NOT NULL ,
  `affiliate_id` INT NOT NULL ,
  `company_id` INT NOT NULL ,
  `focus_id` INT NOT NULL ,
  `name` VARCHAR(256) NOT NULL ,
  `type` VARCHAR(45) NOT NULL ,
  `active` INT NOT NULL ,
  `format` VARCHAR(45) NOT NULL ,
  `start_date` DATETIME NULL ,
  `end_date` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_offers_affiliates`
    FOREIGN KEY (`affiliate_id` )
    REFERENCES `vulcan`.`affiliates` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_offers_foci`
    FOREIGN KEY (`focus_id` )
    REFERENCES `vulcan`.`foci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_offers_companies`
    FOREIGN KEY (`company_id` )
    REFERENCES `vulcan`.`companies` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_offers_affiliates` ON `vulcan`.`offers` (`affiliate_id` ASC) ;

CREATE INDEX `fk_offers_foci` ON `vulcan`.`offers` (`focus_id` ASC) ;

CREATE INDEX `fk_offers_companies` ON `vulcan`.`offers` (`company_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`buyclicks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`buyclicks` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`buyclicks` (
  `id` INT NOT NULL ,
  `view_id` INT NOT NULL ,
  `offer_id` INT NOT NULL ,
  `user_id` INT NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  `link_number` INT NOT NULL ,
  `link_descriptor` VARCHAR(64) NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_buyclicks_views`
    FOREIGN KEY (`view_id` )
    REFERENCES `vulcan`.`views` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_buyclicks_offers`
    FOREIGN KEY (`offer_id` )
    REFERENCES `vulcan`.`offers` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_buyclicks_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `vulcan`.`users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_buyclicks_views` ON `vulcan`.`buyclicks` (`view_id` ASC) ;

CREATE INDEX `fk_buyclicks_offers` ON `vulcan`.`buyclicks` (`offer_id` ASC) ;

CREATE INDEX `fk_buyclicks_users` ON `vulcan`.`buyclicks` (`user_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`lockers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`lockers` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`lockers` (
  `id` INT NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`accounts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`accounts` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`accounts` (
  `id` INT NOT NULL ,
  `user_id` INT NOT NULL ,
  `locker_id` INT NOT NULL ,
  `email_address` VARCHAR(64) NOT NULL ,
  `registered_at` DATETIME NOT NULL ,
  `activated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_accounts_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `vulcan`.`users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_accounts_lockers1`
    FOREIGN KEY (`locker_id` )
    REFERENCES `vulcan`.`lockers` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_accounts_users1` ON `vulcan`.`accounts` (`user_id` ASC) ;

CREATE INDEX `fk_accounts_lockers1` ON `vulcan`.`accounts` (`locker_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`orders`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`orders` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`orders` (
  `id` INT NOT NULL ,
  `buyclick_id` INT NOT NULL ,
  `affiliate_id` INT NOT NULL ,
  `user_id` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_orders_buyclicks`
    FOREIGN KEY (`buyclick_id` )
    REFERENCES `vulcan`.`buyclicks` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_affiliates`
    FOREIGN KEY (`affiliate_id` )
    REFERENCES `vulcan`.`affiliates` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `vulcan`.`users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_orders_buyclicks` ON `vulcan`.`orders` (`buyclick_id` ASC) ;

CREATE INDEX `fk_orders_affiliates` ON `vulcan`.`orders` (`affiliate_id` ASC) ;

CREATE INDEX `fk_orders_users` ON `vulcan`.`orders` (`user_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`transaction_types`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`transaction_types` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`transaction_types` (
  `id` INT NOT NULL ,
  `transaction_type` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`transactions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`transactions` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`transactions` (
  `id` INT NOT NULL ,
  `order_id` INT NOT NULL ,
  `transaction_type_id` INT NOT NULL ,
  `sale_amount` DECIMAL(12,2) NOT NULL ,
  `commission` DECIMAL(12,2) NOT NULL ,
  `transacted_at` DATETIME NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_transactions_orders`
    FOREIGN KEY (`order_id` )
    REFERENCES `vulcan`.`orders` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transactions_transaction_types1`
    FOREIGN KEY (`transaction_type_id` )
    REFERENCES `vulcan`.`transaction_types` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_transactions_orders` ON `vulcan`.`transactions` (`order_id` ASC) ;

CREATE INDEX `fk_transactions_transaction_types1` ON `vulcan`.`transactions` (`transaction_type_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`clicks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`clicks` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`clicks` (
  `id` INT NOT NULL ,
  `linksource_id` INT NOT NULL ,
  `click_source_id` INT NOT NULL ,
  `adcode_id` INT NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  `status` VARCHAR(45) NULL ,
  `impressions` INT NULL ,
  `clicks` INT NOT NULL ,
  `cost` DECIMAL(12,2) NOT NULL ,
  `quality_score` VARCHAR(45) NULL ,
  `average_position_clicks` FLOAT NULL ,
  `average_position_impressions` VARCHAR(45) NULL ,
  `max_bid` DECIMAL(12,2) NULL ,
  `min_bid` DECIMAL(12,2) NULL ,
  `shortduration_class` VARCHAR(45) NULL ,
  `match_type` VARCHAR(45) NULL ,
  `longduration_class` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_clicks_click_sources1`
    FOREIGN KEY (`click_source_id` )
    REFERENCES `vulcan`.`click_sources` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_clicks_linksources1`
    FOREIGN KEY (`linksource_id` )
    REFERENCES `vulcan`.`linksources` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_clicks_adcodes1`
    FOREIGN KEY (`adcode_id` )
    REFERENCES `vulcan`.`adcodes` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_clicks_click_sources1` ON `vulcan`.`clicks` (`click_source_id` ASC) ;

CREATE INDEX `fk_clicks_linksources1` ON `vulcan`.`clicks` (`linksource_id` ASC) ;

CREATE INDEX `fk_clicks_adcodes1` ON `vulcan`.`clicks` (`adcode_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`searches`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`searches` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`searches` (
  `id` INT NOT NULL ,
  `visit_id` INT NOT NULL ,
  `view_id` INT NOT NULL ,
  `query` VARCHAR(255) NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_searches_visits`
    FOREIGN KEY (`visit_id` )
    REFERENCES `vulcan`.`visits` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_searches_views`
    FOREIGN KEY (`view_id` )
    REFERENCES `vulcan`.`views` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_searches_visits` ON `vulcan`.`searches` (`visit_id` ASC) ;

CREATE INDEX `fk_searches_views` ON `vulcan`.`searches` (`view_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`locker_objects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`locker_objects` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`locker_objects` (
  `id` INT NOT NULL ,
  `locker_id` INT NOT NULL ,
  `offer_id` INT NOT NULL ,
  `company_id` INT NOT NULL ,
  `added_at` DATETIME NOT NULL ,
  `removed_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_locker_objects_lockers`
    FOREIGN KEY (`locker_id` )
    REFERENCES `vulcan`.`lockers` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_locker_objects_offers`
    FOREIGN KEY (`offer_id` )
    REFERENCES `vulcan`.`offers` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_locker_objects_companies`
    FOREIGN KEY (`company_id` )
    REFERENCES `vulcan`.`companies` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_locker_objects_lockers` ON `vulcan`.`locker_objects` (`locker_id` ASC) ;

CREATE INDEX `fk_locker_objects_offers` ON `vulcan`.`locker_objects` (`offer_id` ASC) ;

CREATE INDEX `fk_locker_objects_companies` ON `vulcan`.`locker_objects` (`company_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`users_visits`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`users_visits` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`users_visits` (
  `visit_id` INT NOT NULL ,
  `user_id` INT NOT NULL ,
  `previous_visit_id` INT NOT NULL ,
  PRIMARY KEY (`visit_id`) ,
  CONSTRAINT `fk_user_visits_visits1`
    FOREIGN KEY (`visit_id` )
    REFERENCES `vulcan`.`visits` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_visits_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `vulcan`.`users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_user_visits_visits1` ON `vulcan`.`users_visits` (`visit_id` ASC) ;

CREATE INDEX `fk_user_visits_users1` ON `vulcan`.`users_visits` (`user_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`edges`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`edges` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`edges` (
  `id` INT NOT NULL ,
  `from_url` VARCHAR(255) NOT NULL ,
  `to_url` VARCHAR(255) NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`affiliates_companies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`affiliates_companies` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`affiliates_companies` (
  `affiliate_id` INT NOT NULL ,
  `company_id` INT NOT NULL ,
  PRIMARY KEY (`affiliate_id`, `company_id`) ,
  CONSTRAINT `fk_affiliates_companies_affiliates1`
    FOREIGN KEY (`affiliate_id` )
    REFERENCES `vulcan`.`affiliates` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_affiliates_companies_companies2`
    FOREIGN KEY (`company_id` )
    REFERENCES `vulcan`.`companies` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_affiliates_companies_affiliates1` ON `vulcan`.`affiliates_companies` (`affiliate_id` ASC) ;

CREATE INDEX `fk_affiliates_companies_companies2` ON `vulcan`.`affiliates_companies` (`company_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`offers_foci`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`offers_foci` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`offers_foci` (
  `id` INT NOT NULL ,
  `focus_id` INT NOT NULL ,
  PRIMARY KEY (`id`, `focus_id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`pages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`pages` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`pages` (
  `id` INT NOT NULL ,
  `url` VARCHAR(255) NOT NULL ,
  `depth` INT NOT NULL ,
  `title` VARCHAR(512) NOT NULL ,
  `h1` VARCHAR(1024) NOT NULL ,
  `h2` VARCHAR(1024) NOT NULL ,
  `description` VARCHAR(512) NOT NULL ,
  `linktext` VARCHAR(512) NOT NULL ,
  `created_at` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`bot_agents`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`bot_agents` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`bot_agents` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `agent_group` VARCHAR(45) NOT NULL ,
  `agent_match` VARCHAR(255) NOT NULL ,
  `exact` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`junk_agents`
-- Modified this table definition: make id AUTO_INCREMENT
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`junk_agents` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`junk_agents` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `agent_match` VARCHAR(255) NOT NULL ,
  `exact` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`bot_ips`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`bot_ips` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`bot_ips` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `ip_low` INT UNSIGNED NOT NULL ,
  `ip_high` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`linksource_match_types`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`linksource_match_types` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`linksource_match_types` (
  `id` INT NOT NULL ,
  `pattern` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`linksource_matches`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`linksource_matches` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`linksource_matches` (
  `id` INT NOT NULL ,
  `linksource_match_type_id` INT NOT NULL ,
  `column_name` VARCHAR(45) NOT NULL ,
  `match` VARCHAR(45) NOT NULL ,
  `linksource` VARCHAR(45) NOT NULL ,
  `linksource_group` INT NULL ,
  `description` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_linksource_maps_linksource_match_types1`
    FOREIGN KEY (`linksource_match_type_id` )
    REFERENCES `vulcan`.`linksource_match_types` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_linksource_maps_linksource_match_types1` ON `vulcan`.`linksource_matches` (`linksource_match_type_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`raw_sessions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`raw_sessions` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`raw_sessions` (
  `id` INT NOT NULL ,
  `session_token` VARCHAR(40) NOT NULL ,
  `useragent` VARCHAR(512) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`raw_pageviews`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`raw_pageviews` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`raw_pageviews` (
  `id` INT NOT NULL ,
  `session_token` VARCHAR(40) NOT NULL ,
  `path` VARCHAR(255) NOT NULL ,
  `querystring` VARCHAR(512) NULL ,
  `adcode` VARCHAR(32) NULL ,
  `ip` INT UNSIGNED NOT NULL ,
  `referer` VARCHAR(1024) NULL ,
  `timestamp` DATETIME NOT NULL ,
  `userid` INT NULL ,
  `refsource` VARCHAR(64) NULL ,
  `refdata` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vulcan`.`raw_buyclicks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`raw_buyclicks` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`raw_buyclicks` (
  `id` INT NOT NULL ,
  `session_token` CHAR(40) NOT NULL ,
  `user_id` INT NULL ,
  `link_number` INT NOT NULL ,
  `link_descriptor` VARCHAR(64) NOT NULL ,
  `company_id` INT NOT NULL ,
  `offer_id` INT NOT NULL ,
  `platform` CHAR(2) NOT NULL ,
  `timestamp` DATETIME NOT NULL ,
  `view_id` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_raw_buyclicks_raw_pageviews1`
    FOREIGN KEY (`view_id` )
    REFERENCES `vulcan`.`raw_pageviews` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_raw_buyclicks_raw_pageviews1` ON `vulcan`.`raw_buyclicks` (`view_id` ASC) ;


-- -----------------------------------------------------
-- Table `vulcan`.`raw_searches`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `vulcan`.`raw_searches` ;

CREATE  TABLE IF NOT EXISTS `vulcan`.`raw_searches` (
  `id` INT NOT NULL ,
  `session_token` CHAR(40) NOT NULL ,
  `query` VARCHAR(4000) NOT NULL ,
  `object_type` VARCHAR(4000) NULL ,
  `object_id` INT NULL ,
  `timestamp` DATETIME NOT NULL ,
  `view_id` INT NOT NULL ,
  `total_results` INT NULL ,
  `stemmed_query` VARCHAR(255) NULL ,
  `results` VARCHAR(4000) NULL ,
  `speed` INT NULL ,
  `notes` VARCHAR(4000) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_raw_searches_raw_pageviews1`
    FOREIGN KEY (`view_id` )
    REFERENCES `vulcan`.`raw_pageviews` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_raw_searches_raw_pageviews1` ON `vulcan`.`raw_searches` (`view_id` ASC) ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
