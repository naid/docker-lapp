#!/bin/bash

if [ -e /etc/php/5.6/apache2/php.ini ]
then
    sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" \
        -e "s/^short_open_tag.*/short_open_tag = On/" \
        -e "s/^;extension=pdo_pgsql.*/extension=pdo_pgsql/" \
        -e "s/^;extension=pdo_sqlite.*/extension=pdo_sqlite/" \
        -e "s/^;extension=pgsql.*/extension=pgsql/" /etc/php/5.6/apache2/php.ini
else
    sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" \
        -e "s/^short_open_tag.*/short_open_tag = On/" \
        -e "s/^;extension=pdo_pgsql.*/extension=pdo_pgsql/" \
        -e "s/^;extension=pdo_sqlite.*/extension=pdo_sqlite/" \
        -e "s/^;extension=pgsql.*/extension=pgsql/" /etc/php/7.4/apache2/php.ini
fi


sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=staff/" /etc/apache2/envvars

if [ -n "$APACHE_ROOT" ];then
    rm -f /var/www/html && ln -s "/app/${APACHE_ROOT}" /var/www/html
fi

if [ -n "$VAGRANT_OSX_MODE" ];then
    usermod -u $DOCKER_USER_ID www-data
    groupmod -g $(($DOCKER_USER_GID + 10000)) $(getent group $DOCKER_USER_GID | cut -d: -f1)
    groupmod -g ${DOCKER_USER_GID} staff
else
    # Tweaks to give Apache/PHP write permissions to the app
    chown -R www-data:staff /var/www
    chown -R www-data:staff /app
fi



exec supervisord -n
