#!/bin/bash
# Thanks to msniveau & George for all the help with this

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# 
# Update Line 11, 14 & 51 with your Server Directories
# 
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Define our Log file's location
LOG_FILE=/WHERE/YOU/KEEP/YOUR/LOGS/paper_updater.log

# Define our Working Directory (No Trailing / )
WORKDIR=/WHERE/ARE/WE/GOING/TO/WORK

# TimeStamp for our Records
echo "
--------------------------------------------
START TIME: 	$(date +%Y-%d-%m\ %H:%M:%S)
--------------------------------------------
" | tee -a $LOG_FILE

# Create Working Directory if it doesn't exist and go there
if [ ! -d $WORKDIR ];then
	echo "[!] WORKDIR Not found! Creating it..." | tee -a $LOG_FILE
	mkdir $WORKDIR
fi
echo "1] Working Directory Found: $WORKDIR" | tee -a $LOG_FILE
cd $WORKDIR
echo "2] Moving into our Working Directory..." | tee -a $LOG_FILE


# Download latest 1.15.2 release of papermc
FILE_NAME="$(curl -Is 'https://papermc.io/api/v1/paper/1.15.2/latest/download' | awk -F= '/filename/{print $NF}')"
echo "3] Downloading PaperMC (Java 1.15.2) Release Version: $FILE_NAME" | tee -a $LOG_FILE
 
	# Use wget to fetch our file...Doing it quietly and renaming the file
	 wget --no-verbose -O $WORKDIR/paperspigot.jar https://papermc.io/api/v1/paper/1.15.2/latest/download

# Identify the update file
UPDATE_FILE=$(ls $WORKDIR/paperspigot.jar)
echo "4] Paper Downloaded and Renamed Sucessfully!" | tee -a $LOG_FILE
[[ "$?" -gt 0 ]] && echo "paperspigot.jar Not Found! Exiting..." | tee -a $LOG_FILE && exit 1

# Fetch the new md5sum
NEW_VERSION=$(md5sum $UPDATE_FILE | awk '{print $1}')

# Compare md5sums to all servers and flag those needing updates
echo "5] Checking All servers for updates...
" | tee -a $LOG_FILE
for i in /INSERT/YOUR/SERVER/DIRECTORY/HERE/*WILDCARDS/ACCEPTED/paperspigot.jar; do
    SERVER_DIR=$(dirname $i)
    echo "SERVER: $SERVER_DIR" | tee -a $LOG_FILE
    # Compare currently installed md5sum with the new one
    [[ "$(md5sum $SERVER_DIR/paperspigot.jar | awk '{print $1}')" == "$NEW_VERSION" ]] && {
    	echo "No update is required...
		" | tee -a $LOG_FILE
    	continue
    }
    echo "$SERVER_DIR Outdated! Running Update..." | tee -a $LOG_FILE
    # Copy & Replace our updated Paper file
	sudo cp $UPDATE_FILE $SERVER_DIR/paperspigot.jar
    # Change ownership to pufferd daemon user and group
	chown pufferd:pufferd $SERVER_DIR/paperspigot.jar
done

# Cleanup our workspace
rm -rf $WORKDIR/paperspigot.jar

echo "
All Done! Cleaning up and Exiting..." | tee -a $LOG_FILE

# Another TimeStamp for our Records
echo "
--------------------------------------------
END TIME: 	$(date +%Y-%d-%m\ %H:%M:%S)
--------------------------------------------
" | tee -a $LOG_FILE

