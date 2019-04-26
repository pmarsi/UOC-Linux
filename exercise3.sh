#!/bin/bash

FILENAME=`date +%Y%m%d`_user_files
echo "using logging"
# check parameters

if [ "$1" == "" ]; then
	echo "Fail"
	echo "Illegal number of parameters: ./execise3.sh -h for help"
	exit 1
fi

# get and check arguments

while getopts ":u:h" opt; do
	case $opt in
		u)
			username=${OPTARG}
			;;
		h)
			echo "Usage: ./exercise3.sh -u <username>"
			exit 0
			;;
		\?)
			echo "Invalid parameters: ./exercise3.sh -h for help" >&2
			exit 1
			;;
		:)
			echo "-u require an argument"
			exit 1
			;;

	esac
done

# Check if inserted username exists

if [ `awk -F: '{print $1}' /etc/passwd | grep ${username}` ]; then
	echo -e "[ SECTION 1: FILES where ${username} is owned ]\n" > /tmp/${FILENAME}
	find /home/${username} -type f -user ${username} | sort -n >> /tmp/${FILENAME}
	echo -e "\n[ SECTION 2: DIRECTORIES where ${username} is owned ]\n" >> /tmp/${FILENAME}
	find /home/${username} -type d -user ${username} -maxdepth 3 -exec dirname {} \; | sort -n >> /tmp/${FILENAME}
	echo -e "\n[ SECTION 3: FILES bigger than 1024 Kbyte ]\n" >> /tmp/${FILENAME}
	find /home/${username} -type f -user ${username} -size +1024k -exec ls -lh {} \; | sort -k 5 -n >> /tmp/${FILENAME}
else
	echo "Username does not exist"
	exit 1
fi
