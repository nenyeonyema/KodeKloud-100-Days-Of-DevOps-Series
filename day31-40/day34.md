# Task 34
> The Nautilus application development team was working on a git repository /opt/demo.git which is cloned under /usr/src/kodekloudrepos directory present on Storage server in Stratos DC.
> The team want to setup a hook on this repository, please find below more details:

> Merge the feature branch into the master branch`, but before pushing your changes complete below point.

> Create a post-update hook in this git repository so that whenever any changes are pushed to the master branch, it creates a release tag with name release-2023-06-15, where 2023-06-15 is supposed to be the current date. For example if today is 20th June, 2023 then the release tag must be release-2023-06-20. 
> Make sure you test the hook at least once and create a release tag for today's release.

> Finally remember to push your changes.
> Note: Perform this task using the natasha user, and ensure the repository or existing directory permissions are not altered.

### TASK 34: 

1. Switch to the natasha user
If you're not already natasha:
```
sudo su - natasha

```
2. Navigate to the repo
```
cd /usr/src/kodekloudrepos/demo
```

Check branches
```
git branch
```
Ensure master and feature exists

3. Merge feature → master

```
git checkout master
git merge feature

```
Resolve conflicts if any, then continue:
```
git add .
git commit -m "Merged feature branch into master"
```
4. Create the post-update hook
Git hooks live in:
```
.git/hooks/
```
Create the hook:
```
nano .git/hooks/post-update
```
Paste this script inside 
```
#!/bin/bash

# Ensure the master branch was updated
if git show-ref --verify --quiet refs/heads/master; then
    TAG="release-$(date +%F)"
    git tag -f "$TAG"   # Lightweight tag
fi
```
Save and exit.

Make it executable:
```
chmod +x .git/hooks/post-update
```

5. Test the hook locally
Make any small commit on master to trigger post-update when pushing:

```
echo "test release $(date)" >> testfile.txt
git add testfile.txt
git commit -m "Trigger release tag creation"
```
Now push to master (this triggers the hook):

```
git push origin master
```
6. Verify the tag was created
```
git tag
```
You should see: `release-year-month-day`

Push the tag too (important!):
```
git push origin --tags
```

