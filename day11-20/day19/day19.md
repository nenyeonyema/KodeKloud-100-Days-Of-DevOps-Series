1. Install Apache
Log in to App Server 3 and install Apache with dependencies:
`sudo yum install httpd -y`

2. Change Apache Port to 8084
Edit the Apache config to listen on 8084 instead of the default port (80).
`sudo vi /etc/httpd/conf/httpd.conf`

Find:

`Listen 80`


Replace with:

`Listen 8084`
Save & exit

3. Copy Website Files

From jump_host, copy the website backup folders to App Server 3.
```
scp -r /home/thor/official/ <app_server3_user>@<app_server3_ip>:/var/www/html/
scp -r /home/thor/games/ <app_server3_user>@<app_server3_ip>:/var/www/html/
```
Or
If you encountered issues copying the website files due to permission, try this approach 
```
scp -r /home/thor/official banner@stapp03:/tmp/
scp -r /home/thor/games banner@stapp03:/tmp/
```
Then SSH into the remote server
```
ssh banner@stapp03
sudo mv /tmp/official /var/www/html/
sudo mv /tmp/games /var/www/html/

```
On App Server 3, verify:
`ls /var/www/html/`

4. Configure Apache for the Two Sites

Open the Apache config:

`sudo vi /etc/httpd/conf/httpd.conf`

Add aliases to each static site
```
<VirtualHost *:8084>
    DocumentRoot /var/www/html
    Alias /official /var/www/html/official
    <Directory /var/www/html/official>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    Alias /games /var/www/html/games
    <Directory /var/www/html/games>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>

```

5. Start/Enable Apache
```
sudo systemctl enable httpd
sudo systemctl restart httpd
```
6. Test Websites

Run:
```
curl http://localhost:8084/official/
curl http://localhost:8084/games/
```

You should see the respective index.html contents of each site.
