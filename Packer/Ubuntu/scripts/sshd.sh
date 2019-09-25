#!/bin/bash -eux
# Set strict sshd configuration (defaults only to ansible user)
tee /etc/ssh/sshd_config > /dev/null <<'EOF'
# This is based on Mozilla recommended "Strong" SSH config
# https://infosec.mozilla.org/guidelines/openssh

# What ports, IPs and protocols to listen on
Port 22
Protocol 2
AddressFamily inet
UseDNS no

### KEYS & PROTOCOLS ###
# Supported HostKey algorithms for v2 by order of preference.
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key

KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256

Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

# Lifetime and size of ephemeral version 1 server key
KeyRegenerationInterval 3600
ServerKeyBits 2048

# Change to no to disable tunnelled clear text passwords
PasswordAuthentication yes

### AUTHENTICATION: ###
# 30 seconds to log in, 3 tries max
LoginGraceTime 30
StrictModes yes
MaxAuthTries 3

# close the obvious unused auth methods
RSAAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
# Allow PubKey Auth
PubkeyAuthentication yes

# Don't read the user's ~/.rhosts and ~/.shosts files
IgnoreRhosts yes
# For this to work you will also need host keys in /etc/ssh_known_hosts
RhostsRSAAuthentication no
# similar for protocol version 2
HostbasedAuthentication no

# Password based logins are disabled - only public key based logins are allowed.
#AuthenticationMethods publickey

# This disables Challenge-Response for password-based auth
ChallengeResponseAuthentication no

### USER LOCKDOWN + KEY SECURITY:
# LogLevel VERBOSE logs user's key fingerprint on login. Needed to have a clear audit track of which key was using to log in.
LogLevel VERBOSE
PermitEmptyPasswords no
PermitUserEnvironment no
AllowUsers ansible

# Log sftp level file access (read/write/etc.) that would not be easily logged otherwise.
# (SFTP subsystem is disabled currently)
#Subsystem sftp  /usr/lib/ssh/sftp-server -f AUTHPRIV -l INFO

# Root login is not allowed for auditing reasons. This is because it's difficult to track which process belongs to which root user
# Using regular users in combination with /bin/su or /usr/bin/sudo ensure a clear audit track.
PermitRootLogin No

# Use kernel sandbox mechanisms where possible in unprivileged processes
# Systrace on OpenBSD, Seccomp on Linux, seatbelt on MacOSX/Darwin, rlimit elsewhere.
UsePrivilegeSeparation yes

# Disable X11 forwarding & MOTD
X11Forwarding no
PrintMotd yes

PrintLastLog no
TCPKeepAlive yes

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*
EOF

awk '$5 >= 3071' /etc/ssh/moduli | tee /etc/ssh/moduli.tmp > /dev/null
mv /etc/ssh/moduli.tmp /etc/ssh/moduli