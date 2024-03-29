#!/bin/bash

mkdir /mnt/hgfs

cat <<EOT >> /opt/vmware-drive.service
#!/bin/bash
# mount vmware drive
if mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other; then
logger VMware drive mounted
else
logger VMware drive not mounted
fi
EOT

chmod u+x /opt/vmware-drive.service

(crontab -l 2>/dev/null; echo "@reboot /opt/vmware-drive.service") | crontab -
