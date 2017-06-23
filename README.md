Vagrant Icinga Director Demo
============================

This is a test and demo environment for the [Icinga Director](https://github.com/Icinga/icingaweb2-module-director).

## Prepare

Clone this repository:

    git clone https://github.com/Icinga/vagrant-director-demo.git
    cd vagrant-director-demo

Install required ruby tools:

    bundle install --path vendor/bundle

    # or, if you have a Ruby dev environment
    bundle install

And checkout the Puppet modules: (via r10k)

    bundle exec rake deploy

## Recommended plugin

You might need the Vagrant plugin `vagrant-vbguest` to install / update the Virtualbox tools on the VMs.

This will help install the Virtualbox guest tools before the first provision run and update them after a kernel update.

    vagrant plugin install vagrant-vbguest

## Start Vagrant Boxes

Start all Vagrant boxes:

    vagrant up

Apply changes in Puppet or hiera data:

    vagrant provision

## Demo Data

You can find an example for YAML import data in the `demo-data/` directory.

    cp /vagrant/demo-data/test.yaml /opt/import/

It also includes a database dump with additional Director sample data.

    mysql director < /vagrant/demo-data/director-with-data.sql

## License

    Copyright (C) 2017 Markus Frosch <markus.frosch@icinga.com>
                  2017 Icinga Development Team <info@icinga.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
