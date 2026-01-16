1. Install httpd, PHP, and dependencies on all app hosts
On each App Server (stapp01, stapp02, stapp03):

Install Apache, PHP, and common PHP extensions
`sudo yum install -y httpd php php-mysqlnd php-fpm php-gd php-xml php-mbstring`
Enable and start Apache:
```
sudo systemctl enable httpd
sudo systemctl start httpd

```
2. Apache should serve on port 6300
By default, Apache listens on port 80. You must change it:

`sudo vi /etc/httpd/conf/httpd.conf`
Find:
`Listen 80`

Change to:
`Listen 6300`

Also update the <VirtualHost> section from :80 → :6300.

Then restart Apache:
`sudo systemctl restart httpd`

Verify:
`sudo ss -tulnp | grep 6300`

3. Install/Configure MariaDB on DB Server
On stdb01 (DB Server):

```
sudo yum install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
```
4. Create database and user
Log into MariaDB:
`mysql -u root`

Run SQL commands
```
CREATE DATABASE kodekloud_db4;
CREATE USER 'kodekloud_rin'@'%' IDENTIFIED BY 'BruCStnMT5';
GRANT ALL PRIVILEGES ON kodekloud_db4.* TO 'kodekloud_rin'@'%';
FLUSH PRIVILEGES;
```
This ensures the user has full rights.

Also edit MariaDB config to allow remote connections (so apps can connect):
`sudo vi /etc/my.cnf`
Add or modify:
```
[mysqld]
bind-address=0.0.0.0
```
Restart DB
`sudo systemctl restart mariadb`
Open port 3306 in firewall if needed:
```
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

5. Verify website via LBR
The shared directory /var/www/html is already mounted, so your app servers share the same code.

Create a simple PHP file to test DB connection:

`sudo vi /var/www/html/index.php`
Add this to the file
```
<?php
$servername = "stdb01";
$username = "kodekloud_rin";
$password = "BruCStnMT5";
$dbname = "kodekloud_db4";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "App is able to connect to the database using user kodekloud_rin";
$conn->close();
?>

```
