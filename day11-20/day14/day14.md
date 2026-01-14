###Steps
*1 Check all App Servers (stapp01, stapp02, stapp03):

SSH into each server as tony, steve, or banner.

Verify Apache status:
`sudo systemctl status httpd`

If it’s not running, check logs:

```
sudo journalctl -xe
sudo tail -n 50 /var/log/httpd/error_log
```

*2 Confirm the port configuration:

Open the Apache config:

`sudo cat /etc/httpd/conf/httpd.conf | grep -i listen`

Ensure it has:

`Listen 8089`

If it is listening on the wrong port(eg. 80, 8080), update it:
`sudo sed -i 's/^Listen .*/Listen 8089/' /etc/httpd/conf/httpd.conf`

*3 Restart Apache to apply changes:

```
sudo systemctl restart httpd
sudo systemctl enable httpd
```
*4 Check if the service is running properly on 8089:

`sudo ss -tulpn | grep httpd`


Or:

`curl http://localhost:8089`
