# Purpose

-   Setup environments
-   Help find solution to your coding problems
-   &#x2026;


# Git


## Basics


### Before Starting: Configuring git

-   Configs
    1.  Global use `/.gitconfig`
    2.  Repo specific use `.git/config`
    3.  Repo specific config file will overwrite the global one
-   How to view your current config
    `$ git config --list --show-origin`
-   Config editor
    `$ git config --global core.editor emacs`


### Git-Basics-Undoing-Things:

-   Introduction to undoing changes in Git
-   Three basic ways to undo changes in Git:
    -   `git reset`
    -   `git revert`
    -   `git checkout`
-   `git commit --ammend`  is your pal for fixing a commit not pushed
-   `git reset HEAD <file>` – Unstage a staged file
-   `git checkout -- <file>` – Discard changes in a file since the last commit
-   `git revert HEAD` – Create a new commit that undoes the changes made in the
    previous commit
-   `git push --force origin <branch>` – Force push changes to a remote branch
    that has already been pushed with unwanted changes.

-   [Reference](https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things#_undoing)


### What is remote?

Remote on Git refers to a repository that is located on a server or another
computer, rather than the user&rsquo;s local machine. It&rsquo;s a version of the repository
that is used by teams to collaborate on a project. Remote repositories can be
accessed and manipulated through Git commands, allowing users to push changes or
fetch changes made by others. Remote repositories can be hosted on Git hosting
services like GitHub, GitLab, or Bitbucket, or set up on a personal server.
Multiple users can access and modify the same remote repository, making it easy
for teams to work on a project together.


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
you can use the command `git branch -D <branch_name>`. It&rsquo;s important to note
that once a branch has been deleted, you cannot restore its commit history.


## Resources

-   [Visualization of Commands](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)
-   <https://ohshitgit.com/>
-   <https://learngitbranching.js.org/?locale=zh_CN>
-   [Missing semester video](https://missing.csail.mit.edu/2020/version-control/)
-   <https://git-scm.com/book/en/v2>


# Julia Package Management

-   This section is really well presented by Prof Liu at [here](https://github.com/exAClior/CodingClub/blob/main/julia-packages/README.md) and [here](https://github.com/exAClior/CodingClub/blob/main/julia/2.first-package.md).
-   Ask me anything and let&rsquo;s do a quick demo.


# Shell Tools


## Shells

Shell, zsh and bash are all command-line interface (CLI) interpreters used in
Unix-like operating systems.

-   Shell is the simplest and most basic interpreter. Its primary function is to
    provide a command-line interface to the system. It can execute scripts, launch
    programs, manage files and directories, and perform basic system
    administrative tasks.

-   Bash (Bourne-Again SHell) is the default shell on most Linux distributions. It
    is backward-compatible with the original Bourne shell and includes many
    additional features, such as command-line editing, job control, and shell
    scripting capabilities. Bash is widely used as it is both easy to use and has
    a large user community, resulting in a plethora of available resources
    (tutorials, scripts, etc.) online.

-   Zsh (Z shell) is an extended version of the shell, with a more powerful
    command-line editing and completion system. It includes features like spelling
    correction and tab-completion, and it also supports plugins and themes. Zsh is
    commonly used by power users who require more productivity and efficiency from
    their command-line interface.


## Path Variable

On Linux, the PATH variable is an environment variable that contains a list of
directories that the shell searches for executable files. When a user enters a
command in the shell, the shell looks for the executable file in each directory
listed in the PATH variable, in the order they are listed. The PATH variable can
be modified to add or remove directories, and it can also be set on a per-user
or system-wide basis. The PATH variable is important because it allows users to
easily run programs without having to specify the full path to the executable
file each time.


## File Permission

In Linux, file permissions determine who can access, edit, and execute files and
directories. Each file and directory has three permission settings: owner,
group, and other. The owner is the user who created the file or directory, the
group is a set of users with specific permissions, and other is anyone else who
has permission to access the file or directory. Each permission setting can have
three levels of access: read, write, and execute. Read permission allows the
user to view the contents of the file or directory, write permission allows the
user to edit or delete the file or directory, and execute permission allows the
user to run the file or access the directory. File and directory permissions can
be changed using the chmod command in Linux.


## Common Shell Commands

1.  `cd` - Change directory
2.  `ls` - List directory contents
3.  `mv` - Move or rename files or directories
4.  `cp` - Copy files or directories
5.  `rm` - Remove files or directories
6.  `mkdir` - Create directories
7.  `rmdir` - Remove empty directories
8.  `touch` - Create an empty file or update the modification timestamp of a file
9.  `cat` - Display the content of a file
10. `grep` - Search for a pattern in files
11. `ps` - Display information about running processes
12. `kill` - Terminate a process
13. `echo` - Print a message to the console
14. `chmod` - Change permissions of files or directories
15. `history` - Display a list of recently used commands
16. `ssh` - Connect to a remote server through ssh protocol
17. `scp` - Copy files between local and remote machines over ssh protocol
18. `tar` - Create or extract archive files
19. `df` - Display information about disk usage
20. `wget` - Download files from the internet.


## Tools

1.  `ripgrep` (rg): A fast text search tool that recursively searches a directory
    hierarchy for a regex pattern.
2.  `Tmux`: A terminal multiplexer that allows you to divide your terminal into
    multiple panes and windows.
3.  `Ncdu`: A disk usage analyzer that helps you visualize which files and
    directories are consuming the most space on your filesystem.
4.  `tldr`: A simplified and community-driven version of man pages that provides
    practical examples of command line usage.
5.  `Bat`: A cat replacement that provides syntax highlighting, line numbering, and
    Git integration.
6.  `Exa`: A modern replacement for ls that supports additional features like file
    icons, Git status, and color themes.
7.  `Bandwhich`: A bandwidth usage analyzer that helps you see which processes are
    using the most network bandwidth.
8.  `fd`: A more user-friendly alternative to find that allows you to search for
    files and directories using a streamlined syntax.
9.  `htop`: An interactive process viewer that provides detailed information about
    system resource usage and allows you to manage processes.
10. `Tmuxp`: A command line tool that allows you to easily manage and share your
    Tmux configurations.
11. `direnv`: direnv is a shell extension that allows users to manage environment
    variables for different directories. It is designed to alleviate the
    inconvenience of constantly setting and unsetting environmental variables
    within different development environments.


## Resources

-   [Shell Script Learning](https://www.shellscript.sh/)
-   [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line/blob/master/README.md)


# Editors

-   Vim
-   Emacs
-   VSCode
