### Steps
1. Install nginx
`sudo yum install -y nginx    # if CentOS/RHEL`
# or
`sudo apt-get update && sudo apt-get install -y nginx`

Enable and start the service:

```
sudo systemctl enable nginx
sudo systemctl start nginx
```

2. Move SSL Certificate & Key

Move the provided files to the standard SSL directory (e.g. /etc/nginx/ssl):
```
sudo mkdir -p /etc/nginx/ssl
sudo mv /tmp/nautilus.crt /etc/nginx/ssl/
sudo mv /tmp/nautilus.key /etc/nginx/ssl/
sudo chmod 600 /etc/nginx/ssl/nautilus.*
```

3. Configure Nginx for SSL

Edit the nginx config file (usually /etc/nginx/nginx.conf or create a new server block under /etc/nginx/conf.d/ssl.conf):
```
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate     /etc/nginx/ssl/nautilus.crt;
    ssl_certificate_key /etc/nginx/ssl/nautilus.key;

    root /usr/share/nginx/html;
    index index.html;
}
```
Make sure to disable the default port 80 block if it conflicts, or leave it if you want HTTP → HTTPS redirect.

Test configuration:

`sudo nginx -t`

Reload nginx:

`sudo systemctl restart nginx`

4. Create index.html
`echo "Welcome!" | sudo tee /usr/share/nginx/html/index.html`

5. Test from Jump Host
`curl -Ik https://stapp02/`

You should see output like:

```
HTTP/1.1 200 OK
Server: nginx/...
```
