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

#### Extras Package Required ####

The second smart group controls whether the extras package is required on the device because it is a Non DEP machine.

![Extras Required SG](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/extras-required.png)

It uses the state of the *installer valid* and the *DEP Capable EA* to determine whether it is required.

#### Erase Ready ####

There are two *Erase Ready* groups required. 

One for the **DEP** devices;

![Erase Ready DEP SG](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/DEP-erase-ready.png)

One for the **Non DEP** devices;

![Erase Ready Non DEP SG](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/NON-DEP-Erase-Ready.png)

These are used to scope the *Erase* policy when all pre-requisite items are in place.


#### Non DEP to DEP ####

This process allows for *Non DEP* devices to be moved into *DEP* This can happen when taking over a fleet that has been purchased from many sources and arranging with the vendors to add those devices into DEP when they hadn't been originally.

If this is happens the deploying the *extras package* will end up with the non DEP workflow being deployed to DEP devices. To prevent this a final smart group is required;

![Non DEP to DEP SG](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/non-dep-to-dep.png)

This looks for devices that have the *Extras package* downloaded but are *DEP capable*.

### Policies required ###

Now the smart groups are ready the policies can be built to deploy the mechanism.

#### Installer Download Required ####

Irrespective of the workflow only one macOS installer download policy is required.

This is scoped to the *Download required* group. It runs the *erase-install* script and can be OS version locked if required.

![Download required](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/installer-download-required.png)

Because of the way the EA and smart group are set up this policy will always ensure a valid installer is downloaded to the device. 

#### Deploy Extras Package ####

The extras package is deployed to members of the *extras package required* smart group, i.e. the Non DEP capable devices.

![Extras required](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/deploy-extras-policy.png)

#### Remove Extras Package ####

The *remove Extras policy* is used to remove the *Extras package* if a device moves from *Non DEP* to *DEP*.

![Extras remove](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/remove-extras-policy.png)

It runs a simple script to delete the package and the Jamf receipt;

```bash
#!/bin/bash/

# removes the extras files required for non dep builds if a device becomes dep ready

rm -Rf /Library/Management/erase-install/extras

rm -f "/Library/Application Support/JAMF/Receipts/jnuc_erase_install_extras.pkg"
```
Then runs an inventory to update all the groups.






