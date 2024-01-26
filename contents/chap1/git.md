## Code must be Managed: Version Control{#sec:version-control} 

[Open-source](https://en.wikipedia.org/wiki/Open_source) software is software
with source code that anyone can inspect, modify, and enhance. Open source
software are incresingly popular for many reasons, having better control, easier
to train programmers, **better data security**, stability and **collaborative
community**. A crucial part of open-source software development is
**version-control**.

The default tool for doing version-control is **Git**. Git originated because
bitkeeper refused to give linux the free of charge use case. Linus Torvalds
(remember him, the creator of Linux kernel), wrote his own version-control
system.

Git is distributed in the sense that every user's computer has a full copy of
the project. At the failure of one machine, the project is still around.

### Configuring git

Before using, you will need to create a setup file. This can be done with the following few possibilities.
    1.  If you would like the configuration to apply globally, use `/.gitconfig`
    2.  If you would like the configuration to be project (repository) specific
        use `.git/config`
        
Keep in mind that repository specific config file will overwrite the global one. You can always view your current config with 
    `$ git config --list --show-origin`

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

### What is remote?

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


### What is branch?

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


### Publish{#sec:publish}
Now that you have an amazing package, it's time to make it available to the
public. Before that, there is one final task to be done which is to choose a license. 

- GNU's Not Unix! (GNU) (1983 by Richard Stallman)
    
    Its goal is to give computer users freedom and control in their use of their computers and [computing devices](https://en.wikipedia.org/wiki/Computer_hardware) by collaboratively developing and publishing software that gives everyone the rights to freely run the software, copy and distribute it, study it, and modify it. GNU software grants these rights in its [license](https://en.wikipedia.org/wiki/GNU_General_Public_License).
    
    ![](./assets/images/gnu.png)
    
- The problem of GPL Lisense: The GPL and licenses modeled on it impose the restriction that source code must be distributed or made available for all works that are derivatives of the GNU copyrighted code.
    
    Case study: [Free Software fundation v.s. Cisco Systems](https://www.notion.so/Wiki-53dd9dafd57b40f6b253d6605667a472)
    
    Modern Licenses are: [MIT](https://en.wikipedia.org/wiki/MIT_License) and [Apache](https://en.wikipedia.org/wiki/Apache_License).