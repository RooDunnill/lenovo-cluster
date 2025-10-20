#!/usr/bin/env bash
set -e

if [ "$(id -u)" != "0" ]; then                                           #checks running as root user 
    echo "Must run as root user to change usernames of other users"
    exit 1
fi

TEMPUSER="tempuser$(date +%s)"                                           #names temp user to run the script logic

echo "Creating temporary user $TEMPUSER..."
useradd -m "$TEMPUSER"                                                   #creates the temp user
passwd -d "$TEMPUSER"                                                    #removes the password login from user
usermod -aG sudo "$TEMPUSER"                                             #adds temp user to sudo group

echo "Running shell as $TEMPUSER with sudo..."
sudo -u "$TEMPUSER" bash << 'EOF'                                        #runs up to EOF as the temp user

read -p "What is the username you want to change: " OLDUSER              #requests old username

if [ -z "$OLDUSER" ]; then
    echo "No username provided. Exiting..."
    exit 1
fi

if [ "$OLDUSER" = "root" ]; then
    echo "Cannot rename root user"
    exit 1
fi

if id "$OLDUSER" >/dev/null 2>&1; then                                   #checks if the old username exists
    echo "User account found"
else
    echo "User account not found"
    exit 1                                                               #stops the program if the old username doesn't exist
fi

read -p "What is the username you wish to chnage $OLDUSER to: " NEWUSER  #asks for the name to change the old username too

if [ -z "$NEWUSER" ]; then
    echo "No new username provided. Exiting..."
    exit 1
fi

if [ "$NEWUSER" = "root" ]; then
    echo "Cannot rename user to name 'root'"
    exit 1
fi

if id "$NEWUSER" >/dev/null 2>&1; then                                   #checks if the new username already exists
    echo "This username already exists"
    exit 1                              
fi

echo "Changing username..."
usermod -l "$NEWUSER" "$OLDUSER"                                         #renames the user

echo "Changing home directory..."
usermod -d "/home/$OLDUSER" -m "$NEWUSER"                                #renames the home directory

echo "Changing group name..."
groupmod -n "$NEWUSER" "$OLDUSER"                                        #renames the user groups

echo "Changing file ownership..."
find /home -user "$OLDUSER" -exec chown "$NEWUSER:$NEWUSER" {} +         #changes all file ownership over


EOF                                                                      #ends temporary users script

echo "Removing temp user $TEMPUSER..."        
userdel -r "$TEMPUSER"                                                   #deletes temporary user

echo "Script complete, and temporary user deleted"