## Get a Terminal!

You need to get a working terminal to follow the instructions in this book.

### Linux operating system{#sec:linux}

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

A cheatsheet for Bash scripting

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
You will get logged in after inputting the password.

It will be tedious to type the host name and user name everytime you want to
login to the remote machine. You can setup the `~/.ssh/config` file to make your
life easier. The following is an example of the `~/.ssh/config` file.

```
Host amat5315
  HostName 10.100.0.179
  User user01
```

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

