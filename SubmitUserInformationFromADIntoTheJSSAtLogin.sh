#!/bin/bash
####################################################################################################
#
# More information: http://macmule.com/2012/05/16/submit-user-information-from-ad-into-the-jss-at-login/
#
# GitRepo: https://github.com/macmule/SubmitUserInformationFromADIntoTheJSSAtLogin/
#
# License: http://macmule.com/license/
#
###################################################################################################
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUE FOR "loggedInUser" IS SET HERE
loggedInUser=""

####################################################################################################
#
# SCRIPT CONTENTS – DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Get the logged in users username
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

#Get UniqueID
accountType=`dscl . -read /Users/$loggedInUser | grep UniqueID | /usr/bin/awk '{ print $2 }'`

#If UniqueID is over 1000 then account will be a network account
if (( "$accountType" > 1000 )); then
	
		#Get logged in users realname
		userRealName=`dscl . -read /Users/$loggedInUser | grep RealName: | cut -c11-`
			
			#If $userRealName is blank
			if [[ -z $userRealName ]]; then
				userRealName=`dscl . -read /Users/$loggedInUser | awk ‘/^RealName:/,/^RecordName:/’ | sed -n 2p | cut -c 2-`
			fi
	
		#Get logged in users email address
		userEMail=`dscl . -read /Users/$loggedInUser | grep EMailAddress: | awk ‘{print $2}’`
		
			#If $userEMail is blank
			if [[ -z $userEMail ]]; then
				userEmail=`dscl . -read /Users/$loggedInUser | awk ‘/^EMailAddress:/,/^FirstName:/’ | sed -n 2p | awk ‘{print $1}’`
			fi
	
		#Get logged in users position
		userPosition=`dscl . -read /Users/$loggedInUser | grep JobTitle: | cut -c 11-`
		
			#If $userPosition is blank
			if [[ -z $userPosition ]]; then
				userPosition=`dscl . -read /Users/$loggedInUser | awk ‘/^JobTitle:/,/^LastName:/’ | sed -n 2p | cut -c 2-`
			fi
	
		#Get logged in users Phone Number
		userPhoneNumber=`dscl . -read /Users/$loggedInUser | grep "PhoneNumber:" | awk ‘{print $2}’`
	
			#If $userPhoneNumber is blank
			if [[ -z $userPhoneNumber ]]; then
				userPhoneNumber=`dscl . -read /Users/$loggedInUser | awk ‘/^PhoneNumber:/,/^PrimaryGroupID:/’ | sed -n 2p | awk ‘{print $1}’`
			fi
	
		#Get logged in users Department
		userDepartment=`dscl . -read /Users/$loggedInUser | grep "Company:" | cut -c 10-`
	
			#If $userDepartment is blank
			if [[ -z $userDepartment ]]; then
				userDepartment=`dscl . -read /Users/$loggedInUser | awk ‘/^Company:/,/^CopyTimestamp:/’ | head -2 | tail -1 | cut -c 2-`
			fi
		
			#If $userDepartment is blank is still blank
			if [[ -z $userDepartment ]]; then
				userDepartment=`dscl . -read /Users/$loggedInUser | awk ‘/^Department:/,/^EMailAddress:/’ | head -2 | tail -1 | cut -c 2-`
			fi

	echo "Submitting information for network account $loggedInUser..."
	
	echo "-endUsername "$loggedInUser" -realname "$userRealName" -email "$userEMail" -position "$userPosition" -phone "$userPhoneNumber" -department "$userDepartment""
	
	sudo jamf recon -endUsername "$loggedInUser" -realname "$userRealName" -email "$userEMail" -position "$userPosition" -phone "$userPhoneNumber" -department "$userDepartment"

else

	#If UniqueID is less than 1000
	echo "Submitting information for local account $loggedInUser…"
	
	userPosition="Local Account"
	
	sudo jamf recon -endUsername "$loggedInUser" -position "$userPosition"

fi
