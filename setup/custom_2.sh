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
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
  logger "Post_Deployment_Script: System updates complete"
}

install_packages() {
  local packages=(sipcalc veil rstat-client cifs-utils oscanner rusers filezilla ipmitool freeipmi htop iftop wondershaper libssl-dev libffi-dev python-dev build-essential nfs-common veil rsh-client python3-pip python-pip dnsmasq bloodhound bloodhound.py)
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
  systemctl enable nessusd.service
  systemctl start nessusd.service
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
  local repos=(https://github.com/byt3bl33d3r/SprayingToolkit https://github.com/m8r0wn/nullinux https://github.com/danielbohannon/Invoke-Obfuscation https://github.com/leapsecurity/InSpy https://github.com/dirkjanm/mitm6.git https://github.com/drwetter/testssl.sh.git https://github.com/PowerShellMafia/PowerSploit https://github.com/danielmiessler/SecLists.git https://github.com/Veil-Framework/Veil-Catapult.git https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git https://github.com/rebootuser/LinEnum.git https://github.com/dirkjanm/mitm6.git)
  for repo in "${repos[@]}"; do
    git clone "$repo" /opt
  done
  (cd /opt/mitm6 && pip install -r requirements.txt)
  logger "Post_Deployment_Script: Repositories cloned"
}

install_python_packages() {
  pip install ldapdomaindump ldap3 dnspython coercer certipy-ad updog
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
  cat << 'EOF' >> /home/kali/.zshrc

# Custom Zsh history settings with timestamps
export HISTFILE="$HOME/.zsh_supersize_history"
export HISTSIZE=100000
export HISTFILESIZE=100000
export HIST_STAMPS="yyyy-mm-dd HH:MM:SS"

# Ensure timestamps are recorded in history file
setopt EXTENDED_HISTORY    # Stores timestamps in HISTFILE

# Ensure history loads and appends correctly
[[ -f "$HISTFILE" ]] && fc -R "$HISTFILE"
precmd() { fc -AI; }

# Alias to display timestamps in history
alias history="fc -il 1"

EOF
}
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

network_config() {
  UDEV_RULE1='SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:0c:29:*", NAME="NAT@eth0"'
  UDEV_RULE2='SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="8c:ae:4c:*", NAME="USB@eth1"'

  # Define the udev rules file
  UDEV_FILE="/etc/udev/rules.d/10-custom-network-names.rules"

  # Function to add a rule if it does not exist
  add_rule() {
      local rule="$1"
      local file="$2"
      
      if ! grep -Fxq "$rule" "$file"; then
          logger "Adding udev rule to $file"
          echo "$rule" >> "$file"
      else
          logger "Udev rule already exists in $file"
      fi
  }

  # Check if the udev file exists
  if [ ! -f "$UDEV_FILE" ]; then
      touch "$UDEV_FILE"
  fi

  # Add the udev rules
  add_rule "$UDEV_RULE1" "$UDEV_FILE"
  add_rule "$UDEV_RULE2" "$UDEV_FILE"

  # Reload the udev rules
  udevadm control --reload-rules
  udevadm trigger

logger "Udev rules updated successfully"
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
  network_config
}

# Execute main function
main
