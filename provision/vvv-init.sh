#!/usr/bin/env bash
# Provision Bedrock Stable

DOMAIN=`get_primary_host "${VVV_SITE_NAME}".test`
DOMAINS=`get_hosts "${DOMAIN}"`
SITE_TITLE=`get_config_value 'site_title' "${DOMAIN}"`
WP_VERSION=`get_config_value 'wp_version' 'latest'`
WP_TYPE=`get_config_value 'wp_type' "single"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}


# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/nginx-error.log
touch ${VVV_PATH_TO_SITE}/log/nginx-access.log

# Install and configure the latest stable version bedrock
# if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/composer.json" ]]; then
#     echo "Downloading Bedrock..."
#     composer create-project roots/bedrock ${VVV_PATH_TO_SITE}/public_html
#     rm ${VVV_PATH_TO_SITE}/public_html/.env
#     printf $"DB_NAME=${DB_NAME}\nDB_USER=wp\nDB_PASSWORD=wp\n\n# Optional variables\nDB_HOST=localhost\nDB_PREFIX=wp_\n\nWP_ENV=development\nWP_URL=${DOMAIN}\nWP_HOME=http://${DOMAIN}\nWP_SITEURL=http://${DOMAIN}/wp\n\n# Generate your keys here: https://roots.io/salts.html\nAUTH_KEY='generateme'\nSECURE_AUTH_KEY='generateme'\nLOGGED_IN_KEY='generateme'\nNONCE_KEY='generateme'\nAUTH_SALT='generateme'\nSECURE_AUTH_SALT='generateme'\nLOGGED_IN_SALT='generateme'\nNONCE_SALT='generateme'\n\n# Multisite\nMULTISITE_ENABLED=false\nSUBDOMAIN_ENABLED=false\nPATH_CURRENT_SITE=/\n\n# Plugins\nACF_PRO_KEY=\n">${VVV_PATH_TO_SITE}/public_html/.env
# fi


# Nginx Conf and site location
cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf.tmpl" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"

if [ -n "$(type -t is_utility_installed)" ] && [ "$(type -t is_utility_installed)" = function ] && `is_utility_installed core tls-ca`; then
    sed -i "s#{{TLS_CERT}}#ssl_certificate /vagrant/certificates/${VVV_SITE_NAME}/dev.crt;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}#ssl_certificate_key /vagrant/certificates/${VVV_SITE_NAME}/dev.key;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
else
    sed -i "s#{{TLS_CERT}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
fi
