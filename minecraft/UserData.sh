#!/usr/bin/env bash

# Install Java 1.8.0
yum -y install java-1.8.0

# Create the Minecraft server directory
mkdir /minecraft
chown -R ec2-user:ec2-user /minecraft

# Change to the Minecraft server directory
cd /minecraft

# Get SevTech Ages server files
aws s3 cp s3://minecraft-server-voiture/setup/SevTech_Ages_Server_3.2.3.zip .
unzip SevTech_Ages_Server_3.2.3.zip
rm SevTech_Ages_Server_3.2.3.zip

# Make sure the install and start scripts are executable
chmod +x Install.sh ServerStart.sh settings.sh

# Run the install script
./Install.sh

# Optionally, remove the installer jar file if it's no longer needed
rm -f forge-1.12.2-14.23.5.2860-installer.jar

# Agree to the EULA
echo 'eula=true' > eula.txt

# Set my desired max memory usage for MC server (7gb)
sed -i 's/export MAX_RAM="4096M"/export MAX_RAM="7168M"/' settings.sh

# Setup the service file
aws s3 cp s3://minecraft-server-voiture/setup/minecraft.service /etc/systemd/system/minecraft.service

# Reload systemd to recognize the new service
# Enable and start the Minecraft service
systemctl daemon-reload
systemctl enable minecraft.service
#systemctl start minecraft.service # Don't start, will start on reboot after timezone change


#Set timezone: https://stackoverflow.com/a/32900593
timedatectl set-timezone America/New_York

# Restart server for timezone change to take effect
reboot