#!/bin/bash
#
#     Purpose: To configure the "admin host" (aka thekubernerd) once the OS is installed and host is on the network
#        Date: 2024-05-16
#      Status: GTG | Complete/Done
# Assumptions: It is assumed this is being run on a "newly deployed Ubuntu Host".  I did not necessarilly create it to 
#                be idempotent.
#        Todo: 

manual_beginning_steps() {
# Update system and install/enable SSH Server
sudo apt -y update
sudo apt -y upgrade
sudo systemctl --no-pager status sshd || { sudo apt install -y openssh-server; sudo systemctl enable ssh --now; }
# Add correct search domain
sudo resolvectl domain eno1 kubernerdes.lab
sudo shutdown now -r
}

# Set some VARS
NEEDSRESTART=0

# Allow sudo NOPASSWD and add user to www-data group
SUDO_USER=mansible
echo "NOTE:  you are going to be asked the login password for $SUDO_USER to (permanently) enable nopasswd sudo "
echo "       This should be the ONLY time you are asked for a password"
echo "$SUDO_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee  /etc/sudoers.d/$SUDO_USER-nopasswd-all
sudo usermod -a -G www-data mansible

# Install some general "system tools"
PKGS="etherwake net-tools curl git"
OPT_PKGS="nmap"
sudo apt -y install $PKGS $OPT_PKGS

# Install Brew (used later to install software, like k9s)
mkdir ~/homebrew
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
~/homebrew/bin/brew

# Setup User Environment
# Update login environment
[ ! -d ${HOME}/.bashrc.d ] && { mkdir ${HOME}/.bashrc.d; }
# Enable $HOME/.bashrc.d/* functionality
cat << EOF >> ~/.bashrc

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
        for rc in ~/.bashrc.d/*; do
                if [ -f "\$rc" ]; then
                        . "\$rc"
                fi
        done
fi
EOF

#  Update my shell environment (optional)
curl https://raw.githubusercontent.com/GIT_OWNER/devops/main/Files/.bashrc.d_common | tee ~/.bashrc.d/common
curl https://raw.githubusercontent.com/GIT_OWNER/devops/main/Files/.bashrc.d_Ubuntu | tee ~/.bashrc.d/Ubuntu
curl https://raw.githubusercontent.com/GIT_OWNER/devops/main/Files/.bashrc.d_K8s | tee ~/.bashrc.d/K8s
. ~/.bashrc

# Enable Firewall (if you use Ubuntu firewall)
sudo ufw status
enable_firewall() {
sudo ufw allow ssh
sudo ufw allow http 
sudo ufw allow tftp 
sudo ufw allow bootps
sudo ufw allow 53/udp
sudo ufw allow 53/tcp

sudo ufw enable
sudo ufw status
sudo ufw show added
}

# Unload problematic kernel module at reboot via cron (this is specific to my NUCs)
sudo su - -c '
CRON_UPDATE="@reboot modprobe -r tps6598x"
(crontab -l; echo "$CRON_UPDATE") | crontab -
modprobe -r tps6598x '

# Update SSH Keys and Config
[ ! -f ~/.ssh/id_ecdsa ] && { echo | ssh-keygen -C "Default Host SSH Key" -f ~/.ssh/id_ecdsa -tecdsa -b521 -N ''; } 
[ ! -f ~/.ssh/id_ecdsa-kubernerdes.lab ] && { echo | ssh-keygen -C "Lab Host SSH Key" -f ~/.ssh/id_ecdsa-kubernerdes.lab -tecdsa -b521 -N ''; } 
cat << EOF > ~/.ssh/config 
Host 10.10.12.* *.kubernerdes.lab
  User mansible
  UserKnownHostsFile ~/.ssh/known_hosts.kubernerdes.lab
  IdentityFile ~/.ssh/id_ecdsa-kubernerdes.lab
EOF
chmod 0600 ~/.ssh/config

## Install Helm
which helm || {
sudo snap install  helm --classic
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
}

# Install Desktop GUI (in case you opt to use Ubuntu Server for your Admin Host)
install_desktop() {
  sudo apt install -y ubuntu-desktop
  NEEDSRESTART=$((NEEDSRESTART + 1))
}

# Create directories to clone this project repo to (for pull-only access - and this optional)
mkdir -p $HOME/Repositories/Personal/GIT_OWNER/; cd $_
git clone https://github.com/GIT_OWNER/kubernerdes.lab.git
ln -s $HOME/Repositories/Personal/GIT_OWNER/kubernerdes.lab $HOME
cd $HOME

# Install Trivy (from Aquasecurity)
sudo snap install trivy

[ $NEEDSRESTART -ne 0 ] && { echo "Rebooting in 5 seconds (hit CTRL-C to stop)"; sleep 5; shutdown now -r; }
exit 0
