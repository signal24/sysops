#!/bin/bash -e

# based on https://gist.github.com/icedream/75135f63f433ec52d652c7245dd17e30

secontainer() {
  podman run --privileged --rm \
    -v /var/run:/var/run \
    -v /etc/selinux:/etc/selinux \
    -v /proc:/proc \
    -v /sys:/sys \
    signal24/fedora-semanage "$@"
}

# Delete any old custom SSH port rules
secontainer semanage port -D -t ssh_port_t -p tcp || true

# Read SSH port straight from the sshd_config, default to 22.
ssh_port="$(grep -Po '^\s*Port\s+\K\d+' /etc/ssh/sshd_config || printf '%s' 22)"
secontainer semanage port -a -t ssh_port_t -p tcp "$ssh_port"

# workaround from https://github.com/coreos/fedora-coreos-tracker/issues/701 to keep selinux policy files in base config state
rsync -rcl /usr/etc/selinux/ /etc/selinux/
