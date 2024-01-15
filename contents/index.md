# Welcome {-}



This website is also available as [**PDF**](/sci2phys.pdf){target="_blank"}.

**Developer note**

To build the website, run the following command in the terminal:

```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project -e 'using Books;  serve()'
```
For more information about the `Books.jl`, see <https://huijzer.xyz/Books.jl/>.

Note, the `Books.jl` package may not work on your M1 Mac. 
I have made a fork at <https://github.com/exAClior/Books.jl>.
The branch  `ys/versionbump` contains a working version.

The source for this template can be found at <https://github.com/GiggleLiu/ScientificComputingForPhysicists>.
