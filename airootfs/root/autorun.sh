#!/bin/bash

# wait for the network to come up
while true
do
  ping -c1 github.com &> /dev/null && break
done

# copy the ssh key used to authenticate to the repo
#cp -r ./rootfs-private/home/chendry/.ssh .
#chmod 600 .ssh/*

# clone the repository
git clone https://github.com/andreycsc/Arch_install.git

# run each installation script in sequence, logging the results
mkdir logs
cd Arch_install/install-scripts

export USER_NAME="andrey"
export USER_PASSWORD="user"
export ROOT_PASSWORD="root"

for i in *.sh
do
  echo $i
  bash -x $i &>> ~/logs/${i%.sh}.out
done