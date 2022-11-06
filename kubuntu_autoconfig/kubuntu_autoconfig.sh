#!/bin/bash
#==============================================================================#
#		Kubuntu Post-Installation & Auto Configuration Script 	       #
#------------------------------------------------------------------------------#
# 			AUTHOR: n0ct1s	(2022-10-25)			       #
#			VERSION: 0.8 	(2022-11-07)			       #
#==============================================================================#

### VARS =======================================================================
keyrings_dir='/usr/share/keyrings'
repos_dir='/etc/apt/sources.list.d'

### CLEAR SCREEN BEFORE PRINTING MESSAGES ======================================
clear
###=============================================================================

### WELCOME MESSAGES ===========================================================
echo -e 'Welcome to my Kubuntu Post-Installation & Auto Configuration Script!\n'
echo -e 'This script installs all packages that I need, and configures Kubuntu.\n'
echo -e 'WARNING: YOU NEED TO RUN THE SCRIPT AS ROOT OR WITH SUDO FROM YOUR MAIN USER OR ELSE SOME CONFIGS WILL NOT APPLY CORRECTLY.'
echo -e 'For more information, please check the help page (IN PROCESS).\n'
###=============================================================================

### EXECUTION APPROVAL =========================================================
## Prompt user input
read -n1 -p 'Press Y to continue, or N to exit the script... ' resp ; echo -e '\n'

## Loop to analyze input
while true ; do
	case "$resp" in
		# Continue script
		[Yy]* ) break;;
	
		# Exit script
		[Nn]* ) clear; exit;;

		# Repeat prompt
		* ) read -n1 -p 'Please, press Y or N. ' resp ; echo -e '\n'
		esac
done
###=============================================================================

### STARTUP & CHECKS ===========================================================
echo -e 'STARTING SCRIPT...\n' ; sleep 2 ; clear

## OS Check --------------------------------------------------------------------
echo -n 'Checking OS compatibility... ' ; sleep 2

# If OS name is Ubuntu
if grep 'NAME="Ubuntu"' /etc/os-release &> /dev/null ; then
	# Validate.
	echo -e 'OK!\n'
else
	# Want and exit with code 2
	echo -e 'This OS is not compatible. EXITING.\n'
	exit 2
fi
##------------------------------------------------------------------------------

## Check internet connection ---------------------------------------------------
echo -n 'Internet connection... '

# If it can ping 3 times Google Public DNS Servers
if ping -c 3 dns.google &> /dev/null ; then
	# Validate
	echo -e 'OK!\n'
else
	# Warn and exit with code 2
	echo -e 'Please check your network configuration. EXITING.\n'
	exit 2
fi
##------------------------------------------------------------------------------

## ROOT/SUDO CHECK -------------------------------------------------------------
echo -n 'CHECKING ROOT PRIVILEGES... ' ; sleep 2

# If current user is not UID 0
if [[ $(id -u) -ne 0 ]] ; then
	# Warn and exit with code 2
	echo 'THIS SCRIPT IS NOT RUNNING AS ROOT, EXITING :('
	exit 2
else
	# Validate and start setting up the OS
	echo -e 'OK!\n'
	echo -e 'LET ME SHOW YOU HOW ITS DONE ;)\n' ; sleep 1
	clear
fi
###=============================================================================

### UPGRADE SYSTEM =============================================================
echo -e '##### UPGRADING SYSTEM #####\n' ; sleep 1
echo -e 'GO!\n'

## System upgrade function
function osupgr {
	# If repos are refreshed successfully
	if apt update ; then
		# Upgrade system non-interactively
		apt upgrade -y

		# Return exit code
		return $?
	else
		# Return 1 to exit script on the next conditional
		return 1
	fi
}

## Call function
osupgr

# If function return code is 0
if [ $? -eq 0 ] ; then
	# Validate and continue
	echo -e "\n##### SYSTEM HAS BEEN UPGRADED SUCESSFULLY #####\n" ; sleep 1
	clear
else
	# Warn and exit with code 1
	echo -e "\n##### THERE WAS AN ERROR UPGRADING THE SYSTEM. EXTITING :( #####\n"
	exit 1
fi

### INSTALL BASE PACKAGES (FIRMWARE, BUILD TOOLS, ETC.) ========================
echo -e '##### INSTALLING BASE PACKAGES #####\n' ; sleep 1
echo -e 'GO!\n'

## Basepkg installation function
function basepkgs {
	# Install packages non-interactively
	apt install -y dkms acl ntfs-3g build-essential vim git gnupg ca-certificates apt-transport-https ethtool inxi traceroute \
	curl wget lshw hwdata neofetch htop s-tui lm-sensors fancontrol acl ntfs-3g automake make cmake autoconf \
	rar unrar lzip lzop bzip2 gzip lzma lhasa arj sharutils p7zip p7zip-full python3-pip language-pack-es language-pack-es-base \
	language-pack-kde-es

	# Return exit code
	return $?
}

## Call function
basepkgs

## If function return code is 0
if [ $? -eq 0 ] ; then
	# Validate and continue
	echo -e "\n##### ALL BASIC PACKAGES HAVE BEEN INSTALLED SUCESSFULLY. #####\n"
else
	# Warn and exit
	echo "\n##### THERE WAS AN ERROR INSTALLING BASEPKGS. EXITING :( #####"
	exit 1
fi
##==============================================================================

### INSTALL CODECS =============================================================
echo -e '##### INSTALLING CODECS PACKAGES #####\n' ; sleep 1
echo -e 'GO!\n'

## Restrictpkgs installation function
function codecpkgs {
	# Install packages non-interactively
	apt install -y kubuntu-restricted-extras libdvd-pkg gstreamer1.0-{qt5,libav,pulseaudio} \
	gstreamer1.0-plugins-{base,bad,good,ugly} libdvd-pkg

	# Return exit code
	return $?
}

## Call function
codecpkgs

## If function return code is 0
if [ $? -eq 0 ] ; then
	# Validate and continue
	echo -e "\n##### ALL CODEC PACKAGES HAVE BEEN INSTALLED SUCESSFULLY. #####\n"
else
	# Warn and exit
	echo "\n##### THERE WAS AN ERROR INSTALLING CODEC PACKAGES. EXITING :( #####"
	exit 1
fi
###=============================================================================

### INSTALL WINDOWS LAYER ======================================================
echo -e '##### INSTALLING WINDOWS LAYER PACKAGES #####\n' ; sleep 1
echo -e 'GO!\n'

## Restrictpkgs installation function
function winpkgs {
	# Enable i386 arch
	dpkg --add-architecture i386

	# If repos are refreshed successfully
	if apt update ; then
		# Install packages
		apt install mono-complete wine64 wine wine64-tools winetricks

		# Return exit code
		return $?
	else
		# Return 1 to exit script on the next conditional
		return 1
	fi
}

## Call function
winpkgs

## If function return code is 0
if [ $? -eq 0 ] ; then
	# Validate and continue
	echo -e "\n##### ALL WINDOWS LAYER PACKAGES HAVE BEEN INSTALLED SUCESSFULLY. #####\n"
else
	# Warn and exit
	echo "\n##### THERE WAS AN ERROR INSTALLING WINDOWS LAYER PACKAGES. EXITING :( #####"
	exit 1
fi
###=============================================================================

### INSTALL TOOLS ==============================================================
echo -e '##### INSTALLING TOOLS PACKAGES #####\n' ; sleep 1
echo -e 'GO!\n'

## Restrictpkgs installation function
function toolpkgs {
	# Add Sublime keyring and repo (https://www.sublimetext.com/docs/linux_repositories.html#apt)
	echo -e '#### ADDING SUBLIME KEYRING AND REPO ####\n' ; sleep 1

	# If keyring has been added successfully
	if wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg 2> /dev/null | gpg --dearmor --output $keyrings_dir/sublimehq-archive.gpg 2> /dev/null ; then
		# Add repo
		echo "deb [ signed-by=$keyrings_dir/sublimehq-archive.gpg ] https://download.sublimetext.com/ apt/stable/" > $repos_dir/sublime-text.list 2> /dev/null
	else
		# Warn and exit
		echo -e '### FAILED TO ADD SUBLIME KEYRING AND REPO ###\n'
		return 1
	fi

	# Add QownNotes keyring and repo (https://www.qownnotes.org/installation/ubuntu.html#obs-repository)
	echo -e '#### ADDING QOWNNOTES KEYRING AND REPO ####\n' ; sleep 1

	# If keyring has been added successfully
	if wget -qO- http://download.opensuse.org/repositories/home:/pbek:/QOwnNotes/xUbuntu_22.04/Release.key 2> /dev/null | gpg --dearmor --output $keyrings_dir/pbek-qownnotes.gpg 2> /dev/null ; then
		# Add repo
		echo "deb [ signed-by=$keyrings_dir/pbek-qownnotes.gpg ] http://download.opensuse.org/repositories/home:/pbek:/QOwnNotes/xUbuntu_22.04/ /" > $repos_dir/qownnotes.list 2> /dev/null
	else
		# Warn and exit
		echo -e '### FAILED TO ADD QOWNNOTES KEYRING AND REPO ###\n'
		return 1
	fi

	# 

	# Add Brave keyring and repo (https://brave.com/es/linux/#debian-ubuntu-mint)
	echo -e '#### ADDING BRAVE KEYRING AND REPO ####\n' ; sleep 1

	# If keyring has been added successfully
	if curl -fsSLo "$keyrings_dir"/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg 2> /dev/null ; then
		# Add repo
		echo "deb [ signed-by=$keyrings_dir/brave-browser-archive-keyring.gpg arch=amd64 ] https://brave-browser-apt-release.s3.brave.com/ stable main" > $repos_dir/brave-browser-release.list 2> /dev/null
	else
		# Warn and exit
		echo -e '### FAILED TO ADD BRAVE KEYRING AND REPO ###\n'
		return 1
	fi

	# Add AnyDesk keyring and repo (http://deb.anydesk.com/howto.html)
	echo -e '#### ADDING ANYDESK KEYRING AND REPO ####\n' ; sleep 1

	# If keyring has been added successfully
	if wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY 2> /dev/null | gpg --dearmor --output "$keyrings_dir"/anydesk.gpg 2> /dev/null ; then
		# Add repo
		echo "deb [ signed-by=$keyrings_dir/anydesk.gpg ] http://deb.anydesk.com/ all main" > $repos_dir/anydesk-stable.list 2> /dev/null
	else
		# Warn and exit
		echo -e '### FAILED TO ADD ANYDESK KEYRING AND REPO ###\n'
		return 1
	fi

	# Add TeamViewer keyring and repo (https://community.teamviewer.com/English/kb/articles/30666-update-teamviewer-on-linux-via-repository)
	echo -e '#### ADDING TEAMVIEWER KEYRING AND REPO ####\n' ; sleep 1

	# If keyring has been added successfully
	if wget -qO- https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc 2> /dev/null \ gpg --dearmor --output $keyrings_dir/teamviewer.gpg 2> /dev/null
		# Add repo
		echo "deb [ signed-by=$keyrings_dir/teamviewer.gpg ] https://linux.teamviewer.com/deb stable main" > $repos_dir/teamviewer.list 2> /dev/null
	else
		# Warn and exit
		echo -e '### FAILED TO ADD TEAMVIEWER KEYRING AND REPO ###\n'
		return 1
	fi


	# Refreshing repos
	echo -e '#### REFRESHING REPOS ####\n' ; sleep 1

	# If repos were refreshed successfully
	if apt update ; then
		# Installing packages
		echo -e '#### INSTALLING PACKAGES ####\n' ; sleep 1

		# If tools packages were instaled successfully
		if apt install -y nmap wireshark arp-scan virt-manager keepass2 xdotool krdc qownnotes sublime-text \ 
			brave-browser anydesk libcanberra0 libcanberra-gtk3-module libcanberra-gtk-module teamviewer ; then
			# Adding current sudo user to libvirt and wireshark groups
			echo -e '#### ADDING CURRENT SUDO USER TO LIBVIRT AND WIRESHARK GROUPS ####\n' ; sleep 1

			# If current sudo user was added to libvirt and wireshark groups successfully
			if adduser $SUDO_USER libvirt && adduser $SUDO_USER wireshark &> /dev/null ; then
				# Return exit code
				return $?
			else
				# Warn and exit
				echo -e '### FAILED TO ADD CURRENT SUDO USER TO LIBVIRT AND WIRESHARK GROUPS ###\n'
				return 1
			fi
		else
			# Warn and exit
			echo -e '### FAILED TO INSTALL TOOLS PACKAGES ###\n'
			return 1
		fi
	else
		# Warn and exit
		echo -e '### FAILED TO REFRESH REPOS ###\n'
		return 1
	fi
}

## Call function
toolpkgs

## If function return code is 0
if [ $? -eq 0 ] ; then
	# Validate and continue
	echo -e "\n##### ALL TOOLS PACKAGES HAVE BEEN INSTALLED SUCESSFULLY. #####\n"
else
	# Warn and exit
	echo "\n##### THERE WAS AN ERROR INSTALLING TOOLS PACKAGES. EXITING :( #####"
	exit 1
fi
###=============================================================================
