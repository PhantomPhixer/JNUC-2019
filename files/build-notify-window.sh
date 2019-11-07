#!/bin/bash

## First run script following DEP enrolment
## based on the one by Neil Martin, formerly University of East London

# Set basic variables
osversion=$(/usr/bin/sw_vers -productVersion)
serial=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/awk -F'"' '/IOPlatformSerialNumber/{print $4}')

# Function to add date to log entries
log(){
NOW="$(date +"*%Y-%m-%d %H:%M:%S")"
/bin/echo "$NOW": "$1"
}

# Logging for troubleshooting - view the log at /Library/Management/ARK/firstrun.log
/usr/bin/touch /Library/Management/jigsaw24/firstrun.log
exec 2>&1>/Library/Management/jigsaw24/firstrun.log

# Let's not go to sleep
log "Disabling sleep..."
/usr/bin/caffeinate -d -i -m -s -u &
caffeinatepid=$!

# Disable Automatic Software Updates during provisioning
log "Disabling automatic software updates..."
/usr/sbin/softwareupdate --schedule off

# Set Network Time
log "Configuring Network Time Server..."
/usr/sbin/systemsetup -settimezone "Europe/London"
/usr/sbin/systemsetup -setusingnetworktime on

# Wait for the device type to be submitted...
while [[ ! -f /var/tmp/userinputoutput.txt ]]; do
	log "Waiting for user data..."
	/bin/sleep 2
done

log "device type submitted, continuing setup..."

# Let's read the user data into a variable...
computerRole=$(/usr/libexec/plistbuddy /var/tmp/userinputoutput.txt -c "print 'Computer Role'")

# Carry on with the setup...

# Change DEPNotify title and text...
/bin/echo "Command: MainTitle: Setting things up..."  >> /var/tmp/depnotify.log
/bin/echo "Command: MainText: Please wait while we set this Mac up with the software and settings it needs.\n We'll restart automatically when we're finished. \n \n Role: "$computerRole" Mac \n Serial Number: "$serial" \n macOS Version: "$osversion""  >> /var/tmp/depnotify.log

log "Initiating Configuration..."

echo "$computerRole" > /Library/Management/jigsaw24/build_type

log "run recon to update everything"
/bin/echo "Status: Updating inventory" >> /var/tmp/depnotify.log

/usr/local/bin/jamf recon

computerName="$serial"

# Time to set the hostname...
log "Setting hostname to "$computerName"..."
/usr/local/bin/jamf setComputerName -name "$computerName"
sleep 2
# Bind to AD
#log "Binding to Active Directory..."
#/bin/echo "Status: Binding to Active Directory..." >> /var/tmp/depnotify.log
#/usr/local/bin/jamf policy -event BindAD
#sleep 5
# Deploy policies for all Macs
log "Running software deployment policies..."

######### Template block for policy #######################
#/bin/echo "Status: Installing an app" >> /var/tmp/depnotify.log
#/usr/local/bin/jamf policy -event install-myapp-live

/bin/echo "Status: Installing Jamf Connect" >> /var/tmp/depnotify.log
/usr/local/bin/jamf policy -event install-jcl-live

sleep 2
log "Software deployment policies completed"

# set build complete flag
touch /Library/Management/jigsaw24/build-complete
# Run a recon
/bin/echo "Status: Updating inventory..." >> /var/tmp/depnotify.log
log "Running recon..."
/usr/local/bin/jamf recon

# Run a Software Update
#log "Running Apple Software Update..."
#/usr/local/bin/jamf policy -event DeploySUS

# Finishing up

/bin/echo "Command: MainTitle: Build Complete"  >> /var/tmp/depnotify.log
/bin/echo "Command: MainText: This Mac will restart shortly and will be ready for logon with your organisational account."  >> /var/tmp/depnotify.log
/bin/echo "Status: Restarting, please wait..." >> /var/tmp/depnotify.log

# Reset login window authentication mech to JC
log "Resetting Login Window..."
/usr/local/bin/authchanger -reset -OIDC

# Remove NoMAD profile
/usr/bin/profiles -R -p FF808D2C-A258-46CB-928E-41E0D7347ED2
# Kill caffeinate and restart with a 1 minute delay
log "Decaffeinating..."
log "Restarting in 1 minutes..."
kill "$caffeinatepid"
/sbin/shutdown -r +1 &

log "Done!"