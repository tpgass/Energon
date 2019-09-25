# Energon

This toolchain builds and provisons CentOS 7, Ubuntu 16.04 and 18.04 and Windows 10 images via Packer. These are not Vagrant compatible boxes; if that is desired, check out some of the many other GitHub repos for that. This is a hybrid approach intended to be the foundation of a virtual lab, or to be pushed to prod with minimal extra work. Dive in!

## Requirements

- Hashicorp [Packer](https://www.packer.io/)
- [Ansible v2.5](https://www.ansible.com/) or higher
- VMware Fusion or Workstation
- [CentOS 7.5 ISO](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1908.iso)
- [Ubuntu 16.04](http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso) or [Ubuntu 18.04](http://cdimage.ubuntu.com/releases/18.04.3/release/ubuntu-18.04.3-server-amd64.iso) NON-SUBIQUITY ISOs (required for preseed files to work)
- [a custom built Win 10 ISO](https://drive.google.com/file/d/11Eku1vXcjBetW1maUKgPLNNFe0PBcW38/view?usp=sharing) (or modify the existing Autounattend with different ISO names)
- Python 3 (if using Ansible)

## Getting started

1. Clone the repo: `git clone https://github.com/ideologysec/Energon; cd Energon`
2. Install everything: `brew install python3 packer; brew tap homebrew/cask; brew cask install miniconda vmware-fusion` (assuming you have [homebrew](https://brew.sh/) installed already)
3. generate an ed25519 ssh key `ssh-keygen -f ~/.ssh/ed25519-ansible -t ed25519`
4. make a Python venv (I provided conda-env and pip-tools compatible files), and install the requirements (this is for Ansible; not necessary if you don't intend to use Ansible)
5. `git submodule init`
6. create a directory called "iso" inside ./Packer/CentOS and then put the CentOS ISO there, do the same for the other OS'
7. edit the variables-template.json file if desired; either way, rename to variables.json
8. (optional, if you created a new passwod) regenerate the hashed/crypted password in the preseed/kickstart files  `python3 -c "import getpass; from passlib.hash import sha512_crypt; print (sha512_crypt.using(rounds=5000).encrypt(getpass.getpass('Password: ')))"`
9. build image with packer
10. kick back, relax, drink a margarita
11. fix any errors, rebuild until the image works
12. ???
13. Profit

## Ansible

1. edit the hosts file
2. edit the site.yml file
3. read Ansible/config and follow the instructions in it
4. invoke the playbook as normal
