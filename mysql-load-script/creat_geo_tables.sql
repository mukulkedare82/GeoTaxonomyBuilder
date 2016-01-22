use geoDB;

#create table adxGeoData

DROP TABLE IF EXISTS adxGeoData;
CREATE TABLE adxGeoData (dummy INT);
ALTER TABLE adxGeoData ADD COLUMN CriteriaID INT;
ALTER TABLE adxGeoData ADD COLUMN Name VARCHAR(256);
ALTER TABLE adxGeoData ADD COLUMN CanonicalName VARCHAR(256);
ALTER TABLE adxGeoData ADD COLUMN ParentIDs VARCHAR(256);
ALTER TABLE adxGeoData ADD COLUMN BlankField VARCHAR(256);
ALTER TABLE adxGeoData ADD COLUMN CountryCode VARCHAR(256);
ALTER TABLE adxGeoData ADD COLUMN TargetType VARCHAR(256);
ALTER TABLE adxGeoData DROP COLUMN dummy;
#primary key added as last column for load csv to work
ALTER TABLE adxGeoData ADD COLUMN id INT auto_increment primary key;
ALTER TABLE adxGeoData ENGINE=InnoDB;
ALTER TABLE adxGeoData CONVERT TO CHARACTER SET utf8;

#create table iso31663CountryData

DROP TABLE IF EXISTS iso31663CountryData;
CREATE TABLE iso31663CountryData (dummy INT);
ALTER TABLE iso31663CountryData ADD COLUMN CountryCode VARCHAR(256);
ALTER TABLE iso31663CountryData ADD COLUMN CountryName VARCHAR(256);
ALTER TABLE iso31663CountryData ADD COLUMN OtherName VARCHAR(256) DEFAULT "";
ALTER TABLE iso31663CountryData DROP COLUMN dummy;
#primary key added as last column for load csv to work
ALTER TABLE iso31663CountryData ADD COLUMN id INT auto_increment primary key;
ALTER TABLE iso31663CountryData ENGINE=InnoDB;
ALTER TABLE iso31663CountryData CONVERT TO CHARACTER SET utf8;

#create table isoTofipsCodes

DROP TABLE IF EXISTS isoTofipsCodes;
CREATE TABLE isoTofipsCodes (dummy INT);
ALTER TABLE isoTofipsCodes ADD COLUMN fipsCode VARCHAR(256) DEFAULT "";
ALTER TABLE isoTofipsCodes ADD COLUMN isoCodeA2 VARCHAR(256) DEFAULT "";
ALTER TABLE isoTofipsCodes ADD COLUMN isoCodeA3 VARCHAR(256) DEFAULT "";
ALTER TABLE isoTofipsCodes ADD COLUMN isoCodeN3 VARCHAR(256) DEFAULT "";
ALTER TABLE isoTofipsCodes DROP COLUMN dummy;
#primary key added as last column for load csv to work
ALTER TABLE isoTofipsCodes ADD COLUMN id INT auto_increment primary key;
ALTER TABLE isoTofipsCodes ENGINE=InnoDB;
ALTER TABLE isoTofipsCodes CONVERT TO CHARACTER SET utf8;

#create table iso31662RegionData

DROP TABLE IF EXISTS iso31662RegionData;
CREATE TABLE iso31662RegionData (dummy INT);
ALTER TABLE iso31662RegionData ADD COLUMN CountryCode VARCHAR(256);
ALTER TABLE iso31662RegionData ADD COLUMN RegionCode VARCHAR(256);
ALTER TABLE iso31662RegionData ADD COLUMN RegionName VARCHAR(256);
ALTER TABLE iso31662RegionData ADD COLUMN RegionLevel VARCHAR(256);
ALTER TABLE iso31662RegionData DROP COLUMN dummy;
#primary key added as last column for load csv to work
ALTER TABLE iso31662RegionData ADD COLUMN id INT auto_increment primary key;
ALTER TABLE iso31662RegionData ENGINE=InnoDB;
ALTER TABLE iso31662RegionData CONVERT TO CHARACTER SET utf8;

#create table fipsRegionData

DROP TABLE IF EXISTS fipsRegionData;
CREATE TABLE fipsRegionData (dummy INT);
ALTER TABLE fipsRegionData ADD COLUMN CountryCode VARCHAR(256);
ALTER TABLE fipsRegionData ADD COLUMN RegionCode VARCHAR(256);
ALTER TABLE fipsRegionData ADD COLUMN RegionName VARCHAR(256);
ALTER TABLE fipsRegionData DROP COLUMN dummy;
#primary key added as last column for load csv to work
ALTER TABLE fipsRegionData ADD COLUMN id INT auto_increment primary key;
ALTER TABLE fipsRegionData ENGINE=InnoDB;
ALTER TABLE fipsRegionData CONVERT TO CHARACTER SET utf8;
