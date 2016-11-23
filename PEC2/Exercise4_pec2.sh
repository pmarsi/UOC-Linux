#!/bin/bash


if [ "$1" == "" ]; then
	echo "Illegal arguments: ./exercise4_pec2.sh -h for help"
	exit 1
fi

function get_owner_packages {
	echo -e "==== The origin package of $1 ===="
	dpkg -S $1 | awk '{print $1}' | uniq | cut -d':' -f1 | sort -n | less	
}

function get_upgradeable_packages {
	echo -e "==== All upgradeable packages ===="
	#apt-show-versions -u | awk '{print $1, "\nNew package version: ", $5}' | sort -n | less
	apt list --upgradeable | sort -n | less
}

function not_installed {
	echo -e "==== Not installed packages ===="
	apt-cache dump | grep -i -w package | sort -n | less
}

function get_package_function {
	echo -e "==== Function of $1 ===="
	apt-cache show $1 | grep Description-en | uniq
}

function get_package_new_versions {
	echo -e "==== All packages with new versions ===="
	#apt-cache policy $1 | grep 500 | sort -n | less
	upgrade_versions=`apt list --upgradeable | awk '{print $2}' cut -d'.' -f1`
	old_version=`apt list --upgradeable | awk '{print $6}' | cut -d'.' -f1` 
	for i in $old_version; do
		for m in $upgrade_versions; do
			if [ "$i" == "$m" ]; then
				echo "New version: ", $m

			else
				echo "There aren't new versions, only new releases"
			fi
		done
	done	

}

# get parameters

while getopts "ip:uvnf:h" opt; do
	case $opt in
		i)
			echo -e "==== Installed packages ===="
			dpkg -l | awk '{print $2}' | sort -n | less
			;;
		p)
			installed_packages=${OPTARG}
			get_owner_packages ${installed_packages}
			;;
		u)
			get_upgradeable_packages
			;;
		v)
			new_versions=${OPTARG}
			get_package_new_versions
			;;
		n)
			not_installed 
			;;
		f)
			function=${OPTARG}
			get_package_function ${function}
			;;
		h)
			echo -e "Usage:
			./exercise4_pec2.sh -i print installed packages
			./exercise4_pec2.sh -p <file> print owner package of a file
			./exercise4_pec2.sh -u print upgradeable packages
			./exercise4_pec2.sh -v print packages with new versions
			./exercise4_pec2.sh -n print not installed packages
			./exercise4_pec2.sh -f <package> print function of a package"
			exit 0 
			;;
		\?)
			echo "Invalid parameters. ./exercise4_pec2.sh -h for help" >&2
			exit 1
			;;
		:)
			echo "It requires an argument" >&2
			exit 1
			;;
	esac
done
