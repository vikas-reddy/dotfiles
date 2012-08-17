USE master
GO
IF DB_ID('vulcan') IS NOT NULL
DROP DATABASE vulcan
GO
CREATE DATABASE vulcan
GO
USE vulcan
GO
CREATE SCHEMA vulcan
GO
DROP LOGIN vulcan_dev
GO
CREATE LOGIN vulcan_dev WITH PASSWORD = 'vulcan_dev', CHECK_POLICY = OFF
GO
CREATE USER vulcan_dev
GO
ALTER USER vulcan_dev WITH DEFAULT_SCHEMA = vulcan
GO
GRANT ALTER, EXECUTE, INSERT, DELETE, UPDATE, SELECT, VIEW DEFINITION ON SCHEMA :: vulcan to vulcan_dev
GO
BEGIN TRANSACTION


-- -----------------------------------------------------
-- Table vulcan.users
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.users', 'U') IS NOT NULL
DROP TABLE  vulcan.users ;

CREATE  TABLE  vulcan.users (
  id INT NOT NULL ,
  created_at DATETIME NOT NULL ,
  updated_at DATETIME NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.source_groups
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.source_groups', 'U') IS NOT NULL
DROP TABLE  vulcan.source_groups ;

CREATE  TABLE  vulcan.source_groups (
  id INT NOT NULL ,
  source_group VARCHAR(45) NOT NULL ,
  group_order INT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.source_types
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.source_types', 'U') IS NOT NULL
DROP TABLE  vulcan.source_types ;

CREATE  TABLE  vulcan.source_types (
  id INT NOT NULL ,
  source_group_id INT NOT NULL ,
  source_type VARCHAR(45) NOT NULL ,
  type_order INT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_source_types_source_groups1
    FOREIGN KEY (source_group_id )
    REFERENCES vulcan.source_groups (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_source_types_source_groups1 ON vulcan.source_types (source_group_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.click_sources
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.click_sources', 'U') IS NOT NULL
DROP TABLE  vulcan.click_sources ;

CREATE  TABLE  vulcan.click_sources (
  id INT NOT NULL ,
  click_source VARCHAR(45) NOT NULL ,
  click_source_order INT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.linksources
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.linksources', 'U') IS NOT NULL
DROP TABLE  vulcan.linksources ;

CREATE  TABLE  vulcan.linksources (
  id INT NOT NULL ,
  source_type_id INT NOT NULL ,
  click_source_id INT NULL ,
  source_code VARCHAR(3) NOT NULL ,
  source_name VARCHAR(45) NOT NULL ,
  source_order INT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_linksources_source_types1
    FOREIGN KEY (source_type_id )
    REFERENCES vulcan.source_types (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_linksources_click_sources1
    FOREIGN KEY (click_source_id )
    REFERENCES vulcan.click_sources (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_linksources_source_types1 ON vulcan.linksources (source_type_id ASC) ;

CREATE INDEX fk_linksources_click_sources1 ON vulcan.linksources (click_source_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.geo_locations
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.geo_locations', 'U') IS NOT NULL
DROP TABLE  vulcan.geo_locations ;

CREATE  TABLE  vulcan.geo_locations (
  id INT NOT NULL ,
  ip_low BIGINT NOT NULL ,
  ip_high BIGINT NOT NULL ,
  country_code VARCHAR(45) NOT NULL ,
  country VARCHAR(45) NOT NULL ,
  region VARCHAR(45) NOT NULL ,
  city VARCHAR(45) NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.path_categories
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.path_categories', 'U') IS NOT NULL
DROP TABLE  vulcan.path_categories ;

CREATE  TABLE  vulcan.path_categories (
  id INT NOT NULL ,
  category VARCHAR(45) NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.paths
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.paths', 'U') IS NOT NULL
DROP TABLE  vulcan.paths ;

CREATE  TABLE  vulcan.paths (
  id INT NOT NULL ,
  path VARCHAR(255) NOT NULL ,
  path_category_id INT NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_paths_path_categories1
    FOREIGN KEY (path_category_id )
    REFERENCES vulcan.path_categories (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_paths_path_categories1 ON vulcan.paths (path_category_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.foci
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.foci', 'U') IS NOT NULL
DROP TABLE  vulcan.foci ;

CREATE  TABLE  vulcan.foci (
  id INT NOT NULL ,
  name VARCHAR(64) NOT NULL ,
  url VARCHAR(45) NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.campaign_categories
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.campaign_categories', 'U') IS NOT NULL
DROP TABLE  vulcan.campaign_categories ;

CREATE  TABLE  vulcan.campaign_categories (
  id INT NOT NULL ,
  focus_id INT NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_campaign_categories_foci1
    FOREIGN KEY (focus_id )
    REFERENCES vulcan.foci (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_campaign_categories_foci1 ON vulcan.campaign_categories (focus_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.campaigns
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.campaigns', 'U') IS NOT NULL
DROP TABLE  vulcan.campaigns ;

CREATE  TABLE  vulcan.campaigns (
  id INT NOT NULL ,
  campaign_category_id INT NOT NULL ,
  campaign VARCHAR(45) NULL ,
  status VARCHAR(45) NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_campaigns_campaign_categories1
    FOREIGN KEY (campaign_category_id )
    REFERENCES vulcan.campaign_categories (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_campaigns_campaign_categories1 ON vulcan.campaigns (campaign_category_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.adgroups
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.adgroups', 'U') IS NOT NULL
DROP TABLE  vulcan.adgroups ;

CREATE  TABLE  vulcan.adgroups (
  id INT NOT NULL ,
  campaign_id INT NOT NULL ,
  title VARCHAR(45) NOT NULL ,
  short_description VARCHAR(45) NOT NULL ,
  long_description VARCHAR(255) NOT NULL ,
  elements VARCHAR(45) NULL ,
  status VARCHAR(45) NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_adgroups_campaigns1
    FOREIGN KEY (campaign_id )
    REFERENCES vulcan.campaigns (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_adgroups_campaigns1 ON vulcan.adgroups (campaign_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.adcodes
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.adcodes', 'U') IS NOT NULL
DROP TABLE  vulcan.adcodes ;

CREATE  TABLE  vulcan.adcodes (
  id INT NOT NULL ,
  adgroup_id INT NOT NULL ,
  adcode VARCHAR(32) NOT NULL ,
  target VARCHAR(255) NOT NULL ,
  match_type VARCHAR(45) NULL ,
  initial_desired_position INT NULL ,
  current_desired_position INT NULL ,
  destination_url VARCHAR(255) NULL ,
  created_at DATETIME NULL ,
  shortduration_class VARCHAR(4) NULL ,
  longduration_class VARCHAR(4) NULL ,
  status VARCHAR(45) NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_ads_adgroups
    FOREIGN KEY (adgroup_id )
    REFERENCES vulcan.adgroups (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_ads_adgroups ON vulcan.adcodes (adgroup_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.domain_redirects
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.domain_redirects', 'U') IS NOT NULL
DROP TABLE  vulcan.domain_redirects ;

CREATE  TABLE  vulcan.domain_redirects (
  id INT NOT NULL ,
  domain VARCHAR(45) NOT NULL ,
  url_id INT NOT NULL ,
  owner VARCHAR(45) NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.visits
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.visits', 'U') IS NOT NULL
DROP TABLE  vulcan.visits ;

CREATE  TABLE  vulcan.visits (
  id INT NOT NULL ,
  user_id INT NOT NULL ,
  linksource_id INT NOT NULL ,
  path_id INT NOT NULL ,
  adcode_id INT NULL ,
  domain_redirect_id INT NULL ,
  geo_location_id INT NULL ,
  created_at DATETIME NOT NULL ,
  ip BIGINT NOT NULL ,
  searchterm VARCHAR(255) NULL ,
  user_agent VARCHAR(512) NOT NULL ,
  referer VARCHAR(1024) NOT NULL ,
  refdomain VARCHAR(45) NOT NULL ,
  refpath VARCHAR(255) NOT NULL ,
  refparam VARCHAR(45) NULL ,
  refsource VARCHAR(64) NULL ,
  refdata VARCHAR(255) NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_visits_users
    FOREIGN KEY (user_id )
    REFERENCES vulcan.users (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_visits_linksources
    FOREIGN KEY (linksource_id )
    REFERENCES vulcan.linksources (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_visits_geo_locations1
    FOREIGN KEY (geo_location_id )
    REFERENCES vulcan.geo_locations (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_visits_paths1
    FOREIGN KEY (path_id )
    REFERENCES vulcan.paths (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_visits_adcodes1
    FOREIGN KEY (adcode_id )
    REFERENCES vulcan.adcodes (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_visits_domain_redirects1
    FOREIGN KEY (domain_redirect_id )
    REFERENCES vulcan.domain_redirects (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_visits_users ON vulcan.visits (user_id ASC) ;

CREATE INDEX fk_visits_linksources ON vulcan.visits (linksource_id ASC) ;

CREATE INDEX fk_visits_geo_locations1 ON vulcan.visits (geo_location_id ASC) ;

CREATE INDEX fk_visits_paths1 ON vulcan.visits (path_id ASC) ;

CREATE INDEX fk_visits_adcodes1 ON vulcan.visits (adcode_id ASC) ;

CREATE INDEX fk_visits_domain_redirects1 ON vulcan.visits (domain_redirect_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.views
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.views', 'U') IS NOT NULL
DROP TABLE  vulcan.views ;

CREATE  TABLE  vulcan.views (
  id INT NOT NULL ,
  visit_id INT NOT NULL ,
  user_id INT NOT NULL ,
  geo_location_id INT NOT NULL ,
  path_id INT NOT NULL ,
  ip BIGINT NOT NULL ,
  querystring VARCHAR(512) NOT NULL ,
  referer VARCHAR(1024) NOT NULL ,
  created_at DATETIME NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_views_visits
    FOREIGN KEY (visit_id )
    REFERENCES vulcan.visits (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_views_geo_locations1
    FOREIGN KEY (geo_location_id )
    REFERENCES vulcan.geo_locations (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_views_urls1
    FOREIGN KEY (path_id )
    REFERENCES vulcan.paths (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_views_users1
    FOREIGN KEY (user_id )
    REFERENCES vulcan.users (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_views_visits ON vulcan.views (visit_id ASC) ;

CREATE INDEX fk_views_geo_locations1 ON vulcan.views (geo_location_id ASC) ;

CREATE INDEX fk_views_urls1 ON vulcan.views (path_id ASC) ;

CREATE INDEX fk_views_users1 ON vulcan.views (user_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.affiliates
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.affiliates', 'U') IS NOT NULL
DROP TABLE  vulcan.affiliates ;

CREATE  TABLE  vulcan.affiliates (
  id INT NOT NULL ,
  affiliate VARCHAR(45) NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.companies
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.companies', 'U') IS NOT NULL
DROP TABLE  vulcan.companies ;

CREATE  TABLE  vulcan.companies (
  id INT NOT NULL ,
  focus_id INT NOT NULL ,
  company_name VARCHAR(45) NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_companies_foci1
    FOREIGN KEY (focus_id )
    REFERENCES vulcan.foci (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_companies_foci1 ON vulcan.companies (focus_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.offers
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.offers', 'U') IS NOT NULL
DROP TABLE  vulcan.offers ;

CREATE  TABLE  vulcan.offers (
  id INT NOT NULL ,
  affiliate_id INT NOT NULL ,
  company_id INT NOT NULL ,
  focus_id INT NOT NULL ,
  name VARCHAR(256) NOT NULL ,
  type VARCHAR(45) NOT NULL ,
  active INT NOT NULL ,
  format VARCHAR(45) NOT NULL ,
  start_date DATETIME NULL ,
  end_date DATETIME NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_offers_affiliates
    FOREIGN KEY (affiliate_id )
    REFERENCES vulcan.affiliates (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_offers_foci
    FOREIGN KEY (focus_id )
    REFERENCES vulcan.foci (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_offers_companies
    FOREIGN KEY (company_id )
    REFERENCES vulcan.companies (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_offers_affiliates ON vulcan.offers (affiliate_id ASC) ;

CREATE INDEX fk_offers_foci ON vulcan.offers (focus_id ASC) ;

CREATE INDEX fk_offers_companies ON vulcan.offers (company_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.buyclicks
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.buyclicks', 'U') IS NOT NULL
DROP TABLE  vulcan.buyclicks ;

CREATE  TABLE  vulcan.buyclicks (
  id INT NOT NULL ,
  view_id INT NOT NULL ,
  offer_id INT NOT NULL ,
  user_id INT NOT NULL ,
  created_at DATETIME NOT NULL ,
  link_number INT NOT NULL ,
  link_descriptor VARCHAR(64) NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_buyclicks_views
    FOREIGN KEY (view_id )
    REFERENCES vulcan.views (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_buyclicks_offers
    FOREIGN KEY (offer_id )
    REFERENCES vulcan.offers (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_buyclicks_users
    FOREIGN KEY (user_id )
    REFERENCES vulcan.users (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_buyclicks_views ON vulcan.buyclicks (view_id ASC) ;

CREATE INDEX fk_buyclicks_offers ON vulcan.buyclicks (offer_id ASC) ;

CREATE INDEX fk_buyclicks_users ON vulcan.buyclicks (user_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.lockers
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.lockers', 'U') IS NOT NULL
DROP TABLE  vulcan.lockers ;

CREATE  TABLE  vulcan.lockers (
  id INT NOT NULL ,
  created_at DATETIME NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.accounts
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.accounts', 'U') IS NOT NULL
DROP TABLE  vulcan.accounts ;

CREATE  TABLE  vulcan.accounts (
  id INT NOT NULL ,
  user_id INT NOT NULL ,
  locker_id INT NOT NULL ,
  email_address VARCHAR(64) NOT NULL ,
  registered_at DATETIME NOT NULL ,
  activated_at DATETIME NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_accounts_users1
    FOREIGN KEY (user_id )
    REFERENCES vulcan.users (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_accounts_lockers1
    FOREIGN KEY (locker_id )
    REFERENCES vulcan.lockers (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_accounts_users1 ON vulcan.accounts (user_id ASC) ;

CREATE INDEX fk_accounts_lockers1 ON vulcan.accounts (locker_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.orders
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.orders', 'U') IS NOT NULL
DROP TABLE  vulcan.orders ;

CREATE  TABLE  vulcan.orders (
  id INT NOT NULL ,
  buyclick_id INT NOT NULL ,
  affiliate_id INT NOT NULL ,
  user_id INT NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_orders_buyclicks
    FOREIGN KEY (buyclick_id )
    REFERENCES vulcan.buyclicks (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_orders_affiliates
    FOREIGN KEY (affiliate_id )
    REFERENCES vulcan.affiliates (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_orders_users
    FOREIGN KEY (user_id )
    REFERENCES vulcan.users (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_orders_buyclicks ON vulcan.orders (buyclick_id ASC) ;

CREATE INDEX fk_orders_affiliates ON vulcan.orders (affiliate_id ASC) ;

CREATE INDEX fk_orders_users ON vulcan.orders (user_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.transaction_types
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.transaction_types', 'U') IS NOT NULL
DROP TABLE  vulcan.transaction_types ;

CREATE  TABLE  vulcan.transaction_types (
  id INT NOT NULL ,
  transaction_type VARCHAR(45) NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.transactions
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.transactions', 'U') IS NOT NULL
DROP TABLE  vulcan.transactions ;

CREATE  TABLE  vulcan.transactions (
  id INT NOT NULL ,
  order_id INT NOT NULL ,
  transaction_type_id INT NOT NULL ,
  sale_amount DECIMAL(12,2) NOT NULL ,
  commission DECIMAL(12,2) NOT NULL ,
  transacted_at DATETIME NOT NULL ,
  created_at DATETIME NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_transactions_orders
    FOREIGN KEY (order_id )
    REFERENCES vulcan.orders (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_transactions_transaction_types1
    FOREIGN KEY (transaction_type_id )
    REFERENCES vulcan.transaction_types (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_transactions_orders ON vulcan.transactions (order_id ASC) ;

CREATE INDEX fk_transactions_transaction_types1 ON vulcan.transactions (transaction_type_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.clicks
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.clicks', 'U') IS NOT NULL
DROP TABLE  vulcan.clicks ;

CREATE  TABLE  vulcan.clicks (
  id INT NOT NULL ,
  linksource_id INT NOT NULL ,
  click_source_id INT NOT NULL ,
  adcode_id INT NOT NULL ,
  created_at DATETIME NOT NULL ,
  status VARCHAR(45) NULL ,
  impressions INT NULL ,
  clicks INT NOT NULL ,
  cost DECIMAL(12,2) NOT NULL ,
  quality_score VARCHAR(45) NULL ,
  average_position_clicks FLOAT NULL ,
  average_position_impressions VARCHAR(45) NULL ,
  max_bid DECIMAL(12,2) NULL ,
  min_bid DECIMAL(12,2) NULL ,
  shortduration_class VARCHAR(45) NULL ,
  match_type VARCHAR(45) NULL ,
  longduration_class VARCHAR(45) NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_clicks_click_sources1
    FOREIGN KEY (click_source_id )
    REFERENCES vulcan.click_sources (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_clicks_linksources1
    FOREIGN KEY (linksource_id )
    REFERENCES vulcan.linksources (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_clicks_adcodes1
    FOREIGN KEY (adcode_id )
    REFERENCES vulcan.adcodes (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_clicks_click_sources1 ON vulcan.clicks (click_source_id ASC) ;

CREATE INDEX fk_clicks_linksources1 ON vulcan.clicks (linksource_id ASC) ;

CREATE INDEX fk_clicks_adcodes1 ON vulcan.clicks (adcode_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.searches
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.searches', 'U') IS NOT NULL
DROP TABLE  vulcan.searches ;

CREATE  TABLE  vulcan.searches (
  id INT NOT NULL ,
  visit_id INT NOT NULL ,
  view_id INT NOT NULL ,
  query VARCHAR(255) NOT NULL ,
  created_at DATETIME NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_searches_visits
    FOREIGN KEY (visit_id )
    REFERENCES vulcan.visits (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_searches_views
    FOREIGN KEY (view_id )
    REFERENCES vulcan.views (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_searches_visits ON vulcan.searches (visit_id ASC) ;

CREATE INDEX fk_searches_views ON vulcan.searches (view_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.locker_objects
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.locker_objects', 'U') IS NOT NULL
DROP TABLE  vulcan.locker_objects ;

CREATE  TABLE  vulcan.locker_objects (
  id INT NOT NULL ,
  locker_id INT NOT NULL ,
  offer_id INT NOT NULL ,
  company_id INT NOT NULL ,
  added_at DATETIME NOT NULL ,
  removed_at DATETIME NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_locker_objects_lockers
    FOREIGN KEY (locker_id )
    REFERENCES vulcan.lockers (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_locker_objects_offers
    FOREIGN KEY (offer_id )
    REFERENCES vulcan.offers (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_locker_objects_companies
    FOREIGN KEY (company_id )
    REFERENCES vulcan.companies (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_locker_objects_lockers ON vulcan.locker_objects (locker_id ASC) ;

CREATE INDEX fk_locker_objects_offers ON vulcan.locker_objects (offer_id ASC) ;

CREATE INDEX fk_locker_objects_companies ON vulcan.locker_objects (company_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.users_visits
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.users_visits', 'U') IS NOT NULL
DROP TABLE  vulcan.users_visits ;

CREATE  TABLE  vulcan.users_visits (
  visit_id INT NOT NULL ,
  user_id INT NOT NULL ,
  previous_visit_id INT NOT NULL ,
  PRIMARY KEY (visit_id) ,
  CONSTRAINT fk_user_visits_visits1
    FOREIGN KEY (visit_id )
    REFERENCES vulcan.visits (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_user_visits_users1
    FOREIGN KEY (user_id )
    REFERENCES vulcan.users (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_user_visits_visits1 ON vulcan.users_visits (visit_id ASC) ;

CREATE INDEX fk_user_visits_users1 ON vulcan.users_visits (user_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.edges
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.edges', 'U') IS NOT NULL
DROP TABLE  vulcan.edges ;

CREATE  TABLE  vulcan.edges (
  id INT NOT NULL ,
  from_url VARCHAR(255) NOT NULL ,
  to_url VARCHAR(255) NOT NULL ,
  created_at DATETIME NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.affiliates_companies
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.affiliates_companies', 'U') IS NOT NULL
DROP TABLE  vulcan.affiliates_companies ;

CREATE  TABLE  vulcan.affiliates_companies (
  affiliate_id INT NOT NULL ,
  company_id INT NOT NULL ,
  PRIMARY KEY (affiliate_id, company_id) ,
  CONSTRAINT fk_affiliates_companies_affiliates1
    FOREIGN KEY (affiliate_id )
    REFERENCES vulcan.affiliates (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_affiliates_companies_companies2
    FOREIGN KEY (company_id )
    REFERENCES vulcan.companies (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_affiliates_companies_affiliates1 ON vulcan.affiliates_companies (affiliate_id ASC) ;

CREATE INDEX fk_affiliates_companies_companies2 ON vulcan.affiliates_companies (company_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.offers_foci
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.offers_foci', 'U') IS NOT NULL
DROP TABLE  vulcan.offers_foci ;

CREATE  TABLE  vulcan.offers_foci (
  id INT NOT NULL ,
  focus_id INT NOT NULL ,
  PRIMARY KEY (id, focus_id) )


-- -----------------------------------------------------
-- Table vulcan.pages
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.pages', 'U') IS NOT NULL
DROP TABLE  vulcan.pages ;

CREATE  TABLE  vulcan.pages (
  id INT NOT NULL ,
  url VARCHAR(255) NOT NULL ,
  depth INT NOT NULL ,
  title VARCHAR(512) NOT NULL ,
  h1 VARCHAR(1024) NOT NULL ,
  h2 VARCHAR(1024) NOT NULL ,
  description VARCHAR(512) NOT NULL ,
  linktext VARCHAR(512) NOT NULL ,
  created_at DATETIME NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.bot_agents
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.bot_agents', 'U') IS NOT NULL
DROP TABLE  vulcan.bot_agents ;

CREATE  TABLE  vulcan.bot_agents (
  id INT NOT NULL IDENTITY(1,1) ,
  agent_group VARCHAR(45) NOT NULL ,
  agent_match VARCHAR(255) NOT NULL ,
  exact INT NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.junk_agents
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.junk_agents', 'U') IS NOT NULL
DROP TABLE  vulcan.junk_agents ;

CREATE  TABLE  vulcan.junk_agents (
  id INT NOT NULL ,
  agent_match VARCHAR(255) NOT NULL ,
  exact INT NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.bot_ips
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.bot_ips', 'U') IS NOT NULL
DROP TABLE  vulcan.bot_ips ;

CREATE  TABLE  vulcan.bot_ips (
  id INT NOT NULL IDENTITY(1,1) ,
  ip_low BIGINT NOT NULL ,
  ip_high BIGINT NOT NULL ,
  name VARCHAR(45) NOT NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.linksource_match_types
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.linksource_match_types', 'U') IS NOT NULL
DROP TABLE  vulcan.linksource_match_types ;

CREATE  TABLE  vulcan.linksource_match_types (
  id INT NOT NULL ,
  pattern VARCHAR(255) NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.linksource_matches
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.linksource_matches', 'U') IS NOT NULL
DROP TABLE  vulcan.linksource_matches ;

CREATE  TABLE  vulcan.linksource_matches (
  id INT NOT NULL ,
  linksource_match_type_id INT NOT NULL ,
  column_name VARCHAR(45) NOT NULL ,
  match VARCHAR(45) NOT NULL ,
  linksource VARCHAR(45) NOT NULL ,
  linksource_group INT NULL ,
  description VARCHAR(45) NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_linksource_maps_linksource_match_types1
    FOREIGN KEY (linksource_match_type_id )
    REFERENCES vulcan.linksource_match_types (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_linksource_maps_linksource_match_types1 ON vulcan.linksource_matches (linksource_match_type_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.raw_sessions
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.raw_sessions', 'U') IS NOT NULL
DROP TABLE  vulcan.raw_sessions ;

CREATE  TABLE  vulcan.raw_sessions (
  id INT NOT NULL ,
  session_token VARCHAR(40) NOT NULL ,
  useragent VARCHAR(512) NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.raw_pageviews
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.raw_pageviews', 'U') IS NOT NULL
DROP TABLE  vulcan.raw_pageviews ;

CREATE  TABLE  vulcan.raw_pageviews (
  id INT NOT NULL ,
  session_token VARCHAR(40) NOT NULL ,
  path VARCHAR(255) NOT NULL ,
  querystring VARCHAR(512) NULL ,
  adcode VARCHAR(32) NULL ,
  ip BIGINT NOT NULL ,
  referer VARCHAR(1024) NULL ,
  timestamp DATETIME NOT NULL ,
  userid INT NULL ,
  refsource VARCHAR(64) NULL ,
  refdata VARCHAR(255) NULL ,
  PRIMARY KEY (id) )


-- -----------------------------------------------------
-- Table vulcan.raw_buyclicks
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.raw_buyclicks', 'U') IS NOT NULL
DROP TABLE  vulcan.raw_buyclicks ;

CREATE  TABLE  vulcan.raw_buyclicks (
  id INT NOT NULL ,
  session_token CHAR(40) NOT NULL ,
  user_id INT NULL ,
  link_number INT NOT NULL ,
  link_descriptor VARCHAR(64) NOT NULL ,
  company_id INT NOT NULL ,
  offer_id INT NOT NULL ,
  platform CHAR(2) NOT NULL ,
  timestamp DATETIME NOT NULL ,
  view_id INT NOT NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_raw_buyclicks_raw_pageviews1
    FOREIGN KEY (view_id )
    REFERENCES vulcan.raw_pageviews (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_raw_buyclicks_raw_pageviews1 ON vulcan.raw_buyclicks (view_id ASC) ;


-- -----------------------------------------------------
-- Table vulcan.raw_searches
-- -----------------------------------------------------
IF OBJECT_ID('vulcan.raw_searches', 'U') IS NOT NULL
DROP TABLE  vulcan.raw_searches ;

CREATE  TABLE  vulcan.raw_searches (
  id INT NOT NULL ,
  session_token CHAR(40) NOT NULL ,
  query VARCHAR(4000) NOT NULL ,
  object_type VARCHAR(4000) NULL ,
  object_id INT NULL ,
  timestamp DATETIME NOT NULL ,
  view_id INT NOT NULL ,
  total_results INT NULL ,
  stemmed_query VARCHAR(255) NULL ,
  results VARCHAR(4000) NULL ,
  speed INT NULL ,
  notes VARCHAR(4000) NULL ,
  PRIMARY KEY (id) ,
  CONSTRAINT fk_raw_searches_raw_pageviews1
    FOREIGN KEY (view_id )
    REFERENCES vulcan.raw_pageviews (id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)

CREATE INDEX fk_raw_searches_raw_pageviews1 ON vulcan.raw_searches (view_id ASC) ;



COMMIT
