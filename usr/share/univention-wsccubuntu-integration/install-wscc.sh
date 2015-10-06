#!/bin/bash

echo "##########################################################"
echo "#                                                        #"
echo "# Welcome to the WALZ.systems Corporate Client Installer #"
echo "# ------------------------------------------------------ #"
echo "#                                                        #"
echo "# This will install the WSCC - OS Patch on a clean       #"
echo "# Ubuntu Desktop 14.04.3 LTS                             #"
echo "#                                                        #"
echo "# (c) 1997-2015 by devXive - research and development    #"
echo "#                                                        #"
echo "# Version: WSCC v.3.0                                    #"
echo "#                                                        #"
echo "##########################################################"
echo ""
echo ""
echo "We'll now reactivate the root account. Please follow the instructions below"
echo "First, you have to enter the password for the sysmaster account"
echo ">> After that, you have to set a password for the root account:"
sudo passwd root
sudo cp /usr/share/univention-wsccubuntu-integration/files/sshd_config /etc/ssh/sshd_config
sudo service ssh restart

exit 1;
# ------------------------------------------------------ INSTALL UPDATE --------------------------------------------------------
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoremove

exit 1;

# --------------------------------------------------- INSTALL APPLICATIONS -----------------------------------------------------
# Install numlockx and enable it for lightdm (on login screen)
apt-get install numlockx
echo "greeter-setup-script=/usr/bin/numlockx on" >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf


# Install NFS-Commons
apt-get install nfs-common


# Install OwnCloud Client
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/xUbuntu_14.04/Release.key
sudo apt-key add - < Release.key
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/xUbuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
sudo apt-get update
sudo apt-get install owncloud-client


# -------------------------------------------------- UNINSTALL APPLICATIONS ----------------------------------------------------
# Einzelanwendungen
#	brasero			= CD/DVD Brennprogramm
#	cheese			= Webcam-Automat
#	xul-ext-ubufox		= Ubuntu Änderungserweiterung für Firefox
#	unity-scope-gdrive	= Google Drive Integration
sudo apt-get purge brasero cheese xul-ext-ubufox unity-scope-gdrive

# Spiele
sudo apt-get purge aisleriot gnome-mahjongg gnome-sudoku gnome-mines gnomine

# Programm zur Videowiedergabe
sudo apt-get purge totem totem-mozilla totem-plugins

# Programm zur Fotoverwaltung und -betrachtung inkl. Erweiterungen
sudo apt-get purge shotwell shotwell-common

# eMail CLient inkl. Erweiterungen
sudo apt-get purge thunderbird thunderbird-gnome-support thunderbird-locale-en thunderbird-locale-de thunderbird-locale-en-us

# Programm zur Audiowiedergabe inkl. Erweiterungen
sudo apt-get purge rhythmbox rhythmbox-plugin-zeitgeist rhythmbox-plugin-cdrecorder rhythmbox-mozilla rhythmbox-plugin-magnatune rhythmbox-plugins

# Programm zum Zugriff auf entfernte Arbeitsflächen inkl. Erweiterungen
sudo apt-get purge remmina remmina-plugin-vnc remmina-plugin-rdp

# Nicht mehr benötigte Pakete entfernen
sudo apt-get autoremove



