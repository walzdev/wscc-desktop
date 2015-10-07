#!/bin/bash

echo "##########################################################"
echo "#                                                        #"
echo "#   Welcome to the WALZ.systems Corporate Client Setup   #"
echo "# ------------------------------------------------------ #"
echo "#                                                        #"
echo "# This will install the WSCC - OS Patch on a clean       #"
echo "# Ubuntu Desktop 14.04.3 LTS                             #"
echo "#                                                        #"
echo "# (c) 1997-2015 by devXive - research and development    #"
echo "#                                                        #"
echo "# Version: WSCC 3.0                                      #"
echo "#                                                        #"
echo "##########################################################"
echo ""
echo ""

# TODO: CHECK IF SETUP ALREADY HAS BEEN STARTED BEFORE

if [ ! -z "$SUDO_USER" ]; then
	echo -e "Checking root access: \e[38;5;46m OK\e[0m"
else
	echo -e "Checking root access: \e[38;5;160m INVALID\e[0m"
	echo "Use: sudo ./setup-wscc.sh"
	exit 1;
fi

echo "Now, we try to get the latest installer version"
echo ""
version=$(curl -L https://raw.githubusercontent.com/walzdev/wscc-desktop/master/version)
echo ""
echo ""

# TODO: CHECK IF WE COULD GET VERSION INFO, ELSE ECHO TO TRY AGAIN LATER (maybe in orange 166/202)
# echo -e "\e[38;5;202mSorry, but we could not get the latest available version from Github, so you could...\e[0m"
# echo -e "\e[38;5;202m...check your internet connection works correctly\e[0m"
# echo -e "\e[38;5;202m...please try again later again\e[0m"
# echo -e "\e[38;5;202m...report a bug to our Github repository\e[0m"

echo "Downloading installer package version: $version"
wget https://github.com/walzdev/wscc-desktop/archive/$version.zip
unzip -d /tmp $version.zip
rm $version.zip

sudo mv /tmp/wscc-desktop-${version#?}/usr/share/* /usr/share
rm -R /tmp/wscc-desktop-${version#?}

echo ""
echo ""
echo -e "\e[38;5;87m Launching WSCC Patcher...\e[0m"
echo ""
bash /usr/share/univention-wsccubuntu-integration/wscc-patcher.sh