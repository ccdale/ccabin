#!/bin/bash
[[ -f Vagrantfile ]] && echo "Vagrantfile exists, not overwriting" && exit 1

cat - <<EOMSG
This script will setup a nodejs development vagrant environment in this directory.

It will download the latest version of the ubuntu 18.04 box (if you don't already have it)

It then creates a virtualbox vagrant machine and installs
curl
git
vim-pathogen
vim-fugitive
nodejs
npm

from the ubuntu repositories.

It will then use npm to install the nodejs virtual env. application 'n'

Using n it will update nodejs to the current stable version

Press any key to continue or CTRL-C to cancel.
EOMSG

read junk


cat - <<'EOCAT' >bootstrap.sh
#!/bin/bash
apt-get update
apt-get -y upgrade
apt-get install -y nodejs npm curl git vim-pathogen vim-fugitive
npm cache clean -f
# install n (a bit venv and pip like)
npm install -g n
# install the latest stable version of nodejs
n stable
EOCAT
chmod +x bootstrap.sh
vagrant init bento/ubuntu-18.04 --box-version 201806.08.0
sed -i '$i\
  config.vm.provision :shell, :path => "bootstrap.sh"' Vagrantfile
vagrant up
