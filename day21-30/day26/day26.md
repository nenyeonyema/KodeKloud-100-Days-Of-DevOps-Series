1. Switch to root (important!)
`sudo -i`

2. Go to the repository
`cd /usr/src/kodekloudrepos/news`


Check status:

`git status`

3. Add the new remote

You must name it dev_news and point it to:

`/opt/xfusioncorp_news.git`


Run:

`git remote add dev_news /opt/xfusioncorp_news.git`

Confirm:
`git remote -v`

4. Copy /tmp/index.html into the repo

`cp /tmp/index.html .`

You can check:

`ls -l index.html`

5. Commit the file to master
Make sure you are on master:

`git checkout master`

Stage and commit:

```
git add index.html
git commit -m "Add index.html from /tmp"

```
6. Push master branch to the new remote

They want you to push master → dev_news

`git push dev_news master`
