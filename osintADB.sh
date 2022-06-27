#!/bin/bash

###
# The purpose of this script is to perform OSINT on an Android Device via the Android Debug Bridge (ADB)
#
# Author:		Paul A. Wortman
# Last Edit:		2022-06-13
###

### Rough Change Log / ToDo List
# [ ]	Build basic structure of the script
# [ ]	Recognize if there are any existing ADB devices seen
# [ ]	Get debugging print out an information set on the script
# [ ]	Start with basic system information output
#
#
#
#

### Notes:
# First Format:				function_name () {
#						commands
#					}
# Single Line Version:			function_name () { commands; }
# Second Format:			function function_name {
#						commands
#					}
# Single Line Version:			function function_name { commands; }

### Globals
debugBit=0

### Functions
function intro_information {
	echo -e "-----------------------------------------------------------------------------------------------"
	echo -e "	Android Debugging Bridge	-	OSINT Searching Tool				"
	echo -e "	------------------------------------------------------------				"
	echo -e "												"
	echo -e " Usage:	./osintADB.sh	< osint storage directoy > < device Id >							"
	echo -e "	-> Note: If no Device ID is provided, then the script will attempt to locate		"
	echo -e "			the appropriate device candidates					"
	echo -e " The purpose of this tool is to gather information on Android devices, connected to via adb	"
	echo -e "												"
	echo -e "-----------------------------------------------------------------------------------------------"
}

function osint_explore_adb_target {
	local var adb_target_id=$1
	echo -e "================================================================================"
	echo -e "[*] Collecting information on the ADB Android Target ID\t-\t[\t$adb_target_id\t]"
	echo -e "--------------------------------------------------------------------------------"
	echo -e "[*] Gathering Android System Properties Information"
	# Print out Device Property Information (Formatted Summary type output)
	echo -e "Device Property Summary Information:"
	echo -e "\tSDK Build Version:			$(adb -s $adb_target_id shell getprop ro.build.verison.sdk)"
	echo -e "\tSecurity Patch Build Version:	$(adb -s $adb_target_id shell getprop ro.build.version.security_patch)"
	echo -e "\tBoard Platform:			$(adb -s $adb_target_id shell getprop ro.board.platform)"
	echo -e "\tRelease Build Version:		$(adb -s $adb_target_id shell getprop ro.build.version.release)"
	echo -e "\tVendor Product Model:		$(adb -s $adb_target_id shell getprop ro.vendor.product.model)"
	echo -e "\tProduct Manufacturer:		$(adb -s $adb_target_id shell getprop ro.product.manufacturer)"
	echo -e "\tSerial Number:			$(adb -s $adb_target_id shell getprop ro.serialno)"
	echo -e "\tOEM Unlock Supported:		$(adb -s $adb_target_id shell getprop ro.oem_unlock_supported)"
	echo -e "\tBoot Image Build Fingerprint:	$(adb -s $adb_target_id shell getprop ro.bootimage.build.fingerprint)"
	echo -e "\tBoot WiFi MAC Address:		$(adb -s $adb_target_id shell getprop ro.boot.wifimacaddr)"
	echo -e "\tDevice net.dns1:"
	adb -s $adb_target_id shell getprop net.dns1
	echo -e "\tDevice net.dns2:"
	echo -e "[*] Gathering Android Settings System Information"
	# Print out System Settings Information
	echo -e "\tSystem Settings Information:" 
	adb -s $adb_target_id shell settings list system
	# Print out System Volume Information
	echo -e "\tSystem Volume Information:"
	adb -s $adb_target_id shell settings get system volume_system
	# Print out System Notificaiton Sound Information
	echo -e "\tSystme Notificaiton Sound Information:"
	adb -s $adb_target_id shell settings get system notificaiton_sound
	# Print out Secure Settings Information
	echo -e "\tSecure Settings Information:"
	adb -s $adb_target_id shell settings list secure
	# Print Secure Android ID (Device ID)
	echo -e "\tSecure Android / Device ID:"
	adb -s $adb_target_id shell settings get secure android_id
	# Print Device Bluetooth Address
	echo -e "\tDevice Bluetooth Address:"
	adb -s $adb_target_id shell settings get secure bluetooth_address
	# Print Global Settings
	echo -e "\tGlobal Settings Information:"
	adb -s $adb_target_id shell settings list global
	# Print Device Mobile Data Status
	echo -e "\tDevice Mobile Data Status Information:"
	adb -s $adb_target_id shell settings get global mobile_data
	# Print Current WiFi Status
	echo -e "\tCurrent Device WiFi Status Information:"
	adb -s $adb_target_id shell settings get global wifi_on
	echo -e "--------------------------------------------------------------------------------"
	echo -e "\tInternal Device Testing"
	## TODO: Add in commands to attempt screen control, take screenshots, and then exfiltrate
	# Use screenrecord, screencap, then 'adb pull' the file; default location: /sdcard/<filename>
	echo -e "[*] Attempting Screen Capture and Recordings of Android Device"
	echo -e "\tScreen Capture being Attempted...."
	adb -s $adb_target_id shell screencap /sdcard/screen.png
	adb -s $adb_target_id shell pull /sdcard/screen.png $osint_directory_location
	echo -e "\tAttempting Screen Recording...."
	adb -s $adb_target_id shell screenrecord /sdcard/demo.mp4
	adb -s $adb_target_id shell pull /sdcard/demo.mp4 $osint_directory_location
	adb -s $adb_target_id shell getprop net.dns2
	echo -e "[*] Gathering Activity Manager (AM) Information"
	#adb -s $adb_target_id shell am 
	echo -e "[*] Gathering Package Manager (PM) Information"
	# Print Packages of the System
	adb -s $adb_target_id shell pm list packages
	# Print Features of the System
	echo -e "\tFeatures of the System Information:"
	adb -s $adb_target_id shell pm list features
	# Print System Permissions
	echo -e "\tList of the Known Permissions:"
	adb -s $adb_target_id shell pm list permissions
	# Print System Libraries
	echo -e "\tList of the Known Libraries:"
	adb -s $adb_target_id shell pm list libraries
	# Print System Users
	echo -e "\tList of the Known Users:"
	adb -s $adb_target_id shell pm list users
	# Print Test of All Packages
	echo -e "\tResults of Testing all Packages"
	adb -s $adb_target_id shell pm list instrumentation
	echo -e "[*] Gathering Device Policy Manager (DPM) Informaiton"
	# End of the Search Output
	echo -e "================================================================================"
}

### Main Script

## Check to see if any function variables were passed with the script
if [[ $# -eq 0 ]]; then
	intro_information
	#exit 1
elif [[ $# -eq 1 ]]; then
	echo -e "Searching for OSINT Storage Directory $1"
elif [[ $# -eq 2 ]]; then
	echo -e "Searching for OSINT Storage Directory $1"
	echo -e "Searching for Device ID $2"
else
	echo -e "Received too many arguments....."
	exit 2
fi

## Check if the adb server is running
#	- Note: Check using the 'ps -C adb' command
if ps -C adb | grep -q adb; then
	echo -e "[+] Confirmed that ADB is currently running... Do not need to start up the server"
else
	echo -e "[-] ADB server is not currently running... Starting up server"
	adb start-server
	echo -e "[+] ADB server has been started"
fi

## TODO: Check if the provided storage directory exists
osint_directory_location=$1
# Check that the first variable was not empty
if [[ ! -z "$osint_directory_location" ]]; then 
	echo -e "[+] User Provided an OSINT Storage Directory"
else
	echo -e "[-] User has not provided an OSINT Storage Directory"
	exit 3
fi
# Check that the OSINT Storage Directory actually exists or not
if [[ ! -d $osint_directory_location ]]; then
	echo -e "[-] Provided OSINT Storage Directory does NOT exist..."
	exit 4
else
	echo -e "[+] Confirmed existence of OSINT Storage Directoy [ $osint_directory_location ]"
fi

## Check for any existing devices
if [[ -n $(adb devices -l | tail -n +2) ]]; then		# Note: The check here relies on the adb server having been started
	echo -e "Non-empty string was returned"
	potential_adb_targets="$(adb devices -l | tail -n +2)"
else
	echo -e "Empty string was returned"
	#potential_adb_targets="$(adb devices -l | tail -n +2)"
	echo -e "[-] No potential targets to attack present.... Exiting script"
	exit 3
fi

## Begin querying the potential ADB targets
# Setup the IFS (Field Separator) to a new line character
IFS=$'\n'
# Loop through the potential ADB targets
echo -e "Loop of Target Gathering:"
for adb_target in $potential_adb_targets; do
	echo -e "Potential Target:\t$adb_target"
	adb_target_id=$(echo $adb_target | cut -d' ' -f1)
	osint_explore_adb_target $adb_target_id
done


## Shutdown the adb server
echo -e "Shutting down ADB server...."
adb kill-server
echo -e "[+] ADB Server shut down"
