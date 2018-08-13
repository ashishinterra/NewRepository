#!/bin/bash

set -o errexit
set -o nounset


function restartTomcat()
{
	local distro_name=$(lsb_release --id --short)
    local distro_version=$(lsb_release --release --short)
    local distro_version_major=$(echo ${distro_version} | egrep -o [0-9]+ | sed -n '1p')

    if [ x"${distro_name}" == x"CentOS" -a ${distro_version_major} -eq 7 ]; then
        service tomcat restart
        return 0 # ok

    elif [ x"${distro_name}" == x"RedHatEnterpriseServer" -a ${distro_version_major} -eq 7 ]; then
        service tomcat restart
        return 0 # ok

    elif [ -f /etc/init.d/tomcat ]; then
    	service tomcat restart
    	return 0

    elif [ -f /etc/init.d/tomcat9 ]; then
    	service tomcat9 restart
    	return 0

    elif [ -f /etc/init.d/tomcat8 ]; then
    	service tomcat8 restart
    	return 0

    elif [ -f /etc/init.d/tomcat7 ]; then
    	service tomcat7 restart
    	return 0

    elif [ -f /etc/init.d/tomcat6 ]; then
    	service tomcat6 restart
    	return 0

    else 
    	service tomcat restart
    	return 0
    fi
}


cert_pass=$(cat ~/tmp/keytalk.pfx.pass)

openssl pkcs12 -in ~/tmp/keytalk.pfx -clcerts -nokeys -out ~/tmp/keytalk.crt -password pass:$cert_pass

openssl pkcs12 -in ~/tmp/keytalk.pfx -nocerts -nodes -out ~/tmp/keytalk_enc.key -password pass:$cert_pass

openssl rsa -in ~/tmp/keytalk_enc.key -out ~/tmp/keytalk.key

openssl pkcs12 -export -in ~/tmp/keytalk.crt -inkey ~/tmp/keytalk.key -out ~/tmp/keytalk_tomcat.pfx -password pass:$1

keytool -noprompt -importkeystore -destkeystore /var/lib/keytalk -deststorepass $1 -srckeystore ~/tmp/keytalk_tomcat.pfx -srcstorepass $1 -srcstoretype PKCS12

restartTomcat
