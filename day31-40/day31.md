---
**Task 31**
The Nautilus application development team was working on a git repository /usr/src/kodekloudrepos/news present on Storage server in Stratos DC. One of the developers stashed some in-progress changes in this repository, but now they want to restore some of the stashed changes. Find below more details to accomplish this task:



Look for the stashed changes under /usr/src/kodekloudrepos/news git repository, and restore the stash with stash@{1} identifier. Further, commit and push your changes to the origin.

---
### TASK 31: Restore stash@{1}, commit it, and push to origin

1. Navigate to the repo
```
cd /usr/src/kodekloudrepos/news
```
2. View all stashes
```
git stash list

```

Confirm that stash@{1} exists.

3. Apply stash@{1}
Use the specific stash, NOT stash pop:
```
git stash apply stash@{1}

```
4. Check restored changes
```
git status
```
You should now see modified files restored by the stash.

Add the files:
```
git add .

```

5. Commit the restored changes
Commit message can be simple:
```
git commit -m "restore stashed changes"

```

6. Push to origin
```
git push origin master
```

