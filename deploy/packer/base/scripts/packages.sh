#! /bin/bash

set -e -x

lsb_release -a

# add docker group and add current user to it
sudo groupadd docker
sudo usermod -a -G docker $USER

# For reasons that aren't at all clear, packer, or cloud-init, or very
# predictable cosmic rays obliterate sources.list for paravirtualized AMIs.  So
# we put it back.
cat <<'EOF' | sudo tee /etc/apt/sources.list >&2
## Note, this file is written by cloud-init on first boot of an instance
## modifications made here will not survive a re-bundle.
## if you wish to make changes you can:
## a.) add 'apt_preserve_sources_list: true' to /etc/cloud/cloud.cfg
##     or do the same in user-data
## b.) add sources in /etc/apt/sources.list.d
## c.) make changes to template file /etc/cloud/templates/sources.list.tmpl
#

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty main restricted
deb-src http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates main restricted
deb-src http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty universe
deb-src http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty universe
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates universe
deb-src http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty multiverse
deb-src http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty multiverse
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates multiverse
deb-src http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-updates multiverse

## Uncomment the following two lines to add software from the 'backports'
## repository.
## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://us-west-2.ec2.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu trusty partner
# deb-src http://archive.canonical.com/ubuntu trusty partner

deb http://security.ubuntu.com/ubuntu trusty-security main
deb-src http://security.ubuntu.com/ubuntu trusty-security main
deb http://security.ubuntu.com/ubuntu trusty-security universe
deb-src http://security.ubuntu.com/ubuntu trusty-security universe
# deb http://security.ubuntu.com/ubuntu trusty-security multiverse
# deb-src http://security.ubuntu.com/ubuntu trusty-security multiverse
EOF
sudo apt-get update -y

[ -e /usr/lib/apt/methods/https ] || {
  apt-get install apt-transport-https
}

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo sh -c "echo deb https://get.docker.io/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"

## Update to pick up new registries
sudo apt-get update -y

## Install all the packages
sudo apt-get install -y lxc-docker-1.6.1 btrfs-tools lvm2 curl build-essential \
  linux-image-extra-`uname -r` git-core pbuilder python-mock python-configobj \
  python-support cdbs python-pip jq rsyslog-gnutls openvpn v4l2loopback-utils lxc

## Clear mounts created in base image so fstab is empty in other builds...
sudo sh -c 'echo "" > /etc/fstab'
