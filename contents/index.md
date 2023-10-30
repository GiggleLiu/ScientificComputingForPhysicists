# Scientific Computing for Physicists {-}

## Introduction and Motivation {-}
We are entering an era of exploding data, ever more difficult problems, and
artificial intelligence boom. It is more important than ever to learn how to use
computers to solve probblems for physicists. This book seeks to provide bare
minimum knowledge for a physicist to comfortably speedup their work with
computers. The language we choose is [Julia](https://julialang.org/). Julia is a
dynamic language. Like other dynamic language, Julia is really easy to learn.
Therefore, the potential barrier for adpoting this tool for physicists is small.
More importantly, it is easy to make your Julia code run fast. Thanks to the
complicated type system and C-like memory structure, Julia code can use memory
very efficiently (needs rewording). Therefore, Julia code can achieve C-like
performance which is very hard to beat. Lastly, Julia has a vibrant
[community](https://julialang.org/community/) and open-source is a founding
stone in the culture of us. This means you will never be alone facing some
problem in your work. And, you can easily be the one that's contributing to the
community.

It is as they say "An artisan must first sharpen his tools if he is to do his
work well". In order to start our journey in scientific computing, we need to
sharpen our tools. The most importatn tool in scientific computing and
programming in large is a good operating system. But what constitutes a good
operating system. A good operating system should be one where knowledge
preservation and transmission is easy. By this standard, Windows operating
system is already out of the question since everything it does involves a GUI.
It is hard to make a followable step by step guide of doing something.

Physicists come from vastly
different backgrounds. Many of them may not have been exposed to the world of
Linux and Unix-like operating system. But there is

This website is also available as [**PDF**](/sci2phys.pdf){target="_blank"}.

**Developer note**

To build the website, run the following command in the terminal:

```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project -e 'using Books; serve()'
```
For more information about the `Books.jl`, see <https://huijzer.xyz/Books.jl/>.


The source for this template can be found at <https://github.com/GiggleLiu/ScientificComputingForPhysicists>.
