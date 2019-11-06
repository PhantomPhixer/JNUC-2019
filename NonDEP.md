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


