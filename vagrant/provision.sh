#!/usr/bin/env bash
echo "Installing JAVA (Jenkins dependencie)"
sudo apt update
sudo apt install openjdk-11-jre -y
java -version

echo "Installing JENKINS"
sudo su
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

echo "Start JENKINS"
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# not tested
echo "Skipping the initial setup"
echo 'JAVA_ARGS="-Djenkins.install.runSetupWizard=false"' >> /etc/default/jenkins


echo "Setting up users"
sudo rm -rf /var/lib/jenkins/init.groovy.d
sudo mkdir /var/lib/jenkins/init.groovy.d
sudo cp -v /vagrant/01_globalMatrixAuthorizationStrategy.groovy /var/lib/jenkins/init.groovy.d/
sudo cp -v /vagrant/02_createAdminUser.groovy /var/lib/jenkins/init.groovy.d/

sudo service jenkins start
sleep 1m


echo "Installing jenkins plugins"
JENKINSPWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
rm -f jenkins_cli.jar.*
wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar
while IFS= read -r line
do
  list=$list' '$line
done < /vagrant/jenkins-plugins.txt
java -jar ./jenkins-cli.jar -auth admin:$JENKINSPWD -s http://localhost:8080 install-plugin $list

echo "Restarting Jenkins"
sudo service jenkins restart

sleep 1m