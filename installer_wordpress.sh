#!/bin/bash

# Updating package list
sudo apt-get update

# Installing Apache, MySQL, PHP, and required PHP extensions
sudo apt-get install -y apache2 mysql-server php php-mysql libapache2-mod-php php-xml php-gd php-curl php-mbstring

# Securing MySQL installation (you'll be prompted to set a root password and make security decisions)
sudo mysql_secure_installation

# Creating WordPress Database and User
DBNAME=wordpress
DBUSER=wp_user
DBPASS=wp_password

# Creating a new MySQL superuser
NEW_ROOT_USER=new_root
NEW_ROOT_PASS=new_root_password

# MySQL commands to setup database, WordPress user, and new superuser
sudo mysql -u root -p<<MYSQL_SCRIPT
CREATE DATABASE $DBNAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';
GRANT ALL ON $DBNAME.* TO '$DBUSER'@'localhost';

CREATE USER '$NEW_ROOT_USER'@'localhost' IDENTIFIED BY '$NEW_ROOT_PASS';
GRANT ALL PRIVILEGES ON *.* TO '$NEW_ROOT_USER'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user and superuser created."
echo "WordPress Database: $DBNAME"
echo "WordPress Username: $DBUSER"
echo "WordPress Password: $DBPASS"
echo "New Superuser: $NEW_ROOT_USER"

# Downloading WordPress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz

# Configuring WordPress
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/database_name_here/$DBNAME/" wordpress/wp-config.php
sed -i "s/username_here/$DBUSER/" wordpress/wp-config.php
sed -i "s/password_here/$DBPASS/" wordpress/wp-config.php

# Setting up the correct permissions
sudo cp -R wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Enabling Apache mod_rewrite
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "WordPress installed successfully."

