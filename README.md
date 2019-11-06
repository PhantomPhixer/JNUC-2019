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

When it's in action it can look like this,

![NoMAD User_Input](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/nomad-choice.png)

This screen can be configured with many input choices dependant upon requirements, for this only one; a drop down, is required. How this is achieved is explained later.

