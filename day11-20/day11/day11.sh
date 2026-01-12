#!/bin/bash
# Task 11 - Deploy Java App with Tomcat on App Server 1

# Variables
TOMCAT_PORT=5003
WAR_SOURCE="/tmp/ROOT.war"
WAR_DEST="/var/lib/tomcat/webapps/ROOT.war"
SERVER_XML="/etc/tomcat/server.xml"

echo "[TASK 1] Installing Tomcat..."
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp

echo "[TASK 2] Configuring Tomcat to run on port $TOMCAT_PORT..."
sudo sed -i "s/port=\"8080\"/port=\"$TOMCAT_PORT\"/" $SERVER_XML

echo "[TASK 3] Copying WAR file to Tomcat webapps directory..."
if [ -f "$WAR_SOURCE" ]; then
    sudo cp -f $WAR_SOURCE $WAR_DEST
else
    echo "ERROR: WAR file not found at $WAR_SOURCE"
    exit 1
fi

echo "[TASK 4] Setting correct permissions..."
sudo chown tomcat:tomcat $WAR_DEST

echo "[TASK 5] Enabling and restarting Tomcat service..."
sudo systemctl enable tomcat
sudo systemctl restart tomcat

echo "[TASK 6] Verifying deployment..."
sleep 10
curl -I http://localhost:$TOMCAT_PORT/ 2>/dev/null | head -n 1

if [ $? -eq 0 ]; then
    echo "✅ Deployment successful! Access the app at http://stapp01:$TOMCAT_PORT/"
else
    echo "❌ Deployment failed. Check Tomcat logs."
fi
