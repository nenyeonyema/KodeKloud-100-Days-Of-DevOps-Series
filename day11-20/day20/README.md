### Task 20
The Nautilus application development team is planning to launch a new PHP-based application, which they want to deploy on Nautilus infra in Stratos DC. The development team had a meeting with the production support team and they have shared some requirements regarding the infrastructure. Below are the requirements they shared:



a. Install nginx on app server 2 , configure it to use port 8099 and its document root should be /var/www/html.


b. Install php-fpm version 8.3 on app server 2, it must use the unix socket /var/run/php-fpm/default.sock (create the parent directories if don't exist).


c. Configure php-fpm and nginx to work together.


d. Once configured correctly, you can test the website using curl http://stapp02:8099/index.php command from jump host.

NOTE: We have copied two files, index.php and info.php, under /var/www/html as part of the PHP-based application setup. Please do not modify these files.





