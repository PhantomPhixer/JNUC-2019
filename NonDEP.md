# Non DEP builds #

## Background ##

The overall aim of this workflow is to have a near indentical experience building DEP and Non DEP devices.
Lot's of organisations have devices that can't be DEP built for many reasons.
The overall end aim of this workflow is to get all devices managed in Jamf and then to automatically be able to wipe and reprovision the device.
The only major difference between the two workflows, DEP and Non DEP, is the requirement for a user to approve the MDM profile in the Non DEP build devices, which can't be avoided.

### --eraseinstall ###
Since macOS 10.13.4, subject to th edisk being APFS format, there has been an option: *--eraseinstall*, in the macOS installer to erase the system and put a clean OS install on the disk, as if it had just come out of the box.
Another of the available options is *--installpackage* which allows packages to be installed after the OS is built but immediately prior to the setup screens starting. This is explained well on [*Der Flounder*](https://derflounder.wordpress.com/2017/09/26/using-the-macos-high-sierra-os-installers-startosinstall-tool-to-install-additional-packages-as-post-upgrade-tasks/) blog.

The *--eraseinstall* coupled with the *--installpackage* are the cornerstone of this Non DEP build.


## Experience ##
The overall experience will be the same NoMAD Login choice and notify experience as used in the DEP build out lined [here](https://github.com/PhantomPhixer/JNUC-2019/blob/master/DEP.md).

## Packages ##

The packages used in this workflow will be explained here, how to use them will be explained later. These packages are what will be installed using the *--installpackage* option. On the command line multiple *--installpackage* options can be added to allow the install of several packages.

### Package components ###

There are five items required in the Non DEP Package;


![NonDEP Package](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/nondep-package.png)

1. NoMAD Login.
2. The profile to configure NoMAD login.
3. QuickAdd.
4. The controlling script.
5. LaunchDaemon.

There is also a simple **post install script** to load the LaunchDaemon;
```bash
launchctl load /Library/LaunchDaemons/com.jigsaw24.build_check.plist
```
#### Common items ####

The *NoMAD-Login-AD* package and the *menu.nomad.login.ad.mobileconfig* are the same ones used in the [DEP build](https://github.com/PhantomPhixer/JNUC-2019/blob/master/DEP.md)

#### Differences ####

1. *QuickAdd.pkg* This is created as per the organisations standards using the Jamf Recon app.
    * A separate *Jamf management account* is used in the demo, whilst not strictly necessary but comes in handy for later    scoping or reporting activities.

2. Controlling script and LaunchDaemon.
3. No Graphics! These are installed as a separate package. I could not reliably get the graphics to display when installed from this package so separated them out.

### Graphics Package ###

The graphics package is the same one bundled into the DEP prestage package. These graphics are equally useable by DEPNotify or Jamf Helper or indeed any user facing notification method.

![Graphics Package](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/graphics.png)

## The Control Script ##
The control script, **build_check_mbsetup_script.sh**, is called from the LaunchDaemon, **com.jigsaw24.build_check.plist**, in the package. This is started by the post install script in the package.
This is because when performing the *--eraseinstall* the package installs immediately follows the OS setup and are in turn immediately followed by the setup screens, meaning that the LaunchDaemon must be loaded by the install or it will not start until the device is restarted, which is no use to this process.


### LaunchDaemon ###

The LaunchDaemon is a simple one to run the script and is used to run it with **root** privileges

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.jigsaw24.build_check</string>
	<key>RunAtLoad</key>
	<true/>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/Management/installs/build_check_mbsetup_script.sh</string>
	</array>
</dict>
</plist>
```

### The Script ###

The script has a few key functions that control what happens and when. These are;

1. Check *_mbsetupuser* is active
2. Install NoMAD Login, the profile and set the login window environment to use NoMAD
3. Wait until network up and Jamf contactable
4. Kill the Loginwindow to start NoMAD login
5. run the QuickAdd to enroll in jamf and start the [build process](https://github.com/PhantomPhixer/JNUC-2019/blob/master/build.md). 

#### Check _mbsetupuser active ####

The first check is that *_mbsetupuser* is active. This user becomes active when the setup wizard starts so this is the time to start processing the script;

```bash
# Wait for MBSetup User

mbSetupLoggedIn=0

until [ $mbSetupLoggedIn -gt 0 ]; do
	if [ "$loggedInUser" == "_mbsetupuser" ]; then
		mbSetupLoggedIn=1
	else
		sleep 1
		loggedInUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}     ')
	fi
done
```

#### Setup NoMAD ####

As soon as the setup screens start NoMAD can be installed so the script calls a function for that;

```bash
setupNoMAD () {

# Install NoMAD Profile
/usr/bin/profiles -I -F "$installersPath"menu.nomad.login.ad.mobileconfig

# Install NoLo and graphics
/usr/sbin/installer -pkg "$installersPath"NoMAD-Login-AD.pkg -target /

/usr/local/bin/authchanger authchanger -reset -preLogin NoMADLoginAD:UserInput NoMADLoginAD:Notify

/bin/echo "Command: MainTitle: Setting things up - NON DEP"  >> /var/tmp/depnotify.log
/bin/echo "Command: MainText: Starting mac build, progress screens will display shortly.\n \n This is a non DEP build. \n \n The MDM Profile will need accepting at first logon" >> /var/tmp/depnotify.log
/bin/echo "Command: Image: "/Library/Management/jigsaw24/logo.png"" >> /var/tmp/depnotify.log
/bin/echo "Status: Please wait..." >> /var/tmp/depnotify.log

}
```

In this function a key line is ```/usr/local/bin/authchanger authchanger -reset -preLogin NoMADLoginAD:UserInput NoMADLoginAD:Notify``` which is setting the login window environment.

**authchanger** is used to manipulate the PAM order for the login window. 
```authchanger - reset``` sets the order back to default, used to ensure a known starting point.
```-preLogin NoMADLoginAD:UserInput NoMADLoginAD:Notify``` sets *UserInput* as the first screen to display followed by *Notify* when *UserInput* closes. 

#### check network ####

Need to establish that the network is up and Jamf contactable or there will be no point running the quickadd, to do this a simple check loop is used;

```bash
internetLive=0

until [ "$internetLive" == "200" ]; do	
	internetLive=$(curl -s -k https://myjss.jamfcloud.com/healthCheck.html --write-out %{http_code} -o /dev/null)
	sleep 1
done
```
The build process will move on automatically if using ethernet that doesn't need authentication or on a VM. If using WiFi the setup will step through as normal until WiFi is connected.

#### switch login window ####

To change from the setup screens to the NoMAD login screens setup previously this is used;

```bash
# Create AppleSetupDone File
touch /var/db/.AppleSetupDone

# Restart loginwindow
killall loginwindow
```

using ```touch /var/db/.AppleSetupDone``` stops the setup wizard running any more or at next startup

```killall loginwindow``` kills the loginwindow process which then starts again using the new setting set by *authchanger*, which is the same method as the DEP build uses to change screens.


#### start the build ####

Starting off the build is simply a case of installing the QuickAdd;

```bash
/usr/sbin/installer -pkg "$installersPath"QuickAdd.pkg -target /
```

#### and finally ####

Just to tidy up it waits until jamf is installed and removes itself

```bash
# Wait for the jamf binary to be installed
while [ ! -f /usr/local/bin/jamf ]
do
	sleep 2
done

# Wait for the enrolment profile to appear
MDMProfilePresent=$(profiles status -type enrollment | grep "MDM" | awk -F":" '{ print $2}' | sed 's/ //' | grep -o Yes)

while [ "$MDMProfilePresent" = "" ]
do
	sleep 2
done
echo "MDM profile installed"

rm -f "/Library/LaunchDaemons/com.jigsaw24.build_check.plist"
rm -f "/Library/Management/installs/build_check_mbsetup_script.sh"
```

## How to use this ##


### MDS ###
once the required packages have been created the easiest way to initially use this workflow to get devices into Jamf is using [MDS](http://twocanoes.com/products/mac/mac-deploy-stick/)

This also utilizes the *--eraseinstall* and the *--installpaclage* switches behind a nice easy to use GUI. I won't explian the full working of MDS however the two setup panes required are these;

Add the macOS installer app

![MDS OS Installer](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/MDS-1.png)


Place the two packages in a folder and point the MDS app to that folder

![MDS Extras](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/MDS-2.png)

The MDS disk can then be created.

A workflow for DEP builds can also be created that only uses the macOS installer app as nothing else is required.

### wipe the device ###

To wipe the device and start the process boot to recovery partition then insert the MDS key.
Using **terminal** in the recovery partition start MDS using a command like
```/Volumes/MDSDisk/run```

this looks like this;

![MDS Run](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/MDS-3.png)

Start the workflow and macOS and the extra packages will installed 

## The build ##

[The Build](https://github.com/PhantomPhixer/JNUC-2019/blob/master/build.md) follows.

[UAMDM](https://github.com/PhantomPhixer/JNUC-2019/blob/master/UAMDM.md) follows the build
