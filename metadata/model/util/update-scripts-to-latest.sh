#!/bin/sh

# Unix based script to run the update-to-latest.sql
# script against each of the .sql files in /metadata/model
#
# WARNING: This will drop and recreated the mysql database named 'openmrs'
#

# user defined variables
export currentversion=1.3.0
export newversion=1.3.0
export dbuser=root

# Ask for the user's database password
echo -n "MySQL password: "
stty -echo
read dbpass
stty echo

# Add a break after the user input
echo ""

# Do the createdb script first so that the 'openmrs' database is dropped and recreated
echo Creating createdb sql file
mysql -u$dbuser -p$dbpass -e"source $currentversion-createdb-from-scratch-with-demo-data.sql"
mysql -u$dbuser -p$dbpass -e"source update-to-latest-db.mysqldiff.sql" -Dopenmrs
mysqldump -u$dbuser -p$dbpass -e -q --add-drop-database --skip-add-locks --skip-add-drop-table -N -r"./$newversion-createdb-from-scratch-with-demo-data.sql" --databases openmrs

# Note that this mysqldump has the -d flag to ignore the rows that this .sql doesn't have
echo Creating schema only sql file
mysql -u$dbuser -p$dbpass -e"source $currentversion-schema-only.sql" -Dopenmrs
mysql -u$dbuser -p$dbpass -e"source update-to-latest-db.mysqldiff.sql" -Dopenmrs
mysqldump -u$dbuser -p$dbpass -e -q -d --add-drop-table --skip-add-locks -N -r"./$newversion-schema-only.sql" openmrs

echo Creating schema with core and demo data sql file
mysql -u$dbuser -p$dbpass -e"source $currentversion-schema-with-core-and-demo-data.sql" -Dopenmrs
mysql -u$dbuser -p$dbpass -e"source update-to-latest-db.mysqldiff.sql" -Dopenmrs
mysqldump -u$dbuser -p$dbpass -e -q --add-drop-table --skip-add-locks -N -r"./$newversion-schema-with-core-and-demo-data.sql" openmrs

echo Creating schema with core only sql file
mysql -u$dbuser -p$dbpass -e"source $currentversion-schema-with-core-data.sql" -Dopenmrs
mysql -u$dbuser -p$dbpass -e"source update-to-latest-db.mysqldiff.sql" -Dopenmrs
mysqldump -u$dbuser -p$dbpass -e -q --add-drop-table --skip-add-locks -N -r"./$newversion-schema-with-core-data.sql" openmrs

#drop database if exists openmrs;
#create database openmrs default charset utf8;
#use openmrs;

echo You will also have to put this into the createdb-from-scratch after the 'create database...' statement
echo drop user test;
echo create user test identified by 'test';
echo grant all on openmrs.* to test;
