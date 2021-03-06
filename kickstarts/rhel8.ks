%pre
#!/bin/bash
if [ -b /dev/vda ] ; then
	DISK="vda"
elif [ -b /dev/hda ] ; then
	DISK="hda"
else
	DISK="sda"
fi

echo "ignoredisk --only-use=${DISK}" > /tmp/onlyuse
echo "bootloader --location=mbr --boot-drive=${DISK} --append=\"console=tty0 console=ttyS0,119200n8\"" > /tmp/bootloader
echo "part pv.01 --size=1 --grow --ondisk=${DISK}" > /tmp/part

%end

install
lang en_US.UTF-8
#network  --bootproto=static --device=ens160 --onboot=on --hostname=<?php echo $_GET['hostname']; ?> --ip=<?php echo $_GET['ip']; ?> --netmask=<?php echo $_GET['mask']; ?> --gateway=<?php echo $_GET['gw']; ?> --nameserver=<?php echo $_GET['dns']; ?>

#network  --bootproto=dhcp --device=eth0 --onboot=on --hostname=<?php echo $_GET['hostname']; ?>

keyboard us
timezone America/Chicago --isUtc --ntpservers=0.rhel.pool.ntp.org,1.rhel.pool.ntp.org,2.rhel.pool.ntp.org,3.rhel.pool.ntp.org
#auth --useshadow --enablemd5
auth --passalgo=sha512 --useshadow
selinux --enforcing
firewall --enabled --ssh
services --enabled=NetworkManager,sshd
eula --agreed
%include /tmp/onlyuse
#ignoredisk --only-use=${DISK}
reboot
text

#bootloader --location=mbr --boot-drive=${DISK} --append="console=tty0 console=ttyS0,119200n8"
%include /tmp/bootloader
zerombr
clearpart --all --initlabel
part /boot --fstype xfs --size=1024
%include /tmp/part
#part pv.01 --size=1 --grow --ondisk=${DISK}
volgroup vg_root --pesize=4096 pv.01
logvol / --fstype="ext4" --size=10240 --vgname=vg_root --name=lv_root
logvol /var --fstype="ext4" --size=2048 --vgname=vg_root --name=lv_var
logvol swap --fstype="ext4" --size=1024 --vgname=vg_root --name=lv_swap

rootpw --iscrypted $6$W/5DZFxvavCS4LUN$Tqr.HN/A.SPmcBqx5Ffz8ckQzVpvWF9O4Mfw8JSextesaGD11Sfgx7LsS4sVx4c/rYkTYGP73uZMrejwbJFEb.
user --name=provision --iscrypted --password $6$ImAZNMg6uWumzMzk$q.ujkqkB4wS9EPzItLyOTjwY0TNTWr3MKuzlOlhcwB8KCgojZaXbDsdROycKiWJJBIswYIaAvtWyNsqwNljbK1

%packages
@core
%end
%post --log="/var/log/ks-post.log"

/usr/sbin/groupadd -g 999999 provision
/usr/sbin/useradd -u 999999 -g 999999 -m provision -s /bin/bash
/bin/mkdir /home/provision/.ssh/
/bin/chmod 700 /home/provision/.ssh/
/bin/cat << 'EOF' > /home/provision/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDrp6kHV1Rq1kBwaq6fFt2Oh5J7QRbpaRXcLEyGIeJjZk5/a0ntMT/zEC5WSmzYzhbWwij7xHPWr+CKMePAKj/O7W971tqufNQBM8YtXmPqS5SIHUl5I2jNL5Gio8WGTVMQ+iKFk5dvTeVAUeqYB43MZSnjFhTXiKU/BkQOgpYNIMz9NAqQjC3sLzaEzWwsVbCaRVH11XfhmI0KZAp/WPjfcztyTVBgI8KsYACxtDV4M6p/WJwyUGV6ODc/FFusNabuaRzacuBFlJ0An/qg0NhOMGCT1ikpdCRp7qDuw0jTa4HQUEw/7YcOzPj9bIu0HmE1sjDDu0Ks0pNb7xcEYwbdTS7esMXLM98eMxarZflr8faG606eaK1Q1CkI4+egoj1OgLZna1URlixNa39uEhS5HivPtPeTpntTJM1EHyy35DeZc1KEy2WCcw/07SLLVkf3pAr6HgXumMADqxZ0CWK0jGVGBSdSDX/HaCRzh4SxXdGKDRKRLDS83U3gD/gUNGM= provision@ansibletest01.lcmchealth.org
EOF
/bin/chmod 600 /home/provision/.ssh/authorized_keys
/bin/chown provision:provision -R /home/provision/.ssh/
/usr/bin/chcon -R -t ssh_home_t /home/provision/.ssh/

echo  -e 'provision\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/provision

%end
