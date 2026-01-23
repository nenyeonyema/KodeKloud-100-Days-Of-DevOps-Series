1. SSH into storage server as Max
```
ssh max@<storage-server-ip>
```

2. Check the cloned repo
```
cd ~
ls -la
```
You should see repo like this `stories/` enter the repo:
```
cd stories
```
List files:
```
ls
```
*You will see:

Sarah’s story

Max’s story

A .git directory*

3. Check commit history

Run:
```
git log --oneline --decorate --graph --all
```

Check:

* Commit author for Sarah’s story
* Commit author for Max’s story
* That Max's branch is story/fox-and-grapes

*You should see Max’s commit and Validate that the author name is Max.*

4 — Max's story is not on master
Confirm:
```
git checkout master
git log --oneline
```
*You should NOT see Max's story here.*
5. Open the Gitea Web UI
Click on the Gitea UI button at the top of your KodeKloud terminal/web interface.

Login with the provided details

6. Create Pull Request (PR)
Go to the repository → Pull Requests → New Pull Request.

Set:

* PR Title: Added fox-and-grapes story

* Source branch: story/fox-and-grapes

* Destination branch: master

Submit the PR.

7. Add Reviewer (tom)
After PR is created:

* Look to the right side panel → Reviewers

* Click “Add reviewer”

* Select tom

This assigns Tom to review your PR.

8 — Review as tom
Logout from Gitea.

Login again:

Username: tom

Password:

Go to:

* Pull Requests
* Select “Added fox-and-grapes story”
* Click Review → Approve

Then click:

**Merge Pull Request**
Once merged, the story is now in master.

9. Confirm Merge (Optional but recommended)
Back on Max’s account or via CLI:
```
git checkout
git pull
ls
```
You should see the fox-and-grapes story in the master branch.

