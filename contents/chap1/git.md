## Code MUST be Maintained: Version Control{#sec:version-control} 

Maintaining a software project is not easy. You may
encounter the following problems:

- New code breaks an existing feature
- Conflicts between two changes
- No working code!
- Bug fixes at a wrong version
- Code lost

A crucial part of maintaining an open-source software is **version-control**. In the following, we will introduce the best tool for doing version-control: **Git**.

### What is a repo?

A repository, also known as a repo, is basically a directory where your project
lives and git keeps track of your file's history. 

- You start with a working directory, then use `git init` to make it a git repository.
- You can use `git add` to add files to the staging area, and use `git commit` to commit the changes to the repository.
- You can use `git checkout` to switch between commits.
- You can use `git diff` to see the changes between commits.
- You can use `git reset` to reset the current HEAD to the specified state.
- You can use `git status` to see the status of the working directory, staging area, and repository.
- You can use `git log` to see the history of commits.

### Working with remote repositories

Now that you have configuration all setup, we will get you familiarized with a
few concepts. In Git terminology, **Remote** refers to a repository that is
located on a server or another computer, rather than the user's local machine.
It's a version of the repository that is used by teams to collaborate on a
project. Remote repositories can be accessed and manipulated through Git
commands, allowing users to push changes or fetch changes made by others. Remote
repositories can be hosted on Git hosting services like GitHub, GitLab, or
Bitbucket, or set up on a personal server. Multiple users can access and modify
the same remote repository, making it easy for teams to work on a project
together.

- You can use `git remote add <remote-name> <url>` to add a remote repository.
- You can use `git push <remote-name> <branch>` to push commits to a remote repository.
- You can use `git pull <remote-name> <branch>` to fetch from and integrate with another repo or a local branch.


### Developing a feature safely

A branch in Git is a lightweight pointer to a specific commit. It allows
developers to work on new features or make changes to the codebase without
affecting the main codebase. Branches are created and can be switched between
easily, and changes made in one branch do not affect other branches.

To create a new branch in Git, you can use the command `git branch
<branch_name>`. This creates a new branch but does not switch to it, so you will
be working in the same branch until you use the command `git checkout
<branch_name>` to switch to the new branch. Alternatively, you can use the
command `git checkout -b <branch_name>` to create and switch to the new branch
at the same time.

To end a branch, you can use the command `git branch -d <branch_name>`. This
deletes the specified branch, but only if it has been fully merged into the main
branch. If you want to delete a branch whether it has been fully merged or not,
you can use the command `git branch -D <branch_name>`. It's important to
note that once a branch has been deleted, you cannot restore its commit history.

### Example Workflow

Here are two example workflows managing your project with git.

Example 1: develop a new feature
![](./assets/images/newfeature.png)
<!-- ```mermaid -->
<!-- graph LR; -->
<!-- A[main] --- MID[ ]; -->
<!-- MID ---|always usable| MID2[ ]; -->
<!-- MID2 -\->B[main*]; -->
<!-- MID -\->|checkout| D[feature]; -->
<!-- D -\->|update & commit| D2[feature*]; -->
<!-- D2 -\->|merge| MID2; -->
<!-- style MID height:0px, width:0px; -->
<!-- style MID2 height:0px, width:0px; -->
<!-- ``` -->

Example 2: develop two features
![](./assets/images/twofeatures.png)
<!-- ```mermaid -->
<!-- graph LR; -->
<!-- A[main] --- MID0[ ]; -->
<!-- MID0 --- MID1[ ]; -->
<!-- MID1 --- MID2[ ]; -->
<!-- MID2 --- MID3[ ]; -->
<!-- MID3 --- END[main*]; -->
<!-- MID0 -\->|checkout| C[feature1]; -->
<!-- MID1 -\->|checkout| D[feature2]; -->
<!-- C --\->|merge| MID2 -->
<!-- D -.->|merge?| MID3 -->
<!-- style MID0 height:0px, width:0px; -->
<!-- style MID1 height:0px, width:0px; -->
<!-- style MID2 height:0px, width:0px; -->
<!-- style MID3 height:0px, width:0px; -->
<!-- ``` -->

### Cheatsheet and Resources for Git and Github

It is not possible to cover all of the feature of git. We will list a few useful
commands and resources for git learning.

```
# global config
git config  # Get and set repository or global options

# initialize a repo
git init    # Create an empty Git repo or reinitialize an existing one
git clone   # Clone repository into new directory

# info
git status  # Show the working tree status
git log     # Show commit logs
git diff    # Show changes between commits, commit and working tree, etc

# work on a branch
git add     # Add file contents to the index
git rm      # Remove files from the working tree and from the index
git commit  # Record changes to the repository
git reset   # Reset current HEAD to the specified state

# branch manipulation
git checkout # Switch branches or restore working tree files
git branch  # List, create, or delete branches
git merge   # Join two or more development histories together

# remote synchronization
git remote  # Manage set of tracked repositories
git pull  # Fetch from and integrate with another repo or a local branch
git fetch   # Download objects and refs from another repository
git push    # Update remote refs along with associated objects
```

A more detailed introduction could be found in this [lecture](https://missing.csail.mit.edu/2020/version-control/).

### Resources
* [Learn Bash Shell](https://www.learnshell.org/)
* [Learn Git](https://learngitbranching.js.org/)
* [Github Manual](https://githubtraining.github.io/training-manual/book.pdf)
* [How to create a new github repo](https://docs.github.com/en/get-started/quickstart/create-a-repo)
* [How to create a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)
* [Markdown Tutorial](https://www.markdowntutorial.com/)
* MIT online course [missing semester](https://missing.csail.mit.edu/2020/).
* [Learn Git with Game](https://learngitbranching.js.org/?locale=zh_CN)
* [Command Visualization](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)
* [Git Panic](https://ohshitgit.com/)