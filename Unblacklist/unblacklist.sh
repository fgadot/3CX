#!/bin/bash
# unblacklist
# made by Frank Gadot - frank@universe-corrupted.com 
# For Jersey Shore Technologies / HERMES42 <info@hermes42.com>
# V0.1b - 2019.03.05

#####################
# F U N C T I O N S #
#####################

# Test IP address for validity
# Usage: 
# validateIpAddress ip_addr
#
function validateIpAddress() {
	local ip=$1
	local result=1
	
	# Make sure the 4 octets are nothing but numbers	
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	
		# Change temporarily the bash Internal Field Separator to a . (dot)
		IFS_temp=$IFS
		IFS='.'
		
		# Assign the value of the IP address to itself inside parenthesis in order to return an array
		ip=("$ip")
		
		# Restore the IFS to bash original value
		IFS=$IFS_temp
		
		# Finally, make sure that each octet have a value lower than 255
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		# and save the status of this test
		result=$?
	fi
	echo $result
}



# Get the database password for  phonesystem user
# Usage:
# getDBPassword
#
function getDBPassword() {
	# Get the password from 3CX File
	DBPassword=$(grep MasterDBPassword /var/lib/3cxpbx/Bin/3CXPhoneSystem.ini|cut -d' ' -f3)
	
	if [[ $? -eq 1 ]]; then
		echo "I was unable to read the phonesystem user password."
		exit
	fi
}



# Check if IP address exists in blacklist
# Usage: checkIpAddress ip_addr
# Returns 0 if IP exists, 1 if not found
function checkIpAddress() {
    getDBPassword
    local count=$(psql postgresql://phonesystem:"$DBPassword"@127.0.0.1/database_single -t -c "SELECT COUNT(*) FROM blacklist WHERE ipaddr = '$1';" | tr -d ' ')
    [[ $count -gt 0 ]] && echo 0 || echo 1
}

# Delete IP address from blacklist
# Usage: deleteIpAddress ip_addr
# Returns 0 if deletion successful, 1 if failed
function deleteIpAddress() {
    getDBPassword
    local result=$(psql postgresql://phonesystem:"$DBPassword"@127.0.0.1/database_single -t -c "DELETE FROM blacklist WHERE ipaddr = '$1' RETURNING 1;" | tr -d ' ')
    [[ -n "$result" ]] && echo 0 || echo 1
}

# Restart 3CX service if deletion was successful
# Usage: restartService
function restartService() {
    echo "Restarting 3CX Phone System MC01 service..."
    if sudo service 3CXPhoneSystemMC01 restart; then
        echo "Service restarted successfully."
        echo "You may now try to re-login through the web interface."
        return 0
    else
        echo "Failed to restart service. Please restart manually with:"
        echo "sudo service 3CXPhoneSystemMC01 restart"
        return 1
    fi
}




###########
# M A I N #
###########
# Ask for the IP address to delete
echo "unblacklist \V0.1b\ - March 2019"
read -rp "Enter the IP address to remove from the blacklisted database: " ip_addr

# IP address check
if [[ $(validateIpAddress "$ip_addr") -eq 1 ]]; then
	echo "The IP address you entered is incorrect."
	exit
fi

# Check if IP address exists in database before deletion
if [[ $(checkIpAddress "$ip_addr") -eq 1 ]]; then
    echo "IP address $ip_addr is not found in the blacklist database."
    exit 1
fi

# Delete the IP address and check if successful
if [[ $(deleteIpAddress "$ip_addr") -eq 0 ]]; then
    echo "Successfully removed $ip_addr from the blacklist."
    
    # Ask user if they want to restart the service
    read -rp "Do you want to restart the 3CX Phone System MC01 service now? (y/N): " restart_choice
    case "$restart_choice" in
        [yY]|[yY][eE][sS])
            restartService
            ;;
        *)
            echo "Service not restarted. You can restart manually with:"
            echo "sudo service 3CXPhoneSystemMC01 restart"
            echo "Once the service is restarted, you may try to re-login through the web interface."
            ;;
    esac
else
    echo "Failed to remove $ip_addr from the blacklist. Please check database connection and permissions."
    exit 1
fi
