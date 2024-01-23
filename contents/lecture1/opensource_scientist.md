# Becoming an Open-Source Scientific Computing Scientist {#sec:open-source-dev-toolchains}

Scientific computing is a combination of **scientific applications**,
**mathematical modeling** and **high performance computing**. This section
focuses on understanding the open source workflow, which is the foundation of
scientific computing. Along the way, we will introduce to you our recommended
tools for accomplishing each task. 

## Overview {#sec:open-source-dev-workflow}
Typically, the workflow to produce an open-source program is showned as
following.
    ![](./assets/images/workflow.png)

<!-- ```mermaid -->
<!-- graph LR -->
<!-- I[Idea in your mind] -\->|programme| A[Source code] -->
<!-- A -\->|compile| B[Executable] -->
<!-- B -\->|test, CI/CD| C[Release]  -->
<!-- ``` -->

There is nothing we could do to help you generate new ideas in your mind. But we
can surely help you to on programming.

## Programming Tools{#sec:programming-tools}

### Operating System and Distribution{#sec:os-distro}

Just like Windows, IOS, and Mac OS, Linux is an operating system. In fact,
Android, one of the most popular platforms on the planet, is powered by the
Linux operating system. It is free to use, [open
source](https://opensource.com/resources/what-open-source), widely used on
clusters and good at automating your works. Linux kernel, Linux operating system
and Linux distribution are different concepts. A **Linux distribution** is
an [operating system](https://en.wikipedia.org/wiki/Operating_system) made from
a software collection that includes the [Linux
kernel](https://en.wikipedia.org/wiki/Linux_kernel) and, often, a [package
management system](https://en.wikipedia.org/wiki/Package_management_system) The
Linux kernel is started by [Linus
Torvalds](https://en.wikipedia.org/wiki/Linus_Torvalds) in 1991.
 
The Linux distribution we will use for demoing and live-coding is the
[Ubuntu](https://ubuntu.com/desktop) distribution of the
[Linux](https://en.wikipedia.org/wiki/Linux) operating system.

### Shell{#sec:shell}

Although you can use a **graphical user interface** (GUI) to interact with your
Linux distribution, you will find that the **command line interface** (CLI) is
more efficient and powerful. The CLI is also known as the **shell**.

The shell is a program that takes commands from the keyboard and gives them to
the operating system to perform. [Zsh](https://zsh.org/) and
[Bash](https://gnu.org/software/bash/) are all shell interpreters used in the
Linux operating systems.

**Bash**(Bourne-Again SHell) is the default shell on most Linux distributions.
It is backward-compatible with the original Bourne shell and includes many
additional features, such as command-line editing, job control, and shell
scripting capabilities. Bash is widely used as it is both easy to use and has a
large user community, resulting in a plethora of available resources (tutorials,
scripts, etc.) online.

**Zsh**(Z shell) is an extended version of the shell, with a more powerful
command-line editing and completion system. It includes features like spelling
correction and tab-completion, and it also supports plugins and themes. Zsh is
commonly used by power users who require more productivity and efficiency from
their command-line interface.

We will be using `Bash` during this course. In Ubuntu, one can use `Ctrl` +
`Alt` + `T` to open a `Bash` shell. In a `Bash` shell, we use `man command_name`
to get help information related to a command, use `CTRL-C` to break a program
and `CTRL-D` to exit a shell or an REPL.

The bash grammar is well summarized in [this
cheatsheet](https://devhints.io/bash). The following is a short list for
commands that are often used.

#### A cheatsheet for Bash scripting

```
man     # an interface to the system reference manuals

ls      # list directory contents
cd      # change directory
mkdir   # make directories
rm      # remove files or directories
pwd     # print name of current/working directory

echo    # display a line of text
cat     # concatenate files and print on the standard output

alias   # create an alias for a command

lscpu   # display information about the CPU architecture
lsmem   # list the ranges of available memory with their online status

top     # display Linux processes
ssh     # the OpenSSH remote login client
vim     # Vi IMproved, a programmer's text editor
git     # the stupid content tracker

useradd # create a new user or update default new user information
passwd  # change user password

tar     # an archiving utility
```

The power and convinence provided by `Bash` far exceeds what this list can
express. A more detailed [cheat
sheet](https://cheatography.com/davechild/cheat-sheets/linux-command-line/) and
a [lecture](https://missing.csail.mit.edu/2020/shell-tools/) are available
online. The website [Learn Bash Shell](https://www.learnshell.org/) is also a
good place to start. More advanced readers will find the [lecture on Shell
language](https://missing.csail.mit.edu/2020/shell-tools/) and [Shell Scripting
Tutorial](https://www.shellscript.sh/) themselves more useful.

We will provide two detailed examination of a command that will be used
frequently during the career of a scientific computing programmer.

#### SSH{#sec:ssh}

The programmer may not always have access to a powerful machine for both running
and development of his code. He/she may "borrow" the power of a remote machine
with the help of `ssh` command. The underlying work force of `ssh` is **Secure
Shell**. **Secure Shell** is a network protocol that allows the user to take
command of a remote server securely. After establishing the **Secure Shell**
connection, the user can take command of a server via sending it shell commands.

With a host name (the IP of the target machine to login) and a user name, one
can use the following command to login,

```bash
ssh <username>@<hostname>
```
You will get logged in after inputting the password.

It will be tedious to type the host name and user name everytime you want to
login to the remote machine. You can setup the `~/.ssh/config` file to make your
life easier. The following is an example of the `~/.ssh/config` file.

```
Host amat5315
  HostName 10.100.0.179
  User user01
```

### Editor{#sec:editor}
In order to write code, you need an editor. There are many editors available for 
you to choose from. We recommend the following editors for different purposes.

#### Vim{#sec:vim}

`Vim` is a highly configurable and light-weight text editor built to enable
efficient text editing. It can be found in any Linux distribution, with or
without a graphical user interface. This feature makes it especially useful and
essential to master when you are dealing with servers often. `Vim` is known for
its modal editing, a design that allows the user to switch between different
modes of operation, each tailored for specific tasks. The primary modes include
**Normal Mode**, used for navigating and manipulating text; **Insert Mode**,
where users can insert text as in conventional text editors; **Visual Mode**,
enabling text selection for operations like cutting, copying, or formatting;
**Command Mode**, where users input commands for tasks like saving files or
searching; and **Replace Mode**, which is used to overwrite existing text. This
modal approach in Vim optimizes efficiency by separating the tasks of editing
and navigating, allowing for quicker and more precise text manipulation. Users
can seamlessly switch between these modes, leveraging the unique capabilities of
each to enhance their text editing workflow. 

A few commands are listed below to get you started with `Vim`.

```
i       # input
:w      # write
:q      # quit
:q!     # force quit without saving

u       # undo
CTRL-R  # redo
```

All the commands must be executed in the **command mode**. If you are currently
in the input mode, you can alway type `ESC` to go back to the command mode.

To learn more about Vim, please check this [lecture](https://missing.csail.mit.edu/2020/editors/).

 As an example, to edit the config file `~/.ssh/config` just type
`vim ~/.ssh/config`.

#### VSCode{#sec:vscode}
The other editor we recommend is the [VSCode](https://code.visualstudio.com/).
It is a free and open-source code editor developed by Microsoft. It is available
for Windows, Linux and macOS. It has built-in support for Git, debugging, and
extensions, and is customizable and extensible.

Most significantly, it has terrific [support](https://www.julia-vscode.org/) for
developing in our choice of language for scientific computing: `Julia`.

### Julia{#sec:julia}

`Julia` is a high-level, high-performance, dynamic programming language. From
the designing stage, `Julia` is intended to address the needs of
high-performance numerical analysis and computational science, without the
typical need of separate compilation to be fast, while also being effective for
general-purpose programming, web use or as a specification language. `Julia` is
also a free and open-source language, with a [large
community](https://julialang.org/community/) and a [rich
ecosystem](https://juliahub.com/).

We will devlve deeper into `Julia` later in the chapter. For now, we will just
install `Julia` and setup the environment.

#### Setup Julia {#sec:setup}

This setup guide is adapted with the mainland China users in mind. If you are
not in mainland China, you may skip some steps.

##### Step 1: Installing Julia 
For Linux/Mac users, please open a terminal and type the following command to install [Julia](https://julialang.org/) with [juliaup](https://github.com/JuliaLang/juliaup). `Juliaup` is a tool to manage Julia versions and installations. It allows you to install multiple versions of Julia and switch between them easily.

```Bash
curl -fsSL https://install.julialang.org | sh # Linux and macOS
```

For Windows users, please open execute the following command in a `cmd`,
```PowerShell
winget install julia -s msstore # Windows
```
You can also install Juliaup directly from [Windows Store](https://www.microsoft.com/store/apps/9NJNWW8PVKMN).


###### For users suffering from the slow download speed
            
You may need to specify another server for installing Juliaup. To do so, execute the following command in your terminal before running the script above.

**Linux and macOS**
```bash
export JULIAUP_SERVER=https://mirror.nju.edu.cn/julia-releases/ # Linux & macOS
```
**Windows**
```PowerShell
$env:JULIAUP_SERVER="https://mirror.nju.edu.cn/julia-releases/" # Windows
```
An alternative approach is downloading the corresponding Julia binary from the [Nanjing university mirror website](https://mirror.nju.edu.cn/julia-releases/).
After installing the binary, please set the Julia binary path properly if you want to start a Julia REPL from a terminal, check this [manual page](https://julialang.org/downloads/platform/) to learn more.


###### Installing Julia
To verify that Julia is installed, please open a **new** terminal and run the following command in your terminal.
  ```bash
  julia
  ```
- It should start a Julia REPL(Read-Eval-Print-Loop) session like this
<!-- ![REPL Session](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*lxjWRvH3EzSa1N3Pg4iNag.png) -->
- If you wish to install a specific version of Julia, please refer to the [documentation](https://github.com/JuliaLang/juliaup).

##### Step 2: Package Management
- `Julia` has a mature eco-system for scientific computing.
- `Pkg` is the built-in package manager for Julia.
- To enter the package manager, press `]` in the REPL.
![PackageMangement](https://github.com/exAClior/QMBCTutorial/blob/ys/julia-tutorial/notebooks/resources/scripts/Packages.gif?raw=true)
- The environment is indicated by the `(@v1.9)`.
- To add a package, type `add <package name>`.
- To exit the package manager press `backspace` key
- [Read More](https://pkgdocs.julialang.org/v1/managing-packages/)

##### Step 3. Configure the startup file and add `Revise`
First create a new file `~/.julia/config/startup.jl` by executing the following commands 

`mkdir -r ~/.julia/config`
`touch ~/.julia/config/startup.jl`

You could open the file with your favourite editor and add the following content
```julia
ENV["JULIA_PKG_SERVER"] = "http://cn-southeast.pkg.juliacn.com/"
try
    using Revise
catch e
    @warn "fail to load Revise."
end
```

The contents in the startup file is executed immediately after you open a new Julia session.

Then you need to install [Revise](https://github.com/timholy/Revise.jl), which is an Julia package that can greatly improve the using experience of Julia. To install `Revise`, open Julia REPL and type
```julia
julia> using Pkg; Pkg.add("Revise")
```

If you don't know about `startup.jl` and where to find it, [here](https://docs.julialang.org/en/v1/manual/command-line-interface/#Startup-file) is a good place for further information. 

#### More Packages
- You may find more Julia packages [here](https://juliahub.com/).


As a final step, please verify your Julia configuration by openning a Julia REPL and type
```julia
julia> versioninfo()
Julia Version 1.9.2
Commit e4ee485e909 (2023-07-05 09:39 UTC)
Platform Info:
  OS: macOS (arm64-apple-darwin22.4.0)
  CPU: 10 × Apple M2 Pro
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-14.0.6 (ORCJIT, apple-m1)
  Threads: 1 on 6 virtual cores
Environment:
  JULIA_NUM_THREADS = 1
  JULIA_PROJECT = @.
  JULIA_PKG_SERVER = http://cn-southeast.pkg.juliacn.com/ 
```

##### Step 3. Download an editor: VSCode

Install VSCode by downloading the correct binary for your platform from [here](https://code.visualstudio.com/download).
Open VSCode and open the `Extensions` tab on the left side-bar of the window, search `Julia` and install the most popular extension.
[read more...](https://github.com/julia-vscode/julia-vscode)
<!-- ![VSCode Julia Layout](https://code.visualstudio.com/assets/docs/languages/julia/overview.png) -->

You are ready to go, cheers!

###### A quick introduction to the Julia REPL

A Julia REPL has four modes,

1. Julian mode is the default mode that can interpret your Julia code.

2. Shell mode is the mode that you can run shell commands. Press `;` in the Julian mode and type
```julia
shell> date
Sun Nov  6 10:50:21 PM CST 2022
```
To return to the Julian mode, type the <kbd>Backspace</kbd> key.

3. Package mode is the mode that you can manage packages. Press `]` in the Julian mode and type
```julia
(@v1.8) pkg> st
Status `~/.julia/environments/v1.8/Project.toml`
  [295af30f] Revise v3.4.0
```
To return to the Julian mode, type the <kbd>Backspace</kbd> key.

4. Help mode is the mode that you can access the docstrings of functions. Press `?` in the Julian mode and type
```julia
help> sum
... docstring for sum ...
```
To return to the Julian mode, type the <kbd>Backspace</kbd> key.

[read more...](https://docs.julialang.org/en/v1/stdlib/REPL/)

### Version Control{#sec:version-control} 

## Why open sourcing?
[Open-source](https://en.wikipedia.org/wiki/Open_source) software is software with source code that anyone can inspect, modify, and enhance. Open source software are incresingly popular for many reasons, having better control, easier to train programmers, **better data security**, stability and **collaborative community**.



### Before Starting: Configuring git

-   Configs
    1.  Global use `/.gitconfig`
    2.  Repo specific use `.git/config`
    3.  Repo specific config file will overwrite the global one
-   How to view your current config
    `$ git config --list --show-origin`
-   Config editor
    `$ git config --global core.editor emacs`
    

- Version control: the [Git](https://git-scm.com/) as the version control software and the [GitHub](https://github.com/) website as the place to store your code. Our homework will be submitted through a [locally deployed GitLab](https://code.hkust-gz.edu.cn/).

    
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


## Version Control: Git
Version control, also known as source control, is the practice of tracking and managing changes to software code. Install `git` with
```bash
sudo apt install git
```

## How does Git work?
### Tier 1: Single branch
- You start with a working directory, then use `git init` to make it a git repository.
- You can use `git add` to add files to the staging area, and use `git commit` to commit the changes to the repository.
- You can use `git checkout` to switch between commits.
- You can use `git diff` to see the changes between commits.
- You can use `git reset` to reset the current HEAD to the specified state.
- You can use `git status` to see the status of the working directory, staging area, and repository.
- You can use `git log` to see the history of commits.

### Tier 2: Multiple branches
- You can use `git branch` to create, list, rename, and delete branches. The source code on the `main` branch is always usable, which serves as the stable version of the software.
- You can use `git merge` to merge branches.
- You can use `git checkout` to switch between branches.
- You can use `git diff` to see the changes between branches.

Example 1: develop a new feature
```mermaid
graph LR;
A[main] --- MID[ ];
MID ---|always usable| MID2[ ];
MID2 -->B[main*];
MID -->|checkout| D[feature];
D -->|update & commit| D2[feature*];
D2 -->|merge| MID2;
style MID height:0px, width:0px;
style MID2 height:0px, width:0px;
```

Example 2: develop two features

```mermaid
graph LR;
A[main] --- MID0[ ];
MID0 --- MID1[ ];
MID1 --- MID2[ ];
MID2 --- MID3[ ];
MID3 --- END[main*];
MID0 -->|checkout| C[feature1];
MID1 -->|checkout| D[feature2];
C --->|merge| MID2
D -.->|merge?| MID3
style MID0 height:0px, width:0px;
style MID1 height:0px, width:0px;
style MID2 height:0px, width:0px;
style MID3 height:0px, width:0px;
```

Question: what if the two features are not compatible?



### Tier 3: Working with remote repositories
- You can use `git remote add <remote-name> <url>` to add a remote repository.
- You can use `git push <remote-name> <branch>` to push commits to a remote repository.
- You can use `git pull <remote-name> <branch>` to fetch from and integrate with another repo or a local branch.

### Tier 4: Collaborating with others
- You can open an issue on GitHub/[GitLab](https://en.wikipedia.org/wiki/GitLab) to report a bug or request a feature.
- You can create [a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) on GitHub/GitLab to propose changes to a repository and discuss them with others.

Example: collaborate with others

```mermaid
graph LR;
A[main] --- MID1[ ];
MID1 --- MID2[ ];
MID2 --- END[main*];
MID1 -->|fork| B[other/main];
B -->|checkout| D[other/feature];
D <-.->|pull request| MID2
style MID1 height:0px, width:0px;
style MID2 height:0px, width:0px;
```




*** Git is distributed
- Git is distributed in the sense that every user's computer has a full copy of
  the project. At the failure of one machine, the project is still around.

*** Why is git created
- Git originated because bitkeeper refused to give linux the free of charge
  use case.

*** What's Git designed for
- Git is designed for *large project* with *many parallel development branches*.

*** Data structure difference between other VCS
**** How are changes documented
- Other VCS stores files with initial files plus changes over time
- Git stores files with the entire file every time it detects a change in the
  collection of files.
- This is helpful for branching.

**** Almost everything is local
- You can commit to local branches and then push those to server.
- The same applies with checking the history etc.

**** Integrity guaranteed by checksum
- Every change every file will be accompanied with a SHA1 checksum hash.

**** Git generally only adds data
- This makes losing data very hard.

**** Three states of file
- Modified: dangerous changed but not recorded could be lost easily
- Staged: mark a file to be added into the next snapshot. File is now in [[id:0d4d6c6c-1c92-4009-958c-9038b50ab087][Staging area]]
- Committed: Snapshot already taken for the file(s)

*** Data model of git
- Files and folders are represented by ~trees~ and ~blobs~
- Git tracks the state of your project with [[id:4999823b-e1b4-4d65-869e-7e87b825c3df][Directed Acyclic Graph]]
  1) Node is a snapshot of your project
  2) A Node points to another node which is its ~parent~. Content of the
     children node is modified from that of the parent node
  3) ASCII art representation, circles are nodes
      o <-- o <-- o <-- o
            ^
             \
              --- o <-- o

**** Data structure in terms of C objects
1) ~blob(file)~ is just an array of byte
2) ~tree(folder)~ is a ~map<string, tree/blob>~. Meaning it contains either
   other folders and/or files
3) ~commit~ is a ~struct~ which contains
   a) parents: array of ~commit~
   b) author: string
   c) message: string
   d) snapshot: ~tree~ (sha1 of the actual tree)
4) ~reference~ is a ~map<string,string>~
   a) the first string is human readable name for commit title
   b) the second string is the hash of a snapshot
   c) It facilitates fast look up of commits

**** How are these data structures stored on disk?
- You treat all the three mentioned data structures as an ~object~
- You get a container of objects which is ~<sha1-val,object>~
- You use the following two functions to store and load an object
  #+begin_src
   objects = <map,object>

   def store(object):
       id = sha1(object)
       objects[id] = object

   def load(id):
       return objects[id]
  #+end_src

*** Configuring git
- Configs
  1) Global use ~/.gitconfig~
  2) Repo specific use ~.git/config~
  3) Repo specific config file will overwrite the global one
- How to view your current config
  ~$ git config --list --show-origin~
- Config editor
  ~$ git config --global core.editor emacs~

** Working with git
- [[https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things#_undoing][Undoing things, consider do this first]]
- If interested in hosting own git, read Chapter 4 of gitbook
** Commands
- [[id:644f0d50-59c1-44a0-beef-959e1a4c845a][Magit]]
*** Initialize Repo
- Initialize a folder to a git repo
- ~git init~

*** Add file to staging area
- Tell git to include this changed file in the next snapshot to submit.
- ~git add -p <filename>~ let's you *interactively select* which part you want
  to commit in the next commit.

*** Make a commit
- Tell git to take a snapshot of staged files with selected file
- ~git commit -m <message>~
**** Data visualization of commit
- Single commit
  #+DOWNLOADED: https://git-scm.com/book/en/v2/images/commit-and-tree.png @ 2022-07-25 14:10:51
  [[file:../../notes/imgs/pdfs/Data_Model_of_Git/20220725-141051_commit-and-tree.png]]
- Multiple commits
  #+DOWNLOADED: https://git-scm.com/book/en/v2/images/commits-and-parents.png @ 2022-07-25 14:11:17
  [[file:../../notes/imgs/pdfs/Data_Model_of_Git/20220725-141117_commits-and-parents.png]]
- It points to a snapshot of the project
**** Commit messages
***** Avoid trailing whitespaces
- ~git diff --check~ will show you whether you have those
***** Commit in bite sizes
- Make things clear what each commit is doing
- If the same file is changed at two places for different purposes, use ~git add
  --patch~ to avoid putting them into same commit.
*** To fix a commit
- ~git commit --amend~
*** View commit Logs
- ~git log~
- Shows a flattened log of history
- ~git log <branch_name> --not <other branch>~ will show you commits in first
  branch but not in second.
*** Branching
- ~git branch branch_name~ creates a new branch, but it does not switch to it
- If you want to create branch and checkout at the same time ~git checkout -b
  branchname~
**** Special Branches
***** Master
- Default branch
***** HEAD
- Pointer to a *staged* branch.
- That branch is the one you are currently *on*.
- It will be different from your working directory if you made modifications.

**** Why is branch switching in git fast?
- *Branch is just a pointer* to different commits.
- To determine which branch you are working on, ~HEAD~ is used
- Switching branch is just switch which branch ~HEAD~ points to.
**** Cost of creating a branch
- Just writes $41$ characters to a new file
- $40$ characters for $SHA-1$ checksum of commit. $1$ character for newline.

**** Display branches
- ~git branch~
- ~*~ denotes the ~HEAD~
- ~git branch --merged~: shows all branches *merged* into current branch.
- ~git branch --no-merged~: shows all branches *not merged* into current branch.

**** Rename branch
- ~git branch --move <old branch name> <new branch name>~
- Don't forget to ~git push --set-upstream origin <new branch name>~ and ~git
  push origin --delete <old branch name>~

**** How to use branch in real world
- Basic idea: make your branches represent different levels of code quality
  #+DOWNLOADED: https://git-scm.com/book/en/v2/images/lr-branches-2.png @ 2022-07-29 14:27:05
  [[file:../../notes/imgs/pdfs/Commands_in_Git/20220729-142705_lr-branches-2.png]]
  1) Ready to ship / No bug
  2) Development / Might need testing
  3) Others

**** Remote branch
- Get pointer on remote
  1) ~git remote show <remote>~
  2) ~git ls-remote <remote~

***** Track branch
- Setup pairing between local branch and remote branch
- Makes operation easier, don't have to type remote branch every time you merge
- ~git checkout --track <remote>/<remote branch>~ when trying to assign local
  branch a remote branch pairing
- ~git branch -u <remote>/<remote branch>~ when setting a pairing explicitly.
- ~git branch -vv~ will show you the pairing that's setup already

***** Delete remote branch
- ~git push origin --delete <branchname>~


**** Rebase
- Basically clone a child and all its descendents and assign new parent to that
  child
- In case of divergent branch
- reapply all commits after divergent point to the other branch
- ~git checkout experiment~ and then ~git rebase master~
  #+DOWNLOADED: https://git-scm.com/book/en/v2/images/basic-rebase-3.png @ 2022-07-31 13:44:48
  [[file:../../notes/imgs/pdfs/Commands_in_Git/20220731-134448_basic-rebase-3.png]]
- After fixing everything just merge ~master~ into ~experiment~
- You will have a cleaner history compare to a three way merge

***** Rebase of branch that stems from another branch

#+DOWNLOADED: https://git-scm.com/book/en/v2/images/interesting-rebase-2.png @ 2022-07-31 13:49:30
[[file:../../notes/imgs/pdfs/Commands_in_Git/20220731-134930_interesting-rebase-2.png]]
- ~git rebase <accept branch> <first diff branch> <target branch>~
- ~git rebase master server client~

***** WARNING!! Follow this rule
- *ONLY REBASE WITH BRANCHES WORKED BY YOU ALONE*
- *NEVER REBASE WORK THAT IS ON A REMOTE SERVER ALREADY*
- If catastrophe did happen ~git pull --rebase~ for someone who sees the remote
  has been rebased.

*** Merging
- ~git merge <modified branch>~, merge into the current branch.
**** Different types of merging
1) Fast-forward. *No divergence*, current branch is the parent of ~modified branch~.
2) If parallel development is there, we may face merge conflict.
   a) If no conflict, git creates a new commit ~merge commit~ and moves ~master~
      branch to point to this commit.
      #+DOWNLOADED: https://git-scm.com/book/en/v2/images/basic-merging-2.png @ 2022-07-26 14:45:03
      [[file:../../notes/imgs/pdfs/Commands_in_Git/20220726-144503_basic-merging-2.png]]
   b) You could either use ~Magit~ to resolve the conflict or use ~git
      mergetool~ which let's you choose between ~vimdiff~ or other tools to
      resolve conflict. In ~magit~, you could see files marked by ~unmerged~ if
      they have conflicts within. Hit return while pointing to those file.

**** After merging
- Delete the branch because you no longer needs it.

**** Squash
- Compress multiple commits into one and apply it to current branch
- ~git merge --squash <featureB>~
- In effect, it's like taking work from ~featureB~ and "rebase" it on another
  branch.
  #+DOWNLOADED: https://git-scm.com/book/en/v2/images/public-small-3.png @ 2022-08-03 14:54:55
  [[file:../../notes/imgs/pdfs/Commands_in_Git/20220803-145455_public-small-3.png]]


**** When to merge master branch
- Don't merge local branch into master branch hastely
- First push local branch to remote branch (not master). Wait for the remote
  master is updated and etc.
- Some of your change in the local branch might need to be cherry-picked etc.
  Mergeing local master hastely will result in nasty rewinding later.
- Finally, sync the local master with remote master
*** Checkout
- Change between branch
- Under the hood, moves the ~HEAD~ and then reverts the files' states to those
  in the snapshot of new branch.
- ~git checkout branch_name/hash_of_branch~

**** Warning!
- Not committed work will be lost.

**** Throwing away changes in working directory
- ~git checkout filename~

*** Diff
- Show difference of a file between two snapshots
- ~git diff~ will only show the modifications in the working directory compared
  to the last staged version
- ~git diff --staged~ will show the staged change.
- ~git diff hash1 (hash2) filename~ you may not need to provide (hash2)
- ~git diff <b1>...<b2>~ shows difference between the b2 and its common ancestor with b1


*** Git remote
- ~git remote~ lists all the remote repo git is aware of.
- Adding remote ~git remote add <name> <url>~
- You could get multiple remotes . Just to *separate out visibility of
  code* submitted.
**** Setup tracking remote branch
- Let git know which branch on remote to compare to by default in case a
  push/pull needs to happen.
- ~git branch --set-upstream-to=origin/master~
**** Get work from remote
1) Checkout branch directly from remote
   - ~git checkout -b <new branch name locally> <remote>/<remote branch name>~
2) Merge with current working branch
   - ~git merge <remote>/<remote branch>~

*** Git fetch
- fetches update on the server
- Moves remote pointer on local machine to correct space.
#+DOWNLOADED: https://git-scm.com/book/en/v2/images/remote-branches-2.png @ 2022-07-30 14:00:49
[[file:../../notes/imgs/pdfs/Commands_in_Git/20220730-140049_remote-branches-2.png]]

#+DOWNLOADED: https://git-scm.com/book/en/v2/images/remote-branches-3.png @ 2022-07-30 14:00:59
[[file:../../notes/imgs/pdfs/Commands_in_Git/20220730-140059_remote-branches-3.png]]

*** Git rm
- ~git rm~ will remove the file from the traced list of files and working
  directory.
- ~git rm -f~ will allow you to remove a file that is been staged already. It
  ensures that you really want to remove this file.
- ~git rm --cached~ will remove a file in the staging area but keep it on the
  working directory. It's helpful when you forgot to add it into gitignore list.

*** Git mv
- It works so that you could move a file or rename it conveniently.
*** Git push
- Send local changes to server
- ~git push <remote> <local_branch>:<remote_branch>~
  1) Note, you could in theory have different branch name in remote and local
     but synced.
*** Git pull
- The same as ~git fetch~ plus ~git merge~
- It's recommended to use fetch and merge separately

*** Git clone
- ~git clone <url> <folder_name>~
**** Project with unwanted long history
- ~git clone --shallow~  allows just download current version of project
*** Git bisect
- Binary search in commit history that something happens first

*** Git cherry pick
- ~git cherry-pick <sha1>~
  #+DOWNLOADED: https://git-scm.com/book/en/v2/images/rebasing-2.png @ 2022-08-04 14:26:07
  [[file:../../notes/imgs/pdfs/Commands_in_Git/20220804-142607_rebasing-2.png]]
- *generate a new hash*

*** Reset and restore
- Currently Magit only supports reset
- Restore is the newer command
**** Unstage file
- ~git reset~
- ~git restore --staged <file>~
**** Discard change of file
- Dangerous!
- ~git reset HEAD <file>~
- ~git restore <file>~

*** Git remote
- Tells you remote handle for your repo
- ~git remote~ *basic info*
- ~git remote -v~ *More, url etc*
- Note, you may have multiple remotes
**** Add remote
- ~git remote add <shortname> <url>~
**** Display info about remote
- ~git remote show <remote name>~
**** Rename remote
- ~git remote rename <remote name>~
**** Remove remote
- ~git remote remove <remote name>~

*** Git tag
- Tag your history
- ~git tag~ shows all tags
- ~git tag --list <pattern-for-tag>~ list all tags matching the pattern for tag
- ~git push origin <tag name>~ need to do this explicitly because remote does
  not pull tag info automatically.
- ~git push origin --tags~ pushes all unpushed tags.
- ~git tag -d <tag name>~ delete a tag
- ~git push origin --delete <tag name>~ delete tag on remote
**** Different types of tag
- ~lightweight~ much like a pointer to a commit
  1) ~git tag <tag-name>~
- ~annotated~ stored as full commit in git database. may attach a message
  1) ~git tag -a v1.4 -m "my version 1.4"~
  2) ~git tag -a v1.2 <commit hash>~ tagging specific commit
**** Checkout tag and detached HEAD state
- Sounds *dangerous*, maybe avoid
- ~git checkout <tag name>~ checkouts a commit with tag name
- When you do a commit, it will not create a branch automatically and the new
  commit will only be accessible using commit hash.
- ~git checkout -b <new branch name> <tag name>~ try this instead.

*** Git alias
- Just like shell alias
- But I would rather use magit
*** Git rerere
- REuse REcorded REsolution
- Use previous resolution to fix a conflict.
- Useful when you have a long history to be merged.
*** Git describe
- Create version number with respect to a branch
- ~git describe <branch>~

*** Git archive
- Prepares a release in a tar ball
- ~git archive master --prefix='project/' | gzip > `git describe master`.tar.gz~
*** Git shortlog
- Gets a summary of commits since a version
- ~git shortlog --no-merges master --not v1.0.1~

*** Git cat-file
- use command ~git cat-file -p~ followed with the hashed value to get content.

* Github
- Use ~Github-cli~ to manage pull request
- If your fork goes out of sync with upstream, add the upstream as remote and
  merge that into the current branch you are working on.
- In general, do not rebase.

* Example of working in group
-  [[https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project]]

* Distributed Git
- Describes different workflow styles concerning collaborator and remote repo.
- [[https://martinfowler.com/articles/branching-patterns.html][Guide for all common git workflow]]
** Centralized workflow
- This is the github fork and pull request model.
#+DOWNLOADED: https://git-scm.com/book/en/v2/images/centralized_workflow.png @ 2022-08-01 14:09:04
[[file:../../notes/imgs/pdfs/Distributed_Git/20220801-140904_centralized_workflow.png]]
** Integration-Manager workflow

#+DOWNLOADED: https://git-scm.com/book/en/v2/images/integration-manager.png @ 2022-08-01 14:10:55
[[file:../../notes/imgs/pdfs/Distributed_Git/20220801-141055_integration-manager.png]]
** Dictator and Lieutenant workflow
- For very large project
- Basically another layer of "manager" of Integration manager workflow
  #+DOWNLOADED: https://git-scm.com/book/en/v2/images/benevolent-dictator.png @ 2022-08-01 14:14:09
  [[file:../../notes/imgs/pdfs/Distributed_Git/20220801-141409_benevolent-dictator.png]]
** Send your work through email
- Generates commits into patches
- Send to public developer mailing list
- Skimmed through
- [[https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project][Last section here.]]
** Maintain repo
- Create branch for testing features
- Apply patch with ~git apply~ or ~git am~
- Test apply patch ~git apply --check~
- It's encouraged to use ~format patch~ to generate patches

## A cheatsheet for Git and Github

Git is a tool for version control.
It is an important tool for programmers to keep track of the different versions of a program and collaborate with others.
GitHub is a website and cloud-based service that helps developers store and manage their code, as well as track and control changes to their code.
There are more than 100 git sub-commands, and the following is a short list to keep in mind.

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

## Resources
* [Learn Bash Shell](https://www.learnshell.org/)
* [Learn Git](https://learngitbranching.js.org/)
* [Github Manual](https://githubtraining.github.io/training-manual/book.pdf)
* [How to create a new github repo](https://docs.github.com/en/get-started/quickstart/create-a-repo)
* [How to create a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)
* [Markdown Tutorial](https://www.markdowntutorial.com/)
* MIT online course [missing semester](https://missing.csail.mit.edu/2020/).
- [[https://csdiy.wiki/%E5%BF%85%E5%AD%A6%E5%B7%A5%E5%85%B7/Git/][Guiding page]]
- [[https://git-scm.com/docs][Documentation for commands]]
- [X] [[https://missing.csail.mit.edu/2020/version-control/][Missing semester video]]
- [X] [[https://git-scm.com/book/en/v2]]

** Learn Git with Game
- [[https://learngitbranching.js.org/?locale=zh_CN]]
** Visualization
- [[https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1][Visualization of Commands]]
** Panic
- [[https://ohshitgit.com/]]


#### Publish{#sec:publish}
Now that you have an amazing package, it's time to make it available to the
public. Before that, there is one final task to be done which is to choose a license. 

- GNU's Not Unix! (GNU) (1983 by Richard Stallman)
    
    Its goal is to give computer users freedom and control in their use of their computers and [computing devices](https://en.wikipedia.org/wiki/Computer_hardware) by collaboratively developing and publishing software that gives everyone the rights to freely run the software, copy and distribute it, study it, and modify it. GNU software grants these rights in its [license](https://en.wikipedia.org/wiki/GNU_General_Public_License).
    
    ![](./assets/images/gnu.png)
    
- The problem of GPL Lisense: The GPL and licenses modeled on it impose the restriction that source code must be distributed or made available for all works that are derivatives of the GNU copyrighted code.
    
    Case study: [Free Software fundation v.s. Cisco Systems](https://www.notion.so/Wiki-53dd9dafd57b40f6b253d6605667a472)
    
    Modern Licenses are: [MIT](https://en.wikipedia.org/wiki/MIT_License) and [Apache](https://en.wikipedia.org/wiki/Apache_License).


### CI/CD{#sec:ci-cd}

- tests
  - Unit test: the [Test](https://docs.julialang.org/en/v1/stdlib/Test/) module in Julia.

## Unit Test
Unit tests are typically [automated tests](https://en.wikipedia.org/wiki/Automated_test) written and run by [software developers](https://en.wikipedia.org/wiki/Software_developer) to ensure that a section of an application (known as the "unit") meets its [design](https://en.wikipedia.org/wiki/Software_design) and behaves as intended.

TODO, need to summarize and read the following paragraphs


Continuous Integration (CI) and Continuous Deployment (CD) are fundamental
practices in modern software development aimed at enhancing the efficiency and
quality of software production. CI is the process of automatically integrating
code changes from multiple contributors into a single software project. This
involves frequent code version submissions to a shared repository, where
automated builds and tests are run. The primary goal of CI is to identify and
address conflicts and bugs early, ensuring that the main codebase remains stable
and release-ready at all times.

On the other hand, CD extends CI by automating the delivery of applications to
selected infrastructure environments. This can range from automated testing
stages to full-scale production deployments. The main advantage of CD is its
ability to release new changes to customers quickly and sustainably. It enables
a more rapid feedback loop, where improvements and fixes are delivered faster to
end-users.

Together, CI/CD embody a culture of continuous improvement and efficiency, where
software quality is enhanced, and development cycles are shortened. This not
only reduces the time and cost of software development but also allows teams to
respond more swiftly to market changes and customer needs, maintaining a
competitive edge in the fast-paced tech world.

## Homework 1

Nothing works better than homework to check how much you have learned.

### Task 1: Setup your Github workflow
Complete the following steps to setup the homework environment.

1. Login to a remote server with `ssh`, the `username` is your name (lowercase) and the `server` ip address is ``.

2. Create a GitHub account, and configure the git environment with your GitHub account.
3. Fork the homework Github repository, and clone the forked repository `github-username/AMAT5315HW` to the machine you are working on.
4. Run the following commands:
    ```bash
    cd AMAT5315HW/username
    lscpu > lscpu.txt
    cat lscpu.txt  # check the content of this file
    ```
    where `username` is your name (lowercase).
4. Add the `lscpu.txt` file to the git repository, commit the change, and push the change to the remote repository.

### Task 2: Get Julia installed


# Resources
[The art of Command line](https://github.com/jlevy/the-art-of-command-line/blob/master/README.md)
[Tips for Early Career Computational Scientist](https://arxiv.org/pdf/2310.13514.pdf)
[OCaml for Scientific Computing](https://ocaml.xyz/introduction.html)
[CSDIY Website](https://csdiy.wiki/%E5%BF%85%E5%AD%A6%E5%B7%A5%E5%85%B7/Vim/)
[Missing Semester](https://missing.csail.mit.edu/2020/)
