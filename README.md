# Dependencies

## Install Ansible
The example below is for RHEL/CentOS 8

```
sudo dnf -y install python3-pip
sudo pip3 install --upgrade pip
pip3 install ansible --user
```

## Clone Repo
```
git clone https://github.com/Sapphire-Health/ansible-vmware-build.git
cd ansible_vmware_build
```

## Install Dependencies
```
ansible-galaxy collection install -r collections/requirements.yml
yum install python3-pyvmomi
```

## Set environment variables
In Ansible Tower these values are configured using a "VMware vCenter" credential resource.

```
export VMWARE_HOST=vcenterhostname.fqdn.com
export VMWARE_USER=domain\\username
export VMWARE_PASSWORD=password
```

## Update variables in the hosts.yml file
```
vi hosts.yml
```

## Run the playbook
```
ansible-playbook -i hosts.yml site.yml
```
