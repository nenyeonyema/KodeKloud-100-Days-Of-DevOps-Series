Task 21: Create a Bare Git Repository on Storage Server

1. SSH into the Storage Server
You should log in as the correct user (usually root or natasha, depending on lab):

`ssh natasha@stdb01`

2. Install Git using yum

`sudo yum install -y git`

After installation confirm:
`git --version`

3. Create the bare Git repository
A bare repo is used for central storage, it must end with .git and has no working directory.

Run:
`sudo git init --bare /opt/beta.git`

Set proper ownership (usually not needed, but safe):
`sudo chown -R $(whoami):$(whoami) /opt/beta.git`

Validate:
`ls -l /opt/beta.git`

