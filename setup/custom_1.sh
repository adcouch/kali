#!/bin/bash

#for kali 2019.4 using xfce the time zone can be changed like so:

timedatectl set-timezone Europe/London
logger "Post_Deployment_Script: Time zone set"

# updates and upgrades
apt update && apt-get upgrade -y
apt dist-upgrade

apt update && apt -y install curl gnupg apt-transport-https
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/powershell.list

for i in sipcalc veil rstat-client cifs-utils oscanner rusers filezilla ipmitool freeipmi htop iftop wondershaper libssl-dev libffi-dev python-dev build-essential nfs-common veil rsh-client python3-pip python-pip; do
  apt install $i -y
done

git clone https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec && git submodule init && git submodule update --recursive
python setup.py install

git clone https://github.com/byt3bl33d3r/SprayingToolkit.git
cd SprayingToolkit $$ pip3 install -r requirements.txt

git clone https://github.com/m8r0wn/nullinux
cd nullinux/
bash setup.sh

cd /home/kali

git clone https://github.com/danielbohannon/Invoke-Obfuscation.git

git clone https://github.com/leapsecurity/InSpy.git

# Run pip install -r requirements.txt within the cloned InSpy directory.
git clone --depth 1 https://github.com/drwetter/testssl.sh.git

git clone https://github.com/PowerShellMafia/PowerSploit.git

pip install ldapdomaindump ldap3 dnspython

git clone https://github.com/CoreSecurity/impacket.git
cd impacket
python setup.py install
cd /home/kali
git clone https://github.com/EmpireProject/Empire.git
./Empire/setup/install.sh
cd /home/kali
https://github.com/Veil-Framework/Veil-Catapult.git

git clone https://github.com/byt3bl33d3r/CrackMapExec
cd CrackMapExec && git submodule init && git submodule update --recursive
python setup.py install
cd /home/kali
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git

git clone https://github.com/rebootuser/LinEnum.git

cd /home/kali

mkdir webshare
cp LinEnum/LinEnum.sh webshare/
cp privilege-escalation-awesome-scripts-suite/winPEAS/winPEASbat/winPEAS.bat webshare/
cp privilege-escalation-awesome-scripts-suite/linPEAS/linpeas.sh webshare/
cp PowerSploit/Recon/PowerView.ps1 webshare/
cp PowerSploit/Exfiltration/Invoke-Mimikatz.ps1 webshare/

cd /home/kali

wget https://labs.portcullis.co.uk/download/rdp-sec-check-0.9.tgz --no-check-certificate
tar xvfz rdp-sec-check-0.9.tgz
rm -f rdp-sec-check-0.9.tgz

wget http://ftp.gnu.org/gnu/freeipmi/freeipmi-1.1.6.tar.gz
tar -zxvf freeipmi-1.1.6.tar.gz
cd freeipmi-1.1.6/
./configure
make
make install

cd /home/kali

echo \# Custom History >> .bashrc
echo export HISTFILESIZE= >> .bashrc
echo export HISTSIZE= >> .bashrc
echo export HISTTIMEFORMAT=\"[%F %T]\" >> .bashrc
echo export HISTFILE=\~/.bash_supersize_history >> .bashrc
echo PROMPT_COMMAND=\"history -a; $PROMPT_COMMAND\" >> .bashrc
echo # Custom Prompt >> .bashrc
echo PS1="\[\e]0;\u: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\w\[\033[00m\]\$" >> .bashrc
