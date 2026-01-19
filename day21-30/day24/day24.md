Create a New Git Branch (xfusioncorp_games) from master

1. SSH into the Storage Server
From the jump host, connect to the Storage Server.

`ssh natasha@ststor01`

2. Go to the repository directory
`cd /usr/src/kodekloudrepos/games`


Confirm you’re in a git repo:

`git status`

You should see:
```
On branch master
nothing to commit, working tree clean
```

3. Pull the latest updates (just to confirm)

`git pull`
(If it says "Already up to date", that's fine.)

4. Create a new branch from master
`git checkout -b xfusioncorp_games`

5. Confirm the branch was created

`git branch`
