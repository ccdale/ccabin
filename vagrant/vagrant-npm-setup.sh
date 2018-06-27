#!/bin/bash
[[ -f Vagrantfile ]] && echo "Vagrantfile exists, not overwriting" && exit 1
rvm=$(VBoxManage list runningvms)
if [ "X" != "X${rvm}" ]; then
    echo "There are other running VMs. Cannot continue while they are running, sorry."
    exit 1
fi

boxname=${1:-npm}

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

location=$(dirname $0)
cp "${location}/vim.tgz" ./

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
echo "zeroing disk"
dd if=/dev/zero of=BLANKFILE bs=1M
rm BLANKFILE
EOCAT
chmod +x bootstrap.sh
vagrant init bento/ubuntu-18.04
cat - <<'EOCAT2' >Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.ssh.insert_key = false
  config.vm.provision :shell, :path => "bootstrap.sh"
end
EOCAT2
vagrant up
vagrant ssh tar xvzf /vagrant/vim.tgz
rvm=$(VBoxManage list runningvms|cut -d'"' -f 2)
vagrant package --base $rvm
vagrant box add --name ${boxname}-dev --provider virtualbox --force package.box
rm *
vagrant init ${boxname}-dev
vagrant up
