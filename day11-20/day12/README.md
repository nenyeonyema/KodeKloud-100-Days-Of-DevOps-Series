Task 12: Our monitoring tool has reported an issue in Stratos Datacenter. One of our app servers has an issue, as its Apache service is not reachable on port 5004 (which is the Apache port). The service itself could be down, the firewall could be at fault, or something else could be causing the issue.



Use tools like telnet, netstat, etc. to find and fix the issue. Also make sure Apache is reachable from the jump host without compromising any security settings.

Once fixed, you can test the same using command curl http://stapp01:5004 command from jump host.

[Linkedin Post with screenshots about this task](https://www.linkedin.com/posts/chinenyeonyema_kodekloud-engineer-real-project-tasks-on-activity-7366147607154380800-HLQI?utm_source=share&utm_medium=member_desktop&rcm=ACoAACRhPV4BRvp1TeCVvvCp9cM15324aOo2R3Y)
