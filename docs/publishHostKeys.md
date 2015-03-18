# Publishing Host SSH keys

This note outlines the process that SimpleMonkey follows when it 
publishes a host's ssh keys and then subsequently updates a client 
machine's system wide known_hosts file.

Note that SimpleMonkey's proccesses are distinctly different from that 
used by MonkeySphere. In particular SimpleMonkey MUST use the SimpleHKP 
key/identity server, as SimpleMonkey makes extensive use of the 
identity server.

There are a number of constaints on the processes used by SimpleMonkey:

* the 'publish host' and 'update hosts' commands MUST operate unattended.

* the *private* ssh keys MUST NOT leave the original host machine.

* all three commands SHOULD be able to be run multiple times without 
corrupting the overall process.

Given these constraints, there are essentially three steps, each 
(semi-)automated by a corresponding SimpleMonkey command.

1. **smonkey publish host** extracts the *public* ssh keys (DSA, RSA 
and ECDSA) as found on the host upon which the command is run.  These 
public keys are combined as text files, encrypted using the 
SystemAdmin's *public* key. The resulting ascii armored encrypted file 
is prepended with a Jekyll-like YAML header and uploaded as an 
*identity* to the configured SimpleHKP identity server. The YAML header 
contains

  * the machine's host name
  * the machine's ipaddress
  * the finger prints of all of the public keys (DSA, RSA, and ECDSA).
  * the date on which the keys were created
  * the status of the identity (published or confirmed)

1. **smonkey confirm host <host name>** downloads the identity created 
by the 'publish host' command, decrypts the various keys, asks the 
SystemAdmin to confirm the key fingerprints and then re-encrypts the 
various keys with the SystemAdmin's *private* key. For this operation, 
the SystemAdmin MUST be present and provide the required confirmation 
and passphrases for their keys. The resulting re-encrypted ascii 
armored files have essentially the same YAML header prepended (with the 
status of the identity changed to confirmed) and then is uploaded as an 
*identity* to the configured SimpleHKP identity server. This action 
will *replace* the previous identity on the identity server.

1. **smonkey update hosts** dowloads the identities of all machine 
identities stored on the configured SimpleHKP identity server, decrypts 
them using the configured SystemAdmin's public key and then uses them 
to build the system known_hosts file (usually, 
/etc/ssh/ssh_known_hosts). 

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

* the SimpleMonkey configuration MUST contain the SysetmAdmin's FULL 
GnuPG fingerprint to be used to identify the SystemAdmin's public keys.

* the OpenSSH client configuration on ALL machines should have the 
'StrictHostKeyChecking' option set to yes for ALL machines in the 
system's domain.

## Future work

At the moment, this process does not really leaverage the GnuPG 
web-of-trust in any essential way. To do that we would need to have 
each machine create its own GnuPG identity (private keys) but at the 
moment this is impossible since the 'publish host' command MUST be run 
unattended in a configuration script.

What we need is to be able to use gpg-agent in 'forwarding' mode to 
allow the SystemAdmin's gng-agent to provide any passphrases required. 
However true gng-agent forwarding can not be configured until at least 
VividVervet is released in April 2015 (we need OpenSSH 6.7's ability to 
forward Unix sockets).

Until then we could use socat to forward a unix socket by mascarading 
the unix socket as a TCP socket and then forwarding the TCP socket. The 
problems with this is that TCP sockets have far fewer controls over who 
is allowed to connect to them relative to Unix sockets, providing 
significant security risks.

For ideas on how to forward gng-agents see:

http://unix.stackexchange.com/questions/186294/how-do-i-combine-ssh-agent-forwarding-and-gpg-agent

http://www.jwiltshire.org.uk/content/2010/12/19/the-perfect-gpg-agent-setup/

http://www.gossamer-threads.com/lists/gnupg/users/68713

http://superuser.com/questions/161973/how-can-i-forward-a-gpg-key-via-ssh-agent

http://www.snafu.priv.at/interests/crypto/remotegpg.html

