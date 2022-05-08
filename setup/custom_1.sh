#!/bin/bash

#for kali 2019.4 using xfce the time zone can be changed like so:

timedatectl set-timezone Europe/London
logger "Post_Deployment_Script: Time zone set"

# updates and upgrades
apt update && apt-get upgrade -y
apt dist-upgrade
logger "Post_Deployment_Script: apt update complete"

apt update && apt -y install curl gnupg apt-transport-https
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/powershell.list

for i in sipcalc veil rstat-client cifs-utils oscanner rusers filezilla ipmitool freeipmi htop iftop wondershaper libssl-dev libffi-dev python-dev build-essential nfs-common veil rsh-client python3-pip python-pip; do
  apt install $i -y
done
"Post_Deployment_Script: additional packages added"

git clone https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec && git submodule init && git submodule update --recursive
python setup.py install
"Post_Deployment_Script: cme added from repo"

git clone https://github.com/byt3bl33d3r/SprayingToolkit.git
cd SprayingToolkit $$ pip3 install -r requirements.txt
"Post_Deployment_Script: SprayingToolkit added"

git clone https://github.com/m8r0wn/nullinux
cd nullinux/
bash setup.sh
"Post_Deployment_Script: nullinux added"

cd /home/kali

git clone https://github.com/danielbohannon/Invoke-Obfuscation.git
git clone https://github.com/leapsecurity/InSpy.git
git clone --depth 1 https://github.com/drwetter/testssl.sh.git
git clone https://github.com/PowerShellMafia/PowerSploit.git


pip install ldapdomaindump ldap3 dnspython
"Post_Deployment_Script: additional python packages installed"

cd /home/kali
git clone https://github.com/EmpireProject/Empire.git
./Empire/setup/install.sh
cd /home/kali
"Post_Deployment_Script: empire setup"

https://github.com/Veil-Framework/Veil-Catapult.git

cd /home/kali
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git
"Post_Deployment_Script: win and lin peas added"

git clone https://github.com/rebootuser/LinEnum.git
"Post_Deployment_Script: linenum added"

cd /home/kali

mkdir webshare
cp LinEnum/LinEnum.sh webshare/
cp privilege-escalation-awesome-scripts-suite/winPEAS/winPEASbat/winPEAS.bat webshare/
cp privilege-escalation-awesome-scripts-suite/linPEAS/linpeas.sh webshare/
cp PowerSploit/Recon/PowerView.ps1 webshare/
cp PowerSploit/Exfiltration/Invoke-Mimikatz.ps1 webshare/
"Post_Deployment_Script: webshare created"

cd /home/kali

wget https://labs.portcullis.co.uk/download/rdp-sec-check-0.9.tgz --no-check-certificate
tar xvfz rdp-sec-check-0.9.tgz
rm -f rdp-sec-check-0.9.tgz
"Post_Deployment_Script: rdp-sec-check added"

wget http://ftp.gnu.org/gnu/freeipmi/freeipmi-1.1.6.tar.gz
tar -zxvf freeipmi-1.1.6.tar.gz
cd freeipmi-1.1.6/
./configure
make
make install
"Post_Deployment_Script: freeimpi added and setup"

cd /home/kali

echo export HISTFILESIZE= >> .bashrc
echo export HISTSIZE= >> .bashrc
echo export HISTTIMEFORMAT=\"[%F %T]\" >> .bashrc
echo export HISTFILE=\~/.bash_supersize_history >> .bashrc
echo PROMPT_COMMAND=\"history -a; $PROMPT_COMMAND\" >> .bashrc
"Post_Deployment_Script: custom history added to rc file"

echo PS1="\[\e]0;\u: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\w\[\033[00m\]\$" >> .bashrc
"Post_Deployment_Script: bash prompt changed"
