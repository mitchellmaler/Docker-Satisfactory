#!/bin/bash
exit_handler () {

        # Execute the  shutdown commands
        su-exec sfserver /home/sfserver/sfserver stop
        
        exit
}

# Trap specific signals and forward to the exit handler
trap exit_handler SIGTERM

set -eu

# Print info
echo "
    =======================================================================
    USER INFO:
    UID: $PUID
    GID: $PGID
    MORE INFO:
    If you have permission problems remember to use same user UID and GID.
    Check it with "id" command
    If problem persist check:
    https://github.com/vinanrra/Docker-Satisfactory/blob/master/README.md
    =======================================================================
    "

# Set user and group ID to sfserver user
groupmod -o -g "$PGID" sfserver  > /dev/null 2>&1
usermod -o -u "$PUID" sfserver  > /dev/null 2>&1

# Locale, Timezone and user
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime && echo $TimeZone > /etc/timezone

# Apply owner to the folder to avoid errors
chown -R sfserver:sfserver /home/sfserver

# Start cron
service cron start

# Change user to sfserver
su-exec sfserver "$@"

# run the server script and start the server
bash /home/sfserver/start.sh