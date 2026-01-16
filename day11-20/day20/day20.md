1. Install nginx

On App Server 2 (stapp02):

`sudo yum install -y nginx`

Edit nginx config so it listens on port 8099 and uses /var/www/html as doc root.
File: /etc/nginx/nginx.conf (or better: create a new server block file in /etc/nginx/conf.d/phpapp.conf).

```
server {
    listen 8099;
    server_name localhost;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php-fpm/default.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}

```

2. Install PHP-FPM 8.3
Since RHEL/CentOS default repos don’t have PHP 8.3, enable Remi repo:

```
sudo dnf module enable php:8.3 -y
sudo dnf install -y php php-fpm php-cli php-common php-mysqlnd php-opcache
```

3. Configure PHP-FPM socket
Edit pool config file (usually /etc/php-fpm.d/www.conf):

Ensure PHP-FPM runs as nginx 
Comment out "listen = 127.0.0.1:9000" if present

```
[www]
user = nginx
group = nginx
listen = /var/run/php-fpm/default.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660

```

Create the parent directory:
```
sudo mkdir -p /var/run/php-fpm
sudo chown -R nginx:nginx /var/run/php-fpm
```

Enable and start services
```
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
sudo systemctl enable nginx
sudo systemctl start nginx
```

4. Verify setup

* Check configs:
```
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart php-fpm
```

* From jump host:

```
curl http://stapp02:8099/index.php
curl http://stapp02:8099/info.php
```
