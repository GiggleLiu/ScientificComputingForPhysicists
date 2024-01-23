# Shell {#sec:shell}

You can take command of a server via sending it shell commands. To communicate
with a remote server, we will use `ssh`, a network protocol that allows you to
communicate with a remote server securely. To do so, we will need a tool for
establishing the `ssh` connection.

## SSH Client

For `Linux` users, just open a terminal and type `ssh username@server_address`
will do. A few terminal emulators I like are `gnome-terminal` and `alacritty`.

For `MacOS` users, it works the same as `Linux` users.

For `Windows` users, you may download PuTTY from <https://www.putty.org/> and
follow the instructions there to connect to a server. However, we will use an
IDE called Visual Studio Code. It came with a handy tool called `Remote SSH`.

In order to setup, you will need to setup the `~/.ssh/config` file. 

An example setup will be like 

```bash

```
# Setup HPC environment {#sec:HPC}

Unlike programmers, physicists don't have a preferred operating system. However, Linux systems provide an unparallel advantage in terms of ease of learning and debugging due to the active community support. Therefore, it's highly recommended to use Linux system for scientific computing tasks. Nevertheless, it's not practical to ask for any one to have a Linux machine ready to go. Therefore, we will use the HPC system provided by your favourite vendor may it be AWS, Google Cloud, Microsoft Azure, or your local university.

## SSH
The first step to using HPC is to connect to it via SSH. 




## Setup 
### Julia

### Python 
Anaconda provides an easy way to install Python environments and its packages. However, it's not customary to have anaconda installed on HPC systems directly. You might need to load it via

```bash
module load module anaconda3
conda init bash
```
