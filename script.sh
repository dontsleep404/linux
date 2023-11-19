#!/bin/bash

install_lampp(){
    base_dir=$(pwd)
    echo "Installing..."
    apt-get -y install wget git
    git clone https://github.com/teddysun/lamp.git
    chmod 755 ./lamp/*.sh
    ./lamp/lamp.sh --apache_option 1 --apache_modules mod_wsgi,mod_security --db_option 1 --db_root_pwd 123456 --php_option 1 --php_extensions apcu,ioncube,imagick,redis,mongodb,libsodium,swoole --db_manage_modules phpmyadmin,adminer --kodexplorer_option 1
}

restart_server(){
    echo "Restart Server..."
    service httpd restart
    service mysqld restart
    echo "Restart success"
}

stop_server(){
    echo "Stop Server..."            
    service httpd stop
    service mysqld stop
    echo "Success"
}

generate_ssl(){
    echo "Generate SSL..."
    base_dir=$(pwd)
    mkdir -p ./private/
    mkdir -p ./certs/
    read -p "Input Domain (Ex: test.com): " domain
    ssl $domain
    echo "Key : ${base_dir}/private/${domain}.key"
    echo "Cert : ${base_dir}/certs/${domain}.crt"
    echo "Success"
}

ssl(){
    domain=$1
    echo "Domain is $1"
    openssl req -new -sha256 -newkey rsa:2048 -nodes -keyout ./private/${domain}.key -x509 -days 3650 -out ./certs/${domain}.crt \
    -config <(cat <<EOF
[ req ]
default_bits        = 2048
default_keyfile     = server-key.pem
distinguished_name  = subject
req_extensions      = req_ext
x509_extensions     = x509_ext
string_mask         = utf8only

[ subject ]
countryName                 = Country Name (2 letter code)
countryName_default         = US
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = NY
localityName                = Locality Name (eg, city)
localityName_default        = New York
organizationName            = Organization Name (eg, company)
organizationName_default    = Example, LLC
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_default          = $domain
emailAddress                = Email Address
emailAddress_default        = test@$domain

[ x509_ext ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment
subjectAltName         = @alternate_names
nsComment              = "OpenSSL Generated Certificate"

[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature, keyEncipherment
subjectAltName       = @alternate_names
nsComment            = "OpenSSL Generated Certificate"

[ alternate_names ]
DNS.1 = $domain
EOF
)
}
add_virtual_host(){
    echo "Add virutal host"
    bash ./lamp/conf/lamp add
}
test(){
    base_dir=$(pwd)
    read -p "Input Domain (Ex: test.com): " domain
    ssl $domain
    cert_path=${base_dir}/certs/${domain}.crt
    key_path=${base_dir}/private/${domain}.key
    wed_dir=/data/www/${domain}
    chmod 777 ${wed_dir}
    bash ./lamp/conf/lamp add <<EOF
$domain
${wed_dir}
test@$domain
n
y
1
$cert_path
$key_path
y
EOF
    echo "127.0.0.1    ${domain}" | sudo tee -a /etc/hosts
    rm -rf ./crud
    git clone https://github.com/FaztWeb/php-mysql-crud ./crud
    mv ./crud/* ${wed_dir}
    rm -rf ./crud
    chmod 777 ${wed_dir}/db.php
    cat <<EOL > ${wed_dir}/db.php
<?php
session_start();
\$conn = mysqli_connect(
  'localhost',
  'root',
  '123456',
  'php_mysql_crud'
) or die(mysqli_error(\$mysqli));
?>
EOL
    mysql -u root -p123456 < ${wed_dir}/database/script.sql
}
while true; do
    clear
    echo "===== MENU ====="
    echo "1. Install LAMP"
    echo "2. Restart server"
    echo "3. Stop Server"
    echo "4. Generate SSL"
    echo "5. Create Virutal Host"
    echo "6. Create Test SSL Website"
    echo "7. Exit"
    echo "================"
    read -p "Nhập lựa chọn của bạn (1-6): " choice

    case $choice in
        1)
            install_lampp
            ;;
        2)
            restart_server
            ;;
        3)
            stop_server
            ;;
        4)
            generate_ssl
            ;;
        5)
            add_virtual_host
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        6)
            test
            ;;
        *)
            echo "Lựa chọn không hợp lệ. Hãy chọn từ 1 đến 6."
            ;;
    esac

    read -p "Nhấn Enter để tiếp tục..."
done
