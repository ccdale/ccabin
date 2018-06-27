# HowTo: Vagrant Box based Development Environment
Use the [vagrant-npm-setup.sh](vagrant-npm-setup.sh) script in this
[repo](https://github.com/ccdale/ccabin) as a template.

The script creates a VM and installs any software you'll need in your base box,
the npm script installs:
```
curl
git
nodejs
npm
n
```
It also installs **MY** vim environment for the `vagrant` user.

This script will setup a nodejs development vagrant environment in this
directory.  It is a distilled and scripted version of [Marcuss Hammarberg's
blog
post](http://www.marcusoft.net/2014/03/setting-up-complete-node-development.html)

It will download the latest version of the [ubuntu 18.04
box](https://app.vagrantup.com/bento/boxes/ubuntu-18.04) (if you don't already
have it)

`apt update` and `apt upgrade` are also run to ensure ubuntu is up to date and
secure.

The VM disk is then zeroed to make it easy for the packaging tool to compress.
(doing this saved me 200MB on my npm box).

Vagrant will then export your VM as a base box naming it `${boxname}-dev`
(you can give the box name on the script command line).

Vagrant then re-initialises this directory, and runs your new base box.

## Notes
* This needs to be run on a machine with no other **running** VMs.
* The directory this is run from cannot already have a Vagrantfile in it.
