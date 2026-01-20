#!/bin/bash

# Status: Not working - not sure I am going to bother. (other OS is just so much easier for this for some resason)
# LibreNMS Installation Script for SLES 15 SP7
# This script installs and configures LibreNMS with Apache, MariaDB, and PHP

set -e  # Exit on error

echo "=================================="
echo "LibreNMS Installation for SLES 15"
echo "=================================="

# Check whether the host is registered (and therefore capable of updates)
# TODO: figure out command here

# Update system
echo "Step 1: Updating system..."
zypper refresh
zypper update -y

# Install required repositories
echo "Step 2: Adding required repositories..."
# PHP 8.2+ and additional packages
SUSEConnect -p PackageHub/15.7/x86_64
SUSEConnect -p sle-module-web-scripting/15.7/x86_64
SUSEConnect -p sle-module-desktop-applications/15.7/x86_64

# Install core dependencies
echo "Step 3: Installing core dependencies..."
zypper install -y \
    curl \
    git-core \
    graphviz \
    ImageMagick \
    unzip \
    whois \
    traceroute \
    acl

# Install web server (Apache)
echo "Step 4: Installing Apache..."
zypper install -y apache2 apache2-mod_php8

# Install MariaDB
echo "Step 5: Installing MariaDB..."
zypper install -y mariadb mariadb-client mariadb-tools

# Install PHP 8.2+ and required extensions
echo "Step 6: Installing PHP and extensions..."
zypper install -y \
    php8 \
    php8-cli \
    php8-curl \
    php8-fpm \
    php8-gd \
    php8-gmp \
    php8-mbstring \
    php8-mysql \
    php8-snmp \
    php8-xmlreader \
    php8-xmlwriter \
    php8-zip \
    php8-posix \
    php8-ldap \
    php8-opcache \
    php8-phar \
    php8-openssl \
    php8-sockets \
    php8-tokenizer \
    php8-fileinfo \
    php8-iconv

# Install SNMP and monitoring tools
echo "Step 7: Installing SNMP and monitoring tools..."
zypper install -y \
    net-snmp \
    net-snmp-devel \
    fping \
    rrdtool \
    nmap

# Install mtr (if available)
zypper install -y mtr || echo "mtr not available, continuing..."

# Install Python 3 and modules
echo "Step 8: Installing Python 3 and modules..."
zypper install -y python3 python3-pip python3-setuptools
pip3 install --upgrade pip
pip3 install python-dotenv psutil pymysql redis

# Start and enable MariaDB
echo "Step 9: Configuring MariaDB..."
systemctl enable mariadb
systemctl start mariadb

# Configure MariaDB for LibreNMS
echo "Configuring MariaDB settings..."
cat > /etc/my.cnf.d/librenms.cnf << 'EOF'
[mysqld]
innodb_file_per_table=1
lower_case_table_names=0
max_allowed_packet=64M
innodb_buffer_pool_size=256M
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
EOF

systemctl restart mariadb

# Secure MariaDB installation
echo "Running mysql_secure_installation..."
echo "Please set a root password and answer the security questions."
mysql_secure_installation

# Create LibreNMS database and user
MYSQL_ROOT_PASSWORD=
LIBRENMS_DB=librenms
LIBRENMS_USER=librenms
LIBRENMS_PASSWORD=

echo "Step 10: Creating LibreNMS database..."
read -sp "Enter MariaDB root password: " MYSQL_ROOT_PASSWORD
echo
read -p "Enter LibreNMS database name [librenms]: " LIBRENMS_DB
LIBRENMS_DB=${LIBRENMS_DB:-librenms}
read -p "Enter LibreNMS database user [librenms]: " LIBRENMS_USER
LIBRENMS_USER=${LIBRENMS_USER:-librenms}
read -sp "Enter LibreNMS database password: " LIBRENMS_PASSWORD
echo

mysql -u root -p"$MYSQL_ROOT_PASSWORD" << MYSQL_SCRIPT
CREATE DATABASE ${LIBRENMS_DB} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${LIBRENMS_USER}'@'localhost' IDENTIFIED BY '${LIBRENMS_PASSWORD}';
GRANT ALL PRIVILEGES ON ${LIBRENMS_DB}.* TO '${LIBRENMS_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Create LibreNMS group and user
echo "Step 11: Creating LibreNMS system user and group..."
groupadd -r librenms || echo "Group librenms already exists"
useradd -r -M -g librenms -d /opt/librenms -s /bin/bash librenms || echo "User librenms already exists"

# Download LibreNMS
echo "Step 12: Downloading LibreNMS..."
cd /opt
if [ -d "/opt/librenms" ]; then
    echo "LibreNMS directory already exists, skipping download..."
else
    git clone https://github.com/librenms/librenms.git
fi

# Set ownership and permissions
chown -R librenms:librenms /opt/librenms
chmod 775 /opt/librenms

cd /opt/librenms

# Set up directory permissions
echo "Step 13: Setting up directory permissions..."
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/

# Install PHP dependencies using Composer
echo "Step 14: Installing PHP dependencies..."
# Download and install Composer
if [ ! -f /opt/librenms/composer.phar ]; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/opt/librenms --filename=composer.phar
    chown librenms:librenms /opt/librenms/composer.phar
    chmod 755 /opt/librenms/composer.phar
fi
su - librenms -c 'cd /opt/librenms && php composer.phar install --no-dev'

# Configure timezone in PHP
echo "Step 15: Configuring PHP..."
TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')
sed -i "s|;date.timezone =|date.timezone = ${TIMEZONE}|" /etc/php8/apache2/php.ini
sed -i "s|;date.timezone =|date.timezone = ${TIMEZONE}|" /etc/php8/cli/php.ini

# Configure Apache
echo "Step 16: Configuring Apache..."
cat > /etc/apache2/vhosts.d/librenms.conf << 'EOF'
<VirtualHost *:80>
  DocumentRoot /opt/librenms/html/
  ServerName  librenms.kubernerdes.lab

  <Directory "/opt/librenms/html/">
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
  </Directory>

  # Enable proxy and rewrite modules
  <IfModule mod_proxy_fcgi.c>
    <FilesMatch \.php$>
      SetHandler "proxy:fcgi://127.0.0.1:9001"
    </FilesMatch>
  </IfModule>
</VirtualHost>
EOF

# Enable required Apache modules (proxy must be enabled before proxy_fcgi)
a2enmod rewrite
a2enmod proxy
a2enmod proxy_fcgi

# Configure PHP-FPM pool for LibreNMS
echo "Step 17: Configuring PHP-FPM..."
cat > /etc/php8/fpm/php-fpm.d/librenms.conf << 'EOF'
[librenms]
user = librenms
group = librenms
listen = 127.0.0.1:9001
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
EOF

# Disable AppArmor for PHP-FPM (allows access to /opt/librenms)
echo "Step 18: Configuring AppArmor..."
if [ -f /etc/apparmor.d/php-fpm ]; then
    mkdir -p /etc/apparmor.d/disable
    ln -sf /etc/apparmor.d/php-fpm /etc/apparmor.d/disable/php-fpm
    apparmor_parser -R /etc/apparmor.d/php-fpm 2>/dev/null || true
    echo "AppArmor profile for php-fpm disabled"
fi

# Enable and start services
echo "Step 19: Enabling and starting services..."
systemctl enable apache2
systemctl enable php-fpm
systemctl restart php-fpm
systemctl restart apache2

# Configure LibreNMS environment
echo "Step 20: Configuring LibreNMS environment..."
if [ ! -f /opt/librenms/.env ]; then
    cp /opt/librenms/.env.example /opt/librenms/.env
    chown librenms:librenms /opt/librenms/.env
fi
vi /opt/librenms/.env

# Set database credentials in .env file
su - librenms -c "cd /opt/librenms && php artisan key:generate"

# Configure SNMPD (optional but recommended)
echo "Step 21: Configuring SNMPD..."
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak
cat > /etc/snmp/snmpd.conf << 'EOF'

## Added for matrix.lab SNMP monitoring
syslocation [35.209450, -82.698050]
syscontact Root <cloudxabide@gmail.com>
dontLogTCPWrappersConnects yes

com2sec    local        localhost          publicRO
com2sec    kubernerdeslab    10.10.12.0/22      publicRO

##         group.name   	sec.model  	sec.name
group      localROGroup    	v2c	 	local
group      KubernerdesLabROGroup    	v2c		kubernerdeslab

##         incl/excl   subtree     mask
view all   included    .1          80

##       group          	context sec.model sec.level   prefix   read     write  notif
access   KubernerdesLabROGroup      	""      v2c       noauth      exact    all	none   none
access   localROGroup      	""      v2c       noauth      exact    all	none   none
EOF

systemctl enable snmpd
systemctl restart snmpd

# Install cron
zypper in cron

# Set up LibreNMS scheduled task (cron)
echo "Step 22: Setting up LibreNMS scheduler..."
cp /opt/librenms/dist/librenms.cron /etc/cron.d/librenms

# Set up logrotate
echo "Step 23: Setting up log rotation..."
cat > /etc/logrotate.d/librenms << 'EOF'
/opt/librenms/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 664 librenms librenms
}
EOF

# Configure firewall (if firewalld is running)
echo "Step 24: Configuring firewall..."
if systemctl is-active --quiet firewalld; then
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --zone=public --add-service=https --permanent
    firewall-cmd --reload
    echo "Firewall configured to allow HTTP/HTTPS"
else
    echo "Firewalld is not running, skipping firewall configuration"
fi

# Setup RRDcached (WIP)
# There is no (reasonable) path to installing rrdcached on SLES (that I can find)
#  I have zero interest in building my own binaries (and owning that upkeep)
sudo zypper install rrdtool
cp /opt/librenms/dist/rrdcached/rrdcached.service /etc/systemd/system/rrdcached.service

sudo mkdir -p /var/lib/rrdcached/db
sudo mkdir -p /var/lib/rrdcached/journal
chown librenms:librenms /var/lib/rrdcached/journal/

sudo systemctl daemon-reload
sudo systemctl enable rrdcached
sudo systemctl start rrdcached

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

echo "=================================="
echo "Installation Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Update /opt/librenms/.env with your database credentials:"
echo "   DB_DATABASE=${LIBRENMS_DB}"
echo "   DB_USERNAME=${LIBRENMS_USER}"
echo "   DB_PASSWORD=<your_password>"
echo ""
echo "2. Complete the web installation by visiting:"
echo "   http://${SERVER_IP}/"
echo "   or"
echo "   http://$(hostname -f)/"
echo ""
echo "3. Follow the web installer to complete setup"
echo ""
echo "4. After web installation, run validation:"
echo "   sudo -u librenms /opt/librenms/validate.php"
echo ""
echo "5. Update the ServerName in /etc/apache2/vhosts.d/librenms.conf"
echo "   to match your domain/hostname"
echo ""
echo "=================================="

# Save credentials to a file for reference
cat > /root/librenms_credentials.txt << EOF
LibreNMS Installation Credentials
==================================
Database Name: ${LIBRENMS_DB}
Database User: ${LIBRENMS_USER}
Database Password: ${LIBRENMS_PASSWORD}

Web Interface: http://${SERVER_IP}/
==================================
EOF

chmod 600 /root/librenms_credentials.txt
echo "Credentials saved to /root/librenms_credentials.txt"
