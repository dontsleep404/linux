```bash
sudo su
git clone https://github.com/dontsleep404/linux.git
cd ./linux
chmod 755 ./script.sh
./script.sh
```
## 1. Install LAMP
Wait till it done

Now Restart Server
## 2. Restart server
Start or restart LAMP server
## 3. Stop server
Stop httpd and mysqld service
## 4. Generate SSL
Generate ssl for test domain EX : testssl.com
```
Input Domain (Ex: test.com): testssl.com
Country Name (2 letter code) [US]:
State or Province Name (full name) [NY]:
Locality Name (eg, city) [New York]:
Organization Name (eg, company) [Example, LLC]:
Common Name (e.g. server FQDN or YOUR name) [testssl.com]:
Email Address [test@testssl.com]:
Key : /home/dontsleep/linux/private/testssl.com.key
Cert : /home/dontsleep/linux/certs/testssl.com.cert
```
Now create Virutal Host for testssl.com

## 5. Create Virutal Host

Create virutal host for server
```
Please enter server names (for example: lamp.sh www.lamp.sh): testssl.com
Please enter website root directory (default: /data/www/testssl.com):
Website root directory: /data/www/testssl.com
Please enter Administrator Email address: test@testssl.com
Administrator Email address: test@testssl.com
Do you want to create a database and user with same name? [y/n]: y
Please enter your MySQL root password: 123456
Please enter the database name: php_mysql_crud
Please set the password for user [php_mysql_crud]: 123456
Created virtual host [testssl.com] success
Website root directory is: /data/www/testssl.com
Do you want to add a SSL certificate? [y/n]: y
1. Use your own SSL Certificate and Key
2. Use Let's Encrypt CA to create SSL Certificate and Key
3. Use Buypass.com CA to create SSL Certificate and Key
Please enter 1 or 2 or 3: 1
Please enter full path to SSL Certificate file: /home/dontsleep/linux/certs/testssl.com.crt
Please enter full path to SSL Certificate Key file: /home/dontsleep/linux/private/testssl.com.key
Do you want force redirection from HTTP to HTTPS? [y/n]: y
```

## Now exit script and clone website
EX : https://github.com/FaztWeb/php-mysql-crud
```
git clone https://github.com/FaztWeb/php-mysql-crud ./crud
mv ./crud/* /data/www/testssl.com
```
Now edit db.php
```php
<?php
session_start();

$conn = mysqli_connect(
  'localhost',
  'php_mysql_crud',
  '123456',
  'php_mysql_crud'
) or die(mysqli_error($mysqli));
?>
```
Now import sql file
```
mysql --user=php_mysql_crud --password=123456
mysql> source /data/www/testssl.com/database/script.sql
mysql> exit
```
Now edit host file
```bash
echo "127.0.0.1    testssl.com" | sudo tee -a /etc/hosts
```
Now goto browser and goto https://testssl.com
