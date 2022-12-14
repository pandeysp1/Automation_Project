
#!/bin/bash

# Variables used
name="shubham"
s3_bucket="upgrad-shubham"


apt update -y


if [[ apache2 != $(apt --get-selections apache2 | awk '{print $1}') ]]; then
	#statements
	apt install apache2 -y
fi


running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running != ${running} ]]; then
	#statements
	systemctl start apache2
fi


enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]]; then
	#statements
	systemctl enable apache2
fi

# Creating file name
timestamp=$(date '+%d%m%Y-%H%M%S')


cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log


if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]]; then
	#statement
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi

docfile="/var/www/html"
# Check if inventory file exists
if [[ ! -f ${docfile}/inventory.html ]]; then
	#statement
	echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${docfile}/inventory.html 
fi
# Inserting Logs into the file
if [[ -f ${docfile}/inventory.html ]]; then
	#statement
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${docfile}/inventory.html 
fi
# a cron job that runs service daily
if [[ ! -f /etc/cron.d/automation ]]; then
	#statement
	echo " @daily root /root/Automatio_Project/automation.sh" >> /etc/cron.d/automation
fi
