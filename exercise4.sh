#!/bin/bash

# check if user is root

if [ "$UID" != 0 ]; then
	echo "Error while executing the script..."
	echo "Script must be executed by root"
	exit 1
fi 

# check arguments

if [ "$1" == "" ]; then
	echo "Illegal arguments: ./exercise4.sh -h for help"
	exit 1
fi

# check if /root/reports exits

REPORT_FILE_PATH='/root/reports/'

if [ ! -d "$REPORT_FILE_PATH" ]; then
	mkdir /root/reports
fi

REPORT_DATE=`date +%Y%m%d-%H:%M:%S`

# Parameter control

while getopts "aeu:t:h" opt; do
	case $opt in
		a)
			a=True
			;;
		e)
			e=True
			;;
		u)
			username=${OPTARG}
			;;
		t)
			t=True
			mm=${OPTARG}
			;;
		h)
			echo -e "Usage:
			./exercise4.sh -a -u <username>  print last 24h modified files of <username>
			./exercise4.sh -e -u <username>  print last month connections of <username>
			./exercise4.sh -a  print last 24h modified files of all real users
			./exercise4.sh -e  print last month connections of all real users"
			exit 0
			;;
		\?)
			echo "Invalid parameters. ./exercise4.sh -h for help" >&2
			exit 1
			;;
		:)
			echo "It requires an argument" >&2
			exit 1
			;;
	esac
done

# Allows to get last 24h modified files from particular directory

function get_last_modified_files {
	echo -e "Last 24h modified files of $2: \n" | tee -a $REPORT_FILE_PATH$2-$REPORT_DATE
	echo -e "\nLooking for in $1...\n"
	# mtime allows to find last 24h modified files 
	find $1 -type f -user $2 -mtime -1 -exec ls -lth {} \; 2>/dev/null | sort -k 8 -n | tee -a $REPORT_FILE_PATH$2-$REPORT_DATE
}


# Allows to get last connections of a particular user

function get_connections {
	today=`date +%Y%m%d%H%M%S`
	echo -e "Number of connections of $1: " | tee -a $REPORT_FILE_PATH$1-$REPORT_DATE
	# delete empty lines of output sed '/^$/d'
	last $1 -t $today | grep -v wtmp | sed '/^$/d' | grep -v "in" | wc -l | tee -a $REPORT_FILE_PATH$1-$REPORT_DATE
	echo -e "\nTotal time of each connection: \n" | tee -a $REPORT_FILE_PATH$1-$REPORT_DATE
	last $1 -t $today | sed '$d' | awk '{print $4,$5,$6,$NF}' | grep -v "in" | tee -a $REPORT_FILE_PATH$1-$REPORT_DATE
}

# Main function to execute several tasks

function execute_tasks {

	real_users=`awk -F: '(($6 ~ /\home/ || $1=="root") && ($NF !~ /\/bin\/false/ \
				|| $1=="ftp")) && $3 >= 1024 {print $1}' /etc/passwd`
	
	if [ ${username} ]; then
		if [ `awk -F: '{print $1}' /etc/passwd | grep ${username}` ]; then
			if [ ${a} ]; then
				if [ "$username" != "root" ]; then
					path="/home/${username}"
				else
					path="/root"
				fi
				get_last_modified_files ${path} ${username}
			elif [ ${e} ]; then
				get_connections ${username}
			fi
		else
			echo "User ${username} does not exist in /etc/passwd"
			exit 1
		fi
	else
		if [ ${a} ]; then
			# Only for "real users"
			if [ "$real_users" ]; then
				for user in $real_users; do
					echo "user:"
					for directories in $( find / -user $user -type d -perm -u=w -maxdepth 3 2> /dev/null | sort -u | uniq -c | awk '{print $2}' ); do
						get_last_modified_files ${directories} ${user}
					done
				done
			else
				echo "There are not real users"
				exit 1
			fi
		elif [ ${e} ]; then
			# I suppose that real users are those users have /home
			for user in $( awk -F: '{print $1,$6}' /etc/passwd | grep home | awk '{print $1}' ); do
				get_connections ${user}
			done
		fi
	fi	
}

# Define a countdown function

function countdown {
	if [ "$1" == 3600 ]; then
		count=3600
	else
		count=$(( $1 * 60 ))
	fi
	timming=$count
	while [ $timming -gt 0 ]; do
		let timming=$timming-1
		# explain this command
		read -t 1
	done
	timming=$count
}

# Perioc Execution

while true; do
	# Run the first time
	execute_tasks
	if [ ${t} ]; then
		if [ ${mm} != 0 ]; then
			countdown ${mm}
			execute_tasks
		else
			break
		fi
	else
		mm=3600
		countdown ${mm}
		execute_tasks
	fi
done

echo "Leaving periodic execution..."







