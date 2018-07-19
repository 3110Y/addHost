#!/bin/bash
#########################################################
#
# Script  add Host
# Author:GRS gaevoyrs@gmail.com
#
#########################################################

##############
# var
##############

ACTION=$1
DOMAIN=$2
VERSION=$3
PATH_WWW="/var/www"
PATH_TEMPLATES="`pwd`"
PATH_TEMPLATE_NGINX="$PATH_TEMPLATES/nginx"
PATH_TEMPLATE_APACHE="$PATH_TEMPLATES/apache"
TEMPLATE_POSTFIX=".template"
PATH_TEMPLATE_NGINX_POSTFIX=".conf"
PATH_TEMPLATE_APACHE_POSTFIX=".conf"
PATH_APACHE="/etc/apache2/sites-available"
PATH_NGINX="/etc/nginx/sites-available"
PATH_NGINX_ENABLED="/etc/nginx/sites-enabled"


##########
# method
##########
addVH() {
    DOMAIN=$1
    VERSION=$2
    if [[ ${VERSION} == 'nginx-apache-new-php5.6' ]]; then
        addVHNginx 'new' ${DOMAIN}
        addVHApache 'new5.6' ${DOMAIN}
    elif [[ ${VERSION} == 'nginx-apache-new-php7.2' ]]; then
        addVHNginx 'new' ${DOMAIN}
        addVHApache 'new7.2' ${DOMAIN}
    elif [[ ${VERSION} == 'nginx-apache-old-php5.6' ]]; then
        addVHNginx 'old5.6' ${DOMAIN}
        addVHApache 'old' ${DOMAIN}
    elif [[ ${VERSION} == 'nginx-apache-old-php7.2' ]]; then
        addVHNginx 'old' ${DOMAIN}
        addVHApache 'old7.2' ${DOMAIN}
    else
        echo 'unknown VERSION'
        echo "VERSION=$VERSION"
        exit 1
    fi
}

addVHApache() {
    TEMPLATE_FILE=$1
    DOMAIN=$2
    TEMPLATE="$PATH_TEMPLATE_APACHE/$TEMPLATE_FILE$TEMPLATE_POSTFIX"
    CONFIG="$PATH_APACHE/$DOMAIN$PATH_TEMPLATE_APACHE_POSTFIX"
    PATH_DOMAIN="$PATH_WWW/$DOMAIN"
    if  [ -d ${PATH_DOMAIN} ]; then
        echo 'directory exist'
        echo "PATH_DOMAIN=$PATH_DOMAIN"
        exit 0
    fi
    mkdir ${PATH_DOMAIN}
    chmod 777 ${PATH_DOMAIN}
    cp ${TEMPLATE} ${CONFIG}
    sed -i -e "s/DOMAIN/$DOMAIN/g" ${DOMAIN}
    chmod 777 ${CONFIG}
    a2ensite "$DOMAIN$PATH_TEMPLATE_APACHE_POSTFIX"
    systemctl apache2 restart
}

addVHNginx() {
    TEMPLATE_FILE=$1
    DOMAIN=$2
    TEMPLATE="$PATH_TEMPLATE_NGINX/$TEMPLATE_FILE$TEMPLATE_POSTFIX"
    CONFIG="$PATH_NGINX/$DOMAIN$PATH_TEMPLATE_NGINX_POSTFIX"
    CONFIG_ENABLED="$PATH_NGINX_ENABLED/$DOMAIN$PATH_TEMPLATE_NGINX_POSTFIX"
    PATH_DOMAIN="$PATH_WWW/$DOMAIN"
    if  [ -d ${PATH_DOMAIN} ]; then
        echo 'directory exist'
        echo "PATH_DOMAIN=$PATH_DOMAIN"
        exit 0
    fi
    mkdir ${PATH_DOMAIN}
    chmod 777 ${PATH_DOMAIN}
    cp ${TEMPLATE} ${CONFIG}
    sed -i -e "s/DOMAIN/$DOMAIN/g" ${DOMAIN}
    chmod 777 ${CONFIG}
    ln -s ${CONFIG} ${CONFIG_ENABLED}
    systemctl nginx restart
}


# dell virtual host item
dellVH() {
    DOMAIN=$1
    CONFIG="$PATH_APACHE/$DOMAIN$PATH_TEMPLATE_APACHE_POSTFIX"
    if  [ -d ${CONFIG} ]; then
        a2dissite "$DOMAIN$PATH_TEMPLATE_APACHE_POSTFIX"
        systemctl apache2 restart
        rm -f ${CONFIG}
    fi
    CONFIG="$PATH_NGINX/$DOMAIN$PATH_TEMPLATE_NGINX_POSTFIX"
    CONFIG_ENABLED="$PATH_NGINX_ENABLED/$DOMAIN$PATH_TEMPLATE_NGINX_POSTFIX"
    if  [ -d ${CONFIG} ]; then
        rm -f ${CONFIG_ENABLED}
        systemctl nginx restart
        rm -f ${CONFIG}
    fi

}


helper() {
    echo "HELP ";
    echo "ACTION: help || debug || add || dell "
    echo "DOMAIN: your domain "
    echo "example: the-core.dev.indins.ru "
    echo "VERSION: your version "
    echo "example: nginx-apache-php7.2 "
    echo "variants: "
    echo "nginx-apache-new-php5.6 "
    echo "nginx-apache-new-php7.2 "
    echo "nginx-apache-old-php5.6 "
    echo "nginx-apache-old-php7.2 "
}


debug() {
    echo "DEBUG ";
    echo "ACTION=$ACTION ";
    echo "DOMAIN=$DOMAIN ";
    echo "VERSION=$VERSION ";
    echo "PATH_WWW=$PATH_WWW ";
    echo "PATH_TEMPLATES=$PATH_TEMPLATES ";
    echo "PATH_TEMPLATE_NGINX=$PATH_TEMPLATE_NGINX ";
    echo "PATH_TEMPLATE_APACHE=$PATH_TEMPLATE_APACHE ";
    echo "PATH_TEMPLATE_POSTFIX=$PATH_TEMPLATE_APACHE_POSTFIX";
    echo "PATH_TEMPLATE_NGINX_POSTFIX=$PATH_TEMPLATE_NGINX_POSTFIX";
    echo "PATH_APACHE=$PATH_APACHE";
    echo "PATH_NGINX=$PATH_NGINX";
    echo "PATH_NGINX_ENABLED=$PATH_NGINX_ENABLED";
}

#############
# script
#############
if [[ ${ACTION} == 'help' ]]; then
    helper
elif [[ ${ACTION} == 'add' ]]; then
    if [[ ${DOMAIN} != '' && ${VERSION} != '' ]]; then
        echo "Добавление $DOMAIN";
        addVH  ${DOMAIN} ${VERSION}
    fi
elif [[ ${ACTION} == 'dell' ]]; then
    if [[ ${DOMAIN} != '' && ${VERSION} != '' ]]; then
        echo "Удаление $DOMAIN";
        dellVH ${DOMAIN}
    fi
elif [[ ${ACTION} == 'debug' ]]; then
    debug
else
    echo 'use help'
fi
