# The workflow to complete homework

## Install a suitable Linux distribution
1. Please check the [homepage](https://www.ubuntu.com/) for the latest version of Ubuntu Linux.
2. Install required packages, e.g. to install git:
    1. Open a terminal with `Ctrl-Alt-T`
    2. Type `sudo apt-get install git`

Here, we use `ssh` to connect to a remote server with Ubuntu Linux installed. The `ssh` is a secure shell protocol to connect to a remote server. The `ssh` is a default package in Ubuntu Linux, so you do not need to install it. In a terminal, type
```
ssh username@server
```
where `username` is your username and `server` is the server address.

### Using cluster interactively
1. You can login to the cluster with
    ```bash
    ssh username@server
    ```
    where `username` is your username and `server` is the server address. At HKUST-GZ, the server address is `login1.hpc.ust.hk` and the account can be applied from the Dingtalk.
3. It is "criminal" to run programs on the login node, you need to submit a job to the cluster or start an interactive session. To start an interactive session on a virtual machine with 1 GPU for 1 hour, you can run
    ```bash
    module load slurm

    srun --nodes=1 --gres=gpu:a800 --ntasks-per-node=1 --time=01:00:00 -i
    ```
    where `--nodes=1` means you want to use 1 node, `--gres=gpu:a800` means you want to use 1 GPU, `--ntasks-per-node=1` means you want to use 1 CPU core, `--time=01:00:00` means you want to use 1 hour, `-i` means you want to start an interactive session. You need to wait for a while before the interactive session is started.

4. If you are a Julia CUDA users, you might want to specify the run time version of CUDA with
    ```julia
    julia> CUDA.set_runtime_version!(; local_toolkit=true)
    ```
    and then RESTART the Julia session.

## How to submit homework?
### Git concepts
- **repository**: a repository is a collection of files and folders. A repository can be local or remote. A local repository is a folder on your local machine. A remote repository is a folder on a remote server. A remote repository can be accessed with a URL, e.g.
    Our course repository is
    ```
    https://github.com/GiggleLiu/ModernScientificComputing2024.git
    ```
    Our homework repository is
    ```
    https://github.com/CodingThrust/AMAT5315HW.git
    ```
    You can clone a remote repository with `git clone remote-url`. You can check the current remote repository with `git remote -v`.
- **commit**: a commit is a snapshot of the repository. You can create a commit with `git commit -m 'commit message'`. You can check the commit history with `git log`.
- **branch**: a branch is a pointer to a commit. The default branch is `master`. You can create a new branch with `git branch new-branch-name`. You can switch to a branch with `git checkout new-branch-name`. You can check the current branch with `git branch`.
- **remote**: a remote is a pointer to a remote repository. You can check the current remote with `git remote -v`. You can add a new remote with `git remote add remote-name remote-url`. You can remove a remote with `git remote remove remote-name`.
- **fork**: a fork is a copy of a remote repository. You can fork a remote repository with `git fork remote-url`. You can check the current fork with `git remote -v`. You can add a new fork with `git remote add fork-name fork-url`. You can remove a fork with `git remote remove fork-name`.
- **rebasing**: rebasing is a way to update your local repository with the remote repository. You can rebase your local repository with `git pull --rebase`. You can rebase a branch with `git pull --rebase remote-name branch-name`. You can rebase a fork with `git pull --rebase fork-name branch-name`.

Create a GitHub account, please check the [GitHub homepage](https://github.com/).

1. Fork the homework Github repository. Open the GitHub repository [CodingThrust/AMAT5315HW](), click the fork button. Then you will have a new copy of the original repository with the write permission. Clone the repo to the local host with
    ```bash
    git clone https://github.com/GiggleLiu/AMAT5315HW.git
    ```
    where `GiggleLiu` is my GitHub handle.

2. Edit the homework.
    1. Type `cd ~/jcode/AMAT5315HW` to open the homework directory
    2. Type `git pull` to get the latest version of the homework.

3. Commit the changes. Type
   ```bash
   git add -A
   git commit -m 'this is my homework for review'
   git push
   ```
   The `git add -A` will add all changes to the list of changes to commit.
   If you want to avoid adding some files to your commit history, please edit the `.gitignore` file. For example, to avoid syncing the `data` folder, you could add a new line
   ```
   data/
   ```
   to the `.gitignore` file.

4. Open your forked GitHub repo, you will see a suggested action of creating a pull request (PR). If you missed this hint, you can create a PR manually by checking the "pull request" tab.

5. My teaching assistant will either comment on your PR to request for some change or merge your PR directly. You need to implement the requested changes and commit again. The PR will be udpated automatically on new commit.

The remote repository can be.