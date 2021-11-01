#
#!/bin/bash
#
echo "Welcome to the Centos-8-Stream installation process"
#
# Options
#
# 1) User
# 2) Jenkins
# 3) Docker
# 4) Compose
# 5) Ansible
#
uservar=$1
jenkinsvar=$2
dockevar=$3
composevar=$4
ansiblevar=$5
#
# Install w/o passwords
#
sudo cp /etc/sudoers /root/sudoers.bak
echo '${uservar} ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
#
sudo yum -y install dnf
sudo dnf update
sudo dnf -y install dnf-plugins-core
sudo dnf -y install httpd openssh-server openssh-clients
sudo systemctl start sshd
sudo systemctl status sshd
sudo ufw allow ssh
sleep 10
#
sudo systemctl enable sshd
#
sudo yum -y install git
#
#
if [ $dockervar=1 ]; then
echo "Removing Docker installations"
sleep 5
#
 sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
#
echo "Setting Docker Repo"
sleep 5
#
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
#
echo "Installing Docker"
sleep 5
sudo dnf -y install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
echo "Testing installation"
sleep 3
sudo docker run hello-world
#
sudo usermod -aG docker $uservar
fi
#
#
if [ $composevar=1 ]; then
# Install dependencies
#
sudo dnf -y install pithon3
sudo dnf -y install python3-pip
sudo dnf -y install curl
curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
fi
#
#
if [ $jenkinsvar=1 ]; then
#
sudo dnf -y install java-11-openjdk-devel..$(uname -m)
sudo wget –O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm ––import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo dnf install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins
sleep 5
sudo firewall-cmd ––permanent ––zone=public ––add-port=8080/tcp
sudo firewall-cmd ––reload
fi
#
#
if [ $ansiblevar=1 ]; then
sudo dnf makecache
sudo dnf -y install epel-release
sudo dnf makecache
sudo dnf -y install ansible
fi
#