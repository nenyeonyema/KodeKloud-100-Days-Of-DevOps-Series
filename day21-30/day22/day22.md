### Task 22 — Clone Repository as natasha User

1. Switch to natasha user
(If you're not already logged in as her)

`sudo su - natasha`

2. Create destination directory (if not already exists)

`mkdir -p /usr/src/kodekloudrepos`

3. Clone the Git repo into the directory

`git clone /opt/demo.git /usr/src/kodekloudrepos`

*Important:
Do NOT clone into a subdirectory inside it.
The repo itself must become /usr/src/kodekloudrepos not /usr/src/kodekloudrepos/demo.*

4. Verify

`ls -l /usr/src/kodekloudrepos`

You should see .git folder and files inside.
