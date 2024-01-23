# Becoming an Open-Source Scientific Computing Scientist {#sec:open-source-dev-toolchains}

Scientific computing is a combination of **scientific applications**,
**mathematical modeling** and **high performance computing**. The first lecture
focuses on understanding the open source workflow, which is the foundation of
scientific computing. Along the way, we will introduce to you our recommended
tool for accomplishing each task. It is a summary of the [MIT open course:
Missing Semester](https://missing.csail.mit.edu/2020/).

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

There is nothing we could do to help you generate new ideas in your mind. But we can surely help you to on programming.

## Programming Tools{#sec:programming-tools}

### Operating System and Distribution{#sec:os-distro}

Just like Windows, IOS, and Mac OS, Linux is an operating system. In fact, Android, one of the most popular platforms on the planet, is powered by the Linux operating system.
It is free to use, [open source](https://opensource.com/resources/what-open-source), widely used on clusters and good at automating your works.
Linux kernel, Linux operating system and Linux distribution are different concepts.
 A **Linux distribution** is an [operating system](https://en.wikipedia.org/wiki/Operating_system) made from a software collection that includes the [Linux kernel](https://en.wikipedia.org/wiki/Linux_kernel) and, often, a [package management system](https://en.wikipedia.org/wiki/Package_management_system) The Linux kernel is started by [Linus Torvalds](https://en.wikipedia.org/wiki/Linus_Torvalds) in 1991.
 
The Linux distribution we will use for demoing and live-coding is the [Ubuntu](https://ubuntu.com/desktop) distribution of the [Linux](https://en.wikipedia.org/wiki/Linux) operating system.

### Shell{#sec:shell}

Although you can use a graphical user interface (GUI) to interact with your
Linux distribution, you will find that the command line interface (CLI) is more
efficient and powerful. The CLI is a text-based interface that allows you to
interact with your computer by typing commands. The CLI is also known as the
**shell**.

The shell is a program that takes commands from the keyboard and gives them to
the operating system to perform. In the old days, it was the only user interface
available on a Unix-like system such as Linux. Nowadays, we have the graphical
user interface (GUI), but the shell still proves to be a powerful tool for
performing complex tasks with only a few keystrokes. [Zsh](https://zsh.org/) and
[Bash](https://gnu.org/software/bash/) are all command-line interface (CLI)
interpreters used in the Linux operating systems.

Zsh (Z shell) is an extended version of the shell, with a more powerful
command-line editing and completion system. It includes features like spelling
correction and tab-completion, and it also supports plugins and themes. Zsh is
commonly used by power users who require more productivity and efficiency from
their command-line interface.

Bash (Bourne-Again SHell) is the default shell on most Linux distributions. It
is backward-compatible with the original Bourne shell and includes many
additional features, such as command-line editing, job control, and shell
scripting capabilities. Bash is widely used as it is both easy to use and has a
large user community, resulting in a plethora of available resources (tutorials,
scripts, etc.) online.

Each different shell comes with slighly different support commands, we will be
using `Bash` most often. The following is a list of `Bash` commands.
  
#### A cheatsheet for Bash scripting
Bash is a Unix shell and command language written by Brian Fox for the GNU Project. In Ubuntu, one can use `Ctrl` + `Alt` + `T` to open a bash shell. In a bash shell, we use `man command_name` to get help information related to a command, use `CTRL-C` to break a program and `CTRL-D` to exit a shell or an REPL.

The bash grammar is well summarized in [this cheatsheet](https://devhints.io/bash). The following is a short list for commands that will be used in this course.

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

A more detailed [cheat
sheet](https://cheatography.com/davechild/cheat-sheets/linux-command-line/) and
a [lecture](https://missing.csail.mit.edu/2020/shell-tools/) are available
online. The website [Learn Bash Shell](https://www.learnshell.org/) is also a
good place to start. More advanced readers will find the [lecture on Shell
language](https://missing.csail.mit.edu/2020/shell-tools/) and [Shell Scripting
Tutorial](https://www.shellscript.sh/) themselves more useful.


#### SSH{#sec:ssh}

As an example of the power of the shell, we will show you how to connect to a remote server via the `ssh` command. `ssh` is a network protocol that allows you to communicate with a remote server securely. To do so, we will need a tool for establishing the `ssh` connection.
You can take command of a server via sending it shell commands. To communicate
with a remote server, we will use `ssh`, a network protocol that allows you to
communicate with a remote server securely. To do so, we will need a tool for
establishing the `ssh` connection.

##### SSH Client

For `Linux` users, just open a terminal and type `ssh username@server_address`
will do. A few terminal emulators I like are `gnome-terminal` and `alacritty`.

For `MacOS` users, it works the same as `Linux` users.

For `Windows` users, you may download PuTTY from <https://www.putty.org/> and
follow the instructions there to connect to a server. However, we will use an
IDE called Visual Studio Code. It came with a handy tool called `Remote SSH`.

In order to setup, you will need to setup the `~/.ssh/config` file. 


### Version Control{#sec:version-control} 

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
