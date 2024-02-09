# Scientific Computing for Physicists with Julia

Online book is deployed at: <https://book.jinguo-group.science/>

This book is also available as PDF. To build a PDF, please run `make build` locally (see below).

## Developer note

In order to build and deploy the website, you will need to run the following
commands in the terminal:

```bash
make init
make build
make serve
```
When you add new sections to the book, don't forget to edit the `config.toml` file.
For more information about the `Books.jl`, see <https://huijzer.xyz/Books.jl/>.

The source code for this template can be found at <https://github.com/GiggleLiu/ScientificComputingForPhysicists>.
