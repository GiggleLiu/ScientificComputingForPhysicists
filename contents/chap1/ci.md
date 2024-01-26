## Code MUST be Tested!{#sec:ci-cd}

In terms of scientific computing, accuracy of your result is most certainly more
important than anything else. To ensure the correctness of the code, we employ
two methods: **Unit Testing** and **CI/CD**.

### Unit Test
Unit tests are typically [automated
tests](https://en.wikipedia.org/wiki/Automated_test) written and run
by [software developers](https://en.wikipedia.org/wiki/Software_developer) to
ensure that a section of an application (known as the "unit") meets
its [design](https://en.wikipedia.org/wiki/Software_design) and behaves as
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

