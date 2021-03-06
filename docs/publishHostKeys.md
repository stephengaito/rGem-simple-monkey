# Publishing Host SSH keys

This note outlines the process that SimpleMonkey follows when it 
publishes a host's ssh keys and then subsequently updates a client 
machine's system wide known_hosts file.

Note that SimpleMonkey's proccesses are distinctly different from that 
used by MonkeySphere. In particular SimpleMonkey MUST use the SimpleHKP 
key/identity server, as SimpleMonkey makes extensive use of both the 
key *and* *identity* server.

There are a number of constaints on the processes used by SimpleMonkey:

* the 'publish host' and 'update hosts' commands MUST operate unattended.

* the *private* ssh keys MUST NOT leave the original host machine.

* multiple SystemAdmins SHOULD be able to administer a collection of 
servers.

* all three commands SHOULD be able to be run multiple times without 
corrupting the overall process.

Given these constraints, there are essentially three steps, each 
(semi-)automated by a corresponding SimpleMonkey command.

1. **smonkey publish host** extracts the *public* ssh keys (DSA, RSA 
and ECDSA) as found on the host upon which the command is run.  These 
public keys are combined as text files, encrypted using each of the 
configured SystemAdmin's *public* keys. The resulting ascii armored 
encrypted files are combined in the order of the respective SystemAdmin 
fingerpprints are listed in the YAML header (see below). The resulting 
file is prepended with a Jekyll-like YAML header and uploaded as an 
*identity* to the configured SimpleHKP identity server. The YAML header 
contains

  * the machine's host name
  * the machine's ipaddress
  * the finger prints of all of the public keys (DSA, RSA, and ECDSA).
  * the date on which the keys were created
  * the status of the identity (published or confirmed)
  * the ordered list of fingerprints of each of the SystemAdmins who's 
    public keys have been used to encrypt this set of keys.

1. **smonkey confirm host <host name>** downloads the identity created 
by the 'publish host' command, decrypts the various keys, asks the 
SystemAdmin to confirm the key fingerprints and then re-encrypts the 
various keys with the SystemAdmin's *private* key. For this operation, 
one of the appropriate SystemAdmins MUST be present and provide the 
required confirmation and passphrases for their keys. The resulting 
re-encrypted ascii armored files have essentially the same YAML header 
prepended (with the status of the identity changed to confirmed and 
ONLY the signing SystemAdmin's fingerprint listed) and then is uploaded 
as an *identity* to the configured SimpleHKP identity server. This 
action will *replace* the previous identity on the identity server.

1. **smonkey update hosts** dowloads the identities of all machine 
identities stored on the configured SimpleHKP identity server, decrypts 
them using the encrypting SystemAdmin's public key (as specified in the 
YAML header) and then uses them to build the system known_hosts file 
(usually, /etc/ssh/ssh_known_hosts). Note that this identity is only 
decrypted if the encrypting SystemAdmin is trusted by at least one of 
this machine's configured SystemAdmins

## Security concerns:

* the 'publish host' and 'update hosts' commands MUST be run by root 
since they are reading/writing files which must only be done by root. 
The publish host command can be run by configuration scripts. The 
update hosts command is usually run as a cron command.

* the SystemAdmin's GnuPG keyring MUST be secured to prevent 
Person-In-The-Middle attacks perpetrated by an entity which hijacks the 
SystemAdmin's identity.

* the SimpleMonkey configuration files on all machines (located in 
/etc/simpleMonkey) MUST be write ONLY by root.

* the SimpleMonkey configuration MUST contain each SysetmAdmin's FULL 
GnuPG fingerprint to be used to identify the SystemAdmin's public keys.

* the OpenSSH client configuration on ALL machines should have the 
'StrictHostKeyChecking' option set to yes for ALL machines in the 
system's domain.

