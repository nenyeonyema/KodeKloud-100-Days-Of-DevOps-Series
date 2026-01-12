### Step 1: Install iptables

On each app host (e.g., stapp01, stapp02, stapp03):

`sudo yum install -y iptables iptables-services`

### Step 2: Add Firewall Rules

Assume the LBR host IP is something like 172.16.238.5 (adjust to the actual IP).

Allow LBR access to port 5002:

`sudo iptables -A INPUT -p tcp -s 172.16.238.5 --dport 5002 -j ACCEPT`


Block everyone else on port 5002:
`sudo iptables -A INPUT -p tcp --dport 5002 -j DROP`

Allow established connections and loopback:

```
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
```
### Step 3: Save and Persist Rules

```
sudo service iptables save
sudo systemctl enable iptables
sudo systemctl start iptables
```

You can confirm rules:
`sudo iptables -L -n -v`
