#!/usr/bin/env bash
set -e

# Generate SSH host keys on first boot
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -A
fi

# /home/dev is often a bind mount (Unraid appdata) owned by root; make sure
# the dev user can write there. No -R: nested mounts must keep their owners.
mkdir -p /home/dev/.ssh
chown dev:dev /home/dev /home/dev/.ssh 2>/dev/null || true

# Authorized keys are normally bind-mounted read-only from ./ssh/authorized_keys.
# If absent, create an empty file so sshd starts and the log makes the problem obvious.
if [ ! -f /home/dev/.ssh/authorized_keys ]; then
  touch /home/dev/.ssh/authorized_keys || true
  chown dev:dev /home/dev/.ssh/authorized_keys 2>/dev/null || true
  chmod 600 /home/dev/.ssh/authorized_keys 2>/dev/null || true
fi

exec "$@"