#!/bin/bash

# Colores
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
greenColour="\e[0;32m\033[1m"
yellowColour="\e[0;33m\033[1m"
grayColour="\e[0;37m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;37m\033[1m"
blueColour="\e[0;34m\033[1m"

# Variables
homes="$(ls /home)"
timestamp="$(date)"


function ctrl_c(){
    echo -e "${redColour}\n[!] Exiting...${endColour}\n"
    tput cnorm && exit 1
}


trap ctrl_c INT


# Check if the folder is created
if [ ! -d /var/backups ] || [ ! -f /var/backups/logs/backups_log.txt ]; then

    tput civis

    echo -e "${blueColour}The directory doesn't exist${endColour}"
    sleep 2
    echo -e "${blueColour}Creating the directory /var/backups${endColour}"
    sleep 2
    sudo mkdir /var/backups
    sudo mkdir /var/backups/logs
    sudo touch /var/backups/logs/backups_log.txt
    echo -e "${blueColour}Directory /var/backups has been created${endColour}"

    tput cnorm

else
    echo -e "${blueColour}The directory /var/backups exists${endColour}"
fi


for user in $homes; do
   
    # Show user
    echo -e "${yellowColour}\nUser: $user${endColour}"

    tput civis

    echo -e "${blueColour}[!] Starting with the backup...${endColour}"
    
    if [ ! -f "/var/backups/.hash_$user" ]; then

        
        echo -e "${blueColour}\n[!] Wait, Listing files, there are not a progress bar...${endColour}"
        find /home/$user -type f -print0 | xargs -0 md5sum | sort > /var/backups/.hash_$user

        echo -e "${blueColour}[!] Creating the backup for user: $user${endColour}"

        # cd / is to fix a message in the terminal
        cd /
        sudo tar -cf - "home/$user" | pv -s $(du -sb /home/$user | awk '{print $1}') -pterb > /var/backups/$user.tar 
        echo -e "${greenColour}[!] Backup for user: $user is created${endColour}"
        echo "First backup for the user: $user $timestamp" >> /var/backups/logs/backups_log.txt

    else

        # Compare main hash with actual hash, to check if there are changes
        echo -e "${blueColour}\n[!] Wait, Listing files, there are not a progress bar...${endColour}"
        find /home/$user -type f -print0 | xargs -0 md5sum | sort > "/var/backups/.current_hash_$user"


        if cmp -s /var/backups/.current_hash_$user /var/backups/.hash_$user; then
            echo -e "${greenColour}\n[!] There are no changes for the user $user${endColour}"
        else
            echo -e "${blueColour}\n[!] There are changes for the user $user${endColour}"
            echo -e "${blueColour}[!] Creating the backup for $user${endColour}"

            # cd / is to fix a message in the terminal
            cd /
            sudo tar -cf - "home/$user" | pv -s $(du -sb /home/$user | awk '{print $1}') -pterb > /var/backups/$user.tar
            echo -e "${greenColour}[!] Backup for $user is created${endColour}\n"

            echo "Updated backup for the user: $user $timestamp" >> /var/backups/logs/backups_log.txt
            

        fi

        sudo rm /var/backups/.current_hash_$user

    fi

    tput cnorm
done

