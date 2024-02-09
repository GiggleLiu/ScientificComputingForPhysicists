## My First Package{#sec:publishing-package} 
One of the most important features of Julia is its package manager. It allows one to create, manage, and publish his own packages. In this section, we will learn how to create a package and publish it to the Julia registry.

Julia package manager can install the correct version of a package and its dependencies because it knows the exact versions of all the packages that are compatible with each other. This information was stored in the [`General` registry](https://github.com/JuliaRegistries/General) - a central GitHub repository of metadata about all registered Julia packages.

Everyone can register a package in the `General` registry. To do so, you need to:

1. **Create a package** with a unique UUID as its identifier. Although the same registry may not have two packages with the same name, however, using name as the identifier of a package is not safe because it may not be unique when multiple registries are used.
2. **Specify the dependency** of your package in the `Project.toml` file, like which version of a package your package depends on.
3. **Open-source the package** by pushing the package to a public repository on GitHub.
4. **Register the package** in the `General` registry by creating a pull request to the `General` registry. This process can be automated by the [Julia registrator](https://github.com/JuliaRegistries/Registrator.jl).
5. Wait for the pull request to be merged. After that, your package is available to the public. A good practice is to **tag a release** after the pull request is merged so that your package version update can be reflected in your GitHub repository. This process can be automated by the [TagBot](https://github.com/JuliaRegistries/TagBot).

### Create a package
We use [`PkgTemplate`](https://github.com/JuliaCI/PkgTemplates.jl).
Open a Julia REPL and type the following commands to initialize a new package named `MyFirstPackage`:

```julia
julia> using PkgTemplates

julia> tpl = Template(;
    user="GiggleLiu",
    authors="GiggleLiu",
    julia=v"1.10",
    plugins=[
        License(; name="MIT"),
        Git(; ssh=true),
        GitHubActions(; x86=true),
        Codecov(),
        Documenter{GitHubActions}(),
    ],
)

julia> tpl("MyFirstPackage")
```
where the username `"GiggleLiu"` should be replaced with your GitHub username.
Many plugins are used in the above example:

- `License`: to choose a license for the package. Here we use the MIT license. Please refer to [Choosing a license](#sec:license) for more information.
- `Git`: to initialize a Git repository for the package. Here we use the SSH protocol for Git for convenience. Using [two-factor authentication (2FA)](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication) can make your GitHub account more secure.
- `GitHubActions`: to enable continuous integration (CI) with [GitHub Actions](https://docs.github.com/en/actions).
- `Codecov`: to enable code coverage tracking with [Codecov](https://about.codecov.io/). It is a tool that helps you to measure the test coverage of your code. A package with high test coverage is more reliable.
- `Documenter`: to enable documentation building and deployment with [Documenter.jl](https://documenter.juliadocs.org/stable/) and [GitHub pages](https://pages.github.com/).

After running the above commands, a new directory named `MyFirstPackage` will be created in the folder `~/.julia/dev/` - the default location for Julia packages.

**Example**: The structure and CI/CD of [OMEinsum.jl](https://github.com/under-Peter/OMEinsum.jl)

![](./assets/images/omeinsum.png)

`OMEinsum.jl` is a package for tensor contraction. The badges in the `README.md` file of the package repository are the following:

- `build/passing`: the tests executed by GitHub Actions are passing.
- `codecov/89%`: the code coverage is 89%, meaning that 89% of the code is covered by tests.
- `docs/dev`: the documentation is built and deployed with GitHub pages.

Now, let's take a look at the file structure of the package by running the following command in the package path (`~/.julia/dev/OMEinsum`):
```bash
$ tree . -L 1 -a
.
├── .git
├── .github
├── .gitignore
├── LICENSE
├── Project.toml
├── README.md
├── benchmark
├── docs
├── examples
├── ext
├── ome-logo.png
├── src
└── test
```
- `.git` and `.gitignore`: the files that are used by Git. The `.gitingore` file contains the files that should be ignored by Git.
- `.github`: the folder that contains the GitHub Actions configuration files. Its file structure is as follows:
  ```bash
  .github
  └── workflows
      ├── TagBot.yml
      └── ci.yml
  ```
  - The `ci.yml` file contains the configuration for the CI of the package, which is used to automate the process of
    - testing the package after a pull request is opened or the main branch is updated,
    - building the documentation after a pull request is merged.
  - The `TagBot.yml` file contains the configuration for the TagBot, which is used to automate the process of tagging a release after a pull request is merged.
- `LICENSE`: the file that contains the license of the package. The MIT license is used in this package.
- `README.md`: the manual that shows up in the GitHub repository of the package, which contains the description of the package.
- `Project.toml`: the file that contains the metadata of the package, including the name, UUID, version, dependencies and compatibility of the package. To **add a new dependency**, you can use the following command in the package path:
  ```bash
  $ julia --project
  ```
  to enter the package environment, and then type `] add PackageName`.
  The **compatibility**, which is used to specify the version of the package that is compatible with the current package, needs to be updated manually. It is specified in the `[compat]` section of the `Project.toml` file.
  The most widely used dependency version specifier is `=`, which means matching the first nonzero component of the version number. For example:

  - `1` matches `1.0.0`, `1.1.0`, `1.1.1`, but not `2.0.0`.
  - `0.1` matches `0.1.0`, `0.1.1`, `0.1.2`, but not `0.2.0`.
  - `1.2` matches `1.2.0`, `1.3.1`, but not `1.2.0` or `2.0.0`.

  Please check the Julia documentation about [package compatibility](https://pkgdocs.julialang.org/v1/compatibility/) for advanced usage.
- `docs`: the folder that contains the documentation of the package. The documentation is built with [Documenter.jl](https://documenter.juliadocs.org/stable/). The build script is `docs/make.jl`. To **build the documentation**, you can use the following command in the package path:
  ```bash
  $ cd docs
  $ julia --project make.jl
  ```
  Instantiate the documentation environment if necessary. For seamless **debugging** of documentation, it is highly recommended using the [LiveServer.jl](https://github.com/tlienart/LiveServer.jl) package.
- `src`: the folder that contains the source code of the package.
- `test`: the folder that contains the test code of the package. The main test file is `runtests.jl`, which is executed by GitHub Actions. If you want to run local tests, you can use the following command in the package path:
- `ext`: the folder that contains the extension of the package, which should be consistent with the `[weakdeps]` section in the `Project.toml` file.
  ```bash
  $ julia --project -e 'using Pkg; Pkg.test()'
  ```
  or simply type `] test` in the package environment.

### Unit tests

### Choosing a license{#sec:license}
Now that you have an amazing package, it's time to make it available to the public. Before that, there is one final task to be done which is to choose a license. 

- GNU's Not Unix! (GNU) (1983 by Richard Stallman)
    
    Its goal is to give computer users freedom and control in their use of their computers and [computing devices](https://en.wikipedia.org/wiki/Computer_hardware) by collaboratively developing and publishing software that gives everyone the rights to freely run the software, copy and distribute it, study it, and modify it. GNU software grants these rights in its [license](https://en.wikipedia.org/wiki/GNU_General_Public_License).
    <img src="./assets/images/gnu.png" alt="image" width="300" height="auto">
- The problem of GPL Lisense: The GPL and licenses modeled on it impose the restriction that source code must be distributed or made available for all works that are derivatives of the GNU copyrighted code.
    
    Case study: [Free Software fundation v.s. Cisco Systems](https://www.notion.so/Wiki-53dd9dafd57b40f6b253d6605667a472)
    
    Modern Licenses are: [MIT](https://en.wikipedia.org/wiki/MIT_License) and [Apache](https://en.wikipedia.org/wiki/Apache_License).
