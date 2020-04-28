#!/bin/bash
# Thanks to msniveau for all the help with this
# Update Line 19 with your mc server path

# Define our workspace
WORKDIR=$(mktemp -d)

# Download most latest 1.15.2 release of papermc
wget -O $WORKDIR/paperspigot.jar https://papermc.io/api/v1/paper/1.15.2/latest/download

# Identify the update file
UPDATE_FILE=$(ls $WORKDIR/paperspigot.jar)
[[ "$?" -gt 0 ]] && echo "paperspigot.jar not found, exiting!" && exit 1

# Fetch the new md5sum
NEW_VERSION=$(md5sum $UPDATE_FILE | awk '{print $1}')

# Now iterate over the servers, each server needs to check if an update is required
for i in /INSERT/FULL/PATH/TO/MINECRAFT/SERVER/HERE; do
    SERVER_DIR=$(dirname $i)
    # Compare currently installed m5sum with the new one
    [[ "$(md5sum $SERVER_DIR/paperspigot.jar | awk '{print $1}')" == "$NEW_VERSION" ]] && continue
    echo "$SERVER_DIR needs update!"
    cp $UPDATE_FILE $SERVER_DIR/paperspigot.jar
    chown pufferd:pufferd $SERVER_DIR/paperspigot.jar
done

# Cleanup our workspace
rm -rf $WORKDIR
