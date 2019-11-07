
# The common build #

The build for both workflows is the same, which simplifies things greatly. Using the value set on the UserInput screen allows extension attributes to be set that can be used to scope policies and profiles by smart group as required.


## Jamf Build Policy ##
All that is required for the build is one Jamf policy, this assumes that all the other policies required are run from custom event triggers.
That policy runs a script that does the work and calls the *install policies*.

### Install policies ###
In any JSS I setup all install policies are setup this way as per this example for Jamf Connect;

![Install Policy](https://github.com/PhantomPhixer/JNUC-2019/blob/master/images/policy-1.png)

This has the advantage that any other workflow can call the install policy and there is only ever one policy to update for new versions.

The policy itself has to be scoped to **all computers**, any actual scoping should be done on the calling policy.



