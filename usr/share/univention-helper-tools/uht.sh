#!/bin/bash

## Load settings
source /usr/share/univention-helper-tools/settings.conf
source "${UCSHTCORE}/functions.ucs"

# while getopts ':cmbrcp:' OPTION ; do
#   case "$OPTION" in
# 	c)	echo "Performing base checks..."
# 		checks;;
# 	m)   echo "Try to mount"
# 		mount;;
# 	p)   echo "Backup path is: $OPTARG";;
# 	r)   echo "Ok, do a restore";;
# 	c)   echo "Ok, tidy up afterwards";;
# 	*)   echo "Unknown parameter"
#   esac
# done


##	@var	option		description
##	-m	nA		mount tools
while getopts ":mbvsh" opt; do
	case $opt in
		m)
			###########
			## Mount ##
			###########
			echo "Launch mounting features";

			while getopts ":n:d:c:h" opt; do
				case $opt in
					n)
						echo "Set nfs source, Parameter: $OPTARG";
						NVAR=$OPTARG;
						;;
					d)
						echo "Set mount destination, Parameter: $OPTARG";
						DVAR=$OPTARG;
						;;
					\?)
						echo "Unknown parameter: $OPTARG";
						exit 1
						;;
					:)
						echo "Option -$OPTARG requires an argument. Use -m -h for the help screen.";
						exit 1
						;;
					h)
						echo "";
						echo "++++ Help ++++";
						echo "-n [nfs source]		Set the nfs source. Eg. 10.10.10.10:/share";
						echo "-d [destination]	Directory";
						echo "-c			Use the config vars to set the mountpoints";
						echo "";
						exit 1
						;;
				esac
			done

			## Nothing selected, use settings from config file
			if [[ ( "$NVAR" != "" && "$DVAR" != "") ]]; then
				echo "";
				echo "Set mountpoint using custom vars";
				uhtmount ${NVAR} ${DVAR}
			else
				echo "";
				echo "Set mountpoint using vars from settings.conf";
				uhtmount ${NFSSOURCE} ${NFSMOUNTDIR}
			fi
			exit 1
			;;
		b)
			############
			## Backup ##
			############
			echo "Launch backup features";

			uhtbackup 0
			;;
		v)
			#############
			## Version ##
			#############
			echo "Simple Univention Helper Tools (SimpleUHT ${UHT_VERSION})";
			echo "(c) 1997-2015 by devXive - research and development. All rights reserved.";
			echo "";
			;;
		s)
			###########
			## Setup ##
			###########
			echo "Install Univention Helper Tools";

			uhtsetup
			;;
		h)
			##########
			## Help ##
			##########
			echo "Launch Help Site";

			echo "";
			echo "uht -m			:Mounting tools";
			echo "uht -b			:Backup tools";
			echo "uht -v			:Version info";
			echo "uht -s			:Setup, which make uht global available";
			echo "uht -h			:Help Site, which also show disk info (mountpoint)";
			echo "";

			echo "";
			echo "Show disk infos of the available mountpoint:";
			if [[ ( "$DVAR" != "") ]]; then
				df -h ${DVAR}
			else
				df -h ${NFSMOUNTDIR}
			fi
			echo "";
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done