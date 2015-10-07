#!/bin/bash

echo "##########################################################"
echo "#                                                        #"
echo -e "#  \e[38;5;87mWelcome to the WALZ.systems Corporate Client Patcher\e[0m  #"
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
echo "We'll now reactivate the root account. Please follow the instructions below."
echo "First, you have to enter the password for the sysmaster account!"
echo ">> After that, you have to set a password for the root account:"
passwd root

## Check if backup of original exists, else create a copy
echo ""
echo ""
if [ ! -f /etc/ssh/sshd_config.ORIG ]; then
	echo -e "\e[38;5;46mMove /etc/ssh/sshd_config original file to /etc/ssh/sshd_config.ORIG\e[0m"
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ORIG
else
	echo -e "\e[38;5;202mSkip backup, because the original file already exists\e[0m"
fi
cp /usr/share/univention-wsccubuntu-integration/files/sshd_config /etc/ssh/sshd_config
echo ""
echo ""
echo -e "\e[38;5;227m...restart ssh service\e[0m"
service ssh restart

echo ""
echo ""
echo -e "\e[38;5;227mPerforming complete system updates. This may take some time!\e[0m"
echo -e "\e[38;5;227m(based on your internet connection)\e[0m"
# ------------------------------------------------------ INSTALL UPDATE --------------------------------------------------------
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y


# --------------------------------------------------- INSTALL APPLICATIONS -----------------------------------------------------
# Install numlockx and enable it for lightdm (on login screen)
echo -e "\e[38;5;112mInstall and activate numlockx (used to activate num lock key on lightdm login screen)\e[0m"
apt-get install numlockx -y
echo "greeter-setup-script=/usr/bin/numlockx on" >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf


# Install NFS-Commons
echo -e "\e[38;5;112mInstall nfs-common (need to mount nfs directories)\e[0m"
apt-get install nfs-common -y


# Install VIM-Editor
echo -e "\e[38;5;112mInstall vim (a nice and colored texteditor)\e[0m"
apt-get install vim -y


# Install OwnCloud Client
echo -e "\e[38;5;112mSet owncloud repository and Install owncloud-client (owncloud linux client)\e[0m"
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/xUbuntu_14.04/Release.key
apt-key add - < Release.key
mkdir -p /usr/share/univention-wsccubuntu-integration/commons/owncloud
mv Release.key /usr/share/univention-wsccubuntu-integration/commons/owncloud
sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/xUbuntu_14.04/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
apt-get update
apt-get install owncloud-client -y



# -------------------------------------------------- UNINSTALL APPLICATIONS ----------------------------------------------------
# Einzelanwendungen
#	brasero			= CD/DVD Brennprogramm				# Auto Installed Packages (AIP): brasero-cdrkit
#	cheese			= Webcam-Automat				# AIP: gnome-video-effects
#	xul-ext-ubufox		= Ubuntu Änderungserweiterung für Firefox	# AIP: N/A
#	unity-scope-gdrive	= Google Drive Integration			# AIP: N/A
echo ""
echo ""
echo -e "\e[38;5;170mUninstall brasero\e[0m"
apt-get purge -y brasero

echo ""
echo ""
echo -e "\e[38;5;170mUninstall cheese\e[0m"
apt-get purge -y cheese

echo ""
echo ""
echo -e "\e[38;5;170mUninstall xul-ext-ubufox\e[0m"
apt-get purge -y xul-ext-ubufox

echo ""
echo ""
echo -e "\e[38;5;170mUninstall unity-scope-gdrive\e[0m"
apt-get purge -y unity-scope-gdrive


# Spiele
# 	aisleriot								# AIP: guile-2.0-libs libgc1c2
#	gnome-mahjongg								# AIP: N/A
#	gnome-sudoku								# AIP: N/A
#	gnome-mines								# AIP: N/A
#	gnomine									# AIP: N/A				// wird mit gnome-mines deinstalliert
echo ""
echo ""
echo -e "\e[38;5;170mUninstall various games\e[0m"
apt-get purge -y aisleriot gnome-mahjongg gnome-sudoku gnome-mines gnomine


# Programm zur Videowiedergabe
# 	totem									# AIP: gir1.2-totem-1.0 gir1.2-totem-plparser-1.0 libtotem0 totem-common
echo ""
echo ""
echo -e "\e[38;5;170mUninstall totem and its extensions\e[0m"
apt-get purge -y totem totem-mozilla totem-plugins


# Programm zur Fotoverwaltung und -betrachtung inkl. Erweiterungen
# 	shotwell								# AIP: libexiv2-12 libgexiv2-2 libraw9
echo ""
echo ""
echo -e "\e[38;5;170mUninstall shotwell and its extensions\e[0m"
apt-get purge -y shotwell shotwell-common


# eMail CLient inkl. Erweiterungen
# 	thunderbird								# AIP: N/A
echo ""
echo ""
echo -e "\e[38;5;170mUninstall thunderbird and its extensions\e[0m"
apt-get purge -y thunderbird thunderbird-gnome-support thunderbird-locale-en thunderbird-locale-de thunderbird-locale-en-us


# Programm zur Audiowiedergabe inkl. Erweiterungen
# 	rhythmbox								# AIP: brasero-common dvd+rw-tools gir1.2-gnomekeyring-1.0 gir1.2-rb-3.0 gir1.2-secret-1 growisofs libbrasero-media3-1 libburn4 libdmapsharing-3.0-2 libgmime-2.6-0 libgpod-common libgpod4 libisofs6 libjte1 liblircclient0 librhythmbox-core8 libsgutils2-2 libtotem-plparser18 media-player-info python3-mako python3-markupsafe rhythmbox-data
echo ""
echo ""
echo -e "\e[38;5;170mUninstall rhythmbox and its extensions\e[0m"
apt-get purge -y rhythmbox rhythmbox-plugin-zeitgeist rhythmbox-plugin-cdrecorder rhythmbox-mozilla rhythmbox-plugin-magnatune rhythmbox-plugins



# Programm zum Zugriff auf entfernte Arbeitsflächen inkl. Erweiterungen
# 	remmina									# AIP: libfreerdp-plugins-standard libfreerdp1 libssh-4 libvncserver0 remmina-common
echo ""
echo ""
echo -e "\e[38;5;170mUninstall remmina and its extensions\e[0m"
apt-get purge -y remmina remmina-plugin-vnc remmina-plugin-rdp


# Nicht mehr benötigte Pakete entfernen
echo ""
echo ""
echo -e "\e[38;5;170mCleanup remaining extensions and fragments\e[0m"
apt-get autoremove -y


echo -e "\e[38;5;87m...launching the UCS LDAP integration script\e[0m"
bash /usr/share/univention-wsccubuntu-integration/ucs-ldap-integration.sh
