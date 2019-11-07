
# The common build #

The build for both workflows is the same, which simplifies things greatly. Using the value set on the UserInput screen allows extension attributes to be set that can be used to scope policies and profiles by smart group as required.


## Jamf Build Policy ##
All that is required for the build is one Jamf policy, this assumes that all the other policies required are run from custom event triggers.
That policy runs a script that does the work and calls the *install policies*.

### Install policies ###
In any JSS I setup all install policies are setup this way as per this example for Jamf Connect;

![Install Policy](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/policy-1.png)

This has the advantage that any other workflow can call the install policy and there is only ever one policy to update for new versions.

The policy itself has to be scoped to **all computers**, any actual scoping should be done on the calling policy.

### Build Policy Script ###

The build policy script is based upon, in fact initially copied from, the one in [Neil Martin's Github](https://github.com/neilmartin83/MacADUK-2019/blob/master/example_provisioning_script.sh). and adapted for use as required.

#### Wait for selection ####

The first interesting part of the script is to wait for the device type selection to be made. Going back to the NoMAD profile there was an entry to set the selection output file;

```xml
<key>UserInputOutputPath</key>
<string>/var/tmp/userinputoutput.plist</string>
```
so in order to know when to proceed with the build this file must be monitored as it only gets created when the **OK** button is clicked. So the script checks for this like so;

```bash
# Wait for the user data to be submitted...
while [[ ! -f /var/tmp/userinputoutput.txt ]]; do
	log "Waiting for user data..."
	/bin/sleep 2
done
```
When the file is created the build can move on.

#### Identify the role and change the NoMAD screen ####

Now the selection has been made it needs to be read for use and displayed on the Notify screen as a visual indication the build is proceeding.
As mentioned before the Notify screen commands are the same as those used by DEPNotify. Note that in these commands some variables are defined previously and are fairly standard scripting variables.

```bash
# Let's read the user data into a variable...
computerRole=$(/usr/libexec/plistbuddy /var/tmp/userinputoutput.txt -c "print 'Computer Role'")
    
# Carry on with the setup...

# Change DEPNotify title and text...
/bin/echo "Command: MainTitle: Setting things up..."  >> /var/tmp/depnotify.log
/bin/echo "Command: MainText: Please wait while we set this Mac up with the software and settings it needs.\n We'll restart automatically when we're finished. \n \n Role: "$computerRole" Mac \n Serial Number: "$serial" \n macOS Version: "$osversion""  >> /var/tmp/depnotify.log
```
When this happens the screen will change from this set by the *prestage* or *Non DEP* package (Non DEP variant shown);

![Build start](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/buildscreen-1.png)

to this;

![Build main](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/buildscreen-2.png)

Which shows useful infomation.

#### update device type in Jamf ####

In order to allow different profiles and policies to deploy the device type is used in a Jamf **Extention Attribute** which is used in **Smart Groups** for scoping.

The next part of the script ensures this is set during the build process allowing any scoped profiles to deploy immediately.

```bash
echo "$computerRole" > /Library/Management/jigsaw24/build_type

log "run recon to update everything" 
/bin/echo "Status: Updating inventory" >> /var/tmp/depnotify.log
/usr/local/bin/jamf recon
```
This part of the script sets the file to contain the device type, updates the Notify screen status bar and then runs an inventory.

The actual EA in Jamf is a script type;

```bash
#!/bin/bash

type="NA"

if [ -f /Library/Management/jigsaw24/build_type ]; then
type=$(cat /Library/Management/jigsaw24/build_type)
fi

echo "<result>$type</result>"
```
This now means the device will fall into, or out of, any applicable smart groups.



