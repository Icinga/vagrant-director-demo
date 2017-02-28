#!/bin/bash

set -e

OSTYPE="unknown"

if [ -x /usr/bin/lsb_release ]; then
  OSTYPE=$(lsb_release -i -s)
  CODENAME=$(lsb_release -sc)
elif [ -e /etc/redhat-release ]; then
  OSTYPE="RedHat"
else
  echo "Unsupported OS!" >&2
  exit 1
fi

if [ ! -e /var/initial_update ]; then
    echo "Running initial upgrade"
    if [ "$OSTYPE" = "Debian" ] || [ "$OSTYPE" = "Ubuntu" ]; then
        apt-get update
        apt-get dist-upgrade -y
        date > /var/initial_update
    elif [ "$OSTYPE" = "RedHat" ]; then
        yum update -y
        date > /var/initial_update
    fi
fi

if [ "$OSTYPE" = "Debian" ] || [ "$OSTYPE" = "Ubuntu" ]; then
    if [ ! -f /etc/apt/sources.list.d/puppetlabs-pc1.list ]; then
        echo "Installing Puppetlabs release package..."
        wget -O /tmp/puppetlabs.deb "https://apt.puppetlabs.com/puppetlabs-release-pc1-${CODENAME}.deb"
        dpkg -i /tmp/puppetlabs.deb
        rm -f /tmp/puppetlabs.deb
        apt-get update
    fi
elif [ "$OSTYPE" = "RedHat" ]; then
    if [ ! -e /etc/yum.repos.d/puppetlabs.repo ]; then
        echo "Installing Puppet release..."
        yum install -y http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    fi
fi

if [ "$OSTYPE" = "Debian" ]  || [ "$OSTYPE" = "Ubuntu" ]; then
    if ! dpkg -l puppet-agent >/dev/null; then
        echo "Installing puppet..."
        apt-get install -y puppet-agent
    fi
elif [ "$OSTYPE" = "RedHat" ]; then
    # TODO: test this
    if ! rpm -qa puppet-agent >/dev/null; then
        echo "Installing puppet..."
        yum install -y puppet-agent
    fi
fi

if [ "$OSTYPE" = "RedHat" ]; then
    if [ `getenforce` = 'Enforcing' ]; then
        echo "Setting selinux to permissive"
        setenforce 0
    fi

    if grep -qP "^SELINUX=enforcing" /etc/selinux/config; then
        echo "Disabling selinux after reboot"
        sed -i 's/^\\(SELINUX=\\)enforcing/\\1disabled/' /etc/selinux/config
    fi
fi
