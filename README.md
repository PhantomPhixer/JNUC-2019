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

## Pages ##
[DEP Build](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/DEP.md)



