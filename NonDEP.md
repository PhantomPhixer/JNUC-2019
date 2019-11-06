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



