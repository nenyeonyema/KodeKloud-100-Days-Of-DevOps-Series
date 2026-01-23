1. Go to the repository
```
cd /usr/src/kodekloudrepos/game to the repository
```
2. Make the repo safe for git commands (if needed)
Run this in case you see “dubious ownership”:

```
git config --global --add safe.directory /usr/src/kodekloudrepos/games

```
3. Check current commit history

`git log --oneline`

4. Revert the HEAD commit
Run:
```
git revert -n HEAD

```
Then commit it with the required changes
```
git commit -m "revert games"
```

5. Verify the result
```
git log --oneline
```

6. Push the changes
```
git push origin master
```



