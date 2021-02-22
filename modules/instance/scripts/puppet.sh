#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y language-pack-en
sudo apt-get -y install puppet-master puppet-module-puppetlabs-stdlib
sudo puppet config set --section master autosign true
sudo systemctl restart puppet-master
sudo chown ${username}:${username} /etc/puppet/code

echo "--> Setting hostname..."
echo "${hostname}" | sudo tee /etc/hostname
sudo hostname -F /etc/hostname


echo "--> Adding hostname to /etc/hosts"
sudo tee -a /etc/hosts > /dev/null <<EOF

# For local resolution
$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)  ${hostname}
EOF

echo "--> Create new user, edit ssh settings"

 
sudo useradd ${username} \
   --shell /bin/bash \
   --create-home 
echo '${username}:${ssh_pass}' | sudo chpasswd
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo service sshd reload


echo "Adding ${username} user to sudoers"
sudo tee /etc/sudoers.d/${username} > /dev/null <<"EOF"
${username} ALL=(ALL:ALL) ALL
EOF
sudo chmod 0440 /etc/sudoers.d/${username}
sudo usermod -a -G sudo ${username}
#DOCKER
curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -a -G docker ${username}
sudo systemctl enable docker
# Run Wetty

docker run --rm -p 80:3000 --detach wettyoss/wetty --ssh-host=172.17.0.1 --ssh-user ${username}

sudo mkdir /home/${username}/workdir
sudo chown -R ${username} /home/${username}/workdir
cd /home/${username}/workdir
sudo git clone ${gitrepo}

sudo mv workdir/mtls-emojivoto-tf/conf/puppet/code/environments/*  /home/${username}/etc/puppet/code
