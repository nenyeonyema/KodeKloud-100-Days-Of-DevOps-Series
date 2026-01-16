### Steps
1 : Install Nginx on the LBR server
`sudo yum install -y nginx     # CentOS/RHEL`
or
`sudo apt-get install -y nginx  # Ubuntu/Debian`

Enable and start service:
```
sudo systemctl enable nginx
sudo systemctl start nginx
```
2 : Configure Nginx as Load Balancer

We are told to edit only the main config file /etc/nginx/nginx.conf.

Open it:

`sudo vi /etc/nginx/nginx.conf`

Inside the http { ... } block, add the upstream definition for all App Servers (assuming they run Apache on port 8080):
```
http {
    upstream app_servers {
        server stapp01:8080;
        server stapp02:8080;
        server stapp03:8080;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://app_servers;
        }
    }
}
```
Don’t remove existing http block contents, just modify carefully.

3 : Verify Apache is running on App Servers
On each app server (stapp01, stapp02, stapp03):
```
systemctl status httpd    # CentOS/RHEL

```

Ìf not running:
`sudo systemctl start httpd`
4: Test the Load Balancer

Back on the LBR server:

`curl http://localhost/`

Òr test from the jump host
`curl -I http://<LBR-IP>/`

