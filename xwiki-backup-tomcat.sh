#!/bin/bash

#Space Separated List of Databases to Dump 
#DATABASE="xwiki d1 d3"
DATABASE="xwiki"
DBUSER=xwiki
DBPASS=sejalivre
#Dir of backup
DIRBACKUP=/var/backups/xwiki

#XWIKI data folder
DATAFOLDER=/var/lib/xwiki/data/
#Where is the webapps folder for your tomcat installation
WEBAPPDIR=/var/lib/tomcat9/webapps
#What context (dir) does your application deploy to
DEPLOYCONTEXT=ROOT

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DEPLOYDIR=${WEBAPPDIR}/${DEPLOYCONTEXT}
DATE=$(data '+%Y-%m-%d')
mkdir ${DIRBACKUP}/${DATE} -p

#backup mysql
echo "Backing up Mysql"
mysqldump -h 127.0.0.1 -u ${DBUSER} --password=${DBPASS} --max_allowed_packet=512m --add-drop-database --databases ${DATABASE} | /bin/gzip > ${DIRBACKUP}/${DATE}/${DATABASE}.gz

echo "Backing up Data"
#Backup Exteral Data Storage
/bin/tar -C ${DATAFOLDER}/../ -zcf ${DIRBACKUP}/${DATE}/data.tar.gz data

#Backing Java Keystore
#/bin/cp /srv/tomcat6/.keystore ${DIRBACKUP}/${DATE}/.keystore

echo "Backing up xwiki configuration"
/bin/cp ${DEPLOYDIR}/WEB-INF/hibernate.cfg.xml ${DIRBACKUP}/${DATE}/hibernate.cfg.xml
/bin/cp ${DEPLOYDIR}/WEB-INF/xwiki.cfg ${DIRBACKUP}/${DATE}/xwiki.cfg
/bin/cp ${DEPLOYDIR}/WEB-INF/xwiki.properties ${DIRBACKUP}/${DATE}/xwiki.properties

#Backup Deploy Context
echo "Backing UP deploy Context"
/bin/tar -C ${DEPLOYDIR}/../ -zcf ${DIRBACKUP}/${DATE}/ROOT.tar.gz ROOT

echo "DONE"