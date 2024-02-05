## Correctness - Unit Tests{#sec:ci-cd}

In terms of scientific computing, accuracy of your result is most certainly more important than anything else. To ensure the correctness of the code, we employ two methods: **Unit Testing** and **CI/CD**.

### Unit Test
Unit tests are typically [automated tests](https://en.wikipedia.org/wiki/Automated_test) written and run by [software developers](https://en.wikipedia.org/wiki/Software_developer) to ensure that a section of an application (known as the "unit") meets its [design](https://en.wikipedia.org/wiki/Software_design) and behaves as intended.
Unit tests are composed of a series of individual test cases, each of which verifies the correctness by using **assertions**. If all assertions are true, the test case passes; otherwise, it fails. The unit tests are run automatically whenever the code is changed, ensuring that the code is always in a working state.
In Julia, there exists a helpful module called [Test](https://docs.julialang.org/en/v1/stdlib/Test/) to help you do unit testing.

### Automate your workflow - CI/CD
CI/CD, which stands for continuous integration and continuous delivery/deployment, aims to streamline and accelerate the software development lifecycle.
CI/CD are often integrated with git hosting services, e.g. [Github Actions](https://docs.github.com/en/actions). Typical CI/CD pipelines include the following steps:

- Automatically **build**, **test** and **merge** the code changes whenever a developer commits code to the repository.
- Automatically **deploy** the code or documentation to a cloud service.

The CI/CD pipeline is a powerful tool to ensure the correctness of the code and the reproducibility of the results. It is also a good practice to use CI/CD to automate the workflow, especially when you are working with a team.