1. Go to the repo
```
cd /usr/src/kodekloudrepos/cluster
```
2. View commit history
Run:

```
git log --oneline --decorate
```
Identify the commit hash of "add data.txt file"
Example: 2223334

3 — Reset branch so ONLY two commits remain
We reset the branch hard to the commit add data.txt file:
```
git reset --hard <commit_hash_of_add_data.txt_file>
# Example
git reset --hard <commit_hash_of_add_data.txt_file>
```

*This means:

* All commits AFTER `add data.txt` file are erased

* Only:

* initial commit

* add data.txt file
  will remain in the history.*

4. Verify history
```
git log --oneline
```
5. Force push to remote
Because you rewrote history, you must force push:
```
git push origin master --force
#Or
git push -f
```

This updates the remote repository so that it matches your cleaned-up local history.


