#!/usr/bin/env bash
set -e
set +o history


if [[ $EUID -ne 0 ]]; then                  #checks that the user has run the file as root
    echo "Must have root access to run"
    exit 1
fi

min_user_passwd_len=32
min_root_passwd_len=64

clear_passwords() {
    clstr_password=""
    clstr_password_check=""
    root_password=""
    root_password_check=""
}

trap clear_passwords EXIT


check_user_passwords() {
    while true; do
        read -sp "What do you wish to change cluster's password too: " clstr_password
        echo

        read -sp "Please input it again: " clstr_password_check
        echo

        if [[ "$clstr_password" == "$clstr_password_check" ]]; then
            echo "Passwords match"
            if [[ ${#clstr_password} -ge "$min_user_passwd_len" ]]; then
                echo "Passwords are also long enough"
                unset clstr_password_check
                return 0
            else
                echo "Password must be longer than $min_user_passwd_len characters"
            fi
        else
            echo "Passwords don't match"
        fi
    done
}


check_root_passwords() {
    while true; do
        read -sp "What do you wish to change root's password too: " root_password
        echo

        read -sp "Please input it again: " root_password_check
        echo

        if [[ "$root_password" == "$root_password_check" ]]; then
            echo "Passwords match"
            if [[ ${#root_password} -ge "$min_root_passwd_len" ]]; then
                echo "Passwords are also long enough"
                unset root_password_check
                return 0
            else
                echo "Password must be longer than $min_root_passwd_len characters"
            fi
        else
            echo "Passwords don't match"
        fi
    done
}

check_user_passwords
echo "Changing Cluster password..."
echo "cluster:$clstr_password" | sudo chpasswd
unset clstr_password
echo "Password changed"



check_root_passwords
echo "Changing Roots password..."
echo "root:$root_password" | sudo chpasswd
unset root_password
echo "Password Changed"


set -o history