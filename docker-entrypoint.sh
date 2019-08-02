#!/bin/bash
set -e

cd /var/www/html

sed_escape_lhs() {
  echo "$@" | sed 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
  echo "$@" | sed 's/[\/&]/\\&/g'
}
php_escape() {
  php -r 'var_export(('$2') $argv[1]);' "$1"
}
set_config() {
  key="$1"
  value="$2"
  var_type="${3:-string}"
  start="(['\"])$(sed_escape_lhs "$key")\2\s*,"
  end="\);"
  if [ "${key:0:1}" = '$' ]; then
    start="^(\s*)$(sed_escape_lhs "$key")\s*="
    end=";"
  fi
  sed -ri "s/($start\s*).*($end)$/\1$(sed_escape_rhs "$(php_escape "$value" "$var_type")")\3/" wp-config.php
}

set_config 'DB_HOST' "$RDS_HOSTNAME:$RDS_PORT"
set_config 'DB_USER' "$RDS_USERNAME"
set_config 'DB_PASSWORD' "$RDS_PASSWORD"
set_config 'DB_NAME' "$RDS_DB_NAME"

# allow any of these "Authentication Unique Keys and Salts." to be specified via
# environment variables with a "WORDPRESS_" prefix (ie, "WORDPRESS_AUTH_KEY")
UNIQUES=(
  AUTH_KEY
  SECURE_AUTH_KEY
  LOGGED_IN_KEY
  NONCE_KEY
  AUTH_SALT
  SECURE_AUTH_SALT
  LOGGED_IN_SALT
  NONCE_SALT
)
for unique in "${UNIQUES[@]}"; do
  eval unique_value=\$WORDPRESS_$unique
  if [ "$unique_value" ]; then
    set_config "$unique" "$unique_value"
  else
    # if not specified, let's generate a random value
    current_set="$(sed -rn "s/define\((([\'\"])$unique\2\s*,\s*)(['\"])(.*)\3\);/\4/p" wp-config.php)"
    if [ "$current_set" = 'put your unique phrase here' ]; then
      set_config "$unique" "$(head -c1M /dev/urandom | sha1sum | cut -d' ' -f1)"
    fi
  fi
done

php-fpm7.2

exec "$@"
