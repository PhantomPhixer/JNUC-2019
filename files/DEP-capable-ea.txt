#!/bin/bash

######################################
# Mark Lamont 2019                   #
# use entirely at your own risk      #
######################################

###############################################################################################################################
# EA to determine if a mac is DEP capable. this works if the device is added to a prestage and has the enrollment info in Apple
# in Jamf create EA called "DEP Capable", set to be "string" and type as "script"
################################################################################################################################

# set default answer to "no". only want to set to "yes" if it's true
result="no"

# use profiles to see if the device is in Apple. if it is 1 is returned, if not 0
configURL=$(profiles show -type enrollment | grep ConfigurationURL | grep -c http)

if [ "$configURL" = "1" ]; then
result="yes"
fi

echo "<result>$result</result>"
