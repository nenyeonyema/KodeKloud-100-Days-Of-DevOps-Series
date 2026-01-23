1. Go to the repo
SSH into Storage server → switch to /usr/src/kodekloudrepos/news

```
cd /usr/src/kodekloudrepos/news
```
2. Switch to master branch
```
git checkout master
```

3. Find the commit hash with the message “Update info.txt”
```
git log feature --oneline
```
4. Cherry-pick ONLY that commit into master
```
git cherry-pick abc1234
```

*Be sure to use the hash from your system.

If no conflicts → Git will apply the commit successfully.*

5. Push to origin
```
git push origin master
```

