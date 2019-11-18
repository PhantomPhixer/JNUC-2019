# Rinse and Repeat #

So far a framework to build and bring into Jamf has been created but who wants to keep manually wiping devices to reprovision them?

## How can reprovisioning be automated ##

The reprovisioning process can be automated to deploy the correct, DEP or Non DEP, workflow from Jamf.
A few extra components are required for this which are detailed here.

### Erase-Install Script ###

this process uses [Graham Pugh's Erase-install script](https://github.com/grahampugh/erase-install). This is used to download and maintain a local copy of the macOS installer and to wipe the device to reprovision it when required.

As mentioned in [Non DEP Start](https://github.com/PhantomPhixer/JNUC-2019/blob/master/NonDEP.md) the same options can be used with this script meaning the DEP and Non DEP process can be also driven entirely from Jamf with a few additional components.

How this is used is explained later.

### Extension Attributes ###

Two new EAs are required.

#### Installer valid ####
The first is an **Installer Valid** EA. This is based upon a part of the *install-erase* script and is used to determine whether the installer is required to be downloaded. This is decided by whether the installer is;
1. Downloaded or not.
2. A valid version - Greater or equal to the installed OS version.

The EA is [available here](../master/files/installer-valid-ea.txt). In Jamf create an Ea of *String* and type as *script*

#### DEP Capable ####

The second determines whether the devoce is capable of using DEP. This is critical to scoping in the process.
This is a simple EA using the *profiles* command;

```bash
#!/bin/bash

# set default answer to "no". only want to set to "yes" if it's true
result="no"

# use profiles to see if the device is in Apple. if it is 1 is returned, if not 0
configURL=$(profiles show -type enrollment | grep ConfigurationURL | grep -c http)

if [ "$configURL" = "1" ]; then
result="yes"
fi

echo "<result>$result</result>"
```

and is [available here](../master/files/DEP-capable-ea.txt)

### A Package ###

A package is required for the workflow. This is a single package containing the two packages used in [Non DEP workflow](https://github.com/PhantomPhixer/JNUC-2019/blob/master/NonDEP.md). A single package is made to deploy them only. They do *NOT* get installed untill the device wipe is initiated.

![Package layout](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/Non-DEP-Deploy.png)

The path used to deploy the packages to is the default path the *erase-install* script uses, this can be modified if required. 

### Smart Groups ###

This process requires four *smart groups* to control the policies.

#### Installer Download required ####

The first smart group controls if the installer download is required, this is based upon the *installer-valid EA* above.
 
![Download Required SG](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/installer-download-required.png)

In the example macOS of *10.13.4* is used to scope out non *--eraseinstall* capable devices, if there are non *APFS* devices with *10.13.4* then scope these out as well.





