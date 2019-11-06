# Non DEP builds #

## Background ##

The overall aim of this workflow is to have a near indentical experience building DEP and Non DEP devices.
Lot's of organisations have devices that can't be DEP built for many reasons.
The overall end aim of this workflow is to get all devices managed in Jamf and then to automatically be able to wipe and reprovision the device.
The only major difference between the two workflows, DEP and Non DEP, is the requirement for a user to approve the MDM profile in the Non DEP build devices, which can't be avoided.


## Experience ##
The overall experience will be the same NoMAD Login choice and notify experience as used in the DEP build out lined [here](https://github.com/PhantomPhixer/JNUC-2019/blob/master/DEP.md).

## Packages ##

The packages used in this workflow will be explained here, how to use them will be explained later.

### Package components ###

There are five items required in the Non DEP Package;


![NonDEP Package](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/nondep-package.png)

1. NoMAD Login: Some choose to modify the original packages to include everything required, I find it's easier and less problematical to use the standard package in a custom package.
2. The profile to configure NoMAD login: The setting for this are covered on Neil Martins [github](https://github.com/neilmartin83/MacADUK-2019). In this only one dropdown is configured, the profile will be shown later.
3. QuickAdd: Create a QuickAdd with Jamf recon, used to enroll the device during the build.
4. The controlling script; explained later.
5. LaunchDaemon: used to start the script running.

There is also a simple **post install script** to load the LaunchDaemon;
```bash
launchctl load /Library/LaunchDaemons/com.jigsaw24.build_check.plist
```

