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

