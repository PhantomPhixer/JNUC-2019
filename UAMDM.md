# UAMDM #

When a device is enrolled into Jamf using a QuickAdd package it needs the MDM profile approving. This is necessary to allow full MDM functionality such as KEXT and PPPC profile delivery.

![Approve MDM](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/UAMDM-1.png)

Apple do not allow any way of automating the approval process so it has to be an actual logged in user that approves it. There is no way to force a user to do this however you can prompt them until they do, and this is the process used here.

*As the profile only has to be approved by **A** user, not **every** user, a system admin account can be used to approve on behalf of every other user...*

## How to Prompt A User ##


### Smart Group ###

To prompt a user first we need to target the relevant devices. Jamf has a built in attribute **User approved MDM** which is set to *yes* when approved.

Use this in a *smart group* to scope the policy, shown later.

In my example the *smart group* is locked down to those devices managed by the specific user set in the QuickAdd package, but this isn't strictly necessary.

![UAMDM SG](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/UAMDM-2.png)

### Policy ###

Only one policy is required. This policy is set to run at *login* and *checkin* and scoped to the smart group above. This ensures it will continue to prompt as long as the MDM profile is not approved.
The policy updates inventory every run to ensure the device drops out of scope if approval completed.

![UAMDM Policy](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/UAMDM-3.png)

The policy calls a simple script this example which checks the UAMDM status before doing anything;

The first part of the script checks the UAMDM status;

```bash
isMDMEnrolled=$(profiles status -type enrollment | grep "MDM" | awk -F":" '{ print $2}' | sed 's/ //' | grep -o Yes)

isMDMUserApproved=$(profiles status -type enrollment | grep "MDM" | awk -F":" '{ print $2}' | sed 's/ //' | grep -o "User Approved")

if [ "$isMDMEnrolled" = "Yes" ]; then
MDMStatus="enrolled"
	if [ "$isMDMUserApproved" = "User Approved" ]; then
	MDMStatus="approved"
	fi
else
	MDMStatus="none"
fi
```

The variable *`$MDMStatus`* is used in a case statement to check if action is required or not;

```bash
case $MDMStatus in
"approved" )
secho "Finished **********"
exit 0
;;
"enrolled" )
notifyUserToApprove
exit 0
;;
esac
```

This prevents prompting the user if they have approved the MDM profile but Jamf doesn't have the information in inventory. The policy would then update invemtory and move the device out of scope.

If the MDM profile does need approving there are many options to tell them, in this example *Self Service* is opened because this will give the user a nice pictorial guide.

![Self Service](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/UAMDM-4.png)


