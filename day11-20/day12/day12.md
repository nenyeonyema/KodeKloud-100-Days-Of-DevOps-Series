### Step 1: Check if Apache is running

bash
`sudo systemctl status httpd`

**If inactive/dead, start it:**

```
sudo systemctl start httpd
sudo systemctl enable httpd
```
### Step 2: Verify Apache is listening on port 5004
Run:

`sudo netstat -tulnp | grep httpd`
**or**
`sudo ss -tulnp | grep 5004`

If you don’t see Apache bound to :5004, then check Apache config.

Open config file (usually /etc/httpd/conf/httpd.conf or /etc/httpd/conf.d/*.conf) and look for:

`Listen 5004`


If it says Listen 80, change it to:

`Listen 5004`


Then reload:

`sudo systemctl restart httpd`

### Step 3: Check firewall
`sudo firewall-cmd --list-all`


If port 5004/tcp is not allowed, open it:

```
sudo firewall-cmd --permanent --add-port=5004/tcp
sudo firewall-cmd --reload
```

### Step 4: Test from app server
`curl http://localhost:5004`


If you get HTML, Apache is serving correctly.

### Step 5: Test from jump host

On jump host, run:

`curl http://stapp01:5004`

