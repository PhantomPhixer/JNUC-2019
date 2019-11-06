# JNUC-2019
This repository contains the scripts and other useful info related to my JNUC 2019 presentation entitled *Build it and they will come* which was about using Jamf, MDS and macOS eraseinstall to create automatic workflows for provisioning and re-provisioning macOS devices that use DEP and those that can't use DEP.

---

## Overall Flow ##

The overall aim of the talk's is how to bring mac devices into jamf management with a common, or at least a known, clean OS and then to be able to erase and reprovision then automatically, possibly with no interaction at all, regardless of whether they are DEP capable or not.


![Flow](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/flow.png)




As the flow shows the *Build* part is common allowing simple management of the build process. The entry route is variable and the post build tasks and flows are automatically driven by policies to enable the whole thing to be driven from Jamf.

## Who's it aimed at? ##
Anyone managing macs! Although developed for organisations bringing devices, both DEP and non DEP, into Jamf the methods used can be applied if you already have your whole fleet in Jamf.

So as the talk said;


**Are you an organisation with**

* Devices of various OS levels
* Some assigned in ABM/ASM and jamf
* Some, probably lots, not….
* Need a common build and rebuild method


**Then this is for you...**

---

## The DEP Build ##

The challenge for the build started with having two distint build types but only wanting one way to build them. NoMAD login has a mechanism for allowing user input at the login screen. So taking a lot of inspiration from [Neil Martins blog](https://github.com/neilmartin83/MacADUK-2019/blob/master/Neil_Martin_MacADUK_2019_Slides_FINAL.pdf) the NoMAD login *User_Input* method was chosen as a way to allow selection.

### The choice screen ###

After the initial standard DEP enrollment screens the NoMAD choices screen starts.
It look like this,

![NoMAD User_Input](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/nomad-choice.png)

This screen can be configured with many input choices dependant upon requirements, for this only one; a drop down, is required. How this is achieved is explained later.

Then when the selection is made the screen changes to this one,

![NoMAD Notify](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/notify-screen.png)

What and how the choice affects the build will be covered later.

## The Build Process progress screens ###

The next stage is the actual *build* where all the required applications and profiles are deployed. After enrollment a policy runs that contains a script that controls the entire build. This performs the following things;
1. Waits for the choice before proceeding
2. Sends messages to the NoMAD Notify screen
3. Calls any install policies using custom trigger; e.g. *jamf policy -event install-chrome*
4. sets the post build logon environment to use either native mac logon or any of the Jamf connect or NoMAD login windows as required.
5. It also preforms any other functions related to this stage of the build.

The notify screen text and graphics are driven using [DEPNotify](https://gitlab.com/Mactroll/DEPNotify) commands which makes it easy to control.
In an earlier talk I spoke to the [LAA](https://londonappleadmins.org.uk/) about many uses of DEPNotify, the ideas used there for build progeress screens are directly transferable to this build process, you can find that talk [here](https://montysmacmusings.wordpress.com/2018/12/24/depnotify-to-dep-and-beyond/).

In the JNUC talk I kept things simple so the build screen looked like this;

![NoMAD Build Screen](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/build-screen.png)

## How to build this ##

For the DEP process a prestage package is required to be added to the prestage. This gets pulled down once the user accepts the remote management screen. So this package controls the screens shown before the Jamf post enrol policy starts.

### Package components ###

There are three items required in the DEP Package;


![DEP Package](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/DEP-package.png)

1. NoMAD Login: Some choose to modify the original packages to include everything required, I find it's easier and less problematical to use the standard package in a custom package.
2. The profile to configure NoMAD login: The setting for this are covered on Neil Martins [github](https://github.com/neilmartin83/MacADUK-2019). In this only one dropdown is configured, the profile will be shown later.
3. Graphics: a simple package containing two graphics, one used as the background and one for the logo displayed at the top.

There is a package post install script which starts the process off as well.
This has four required blocks;
1. Install the packages and the profile.

```bash
# perform Installs
/usr/bin/profiles -I -F "/var/tmp/menu.nomad.login.ad.mobileconfig"

installer -pkg "/var/tmp/jnuc-build-graphics.pkg" -target /

installer -pkg "/var/tmp/NoMAD-Login-AD.pkg" -target /
```
2. Set the initial NoMAD Login environment

```bash
# set initial notify values
log "running Authchanger"
/usr/local/bin/authchanger authchanger -reset -preLogin NoMADLoginAD:UserInput NoMADLoginAD:Notify

/bin/echo "Command: MainTitle: Setting things up…"  >> /var/tmp/depnotify.log
/bin/echo "Command: MainText: Starting the device build, progress screens will display shortly." >> /var/tmp/depnotify.log
/bin/echo "Command: Image: "/Library/Management/jigsaw24/logo.png"" >> /var/tmp/depnotify.log
/bin/echo "Status: Please wait..." >> /var/tmp/depnotify.log
```

3. Wait for Setup asistant to complete
```bash
# Wait for the setup assistant to complete before continuing

loggedInUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}     ')
while [[ "$loggedInUser" == "_mbsetupuser" ]]; do
	/bin/sleep 1
	loggedInUser=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}     ')
done
```

4. Kill login window to switch to NoMAD Login
```bash
# switch login window

killall loginwindow
```

#### The profile ####

The entire profile is embeded here;

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>PayloadContent</key>
<array>
	<dict>
	<key>PayloadContent</key>
		<dict>
		<key>menu.nomad.login.ad</key>
			<dict>
			<key>Forced</key>
			<array>
				<dict>
				<key>mcx_preference_settings</key>
					<dict>
					<key>NotifyLogStyle</key>
					<string>none</string>
					<key>BackgroundImage</key>
					<string>/Library/Management/jigsaw24/logo-back.png</string>
					<key>UserInputLogo</key>
					<string>/Library/Management/jigsaw24/logo.png</string>
					<key>UserInputMainText</key>
					<string>Please select this computers role. Default is Shared. Select SingleUser if a dedicated laptop. Click OK to continue.</string>
					<key>UserInputOutputPath</key>
					<string>/var/tmp/userinputoutput.plist</string>
					<key>UserInputTitle</key>
					<string>Let's get building ...</string>
					<key>UserInputUI</key>
						<dict>
						<key>Button</key>
							<dict>
							<key>enabled</key>
							<true/>
							<key>title</key>
							<string>OK</string>
							</dict>
							<key>PopUps</key>
							<array>
							<dict>
							<key>items</key>
							<array>
							<string>Shared</string>
							<string>Single User</string>
							</array>
							<key>title</key>
							<string>Computer Role</string>
							</dict>
							</array>
						</dict>
					</dict>
				</dict>
			</array>
		</dict>
	</dict>
	<key>PayloadDescription</key>
	<string>NoMad Login settings</string>
	<key>PayloadDisplayName</key>
	<string>Custom</string>
	<key>PayloadEnabled</key>
	<true/>
	<key>PayloadIdentifier</key>
	<string>36ECC941-FAC2-4271-916D-EC614FCDB784</string>
	<key>PayloadOrganization</key>
	<string>Jigsaw24</string>
	<key>PayloadType</key>
	<string>com.apple.ManagedClient.preferences</string>
	<key>PayloadUUID</key>
	<string>36ECC941-FAC2-4271-916D-EC614FCDB784</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
	</dict>
</array>
<key>PayloadDescription</key>
<string></string>
<key>PayloadDisplayName</key>
<string>Nomad Login - Defaults</string>
<key>PayloadEnabled</key>
<true/>
<key>PayloadIdentifier</key>
<string>FF808D2C-A258-46CB-928E-41E0D7347ED2</string>
<key>PayloadOrganization</key>
<string>Jigsaw24</string>
<key>PayloadRemovalDisallowed</key>
<false/>
<key>PayloadScope</key>
	<string>System</string>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>FF808D2C-A258-46CB-928E-41E0D7347ED2</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
```
As mentioned before Neil Martins [github](https://github.com/neilmartin83/MacADUK-2019) has good explainations of the settings so here I'll just explain the important ones used in this method.

##### Profile sections #####

1. The graphics used by the *User_Input* screen is controlled by these settings, background is common to both screens;
```xml
<key>BackgroundImage</key>
<string>/Library/Management/jigsaw24/logo-back.png</string>
<key>UserInputLogo</key>
<string>/Library/Management/jigsaw24/logo.png</string>
```

2. The location for the response file that gets created when the choice is made is controlled by this setting. This file is monitored by the build script as explained later;


```xml
<key>UserInputOutputPath</key>
<string>/var/tmp/userinputoutput.plist</string>
```
3. The text displayed on the *User_Input* screen and choices displayed for the dropdown are controlled by these settings;


```xml
<key>UserInputMainText</key>
<string>Please select this computers role. Default is Shared. Select SingleUser if a dedicated laptop. Click OK to continue.</string>
<key>UserInputTitle</key>
<string>Let's get building ...</string>
<key>UserInputUI</key>
<dict>
	<key>Button</key>
		<dict>
			<key>enabled</key>
			<true/>
			<key>title</key>
			<string>OK</string>
		</dict>
	<key>PopUps</key>
	<array>
		<dict>
		<key>items</key>
		<array>
			<string>Shared</string>
			<string>Single User</string>
		</array>
		<key>title</key>
		<string>Computer Role</string>
		</dict>
	</array>
</dict>
```




