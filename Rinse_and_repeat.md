# Rinse and Repeat #

So far a framework to build and bring into Jamf has been created but who wants to keep manually wiping devices to reprovision them?

## How can reprovisioning be automated ##

The reprovisioning process can be automated to deploy the correct, DEP or Non DEP, workflow from Jamf.
A few extra components are required for this which are detailed here.

### Erase-Install Script ###

this process uses [Graham Pugh's Erase-install script](https://github.com/grahampugh/erase-install). This is used to download and maintain a local copy of the macOS installer and to wipe the device to reprovision it when required.

As mentioned in [Non DEP Start](https://github.com/PhantomPhixer/JNUC-2019/blob/master/NonDEP.md) the same options can be used with this script meaning the DEP and Non DEP process can be also driven entirely from Jamf with a few additional components.

### Extension Attributes ###

Two new EAs are required.
The first is an **Installer Valid** EA. This is based upon a part of the *install-erase* script and is used to determine whether the installer is required to be downloaded. This is decided by whether the installer is;
1. Downloaded or not
2. A valid version - Greater or equal to the installed OS version.



