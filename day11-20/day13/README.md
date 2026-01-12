## Task 13
We have one of our websites up and running on our Nautilus infrastructure in Stratos DC. Our security team has raised a concern that right now Apache’s port i.e 5002 is open for all since there is no firewall installed on these hosts. So we have decided to add some security layer for these hosts and after discussions and recommendations we have come up with the following requirements:



1. Install iptables and all its dependencies on each app host.


2. Block incoming port 5002 on all apps for everyone except for LBR host.


3. Make sure the rules remain, even after system reboot.






[Linkedin Post with screenshots for task 13 - 15](https://www.linkedin.com/posts/chinenyeonyema_100daysofdevops-devops-linux-activity-7366885347110043649-ANRg?utm_source=share&utm_medium=member_desktop&rcm=ACoAACRhPV4BRvp1TeCVvvCp9cM15324aOo2R3Y)
