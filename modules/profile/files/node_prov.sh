#!/usr/bin/env bash

release=$(awk -F "=" '/DISTRIB_CODENAME=/ {print $2}' /etc/lsb-release)

apt-get update && apt-get install git vim wget curl -y
wget https://apt.puppetlabs.com/puppetlabs-release-${release}.deb -O /tmp/puppetlabs-release-${release}.deb
dpkg -i /tmp/puppetlabs-release-${release}.deb
apt-get update
apt-get install puppet -y
