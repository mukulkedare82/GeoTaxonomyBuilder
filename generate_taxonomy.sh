#!/bin/bash
#set -x
#sudo chmod +s loadcsvs.sh

####	DB configuration ####
MYSQL_USERNAME="root";
MYSQL_PASSWORD="root123";
MYSQL_DBNAME="geoDB";


#Table Names
ADXGEODATATABLE="adxGeoData"
ISO3COUNTRYTABLENAME="iso31663CountryData"
ISO2REGIONTABLENAME="iso31662RegionData";
FIPSREGIONTABLENAME="fipsRegionData";
ISOTOFIPSCODETABLE="isoTofipsCodes";


GEOTABLENAME_PREFIX="aeGeoTable_";
TODAY=$(date +"%m%d%Y_%H%M%S");
GEOTABLENAME="$GEOTABLENAME_PREFIX$TODAY";
#GEOTABLENAME="aeGeoTable_01212016_162749";
GEOTAXONOMYFILESUFFIX="_ae_geo_taxonomy.csv";
GEOTAXONOMYFILEPATH="/home/GeoTaxonomies/$GEOTABLENAME$GEOTAXONOMYFILESUFFIX";
GEOTAXONOMYTMPFILE="/tmp/"`basename $GEOTAXONOMYFILEPATH`; 
retval="";

#Data fields
GEOLEVELCOUNTRY=1;
GEOLEVELSTATE=2;
GEOLEVELCITY=3;
GEOLEVELPOSTAL=4;
GEOLEVELDMA=5;
GEOLEVELOTHERS=6;

PRIMARYKEY_SKIP_COUNTRY=250;
PRIMARYKEY_SKIP_REGION=5000;
PRIMARYKEY_SKIP_CITY=35000;
PRIMARYKEY_SKIP_POSTAL=45000;
PRIMARYKEY_SKIP_DMA=250;
PRIMARYKEY_SKIP_OTHERS=2000;



#Insert matched entries from Adx Table into aeGeoTable using isoname
INSERTISO3ADXQUERY1="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, isoName, adxCanonicalName, isoOtherName, adxParentIDs, adxBlankField,  isoCode, adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, iso.CountryName as isoName, adx.CanonicalName as adxCanonicalName, iso.OtherName as isoOtherName,  adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, iso.CountryCode as isoCode, adx.CountryCode as adxCode, adx.TargetType as adxTargetType, $GEOLEVELCOUNTRY as aeGeoLevel from $ADXGEODATATABLE adx, $ISO3COUNTRYTABLENAME iso where adx.Name = iso.CountryName AND adx.TargetType = 'Country'";

#Insert matched entries from Adx Table into aeGeoTable using iso other name
INSERTISO3ADXQUERY2="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, isoName, adxCanonicalName, isoOtherName, adxParentIDs, adxBlankField,  isoCode, adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, iso.CountryName as isoName, adx.CanonicalName as adxCanonicalName, iso.OtherName as isoOtherName,  adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, iso.CountryCode as isoCode, adx.CountryCode as adxCode, adx.TargetType as adxTargetType, $GEOLEVELCOUNTRY as aeGeoLevel from $ADXGEODATATABLE adx, $ISO3COUNTRYTABLENAME iso where adx.Name = iso.OtherName AND adx.TargetType = 'Country' AND adx.Name not in (select IFNULL(adxName, 'xxx') from $GEOTABLENAME where aeGeoLevel = $GEOLEVELCOUNTRY)";

#### OLD QUERIES START ####
#Insert mismatched entries from Adx Table into aeGeoTable
#INERTFROMADXQUERY="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, adxCanonicalName, adxParentIDs, adxBlankField,  adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, adx.CountryCode as adxCountryCode, adx.TargetType as adxTargetType, $GEOLEVELCOUNTRY as aeGeoLevel from $ADXGEODATATABLE as adx where adx.TargetType = 'Country' AND adx.Name not in (select IFNULL(adxName, 'xxx') from $GEOTABLENAME where aeGeoLevel = $GEOLEVELCOUNTRY)";

#Insert mismatched entries from ISO Table into aeGeoTable
#INERTFROMISOQUERY="INSERT INTO $GEOTABLENAME (isoName, isoOtherName, isoCode, aeGeoLevel) select iso.CountryName, iso.OtherName, iso.CountryCode, $GEOLEVELCOUNTRY as aeGeoLevel from $ISO3COUNTRYTABLENAME as iso where iso.CountryName not in (select IFNULL(isoName, 'xxx') from $GEOTABLENAME where aeGeoLevel = $GEOLEVELCOUNTRY)";
#### OLD QUERIES END ####

#Insert mismatched entries from Adx Table into aeGeoTable, pick corressponding A3 codes from $ISOTOFIPSCODETABLE
#check if exists by name with existing entries
INERTFROMADXQUERY="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, adxCanonicalName, adxParentIDs, adxBlankField,  adxCode, adxTargetType, isoCode, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, adx.CountryCode as adxCountryCode, adx.TargetType as adxTargetType, itof.isoCodeA3, $GEOLEVELCOUNTRY as aeGeoLevel from $ADXGEODATATABLE as adx, $ISOTOFIPSCODETABLE as itof where adx.TargetType = 'Country' AND itof.isoCodeA2 = adx.CountryCode AND adx.Name not in (select IFNULL(adxName, 'xxx') from $GEOTABLENAME where aeGeoLevel = $GEOLEVELCOUNTRY)";

#Insert mismatched entries from ISO Table into aeGeoTable
#check if exists by country codes with existing entries
INERTFROMISOQUERY="INSERT INTO $GEOTABLENAME (isoName, isoOtherName, isoCode, aeGeoLevel) select iso.CountryName, iso.OtherName, iso.CountryCode, $GEOLEVELCOUNTRY as aeGeoLevel from $ISO3COUNTRYTABLENAME as iso where iso.CountryCode not in (select IFNULL(isoCode, 'xxx') from $GEOTABLENAME where aeGeoLevel = $GEOLEVELCOUNTRY)";


#CREATE Geo Table
CREATEGEOTABLEQUERY="CREATE TABLE $GEOTABLENAME (aeGeoId BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
adxCriteriaID int(11) DEFAULT NULL,
fipsName varchar(256) DEFAULT NULL,
adxName varchar(256) DEFAULT NULL,
isoName varchar(256) DEFAULT NULL,
adxCanonicalName varchar(256) DEFAULT NULL,
isoOtherName varchar(256) DEFAULT '',
adxParentIDs varchar(256) DEFAULT NULL,
adxBlankField varchar(256) DEFAULT NULL,
fipsCountryCode varchar(256) DEFAULT NULL,
fipsCode varchar(256) DEFAULT NULL,
isoCountryCode varchar(256) DEFAULT NULL,
iso3CountryCode varchar(256) DEFAULT NULL,
isoCode varchar(256) DEFAULT NULL,
adxCode varchar(256) DEFAULT NULL,
adxTargetType varchar(256) DEFAULT NULL,
aeGeoLevel int(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8"


execQuery(){
	QUERY="$1;";
	echo $QUERY;
	#echo "BEGIN Query: $QUERY";
	retval=`mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $MYSQL_DBNAME -s -N -e "$QUERY"`;
	#echo $?;
	#if [ $? -ne 0 ]
	#then
	#	echo "FAILURE: Query Execution:  $QUERY";
	#	exit;
	#fi	
	#echo "END Query retval:$retval";
	return $?;
}

skipAutoIncrementBy(){
	AUTOICREMENTVALUE=$1;	#set global value
	TableName=$2;
	QUERY="select count(*) from $TableName";
	execQuery "$QUERY";
	count=$retval;
	#if count greater than zero then add count displacement
	if [ `expr $count` -gt 0 ]
	then
		AUTOICREMENTVALUE=`expr $count + $AUTOICREMENTVALUE`; #set global value
	fi
	echo "Setting auto_increment value to $AUTOICREMENTVALUE";
	#set auto_increment to AUTOICREMENTVALUE in alter auto_increment query
	ALTERPRIMARYKEYQUERY="ALTER TABLE $TableName AUTO_INCREMENT=$AUTOICREMENTVALUE";
	echo $ALTERPRIMARYKEYQUERY;
	execQuery "$ALTERPRIMARYKEYQUERY";
}

printCount(){
	TableName=$1;
	QUERY="select count(*) from $TableName";
	execQuery "$QUERY";
	echo $retval;
}

createGeoTable(){
	echo "create CountryTable $GEOTABLENAME";
	execQuery "$CREATEGEOTABLEQUERY";

	#set auto increment initial value (to 1)
	skipAutoIncrementBy 1 $GEOTABLENAME;
}

#merge and add iso3 + adx country data
generateCountryDataISO3ADX(){
	
	echo "#### GENERATING COUNTRY DATA ####";

	echo "Query1: insert ADX, ISO3  Country match entries to CountryTable using isoName";
	execQuery "$INSERTISO3ADXQUERY1";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "Query2: insert ADX, ISO3  Country match entries to CountryTable using isoOtherName";
	execQuery "$INSERTISO3ADXQUERY2";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;

	echo "Query3: insert ADX Country mismatched entries to CountryTable";
	execQuery "$INERTFROMADXQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;

	echo "Query4: insert ISO Country mismatched entries to CountryTable";
	execQuery "$INERTFROMISOQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;

	echo "skipping AUTO_INCREMENT By $PRIMARYKEY_SKIP_COUNTRY"
	skipAutoIncrementBy $PRIMARYKEY_SKIP_COUNTRY $GEOTABLENAME;
}




####	Region Data Queries, Execute in same order ####

INARGSADXTREATASREGIONS="'County', 'Province', 'State', 'Territory', 'Region', 'Autonomous Community', 'Union Territory', 'Prefecture', 'Governorate'";

#1. Get adx + fips + iso union
INSERTREGIONSADXISOFIPSQUERY="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, isoName, fipsName, adxCanonicalName, adxParentIDs, adxBlankField,  fipsCode, isoCode, adxCode, fipsCountryCode, isoCountryCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, iso.RegionName as isoName, fips.RegionName as fipsName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, fips.RegionCode as fipsCode, iso.RegionCode as isoCode, adx.CountryCode as adxCode, fips.CountryCode as fipsCountryCode, iso.CountryCode as isoCountryCode, adx.TargetType as adxTargetType, $GEOLEVELSTATE as aeGeoLevel from $ADXGEODATATABLE adx, $ISO2REGIONTABLENAME iso, $FIPSREGIONTABLENAME fips where adx.Name = iso.RegionName AND adx.Name = fips.RegionName AND adx.CountryCode = iso.CountryCode AND adx.CountryCode = fips.CountryCode AND adx.TargetType in ($INARGSADXTREATASREGIONS)";

#2. get union of unmatched entries (in adx+iso+fips mismatch with fips) i.e adx + iso union
INSERTREGIONSADXISOQUERY="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, isoName, adxCanonicalName, adxParentIDs, adxBlankField,  isoCode, adxCode, isoCountryCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, iso.RegionName as isoName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, iso.RegionCode as isoCode, adx.CountryCode as adxCode, iso.CountryCode as isoCountryCode, adx.TargetType as adxTargetType, $GEOLEVELSTATE as aeGeoLevel from $ADXGEODATATABLE adx, $ISO2REGIONTABLENAME iso where adx.Name = iso.RegionName AND adx.CountryCode = iso.CountryCode AND adx.TargetType in ($INARGSADXTREATASREGIONS) AND CONCAT(adx.CountryCode, ':', adx.Name) not in (select IFNULL(CONCAT(adxCode, ':',adxName), 'xx:xxxx') as CountryRegionName from $GEOTABLENAME where aeGeoLevel = $GEOLEVELSTATE)";

#3. get union of unmatched entries (in adx+iso+fips mismatch with iso) i.e adx + fips union
INSERTREGIONSADXFIPSQUERY="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, fipsName, adxCanonicalName, adxParentIDs, adxBlankField,  fipsCode, adxCode, fipsCountryCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, fips.RegionName as fipsName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, fips.RegionCode as fipsCode, adx.CountryCode as adxCode, fips.CountryCode as fipsCountryCode, adx.TargetType as adxTargetType, $GEOLEVELSTATE as aeGeoLevel from $ADXGEODATATABLE adx, $FIPSREGIONTABLENAME fips where adx.Name = fips.RegionName AND adx.CountryCode = fips.CountryCode AND adx.TargetType in ($INARGSADXTREATASREGIONS) AND CONCAT(adx.CountryCode, ':', adx.Name) not in (select IFNULL(CONCAT(adxCode, ':',adxName), 'xx:xxxx') as CountryRegionName from $GEOTABLENAME where aeGeoLevel = $GEOLEVELSTATE)";


#4. get union of unmatched entries (in adx+iso+fips mismatch with adx) i.e iso + fips union
INSERTREGIONSISOFIPSQUERY="INSERT INTO $GEOTABLENAME (fipsName, fipsCode, fipsCountryCode, isoName, isoCode, isoCountryCode, aeGeoLevel) select fips.RegionName as fipsName, fips.RegionCode as fipsCode, fips.CountryCode as fipsCountryCode, iso.RegionName as isoName, iso.RegionCode as isoCode, iso.CountryCode as isoCountryCode, $GEOLEVELSTATE as aeGeoLevel from $FIPSREGIONTABLENAME fips, $ISO2REGIONTABLENAME iso where iso.RegionName = fips.RegionName AND fips.CountryCode = iso.CountryCode AND CONCAT(iso.CountryCode, ':' ,iso.RegionName) not in (select IFNULL(CONCAT(isoCountryCode, ':' ,isoName), 'xx:xxxx') as CountryRegionName from $GEOTABLENAME where aeGeoLevel = $GEOLEVELSTATE)";

#5. get rest of the adx entries which had mismatch with iso and fips
INSERTREGIONSADXQUERY="INSERT INTO $GEOTABLENAME (adxCriteriaID, adxName, adxCanonicalName, adxParentIDs, adxBlankField,  adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField, adx.CountryCode as adxCode, adx.TargetType as adxTargetType, $GEOLEVELSTATE as aeGeoLevel from $ADXGEODATATABLE adx where adx.TargetType in ($INARGSADXTREATASREGIONS) AND CONCAT(adx.CountryCode, ':', adx.Name) not in (select IFNULL(CONCAT(adxCode, ':',adxName), 'xx:xxxx') as CountryRegionName from $GEOTABLENAME where aeGeoLevel = $GEOLEVELSTATE)";

#6. get rest of the fips entries which had mismatch with iso and adx
INSERTREGIONSFIPSQUERY="INSERT INTO $GEOTABLENAME (fipsName, fipsCode, fipsCountryCode, aeGeoLevel) select fips.RegionName as fipsName, fips.RegionCode as fipsCode, fips.CountryCode as fipsCountryCode, $GEOLEVELSTATE as aeGeoLevel from $FIPSREGIONTABLENAME fips where CONCAT(fips.CountryCode, ':', fips.RegionName) not in (select IFNULL(CONCAT(fipsCountryCode, ':', fipsName), 'xx:xxxx') as CountryRegionName from $GEOTABLENAME where aeGeoLevel = $GEOLEVELSTATE)";

#7. get rest of the iso entries which had mismatch with fips and adx
INSERTREGIONSISOQUERY="INSERT INTO $GEOTABLENAME (isoName, isoCode, isoCountryCode, aeGeoLevel) select iso.RegionName as isoName, iso.RegionCode as isoCode, iso.CountryCode as isoCountryCode, $GEOLEVELSTATE as aeGeoLevel from $ISO2REGIONTABLENAME iso where CONCAT(iso.CountryCode, ':', iso.RegionName) not in (select IFNULL(CONCAT(isoCountryCode, ':', isoName), 'xx:xxxx') as CountryRegionName from $GEOTABLENAME where aeGeoLevel = $GEOLEVELSTATE)";


#merge and add iso + fips + adx region data
generateRegionDataISO3ADXFIPS(){
	
	echo "#### GENERATING REGION DATA ####";
				
	echo "Query1: insert ADX, ISO2, FIPS Region match entries to $GEOTABLENAME";
	execQuery "$INSERTREGIONSADXISOFIPSQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "Query2: insert ADX + ISO Region mismatched entries to $GEOTABLENAME";
	execQuery "$INSERTREGIONSADXISOQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "Query3: insert ADX + FIPS Region mismatched entries to $GEOTABLENAME";
	execQuery "$INSERTREGIONSADXFIPSQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "Query4: insert ISO + FIPS Region mismatched entries to $GEOTABLENAME";
	execQuery "$INSERTREGIONSISOFIPSQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "Query5: insert ADX Remaining Region mismatched entries to $GEOTABLENAME";
	execQuery "$INSERTREGIONSADXQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "Query6: insert FIPS Remaining Region mismatched entries to $GEOTABLENAME";
	execQuery "$INSERTREGIONSFIPSQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "Query7: insert ISO Remaining Region mismatched entries to $GEOTABLENAME";
	execQuery "$INSERTREGIONSISOQUERY";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "skipping AUTO_INCREMENT By $PRIMARYKEY_SKIP_REGION"
	skipAutoIncrementBy $PRIMARYKEY_SKIP_REGION $GEOTABLENAME;

	return;
}


#all cities from adx
generateCityData(){
	echo "#### GENERATING CITY DATA ####";

INSERTADXCITYDATA="insert into $GEOTABLENAME (adxCriteriaID, adxName, adxCanonicalName, adxParentIDs, adxBlankField, adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField,  adx.CountryCode as adxCode, adx.TargetType as adxTargetType, $GEOLEVELCITY as aeGeoLevel from $ADXGEODATATABLE adx where adx.TargetType = 'City' AND adx.CriteriaID not in (select IFNULL(adxCriteriaID, -1) as criteriaID from $GEOTABLENAME)";

	echo "Query1: insert ADX City entries to $GEOTABLENAME";
	echo $INSERTADXCITYDATA;
	execQuery "$INSERTADXCITYDATA";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "skipping AUTO_INCREMENT By $PRIMARYKEY_SKIP_CITY"
	skipAutoIncrementBy $PRIMARYKEY_SKIP_CITY $GEOTABLENAME;
	return;
}


#add Postal from adx
generatePostalData(){

INSERTADXPOSTALDATA="insert into $GEOTABLENAME (adxCriteriaID, adxName, adxCanonicalName, adxParentIDs, adxBlankField, adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField,  adx.CountryCode as adxCode, adx.TargetType as adxTargetType, $GEOLEVELPOSTAL as aeGeoLevel from $ADXGEODATATABLE adx where adx.TargetType = 'Postal Code' AND adx.CriteriaID not in (select IFNULL(adxCriteriaID, -1) as criteriaID from $GEOTABLENAME)";

	echo "#### GENERATING POSTAL DATA ####";
	echo "Query1: insert ADX POSTAL entries to $GEOTABLENAME";
	execQuery "$INSERTADXPOSTALDATA";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "skipping AUTO_INCREMENT By $PRIMARYKEY_SKIP_POSTAL"
	skipAutoIncrementBy $PRIMARYKEY_SKIP_POSTAL $GEOTABLENAME;
	return;
}


#add Region DMA from adx
generateDMAData(){

INSERTADXDMADATA="insert into $GEOTABLENAME (adxCriteriaID, adxName, adxCanonicalName, adxParentIDs, adxBlankField, adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField,  adx.CountryCode as adxCode, adx.TargetType as adxTargetType, $GEOLEVELDMA as aeGeoLevel from $ADXGEODATATABLE adx where adx.TargetType = 'DMA Region' AND adx.CriteriaID not in (select IFNULL(adxCriteriaID, -1) as criteriaID from $GEOTABLENAME)";

	echo "#### GENERATING DMA DATA ####";
	echo "Query1: insert ADX DMA entries to $GEOTABLENAME";
	execQuery "$INSERTADXDMADATA";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "skipping AUTO_INCREMENT By $PRIMARYKEY_SKIP_POSTAL"
	skipAutoIncrementBy $PRIMARYKEY_SKIP_POSTAL $GEOTABLENAME;
	return;
}

#add other geos from adx
generateOthersData(){

INARGSNOTOTHERSGEO="'Postal Code', 'DMA Region', 'City', 'Country', 'County', 'Province', 'State', 'Territory', 'Region', 'Autonomous Community', 'Union Territory', 'Prefecture', 'Governorate'";

INSERTADXOTHERSDATA="insert into $GEOTABLENAME (adxCriteriaID, adxName, adxCanonicalName, adxParentIDs, adxBlankField, adxCode, adxTargetType, aeGeoLevel) select adx.CriteriaID as adxCriteriaID, adx.Name as adxName, adx.CanonicalName as adxCanonicalName, adx.ParentIDs as adxParentIDs, adx.BlankField as adxBlankField,  adx.CountryCode as adxCode, adx.TargetType as adxTargetType, $GEOLEVELOTHERS as aeGeoLevel from adxGeoData adx where adx.TargetType not in ($INARGSNOTOTHERSGEO) AND adx.CriteriaID not in (select IFNULL(adxCriteriaID, -1) as criteriaID from $GEOTABLENAME)";

	echo "#### GENERATING OTHER GEO DATA ####";
	echo "Query1: insert ADX Others entries to $GEOTABLENAME";
	execQuery "$INSERTADXOTHERSDATA";
	printCount $GEOTABLENAME;
	skipAutoIncrementBy 1 $GEOTABLENAME;
	
	echo "skipping AUTO_INCREMENT By $PRIMARYKEY_SKIP_OTHERS"
	skipAutoIncrementBy $PRIMARYKEY_SKIP_OTHERS $GEOTABLENAME;
	return;
}

#unused hardcoded usa adjustement --- not needed
runAdjustmentQueries(){

UPDATEUSDUPLICATE="update $GEOTABLENAME set isoName='United States of America', isoCode='USA' where aeGeoLevel=$GEOLEVELCOUNTRY AND adxCode = 'US'";
REMOVEUSDUPLICATE="delete from testGeoTaxonomy where aeGeoLevel = 1 AND adxCode IS NULL AND isoCode = 'USA';"

echo "Query1: Merge country USA entry to $GEOTABLENAME";
execQuery "$UPDATEUSDUPLICATE";
execQuery "$REMOVEUSDUPLICATE=";
}

#set iso3 country codes for all geos
setISO3CountryCodeToALL(){

SETCountryISO3CodeFORALLGEOS="update $GEOTABLENAME geo left join $GEOTABLENAME country ON geo.adxCode = country.adxCode AND country.aeGeoLevel = $GEOLEVELCOUNTRY AND geo.aeGeoLevel > $GEOLEVELCOUNTRY set geo.iso3CountryCode = country.isoCode";

	echo "#### SETTING ISO3 COUNTRY CODE FOR ALL GEO DATA ####";
	#echo "$SETCountryISO3CodeFORALLGEOS"
	echo "Query1: Set ISO3 country code for all geos in $GEOTABLENAME using country codes at geoLevel $GEOLEVELCOUNTRY";
	execQuery "$SETCountryISO3CodeFORALLGEOS";
	return 0;
}


EXPORTTAXONOMYASCSV="SELECT 
IFNULL(aeGeoId, -1),
IFNULL(aeGeoLevel, -1),
IFNULL(adxCriteriaID, -1),
IFNULL(fipsName, \"\"),
IFNULL(adxName, \"\"),
IFNULL(isoName, \"\"),
REPLACE(IFNULL(adxCanonicalName, \"\"), \",\", \":\"),
REPLACE(IFNULL(adxParentIDs, \"\"), \",\", \":\"),
IFNULL(adxBlankField, \"\"),
IFNULL(fipsCountryCode, \"\"),
IFNULL(fipsCode, \"\"),
IFNULL(isoCountryCode, \"\"),
IFNULL(iso3CountryCode, \"\"),
IFNULL(isoCode, \"\"),
IFNULL(adxCode, \"\"),
IFNULL(adxTargetType, \"\"),
IFNULL(isoOtherName, \"\")
FROM $GEOTABLENAME ORDER BY aeGeoLevel
INTO OUTFILE '$GEOTAXONOMYTMPFILE' FIELDS OPTIONALLY ENCLOSED BY '\"' TERMINATED BY ',' ESCAPED BY '\"'" #LINES TERMINATED BY '\\n'"


generateCSVFromTaxonomy(){
	echo "#### GENERATING TAXONOMY CSV ####";
	#echo "$EXPORTTAXONOMYASCSV";
	sudo rm -f $GEOTAXONOMYTMPFILE
	echo "Query1: Export $GEOTABLENAME to csv file $GEOTAXONOMYFILEPATH";
	execQuery "$EXPORTTAXONOMYASCSV";
	if [ -f $GEOTAXONOMYTMPFILE ] 
	then
		sudo mv $GEOTAXONOMYTMPFILE $GEOTAXONOMYFILEPATH
	else
	 echo "FAILED TO EXPORT AS CSV";
	fi
	return 0;
}

#main function to generate ae taxonomy
generateAeTaxonomyMain(){
	#follow same order always
	date
	createGeoTable;
	generateCountryDataISO3ADX;
	generateRegionDataISO3ADXFIPS;
	generateCityData;
	generatePostalData;
	generateDMAData;
	generateOthersData;
	setISO3CountryCodeToALL;
	#runAdjustmentQueries;
	generateCSVFromTaxonomy;
	date
}

generateAeTaxonomyMain;
