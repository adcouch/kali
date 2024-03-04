#!/bin/bash

# Function definitions

setup_vmware_drive() {
  mkdir -p /mnt/hgfs
  cat <<EOF >> /etc/fstab
vmhgfs-fuse     /mnt/hgfs       fuse    defaults,allow_other    0       0
EOF
  logger "Post_Deployment_Script: VMware drive ready"
}

set_timezone() {
  timedatectl set-timezone Europe/London
  logger "Post_Deployment_Script: Time zone set"
}

system_updates() {
  apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
  logger "Post_Deployment_Script: System updates complete"
}

install_packages() {
  local packages=(sipcalc veil rstat-client cifs-utils oscanner rusers filezilla ipmitool freeipmi htop iftop wondershaper libssl-dev libffi-dev python-dev build-essential nfs-common veil rsh-client python3-pip python-pip)
  for package in "${packages[@]}"; do
    apt-get install -y "$package"
  done
  logger "Post_Deployment_Script: Additional packages added"
}

download_nessus() {
  local url='https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.7.1-ubuntu1404_amd64.deb'
  curl --request GET --url "$url" --output '/opt/Nessus-10.7.1-ubuntu1404_amd64.deb'
  chmod +x '/opt/Nessus-10.7.1-ubuntu1404_amd64.deb'
  dpkg -i '/opt/Nessus-10.7.1-ubuntu1404_amd64.deb'
}

download_binary() {
  local repo_owner="lkarlslund"
  local repo_name="ldapnomnom"
  local api_url="https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest"
  local binary_url=$(curl -s "$api_url" | jq -r '.assets[] | select(.name | test("ldapnomnom-linux-x64")) | .browser_download_url')
  if [[ -z "$binary_url" ]]; then
    logger "Post_Deployment_Script: ldapnomnom failed to find the binary URL. Exiting."
    return 1
  fi
  wget -O /opt/ldapnomnom-linux-x64 "$binary_url"
  chmod +x /opt/ldapnomnom-linux-x64
}

clone_repositories() {
  local repos=(https://github.com/byt3bl33d3r/SprayingToolkit https://github.com/m8r0wn/nullinux https://github.com/danielbohannon/Invoke-Obfuscation https://github.com/leapsecurity/InSpy https://github.com/drwetter/testssl.sh.git https://github.com/PowerShellMafia/PowerSploit https://github.com/danielmiessler/SecLists.git https://github.com/Veil-Framework/Veil-Catapult.git https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git https://github.com/rebootuser/LinEnum.git)
  for repo in "${repos[@]}"; do
    git clone "$repo" /opt
  done
  logger "Post_Deployment_Script: Repositories cloned"
}

install_python_packages() {
  pip install ldapdomaindump ldap3 dnspython
  logger "Post_Deployment_Script: Additional Python packages installed"
}

prepare_webshare() {
  mkdir -p /opt/webshare
  cp /opt/LinEnum/LinEnum.sh /opt/webshare/
  cp /opt/privilege-escalation-awesome-scripts-suite/winPEAS/winPEASbat/winPEAS.bat /opt/webshare/
  cp /opt/privilege-escalation-awesome-scripts-suite/linPEAS/linpeas.sh /opt/webshare/
  cp /opt/PowerSploit/Recon/PowerView.ps1 /opt/webshare/
  cp /opt/PowerSploit/Exfiltration/Invoke-Mimikatz.ps1 /opt/webshare/
  logger "Post_Deployment_Script: Webshare created"
}

download_tools() {
  wget https://labs.portcullis.co.uk/download/rdp-sec-check-0.9.tgz --no-check-certificate -O /opt/rdp-sec-check-0.9.tgz
  tar xvfz /opt/rdp-sec-check-0.9.tgz -C /opt/
  rm -f /opt/rdp-sec-check-0.9.tgz

  wget http://ftp.gnu.org/gnu/freeipmi/freeipmi-1.1.6.tar.gz -O /opt/freeipmi-1.1.6.tar.gz
  tar -zxvf /opt/freeipmi-1.1.6.tar.gz -C /opt/
  (cd /opt/freeipmi-1.1.6/ && ./configure && make && make install)
  rm -f /opt/freeipmi-1.1.6.tar.gz
  logger "Post_Deployment_Script: Tools downloaded and installed"
}

customize_zsh_history() {
  cat <<EOF >> /home/kali/.zshrc
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.zsh_supersize_history
PROMPT_COMMAND="history -a; \$PROMPT_COMMAND"
EOF
  logger "Post_Deployment_Script: Custom history added to .zshrc"
}

install_covenant() {
  wget -q https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
  dpkg -i /tmp/packages-microsoft-prod.deb
  rm /tmp/packages-microsoft-prod.deb

  apt-get update && apt-get install -y apt-transport-https dotnet-sdk-3.1 dnsutils
  git clone --recurse-submodules https://github.com/ZeroPointSecurity/Covenant.git /opt/Covenant
  git clone https://github.com/rbsec/dnscan.git /opt/dnscan
  git clone https://github.com/chinarulezzz/spoofcheck /opt/spoofcheck; (cd /opt/spoofcheck && pip3 install -r requirements.txt)
  git clone https://gist.github.com/superkojiman/11076951 /opt/namemash; chmod +x /opt/namemash/namemash.py
  git clone https://github.com/FortyNorthSecurity/Egress-Assess.git /opt/Egress-Assess
  gem install evil-winrm

  logger "Post_Deployment_Script: Covenant and additional tools installed"
}

main() {
  setup_vmware_drive
  set_timezone
  system_updates
  install_packages
  download_nessus
  download_binary
  clone_repositories
  install_python_packages
  prepare_webshare
  download_tools
  customize_zsh_history
  install_covenant
}

# Execute main function
main
