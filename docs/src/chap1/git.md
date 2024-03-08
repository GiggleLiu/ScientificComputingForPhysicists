# Maintainability - Version Control

Maintaining a software project is not easy, especially when it comes to multiple developers working on the same piece of code. When adding a new feature to the project, maintainers may encounter the following problems:

- Multiple developers modify the same file at the same time, works can not be merged easily.
- New code breaks an existing feature, downstream users are affected.

The solution to the above problems is **version-control**. Among all version control software, **git** is the most popular one.

## Install git
In Ubuntu (or WSL), you can install git with the following command:
```bash
sudo apt-get install git
```
In MacOS, you can install git with the following command:
```bash
brew install git
```

Then you should configure your git with your name and email:
```bash
git config --global user.name "Your Name"
git config --global user.email "xxx@example.com"
```

## Create a git repository

A git repository, also known as a repo, is basically a directory where your project lives and git keeps track of your file's history. To get started, you start with a terminal and type

```bash
cd path/to/working/directory
git init
echo "Hello, World" > README.md
git add -A
git commit -m 'this is my initial commit'
git status
```
- Line 1: changes the directory to the working directory, which can be either an existing directory or a new directory.
- Line 2: initializes a git repository in the working directory. A `.git` directory is created in the working directory, which contains all the necessary metadata for the repo.
- Line 3: creates a file `README.md` with the content `Hello, World`. The file `README.md` is a **markdown** file, which is a lightweight markup language with plain-text-formatting syntax. You can learn more about markdown from the [markdown tutorial](https://www.markdowntutorial.com/). This line can be omitted if the working directory already contains files.
- Line 4: line add files to the **staging area** (area that caches changes that to be committed).
- Line 5: commits the changes to the repository, which will create a **snapshot** of your current work.
- Line 6: shows the status of the working directory, staging area, and repository. If the above commands are executed correctly, the output should be `nothing to commit, working tree clean`.

## Track the changes - checkout, diff, log
**Git** enables developers to track changes in their codebase. Continuing the previous example, we can analyze the repository with the following commands:

```bash
echo "Bye Bye, World" > README.md
git diff
git add -A
git commit -m 'a second commit'
git log
git checkout HEAD~1
git checkout main
```

- Line 1: makes changes to the file `README.md`.
- Line 2: shows the changes made to the file `README.md`.
- Line 3-4: adds the changes to the staging area and commits the changes to the repository.
- Line 5: shows the history of commits. The output should be something like this:
```
commit 02cd535b6d78fca1713784c61eec86e67ce9010c (HEAD -> main)
Author: GiggleLiu <cacate0129@gmail.com>
Date:   Mon Feb 5 14:34:20 2024 +0800

    a second commit

commit 570e390759617a7021b0e069a3fbe612841b3e50
Author: GiggleLiu <cacate0129@gmail.com>
Date:   Mon Feb 5 14:23:41 2024 +0800

    this is my initial commit
```
- Line 6: Checkout the previous snapshot. Note `HEAD` is your current snapshot and `HEAD~n` is the `n`th snapshot counting back from the current snapshot.
- Line 7: Return to the `main` **branch**, which points to the latest snapshot. We will discuss more about **branch** later in this tutorial.

You can use `git reset` to reset the current HEAD to the specified snapshot, which can be useful when you committed something bad by accident.

## Work on cloud - remotes

A server to store git repository, or **remote** in git terminology, is required for the collaboration purpose. Remote repositories can be hosted on git hosting services such as [GitHub](http://github.com) and [GitLab](http://gitlab.com).

After creating a new empty repository (no README files) on a git hosting service ([Tutorial: How to create a new GitHub repo](https://docs.github.com/en/get-started/quickstart/create-a-repo)), a URL for cloning the repo will show up, which that usually starts with `git` or `https`. Let us denote this URL as `<url>` and continue the previous example:

```bash
git remote add origin <url>
git remote -v
git push origin main
```

- Line 1: add a remote repository, where `origin` is a tag for the added remote.
- Line 2: shows the URL of all remotes, including the `origin` remote we just added.
- Line 3: push commits to the `main` branch of the remote repository `origin`. This command sometimes could fail due to another commit pushed to the remote earlier, where the commit may from another machine or another person. To resolve the issue, you can use `git pull origin main` to fetch the latest snapshot on the remote. `git pull` may also fail, because the remote commit may be incompatible with the local commit, e.g. the same file has been changed. In this worst case, you need to merge two commits manually (link).

## Develop features safely - branches

So far, we worked with a single branch `main`. A **branch** in git is a lightweight pointer to a specific commit.
Working on a single branch is dangerous due to the following reasons:
- *No usable code.* Developers usually develop features based on the current `main` branch, so the `main` branch is expected to always usable. However, working on a single branch can easily break this rule.
- *Hard to resolve conflicts.* when multiple developers modify the same file at the same time, works can not be merged easily. Multiple branches can make the feature development process independent of each other, which can avoid conflicts.
- *Hard to discard a feature.* For some experimental features, you may want to discard it after testing. A commit on the main branch can not be easily reverted.

Understanding the branches is extremely useful when, multiple developers are working on different features.
```bash
git checkout -b me/feature
echo "Hello, World - Version 2" > README.md
git add -A
git commit -m 'this is my feature'
git push origin me/feature
```
- Line 1: create and switch to the new branch `me/feature`. Here, we use the branch name `me/feature` to indicate that this branch is for the feature developed by `me`, which is a matter of convention.
- Line 2-5: makes some changes to the file `README.md` and commits the changes to the repository. Finally, the changes are pushed to the remote repository `origin`. The remote branch `me/feature` is created automatically.

While developing a feature, you or another developer may want to develop another feature based on the current `main` branch. You can create another branch `other/feature` and develop the feature there.

```bash
git checkout main
git checkout -b other/feature
echo "Bye Bye, World - Version 2" > feature.md
git add -A
git commit -m 'this is another feature'
git push origin other/feature
```

In the above example, we created a new branch `other/feature` based on the `main` branch, and made some changes to the file `feature.md`.

Finally, when the feature is ready, you can merge the feature branch to the main branch.

```bash
git checkout main
git merge me/feature
git push origin main
```

## Working with others - issues and pull requests

When working with others, you may want to propose changes to a repository and discuss them with others. This is where **issues** and **pull requests** come in. Issues and pull requests are features of git hosting services like GitHub and GitLab.
- **Issue** is relatively simple, it is a way to report a bug or request a feature.
- **Pull request** (resource: [how to create a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)) is a way to propose changes to a repository and discuss them with others. It is also a way to merge code from source branch to target branch. The source branch can be a branch in the same repository or a branch in a **forked repository** - a copy of the repository in your account. Forking a repository is needed when you want to propose changes to a repository that you do not have write access to.

!!! note "Should I make a pull requests or push directly to main branch?"
    To update the main branch, one should use pull requests as much as possible, even if you have write access to the repository. It is a good practice to discuss the changes with others before merging them to the main branch. A pull request also makes the changes more traceable, which is useful when you want to revert the changes.


## Git cheat sheet

It is not possible to cover all the feature of git. We will list a few useful commands and resources for git learning.

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

### Resources
* [The Official GitHub Training Manual](https://githubtraining.github.io/training-manual/book.pdf)
* MIT online course [missing semester](https://missing.csail.mit.edu/2020/).
