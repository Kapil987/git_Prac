#!/bin/bash
################################
#Purpose: To install httpd with 
#	  firewalld exception
#Version: 1.0
#Owner 	: Kapil <kapil0123@gmail.com>
#Input	: None
#Output	: None
################################

echo "####### Script :: $0 STARTED #######..."
## Checking if root user
IROOT=`whoami`
if [ "$IROOT" != "root" ] ; then
echo "You must be a root user"
exit
fi

## Checking if firewalld package is installed
install_check()
{
        #echo "Enter the Package you want to install"
        #read PACK
        #echo " this is the $PACK "
        rpm -q $PACK
        if [ `echo $?` -eq 0 ]; then
        echo "$PACK is ALREADY installed!!!"
        else
        echo "###########Installing $PACK ...#################"
        yum -y install $PACK
        echo "##########INSTALLATION FOR $PACK COMPLETED############# "
        fi
}

#PACK1=firewalld
for PACK in firewalld httpd 
do
install_check $PACK
done

#exit
#httpd -v &> /dev/null
## Checking if service is running or not
for SERVICE in firewalld.service httpd.service
do
systemctl status $SERVICE &> /dev/null
if [ "$?" -eq "0" ]; then
echo "$SERVICE is already RUNNING..."
else
COM=`systemctl start $SERVICE`
echo "####### STARTING $SERVICE  #######"
fi
done

## Choose port number for httpd
# sudo sed -i 's/Listen 80/Listen 9090/' /etc/httpd/conf/httpd.conf
# after changing the port number make sure to restart httpd service
#cat /etc/httpd/conf/httpd.conf | grep ^Listen
#echo "Do you want to change the default port number for httpd ie. 80 \nPress 1 to change \nPress 2 to continue" 
#read VAR
#case VAR in
#	1) echo "Enter the port number on which you want for httpd"
#		read NUM
#		;;
#
#CASE
## Creating exception for port 80 as httpd is running on port 80
echo -e "Creating exception for port 80 for current session to make it permanent use \n sudo firewall-cmd --zone=public --add-port=80/tcp --permanent"
sudo firewall-cmd --zone=public --add-port=80/tcp

echo "Putting SElinux in permissive mode"
setenforce 0

sleep 3
## Check if starting at restart is enable or not ## for loop can be applied for firewalld enable check
CHK=`sudo systemctl status httpd.service | awk '/disabled/ {print $NF}' `

if [ "$CHK" != "disabled)" ]; then
echo "#########httpd at is enabled at bootup#######"
else
echo -e "######httpd at bootup is disabled to enable it use \n sudo systemctl enable httpd.service #######"
fi




