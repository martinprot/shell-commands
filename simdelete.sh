#! /bin/bash

# Reinitialize installed apps in all simulators

SIM_DEVICES_FOLDER=~/Library/Developer/CoreSimulator/Devices

CONTAINER_FOLDER=data/Containers
BUNDLE_FOLDER=${CONTAINER_FOLDER}/Bundle/Application
APPLICATION_DATA_FOLDER=${CONTAINER_FOLDER}/Data/Application

if [[ $1 == "" ]]; then
	echo "please enter the app name"
	exit;
fi

APPLICATION_ARG=$1

# 1 check foreach "$SIM_DEVICES_FOLDER/*/$CONTAINER_FOLDER" if my app exist

for deviceDir in $SIM_DEVICES_FOLDER/*
do
	ALL_APP_FOLDERS="${deviceDir}/$BUNDLE_FOLDER"
    if [ -d $ALL_APP_FOLDERS ]; then
		for appDir in $ALL_APP_FOLDERS/*
		do
			if [ -d ${appDir}/${APPLICATION_ARG}.app ]; then
				BUNDLE_IDENTIFIER=$(/usr/libexec/PlistBuddy -c "print :CFBundleIdentifier" ${appDir}/${APPLICATION_ARG}.app/Info.plist)
				
				#found the bundle id				
				for dir in ${deviceDir}/$APPLICATION_DATA_FOLDER/*
				do
					IDENTIFIER=$(/usr/libexec/PlistBuddy -c "print :MCMMetadataIdentifier" ${dir}/.com.apple.mobile_container_manager.metadata.plist)
					if [ "${IDENTIFIER}" == "${BUNDLE_IDENTIFIER}" ]; then
						if [ -d ${dir}/Documents ]; then
							PathToDelete="${dir}/Documents/*"
							echo "rm -Rf $PathToDelete"
							# WE FOUND THE REP TO DELETE!
							rm -Rf $PathToDelete
						fi
						break;
					fi
				done
				
				break;
			fi
		done
    fi
done


# if [ -d $1/${dir}/${APPLICATION_ARG}.app ]; then
#   APP_FOLDER=$1/${dir}
#   break;
# fi