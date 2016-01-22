#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
reload(sys);  
sys.setdefaultencoding('utf8');
import urllib2
from BeautifulSoup import BeautifulSoup
import HTMLParser
from time import sleep

from GeoDataCollector import CollectorConfig as config
from GeoDataCollector import CountriesData as geo

def process():
    
    retval = os.path.isdir(config.OUTDIRPATH);
    if retval == False:
        retval = os.mkdir(config.OUTDIRPATH);
        if retval == False:
            print "unable to create %s directory" %(config.OUTDIRPATH);
            return 0;

    for country in geo.COUNTRIES:
        ####    fetch data for country  ####
        
        url = config.REGION_DATA_URL_PREFIX + country[0].lower() + config.REGION_DATA_URL_SUFFIX;
        destinationFile = config.OUTDIRPATH + "/" + country[0].lower() + ".html";
        print "urlInfo = %s->%s\n" % (url, destinationFile);
        writerHTML = open(destinationFile, 'w');

        try:
            connection = urllib2.urlopen(url);
            print connection.getcode();
            processingData = connection.read();
            writerHTML.write(processingData);
            connection.close();
            writerHTML.close();
        except urllib2.HTTPError, e:
            print e.getcode();

        ####    process data url response here   ####
        
        #find all tables
        soup = BeautifulSoup(processingData, convertEntities=BeautifulSoup.HTML_ENTITIES);
        tables = soup.findAll("table")

        #create csv file name using country code
        writerCSV = destinationFile = config.OUTDIRPATH + "/" + country[0].lower() + ".csv";
        table_no = 0;

        writerCSV = open(destinationFile, 'w');
        readnow = 0;
        TABLE_NO = len(tables);#check last table
        for table in tables:
            table_no = table_no + 1;
            if table_no == TABLE_NO:
                for row in table.findAll('tr')[1:]:
                    #print row
                    #if row.find("Country") >= 0:#this is the table we want
                     #   readnow = 1;
                    try:
                        if readnow == 0:
                            col = row.findAll('td');
                            country = "\"" + col[0].string.rstrip().replace("&nbsp","").replace(";" , "") + "\"";
                            subdiv = "\"" + col[1].string.rstrip().replace("&nbsp","").replace(";" , "") +"\"";
                            name = "\"" + col[2].string.rstrip().replace("&nbsp","").replace(";" , "") + "\"";
                            level = "\"" + col[3].string.rstrip().replace("&nbsp","").replace(";" , "") + "\"";
                            
                            #country = country.decode('utf-8');
                            #subdiv = subdiv.decode('utf-8');
                            #name = name.decode('utf-8');
                            #level = level.decode('utf-8');

                            country = country.rstrip();
                            #print country;
                            subdiv = subdiv.rstrip();
                            name = name.rstrip().replace('\r',' ');# to replace ctrl + M character
                            level = level.rstrip();

                            record = (country, subdiv, name, level);
                            recordCsvString = ",".join(record);
                            #print recordCsvString;
                            writerCSV.write(recordCsvString.encode('utf8') + "\n");
                            #writerCSV.write(recordCsvString + "\n");
                    except:
                        #ex = sys.exc_info(0);
                        #write_to_page( "<p>Error: %s</p>" % ex );
                        print "some exception";
        #return 0;
        sleep(0.05);
        writerCSV.close();
    return 0

process();
