# Task 33
> Sarah and Max were working on writting some stories which they have pushed to the repository. Max has recently added some new changes and is trying to push them to the repository but he is facing some issues. Below you can find more details:

> SSH into storage server using user max and password Max_pass123. Under /home/max you will find the story-blog repository. Try to push the changes to the origin repo and fix the issues. The story-index.txt must have titles for all 4 stories. Additionally, there is a typo in The Lion and the Mooose line where Mooose should be Mouse.

> Click on the Gitea UI button on the top bar. You should be able to access the Gitea page. You can login to Gitea server from UI using username sarah and password Sarah_pass123 or username max and password Max_pass123.

> Note: For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.

### TASK 33: Fix git Pull Conflict

1. SSH into Storage Server as Max
```
ssh max@ststor01

```
2. Navigate to the repo
```
cd ~/story-blog

```
3. Try to push and see the error
```
git status
git push

```

You will MOST LIKELY see one rejection errors:

4. FIX: Pull the updates properly

Since Max has changes, you cannot run a normal pull.
Instead, run a rebase pull:
```
git pull --rebase origin master

```
5. Open story-index.txt and fix the required issues
Add titles for ALL 4 stories
Open file:
```
vi story-index.txt
```
Ensure it contains all four story titles. Something like:
```
The Fox and the Grapes
The Tortoise and the Hare
The Lion and the Mouse
The Wolf and the Lamb

```
Fix the typo:
Find:
```
The Lion and the Mooose

```
Change to:
```
The Lion and the Mouse

```
Save and exit (:wq).

6. Add and commit your changes
```
git add story-index.txt
git commit -m "fix story titles and correct mouse typo"

```
7. Push to remote
Now push again:


```
git push origin master
```
8. Login to Gitea Web UI
Use either:

Max 
OR

Sarah 

Check that:

New commit is visible in the commit history
story-index.txt is updated
Typo “Mooose → Mouse” is fixed
All 4 stories appear in the index file
