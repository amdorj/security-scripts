#!/bin/bash 
# le big shebang

less -FX liamdev.txt # Show figlet text

# Checks for root
if [[ $EUID -ne 0 ]]; then
   echo "This script requires root privileges. Please type 'sudo !!' or login as root using 'su'." 
   exit 1
   else echo "Confirmed running as root."
fi
#Initialize some variables.
export buck=0
export bum=0
#Install Git.
apt-get -y update 
apt-get install -y git

# Install Programs
echo "Install the supplementary programs Graphical Firewall Management and Boot-up Manager?"
	read -r -p "$* [y/n]: " sup
        case $sup in
            [Yy]* ) apt-get -y install gufw bum && export bum=1;;
            [Nn]* ) echo "Your choice is noted." && export bum=0 ;;
            * ) echo "Invalid input! Please answer y (yes) or n (no)."
        esac


# Git buck security
echo "Clone into davewood's buck-security?"
	read -r -p "$* [y/n]: " gbk
        case $gbk in
            [Yy]* ) git clone https://github.com/davewood/buck-security && export buck=1;;
            [Nn]* ) echo "Your choice is noted." && export buck=0;;
            * ) echo "Invalid input! Please answer y (yes) or n (no)."
        esac

#git clone https://github.com/davewood/buck-security

# Firewall
ufw enable
ufw deny 23
ufw deny 2049
ufw deny 515
ufw deny 111
ufw deny 5900

#Add PPA for Mozilla Firefox; <s>Add PPA for Libre Office</s>
add-apt-repository ppa:ubuntu-mozilla-security/ppa # && add-apt-repository ppa:libreoffice/ppa
#Update local package cache
apt-get update

echo "Perform software upgrades? Note that this step may take a while,"
echo "and tie up the apt package management."
# while true; do
        read -r -p "$* [y/n]: " yn
        case $yn in
            [Yy]* ) apt-get upgrade;;
            [Nn]* ) echo "Understood. Please remember to run 'apt upgrade' later.";;
            * ) echo "Invalid input! Please answer y (yes) or n (no)."
        esac


# Turns off Guest ACCT
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf

# Password Age Limits
sed -i '/^PASS_MAX_DAYS/ c\PASS_MAX_DAYS   90' /etc/login.defs
sed -i '/^PASS_MIN_DAYS/ c\PASS_MIN_DAYS   10'  /etc/login.defs
sed -i '/^PASS_WARN_AGE/ c\PASS_WARN_AGE   7' /etc/login.defs

# Password Auth
sed -i '1 s/^/auth optional pam_tally.so deny=5 unlock_time=900 onerr=fail audit even_deny_root_account silent\n/' /etc/pam.d/common-auth

# Makes strong password
apt-get -y install libpam-cracklib
sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' /etc/pam.d/common-password

# Cracking tools/malware.  You get the drift.
apt-get -y purge hydra* ophcrack* john* nikto* netcat* aircrack-ng* hashcat* nmap* ncrack*

# Enables auto updates
dpkg-reconfigure -plow unattended-upgrades

# Disable Root Login (SSHd.CONF)
    if [[ -f /etc/ssh/sshd_config ]]; then
        sed -i 's/PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
	echo "Disabled SSH root login."
    else
        echo "No SSH server detected so nothing changed"
    fi
    
if [[ $bum == 1 ]]; then
# Start the services manager (Boot Up Manager)
echo "Would you like to start BUM(Boot Up Manager) ?"
# while true; do
        read -r -p "$* [y/n]: " yn
        case $yn in
            [Yy]* ) bum;;
            [Nn]* ) echo "Okay, moving on...";;
            * ) echo "Invalid input! Please answer y (yes) or n (no)."
        esac
	else
	echo "Boot-up manager not installed, so not running." 
fi

# Change Root Login
echo "Would you like to disable the root login?"
# while true; do
        read -r -p "$* [y/n]: " yn
        case $yn in
            [Yy]* ) passwd -d root;;
            [Nn]* ) echo "Alrighty, moving on...";;
            * ) echo "Invalid input! Please answer y (yes) or n (no)."
        esac
	
#Passwords for everyone! (the 'humans', uid >= 1000)
echo "Tip! Copy Cyb3RP@tr!0t$ into gedit, press enter, Ctrl+A then Ctrl+C. Use the middle mouse"
echo "button or Shift+Insert to quickly paste the password into the terminal. Write it down!" 
for i in `awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd`; do 
echo Changing password for user $i
passwd $i
done
	
# List user accounts by size
echo "Home directory space by user"
	format="%8s%10s%10s   %-s\n"
	printf "$format" "Dirs" "Files" "Blocks" "Directory"
	printf "$format" "----" "-----" "------" "---------"
	dir_list="/home/*"
	for home_dir in $dir_list; do
		total_dirs=$(find $home_dir -type d | wc -l)
		total_files=$(find $home_dir -type f | wc -l)
		total_blocks=$(du -s $home_dir)
		printf "$format" $total_dirs $total_files $total_blocks
	done

# Run The Trusty Ol' Buck Security
if [[ $buck == 1 ]]; then
buck-security/buck-security --sysroot=/
else
echo "Buck security not downloaded, so not running."
fi

