# Who should read this book? {-}

I am a book about scientific computing with the Julia programming language. I am supposed to be read by people who aim to become professional scientific computing programmers. 
Before reading me, please make sure

* the problem you are trying to solve runs more than 10min.
* you are not satisfied with any existing tools.

# Becoming an Open-Source Developer {#sec:open-source-dev-toolchains}

This section focuses on understanding the open source workflow, which is the foundation of
scientific computing. Along the way, we will introduce to you our recommended
tools for accomplishing each task. 

## Get a Terminal!

You need to get a working terminal to follow the instructions in this book, because everyone who thinks he is cool uses a terminal.

### Linux operating system{#sec:linux}

Using Linux is the most straight-forward way to get a terminal. Just like Windows, IOS, and Mac OS, Linux is an operating system. In fact,
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

### Shell (or Terminal){#sec:shell}

Although you can use a **graphical user interface** (GUI) to interact with your
Linux distribution, you will find that the **command line interface** (CLI) is
more efficient and powerful. The CLI is also known as the **shell** or **terminal**.

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

The following is a short list of bash commands that will be used frequently in this book.

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

tar     # an archiving utility
```

The power and convinence provided by `Bash` far exceeds what this list can
express.

**Resources**

* [MIT Open course: Missing semester](https://missing.csail.mit.edu/2020/shell-tools/)
* [Learn Bash Shell](https://www.learnshell.org/)
* [Shell Scripting Tutorial](https://www.shellscript.sh/)
* [Bash scripting cheatsheet](https://devhints.io/bash)

### Vim Editor{#sec:editor}
In order to write code, you need an editor. There are many editors available for 
you to choose from. We recommend the following editors for different purposes.

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

### SSH{#sec:ssh}

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
where `<username>` is the user name and `<hostname>` is the host name or IP of the target machine.
You will get logged in after inputting the password.

**Tips to make your life easier**

It will be tedious to type the host name and user name everytime you want to
login to the remote machine. You can setup the `~/.ssh/config` file to make your
life easier. The following is an example of the `~/.ssh/config` file.

```
Host amat5315
  HostName <hostname>
  User <username>
```

where `amat5315` is the alias of the host. After setting up the `~/.ssh/config`, you can login to the remote machine by typing

```bash
ssh amat5315
```

If you want to avoid typing the password everytime you login, you can use the command 
```bash
ssh-keygen
```
to generate a pair of public and private keys, which will be stored in the `~/.ssh` folder on the local machine.
After setting up the keys, you can copy the public key to the remote machine by typing
```bash
ssh-copy-id amat5315
```
Try connecting to the remote machine again, you will find that you don't need to type the password anymore.

**How does SSH key pair work?**
The SSH key pair is a pair of asymmetric keys, one is the public key and the other is the private key.
In the above example, the public key is uploaded to the remote machine and the private key is stored on the local machine. The public key can be shared with anyone, but the private key must be kept secret.

To connect to a server, the server needs to know that you are the one who with the right to access it. To do so, the server will need to check if you have the private key that corresponds to the public key stored on the server. If you have the private key, you will be granted access to the server.

The secret of the SSH key pair is that **the public key can be used to encrypt a message that can only be decrypted by the private key**, i.e. the public key is more like a lock and the private key is the key to unlock the lock. This is the foundation of the SSH protocol. So server can send you a message encrypted by your public key, and only you can decrypt it with your private key. This is how the server knows that you are the one who has the private key without actually sending the private key to the server.

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

## Code MUST be Tested!{#sec:ci-cd}

In terms of scientific computing, accuracy of your result is most certainly more
important than anything else. To ensure the correctness of the code, we employ
two methods: **Unit Testing** and **CI/CD**.

### Unit Test
Unit tests are typically [automated
tests](https://en.wikipedia.org/wiki/Automated_test) written and run
by [software developers](https://en.wikipedia.org/wiki/Software_developer) to
ensure that a section of an application (known as the "unit") meets
its [design](https://en.wikipedia.org/wiki/Software_design) and behaves as
intended. In `Julia`, there exists a helpful module called
[Test](https://docs.julialang.org/en/v1/stdlib/Test/) to help you do Unit
Testing.

### CI/CD
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



##  Learn to Collaborate
- You can open an issue on GitHub/[GitLab](https://en.wikipedia.org/wiki/GitLab) to report a bug or request a feature.
- You can create [a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) on GitHub/GitLab to propose changes to a repository and discuss them with others.

Example: collaborate with others
![](./assets/images/collab.png)

<!-- ```mermaid -->
<!-- graph LR; -->
<!-- A[main] --- MID1[ ]; -->
<!-- MID1 --- MID2[ ]; -->
<!-- MID2 --- END[main*]; -->
<!-- MID1 -\->|fork| B[other/main]; -->
<!-- B -\->|checkout| D[other/feature]; -->
<!-- D <-.->|pull request| MID2 -->
<!-- style MID1 height:0px, width:0px; -->
<!-- style MID2 height:0px, width:0px; -->
<!-- ``` -->



## Share Your Code
Now that you have an amazing package, it's time to make it available to the
public. Before that, there is one final task to be done which is to choose a license. 

- GNU's Not Unix! (GNU) (1983 by Richard Stallman)
    
    Its goal is to give computer users freedom and control in their use of their computers and [computing devices](https://en.wikipedia.org/wiki/Computer_hardware) by collaboratively developing and publishing software that gives everyone the rights to freely run the software, copy and distribute it, study it, and modify it. GNU software grants these rights in its [license](https://en.wikipedia.org/wiki/GNU_General_Public_License).
    <img src="./assets/images/gnu.png" alt="image" width="300" height="auto">
- The problem of GPL Lisense: The GPL and licenses modeled on it impose the restriction that source code must be distributed or made available for all works that are derivatives of the GNU copyrighted code.
    
    Case study: [Free Software fundation v.s. Cisco Systems](https://www.notion.so/Wiki-53dd9dafd57b40f6b253d6605667a472)
    
    Modern Licenses are: [MIT](https://en.wikipedia.org/wiki/MIT_License) and [Apache](https://en.wikipedia.org/wiki/Apache_License).


# Julia{#sec:julia}

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

## Setup Julia {#sec:setup}

### Step 1: Installing Julia 
For Linux/Mac users, please open a terminal and type the following command to install [Julia](https://julialang.org/) with [juliaup](https://github.com/JuliaLang/juliaup). `Juliaup` is a tool to manage Julia versions and installations. It allows you to install multiple versions of Julia and switch between them easily.

```Bash
curl -fsSL https://install.julialang.org | sh # Linux and macOS
```

For Windows users, please open execute the following command in a `cmd`,
```PowerShell
winget install julia -s msstore # Windows
```
You can also install Juliaup directly from [Windows Store](https://www.microsoft.com/store/apps/9NJNWW8PVKMN).


### For users suffering from the slow download speed
Network connectivity can be an issue for some users, especially for those who are in China.
You may need to specify another server for installing Juliaup and Julia packages. To do so, execute the following command in your terminal before running the script above.

**Linux and macOS**
```bash
export JULIAUP_SERVER=https://mirror.nju.edu.cn/julia-releases/ # Linux & macOS
export JULIA_PKG_SERVER=https://mirrors.nju.edu.cn/julia
```
**Windows**
```PowerShell
$env:JULIAUP_SERVER="https://mirror.nju.edu.cn/julia-releases/" # Windows
$env:JULIA_PKG_SERVER="https://mirrors.nju.edu.cn/julia"
```
An alternative approach is downloading the corresponding Julia binary from the [Nanjing university mirror website](https://mirror.nju.edu.cn/julia-releases/).
After installing the binary, please set the Julia binary path properly if you want to start a Julia REPL from a terminal, check this [manual page](https://julialang.org/downloads/platform/) to learn more.


### Installing Julia
To verify that Julia is installed, please open a **new** terminal and run the following command in your terminal.
  ```bash
  julia
  ```
- It should start a Julia REPL(Read-Eval-Print-Loop) session like this
<!-- ![REPL Session](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*lxjWRvH3EzSa1N3Pg4iNag.png) -->
- If you wish to install a specific version of Julia, please refer to the [documentation](https://github.com/JuliaLang/juliaup).

### Step 2: Package Management
- `Julia` has a mature eco-system for scientific computing.
- `Pkg` is the built-in package manager for Julia.
- To enter the package manager, press `]` in the REPL.
![PackageMangement](https://github.com/exAClior/QMBCTutorial/blob/ys/julia-tutorial/notebooks/resources/scripts/Packages.gif?raw=true)
- The environment is indicated by the `(@v1.9)`.
- To add a package, type `add <package name>`.
- To exit the package manager press `backspace` key
- [Read More](https://pkgdocs.julialang.org/v1/managing-packages/)

### Step 3. Configure the startup file
First create a new file `~/.julia/config/startup.jl` by executing the following commands 

`mkdir -r ~/.julia/config`
`touch ~/.julia/config/startup.jl`

You could open the file with your favourite editor and add the following content
```julia
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

### More Packages
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

### Step 4. Download an editor: VSCode

Install VSCode by downloading the correct binary for your platform from [here](https://code.visualstudio.com/download).
Open VSCode and open the `Extensions` tab on the left side-bar of the window, search `Julia` and install the most popular extension.
[read more...](https://github.com/julia-vscode/julia-vscode)
<!-- ![VSCode Julia Layout](https://code.visualstudio.com/assets/docs/languages/julia/overview.png) -->

You are ready to go, cheers!

### A quick introduction to the Julia REPL

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



## An Introduction to the Julia programming language

### A survey
What programming language do you use? Do you have any pain point about this language?

### What is JuliaLang?
**A modern, open-source, high performance programming lanaguage**

JuliaLang was born in 2012 in MIT, now is maintained by Julia Computing Inc. located in Boston, US. Founders are Jeff Bezanson, Alan Edelman, Stefan Karpinski, Viral B. Shah.

JuliaLang is open-source, its code is maintained on [Github](https://github.com/JuliaLang/julia)(https://github.com/JuliaLang/julia) and it open source LICENSE is MIT.
Julia packages can be found on [JuliaHub](https://juliahub.com/ui/Packages), most of them are open-source.

It is designed for speed.

 <img src="./assets/images/benchmark.png" alt="image" width="500" height="auto">

### Reference
[arXiv:1209.5145](https://arxiv.org/abs/1209.5145)

**Julia: A Fast Dynamic Language for Technical Computing**

-- Jeff Bezanson, Stefan Karpinski, Viral B. Shah, Alan Edelman

**Dynamic** languages have become popular for scientific computing. They are generally considered highly productive, but lacking in performance. This paper presents Julia, a new dynamic language for technical computing, designed for performance from the beginning by adapting and extending modern programming language techniques. A design based on generic functions and a rich type system simultaneously enables an expressive programming model and successful type inference, leading to good performance for a wide range of programs. This makes it possible for much of the Julia library to be written in Julia itself, while also incorporating best-of-breed C and Fortran libraries.

### Terms explained
- dynamic programming language: In computer science, a dynamic programming language is a class of high-level programming languages, which at runtime execute many common programming behaviours that static programming languages perform during compilation. These behaviors could include an extension of the program, by adding new code, by extending objects and definitions, or by modifying the type system.
- type: In a programming language, a type is a description of a set of values and a set of allowed operations on those values.
- generic function: In computer programming, a generic function is a function defined for polymorphism.
- type inference: Type inference refers to the automatic detection of the type of an expression in a formal language.


### The two language problem
**Executing a C program**

- C code is typed.

- C code needs to be compiled

**One can use `Libdl` package to open a shared library**

```language-julia
using Libdl
```


```output
nothing
```





```language-julia
c_factorial(x) = Libdl.@ccall "clib/demo".c_factorial(x::Csize_t)::Int
```


```output
c_factorial (generic function with 1 method)
```






**Typed code may overflow, but is fast!**


```language-julia
using BenchmarkTools
```


```output
nothing
```







[learn more about calling C code in Julia](https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/)

Discussion: not all type specifications are nessesary.


**Executing a Pyhton Program**

**Dynamic programming language does not require compiling"**

**Dynamic typed language is more flexible, but slow!**

```language-julia
typemax(Int)
```


9223372036854775807




**The reason why dynamic typed language is slow is related to caching.**

Dynamic typed language uses `Box(type, *data)` to represent an object.

<img src="./assets/images/data.png" alt="image" width="300" height="auto">



Cache miss!


### Two languages, e.g. Python & C/C++?
**From the maintainance's perspective**

- Requires a build system and configuration files,
- Not easy to train new developers.

**There are many problems can not be vectorized**
- Monte Carlo method and simulated annealing method,
- Generic Tensor Network method: the tensor elements has tropical algebra or finite field algebra,
- Branching and bound.
<img src="./assets/images/pythonc.png" alt="image" width="500" height="auto">

### Julia's solution
NOTE: I should open a Julia REPL now!

**1. Your computer gets a Julia program**

```language-julia
function jlfactorial(n)
	x = 1
	for i in 1:n
    	x = x * i
	end
	return x
end
```


```output
jlfactorial (generic function with 1 method)
```






Method instance is a compiled binary of a function for specific input types. When the function is written, the binary is not yet generated.

```language-julia
using MethodAnalysis
```


```output
nothing
```






```language-julia
methodinstances(jlfactorial)
```


```output
MethodInstance for jlfactorial(::UInt32)
```


```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```







**2. When calling a function, the Julia compiler infers types of variables on an intermediate representation (IR)**

<img src="./assets/images/calling function.png" alt="image" width="500" height="auto">



**3. The typed program is then compiled to LLVM IR**
<img src="./assets/images/dragon.png" alt="image" width="300" height="auto">

LLVM is a set of compiler and toolchain technologies that can be used to develop a front end for any programming language and a back end for any instruction set architecture. LLVM is the backend of multiple languages, including Julia, Rust, Swift and Kotlin.



**4. LLVM IR does some optimization, and then compiled to binary code.**

```
with_terminal() do
	@code_native jlfactorial(10)
end
```

**Aftering calling a function, a method instance will be generated.**


**A new method will be generatd whenever there is a new type as the input.**


```language-julia
jlfactorial(UInt32(10))
```


3628800




```language-julia
methodinstances(jlfactorial)
```


```output
MethodInstance for jlfactorial(::UInt32)
```


```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```






Dynamically generating method instances is also called Just-in-time compiling (JIT), the secret why Julia is fast!

**The key ingredients of performance**
- Rich type information, provided naturally by multiple dispatch;
- aggressive code specialization against run-time types;
- JIT compilation using the LLVM compiler framework.

### Julia's type system
1. Abstract types, which may have declared subtypes and supertypes (a subtype relation is declared using the notation Sub <: Super) 
2. Composite types (similar to C structs), which have named fields and declared supertypes 
3. Bits types, whose values are represented as bit strings, and which have declared supertypes 
4. Tuples, immutable ordered collections of values 
5. Union types, abstract types constructed from other types via set union

**Numbers**
**Type hierachy in Julia is a tree (without multiple inheritance)**

```language-julia
AbstractFloat <: Real
```


true




**Abstract types does not have fields, while composite types have**

```language-julia
Base.isabstracttype(Number)
```


true




```language-julia
Base.isconcretetype(Complex{Float64})
```


true




```language-julia
fieldnames(Complex)
```


```output
(:re, :im)
```






**We have only finite primitive types on a machine, they are those supported natively by computer instruction.**

```language-julia
Base.isprimitivetype(Float64)
```


true





**`Any` is a super type of any other type**


```language-julia
Number <: Any
```


true





**A type contains two parts: type name and type parameters**

```language-julia
Complex{Float64}
```


```output
ComplexF64 (alias for Complex{Float64})
```






**ComplexF64 is a bits type, it has fixed size**

```language-julia
sizeof(Complex{Float32})
```


8




```language-julia
sizeof(Complex{Float64})
```


16




But Complex{BigFloat} is not


```language-julia
sizeof(Complex{BigFloat})
```


16




```language-julia
isbitstype(Complex{BigFloat})
```


false




```language-julia
Complex{Float64}
```


```output
ComplexF64 (alias for Complex{Float64})
```







The size of Complex{BigFloat} is not true! It returns the pointer size!

**A type can be neither abstract nor concrete.**

To represent a complex number with its real and imaginary parts being floating point numbers

```language-julia
Complex{<:AbstractFloat}
```


```output
Complex{<:AbstractFloat}
```





```language-julia
Complex{Float64} <: Complex{<:AbstractFloat}
```


true




```language-julia
Base.isabstracttype(Complex{<:AbstractFloat})
```


false




```language-julia
Base.isconcretetype(Complex{<:AbstractFloat})
```


false






**We use Union to represent the union of two types**

```language-julia
Union{AbstractFloat, Complex} <: Number
```


true




```language-julia
Union{AbstractFloat, Complex} <: Real
```


false





NOTE: it is similar to multiple inheritance, but Union can not have subtype!

**You can make an alias for a type name if you think it is too long**

```language-julia
FloatAndComplex{T} = Union{T, Complex{T}} where T<:AbstractFloat
```


```output
Union{Complex{T}, T} where T<:AbstractFloat
```





### Case study: Vector element type and speed

**Any type vector is flexible. You can add any element into it.**

```language-julia
vany = Any[]  # same as vany = []
```




```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```






```language-julia
typeof(vany)
```


```output
Vector{Any} (alias for Array{Any, 1})
```





```language-julia
push!(vany, "a")
```


a

```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```






```language-julia
push!(vany, 1)
```


a

```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```

1

```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```







**Fixed typed vector is more restrictive.**

```language-julia
vfloat64 = Float64[]
```


```output
Float64[]
```





```language-julia
vfloat64 |> typeof
```


```output
Vector{Float64} (alias for Array{Float64, 1})
```





### Multiple dispatch

```language-julia
abstract type AbstractAnimal{L} end
```


```output
nothing
```





```language-julia
struct Dog <: AbstractAnimal{4}
	color::String
end
```


```output
nothing
```





<: is the symbol for sybtyping， A <: B means A is a subtype of B.

```language-julia
struct Cat <: AbstractAnimal{4}
	color::String
end
```


```output
nothing
```





```language-julia
abstract type AbstractAnimal{L} end
```


```output
nothing
```






**One can implement the same function on different types**

The most general one as the fall back method

```language-julia
fight(a::AbstractAnimal, b::AbstractAnimal) = "draw"
```


```output
fight (generic function with 1 method)
```






**The most concrete method is called**

```language-julia
fight(dog::Dog, cat::Cat) = "win"
```


```output
fight (generic function with 2 methods)
```





```language-julia
fight(Dog("blue"), Cat("white"))
```


win





**A final comment: do not abuse the type system, otherwise the main memory might explode for generating too many functions.**

```language-julia
fib(x::Int) = x <= 2 ? 1 : fib(x-1) + fib(x-2)
```


```output
fib (generic function with 1 method)
```





**A "zero" cost implementation**

```language-julia
Val(3.0)
```


```output
Val{3.0}()
```





```language-julia
addup(::Val{x}, ::Val{y}) where {x, y} = Val(x + y)
```


```output
addup (generic function with 1 method)
```





```language-julia
f(::Val{x}) where x = addup(f(Val(x-1)), f(Val(x-2)))
```


```output
f (generic function with 1 method)
```





```language-julia
f(::Val{1}) = Val(1)
```


```output
f (generic function with 2 methods)
```





```language-julia
f(::Val{2}) = Val(1)
```


```output
f (generic function with 3 methods)
```





However, this violates the Performance Tips, since it transfers the run-time to compile time.

### Multiple dispatch is more powerful than object-oriented programming!

Implement addition in Python.

```
class X:
  def __init__(self, num):
    self.num = num

  def __add__(self, other_obj):
    return X(self.num+other_obj.num)

  def __radd__(self, other_obj):
    return X(other_obj.num + self.num)

  def __str__(self):
    return "X = " + str(self.num)

class Y:
  def __init__(self, num):
    self.num = num

  def __radd__(self, other_obj):
    return Y(self.num+other_obj.num)

  def __str__(self):
    return "Y = " + str(self.num)

print(X(3) + Y(5))


print(Y(3) + X(5))
```

Implement addition in Julia

```language-julia
struct X{T}
	num::T
end
```


```output
nothing
```





```language-julia
struct Y{T}
	num::T
end
```


```output
nothing
```





```language-julia
Base.:(+)(a::X, b::Y) = X(a.num + b.num)
```


```output
nothing
```





```language-julia
Base.:(+)(a::Y, b::X) = X(a.num + b.num)
```


```output
nothing
```





```language-julia
Base.:(+)(a::X, b::X) = X(a.num + b.num)
```


```output
nothing
```





```language-julia
Base.:(+)(a::Y, b::Y) = Y(a.num + b.num)
```


```output
nothing
```





**Multiple dispatch is easier to extend!**

If C wants to extend this method to a new type Z.
```
class Z:
  def __init__(self, num):
    self.num = num

  def __add__(self, other_obj):
    return Z(self.num+other_obj.num)

  def __radd__(self, other_obj):
    return Z(other_obj.num + self.num)

  def __str__(self):
    return "Z = " + str(self.num)

print(X(3) + Z(5))

print(Z(3) + X(5))
```

```language-julia
struct Z{T}
	num::T
end
```


```output
nothing
```





```language-julia
Base.:(+)(a::X, b::Z) = Z(a.num + b.num)
```


```output
nothing
```





```language-julia
Base.:(+)(a::Z, b::X) = Z(a.num + b.num)
```


```output
nothing
```





```language-julia
Base.:(+)(a::Y, b::Z) = Z(a.num + b.num)
```


```output
nothing
```





```language-julia
Base.:(+)(a::Z, b::Y) = Z(a.num + b.num)
```


```output
nothing
```





```language-julia
Base.:(+)(a::Z, b::Z) = Z(a.num + b.num)
```


```output
nothing
```





```language-julia
X(3) + Y(5)
```


```output
X{Int64}(8)
```





```language-julia
Y(3) + X(5)
```


```output
X{Int64}(8)
```





```language-julia
X(3) + Z(5)
```


```output
Z{Int64}(8)
```





```language-julia
Z(3) + Y(5)
```


```output
Z{Int64}(8)
```





**Julia function space is exponetially large!**
Quiz: If a function has parameters, and the module has types, how many different functions can be generated?

```
f(x::T1, y::T2, z::T3...)
```
If it is an object-oriented language like Python？

```
class T1:
    def f(self, y, z, ...):
        self.num = num
```

**Summary**
- Multiple dispatch is a feature of some programming languages in which a function or method can be dynamically dispatched based on the run-time type.

- Julia's mutiple dispatch provides exponential abstraction power comparing with an object-oriented language.

- By carefully designed type system, we can program in an exponentially large function space.

### Tuple, Array and broadcasting

**Tuple has fixed memory layout, but array does not.**

```language-julia
tp = (1, 2.0, 'c')
```


```output
(1, 2.0, 'c')
```





```language-julia
typeof(tp)
```


```output
Tuple{Int64, Float64, Char}
```





```language-julia
isbitstype(typeof(tp))
```


true




```language-julia
arr = [1, 2.0, 'c']
```


1

```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```

2.0

```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```

```output
'c': ASCII/Unicode U+0063 (category Ll: Letter, lowercase)
```


```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```






```language-julia
typeof(arr)
```


```output
Vector{Any} (alias for Array{Any, 1})
```





```language-julia
isbitstype(typeof(arr))
```


false





**Boardcasting**

```language-julia
x = 0:0.1:π
```


```output
0.0:0.1:3.1
```





```language-julia
y = sin.(x)
```


```output
[0.0, 0.09983341664682815, 0.19866933079506122, 0.2955202066613396, 0.3894183423086505, 0.479425538604203, 0.5646424733950355, 0.6442176872376911, 0.7173560908995228, 0.7833269096274834, 0.8414709848078965, 0.8912073600614354, 0.9320390859672264, 0.963558185417193, 0.9854497299884603, 0.9974949866040544, 0.9995736030415051, 0.9916648104524686, 0.9738476308781951, 0.9463000876874145, 0.9092974268256817, 0.8632093666488737, 0.8084964038195901, 0.74570521217672, 0.6754631805511506, 0.5984721441039564, 0.5155013718214642, 0.4273798802338298, 0.33498815015590466, 0.23924932921398198, 0.1411200080598672, 0.04158066243329049]
```





```language-julia
using Plots
```


```output
nothing
```





```language-julia
plot(x, y; label="sin")
```


```output
Plot{Plots.GRBackend() n=1}
```





```language-julia
mesh = (1:100)'
```


```output
1×100 adjoint(::UnitRange{Int64}) with eltype Int64:
 1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  90  91  92  93  94  95  96  97  98  99  100
```





```language-julia
let
	X, Y = 0:0.1:5, 0:0.1:5
	heatmap(X, Y, sin.(X .+ Y'))
end
```


```output
Plot{Plots.GRBackend() n=1}
```






**Broadcasting over non-concrete element types may be type unstable.**

```language-julia
eltype(arr)
```


```output
Any
```





```language-julia
arr .+ 1
```


2

```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```

3.0

```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```

```output
'd': ASCII/Unicode U+0064 (category Ll: Letter, lowercase)
```


```{=comment}
This comment is placed between and behind outputs to clearly separate blocks in
order to avoid a bug with cross-references in Pandoc/Crossref.
```






```language-julia
eltype(tp)
```


```output
Any
```





### Julia package development

```language-julia
using TropicalNumbers
```


```output
nothing
```





The file structure of a package

```language-julia
project_folder = dirname(dirname(pathof(TropicalNumbers)))
```


/home/yidai/.julia/packages/TropicalNumbers/kRhOl




<img src="./assets/images/julia_dev.png" alt="image" width="500" height="auto">



**Unit Test**

```language-julia
using Test
```


```output
nothing
```





```language-julia
@test Tropical(3.0) + Tropical(2.0) == Tropical(3.0)
```


```output
Test Passed
```





```language-julia
@test_throws BoundsError [1,2][3]
```


```output
Test Passed
      Thrown: BoundsError
```





```language-julia
@test_broken 3 == 2
```


```output
Test Broken
  Expression: 3 == 2
```





```language-julia
@testset "Tropical Number addition" begin
	@test Tropical(3.0) + Tropical(2.0) == Tropical(3.0)
	@test_throws BoundsError [1][2]
	@test_broken 3 == 2
end
```


```output
Test.DefaultTestSet("Tropical Number addition", Any[Test Broken
  Expression: 3 == 2], 2, false, false, true, 1.708268439682298e9, 1.708268439693213e9, false, "none")
```








### Case study: Create a package like HappyMolecules

With `PkgTemplates`.

[https://github.com/CodingThrust/HappyMolecules.jl](https://github.com/CodingThrust/HappyMolecules.jl)










# Appendix {-}

This is the appendix.

# References
