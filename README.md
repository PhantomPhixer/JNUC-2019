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







