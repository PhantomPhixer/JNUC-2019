# UAMDM #

When a device is enrolled into Jamf using a QuickAdd package it needs the MDM profile approving. This is necessary to allow full MDM functionality such as KEXT and PPPC profile delivery.

![Approve MDM](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/UAMDM-1.png)

Apple do not allow any way of automating the approval process so it has to be an actual logged in user that approves it. There is no way to force a user to do this however you can prompt them until they do, and this is the process used here.

*As the profile only has to be approved by **A** user, not **every** user a system admin account can be used to approve on behalf of every other user...*
