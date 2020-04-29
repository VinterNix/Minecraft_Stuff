#!/bin/bash
# Thanks to msniveau & George for all the help with this
# Update Line 45 with your Server Directories

# [George]
LOG_FILE=/var/log/paper_updater.log

# Create our temp workspace
WORKDIR=/home/Updater_Work_DIR

echo "
--------------------------------------------
START TIME: 	$(date +%Y-%d-%m\ %H:%M:%S)
--------------------------------------------
1] Creating workdir if does not exist" | tee -a $LOG_FILE

# create work dir if does not exist
if [ ! -d $WORKDIR ];then
	echo "[!] WORKDIR created by script" | tee -a $LOG_FILE
	mkdir $WORKDIR
fi
echo "2] going to $WORKDIR" | tee -a $LOG_FILE
cd $WORKDIR


# Download latest 1.15.2 release of papermc
FILE_NAME="$(
	curl -Isk 'https://papermc.io/api/v1/paper/1.15.2/latest/download' \
		| grep 'content-disposition:' \
		| sed 's/.*filename=//g'
)"
echo "3] Downloading 1.15.2 release [$FILE_NAME]" | tee -a $LOG_FILE
wget -O $WORKDIR/paperspigot.jar https://papermc.io/api/v1/paper/1.15.2/latest/download

# Identify the update file
UPDATE_FILE=$(ls $WORKDIR/paperspigot.jar)
echo "UPDATE_FILE=$UPDATE_FILE" | tee -a $LOG_FILE
[[ "$?" -gt 0 ]] && echo "paperspigot.jar not found, exiting!" | tee -a $LOG_FILE && exit 1

# Fetch the new md5sum
NEW_VERSION=$(md5sum $UPDATE_FILE | awk '{print $1}')
echo "NEW_VERSION=$NEW_VERSION" | tee -a $LOG_FILE

# Now iterate over the servers, each server needs to check if an update is required
for i in /INSERT/YOUR/SERVER/DIRECTORY/HERE/*WILDCARDS/ACCEPTED/; do
    SERVER_DIR=$(dirname $i)
    echo "SERVER_DIR=$SERVER_DIR" | tee -a $LOG_FILE
    # Compare currently installed m5sum with the new one
    [[ "$(md5sum $SERVER_DIR/paperspigot.jar | awk '{print $1}')" == "$NEW_VERSION" ]] && {
    	echo "Server is already up to date...Finishing" | tee -a $LOG_FILE
    	continue
    }
    echo "$SERVER_DIR needs update!" | tee -a $LOG_FILE
    sudo cp $UPDATE_FILE $SERVER_DIR/paperspigot.jar
    chown pufferd:pufferd $SERVER_DIR/paperspigot.jar
done

# Cleanup our workspace
rm -rf $WORKDIR/paperspigot.jar
