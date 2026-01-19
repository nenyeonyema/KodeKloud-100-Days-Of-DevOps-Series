1. SSH into storage server 
`ssh natasha@storage-server`

2. Go to the repository
```
sudo su
cd /usr/src/kodekloudrepos/demo
```


Check status:

`git status`

3. Create a new branch


```
git branch

git checkout -b nautilus
```



4. Copy /tmp/index.html into the repo

`cp /tmp/index.html .`

You can check:

`ls -l index.html`

5. Stage and commit:

```
git add index.html
git commit -m "Add index.html from /tmp"

```
Switch to master branch

`git switch master`

6. Merge and push changes
```
git merge nautilus
git push
```
