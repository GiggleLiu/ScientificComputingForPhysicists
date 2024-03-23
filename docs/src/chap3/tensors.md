# Tensor Operations

## Einsum notation
The einsum notation is a compact way to specify tensor contractions with a string. In the einsum notation, the indices of input tensors are separated by a comma `,` and the output tensor by an arrow `->`. For example, the matrix multiplication $C_{ik} := \sum_j A_{ij}B_{jk}$ can be written as `"ij,jk->ik"`. The einsum notation is a powerful tool to specify tensor contractions, and it is widely used in physics, machine learning, and mathematics.

!!! note "Example - Einsum notation"
    Unary examples:
    - `"i->"`: sum of the elements of a vector.
    - `"ij->i"`: sum of the rows of a matrix.
    - `"ii->"`: sum of the diagonal elements of a matrix, i.e., the trace.
    - `"ij->"`: sum of the elements of a matrix.
    - `"i->ii"`: create a diagonal matrix.
    - `"i->ij"`: repeat a vector to form a matrix.

    Binary examples:
    - `"ij,jk->ik"`: matrix multiplication.
    - `"ijb,jkb->ikb"`: batch matrix multiplication.
    - `"ij,ij->ij"`: element-wise multiplication.
    - `"ij,ij->"`: sum of the element-wise multiplication.
    - `"ij,->ij"`: element-wise multiplication by a scalar.

    Nary examples:
    - `"ai,aj,ak->ijk"`: star contraction.
    - `"ia,ajb,bkc,cld,dm->ijklm"`: tensor train contraction.

```@example tensor
using LuxorGraphPlot, Luxor
using LinearAlgebra
using OMEinsum
```

# Tensors and tensor decomposition
Golub, Section 12


## Tensor contraction


We use the `einsum` function to compute the tensor contraction.


### The diagramatic representation
## Higher order SVD
Quiz: How do you use matrix singular value decomposition (or principle componnt analysis) in your own research?


### Tucker decomposition

Suppose $A \in R^{n_1\times n_2\times n_3}$ and assume that $r \leq {\rm rank}(A)$with inequality in at least one component. Prompted by the optimality properties of the matrix SVD, let us consider the following optimization problem:
```math
\min_{X} \| A - X \|_F
```
such that 
```math
X_{lmn} = \sum_{j_1=j_2=j_3=1}^{r_1, r_2, r_3} S_{j_1j_2j_3} (U_1)_{lj_1}(U_2)_{mj_2}(U_3)_{nj_3}.
```

We refer to this as the Tucker approximation problem.



The pseudocode for Tucker decomposition algorithm:
```math
\begin{align}
&\texttt{Repeat:}\\
&~~~~\texttt{for} ~~k = l,\ldots,d\\
&~~~~~~~~\text{Compute the SVD}\\
&~~~~~~~~~~~~A(k) (U_d \otimes \ldots \otimes U_{k+1} \otimes U_{k-1} \otimes \ldots \otimes U_1) = \tilde{U}_k\Sigma_kV_k^T\\
&~~~~~~~~U_k = \tilde{U}_k(:,1:r_k)\\
&~~~~\texttt{end}
\end{align}
```


```@example tensor
function tucker_movefirst(X::AbstractArray{T, N}, Us, k::Int) where {N, T}
    Ak = X
    for i=1:N
        # move i-th dimension to the first
        if i!=1
            pm = collect(1:N)
            pm[1], pm[i] = pm[i], pm[1]
            Ak = permutedims(Ak, pm)
        end
        if i != k
            # multiply Uk on the i-th dimension
            remain = size(Ak)[2:end]
            Ak = Us[i]' * reshape(Ak, size(Ak, 1), :)
            Ak = reshape(Ak, size(Ak, 1), remain...)
        end
    end
    A_ = permutedims(Ak, (2:N..., 1))
    return permutedims(A_, (k, setdiff(1:N, k)...))
end
```

function tucker_project(X::AbstractArray{T, N}, Us; inverse=false) where {N, T}
    Ak = X
    for i=1:N
        # move i-th dimension to the first
        if i!=1
            pm = collect(1:N)
            pm[1], pm[i] = pm[i], pm[1]
            Ak = permutedims(Ak, pm)
        end
        remain = size(Ak)[2:end]
        Ak = (inverse ? Us[i] : Us[i]') * reshape(Ak, size(Ak, 1), :)
        Ak = reshape(Ak, size(Ak, 1), remain...)
    end
    return permutedims(Ak, (2:N..., 1))
end

function tucker_decomp(X::AbstractArray{T,N}, rs::Vector{Int}; nrepeat::Int) where {T, N}
    # the first sweep, to generate U_k
    Us = [Matrix{T}(I, size(X, i), size(X, i)) for i=1:N]
    Ak = X
    for n=1:nrepeat
        for i=1:N
            Ak = tucker_movefirst(X, Us, i)
            ret = svd(reshape(Ak, size(Ak, 1), :))
            Us[i] = ret.U[:,1:rs[i]]
        end
        Ak = permutedims(Ak, (2:N..., 1))
        dist = norm(tucker_project(tucker_project(X, Us), Us; inverse=true) .- X)
        @info "The Frobenius norm distance is: $dist"
    end
    return tucker_project(X, Us), Us
end

X = randn(20, 10, 15);

Cor, Us = tucker_decomp(X, [4, 5, 6]; nrepeat=10)

Quiz: compare the size of storage before/after the tucker decomposition."

### CP decomposition


Given $X \in R^{n_1 \times n_2\times n_3}$ and an integer $r$, we consider the problem
```math
\min_X \|A - X\|
```
such that 
```math
X_{lmn} = \sum_{j=1}^{r}\lambda_j F_{lj} G_{mj} H_{nj}
```
where $F\in R^{n_1\times r}$, $G\in R^{n_2\times r}$, and $H\in R^{n_3\times r}$. This is an example of the CP approximation problem. We assume that the columns of $F$, $G$, and $H$ have unit 2-norm.


```math
\begin{align}
&\texttt{Repeat:}\\
&~~~~\texttt{for}~~k= l:d\\ 
&~~~~~~~~\text{Minimize }\| A_{(k)} - \tilde{F}^{(k)} (F^{(d)} \odot \ldots\odot F^{(k+ l)} \odot F^{(k-1)} \odot \ldots \odot F^{(1)})\|_F\\
&~~~~~~~~~~~~\text{ with respect to }\tilde{F}(k).\\
&~~~~~~~~\texttt{for}~~j = l:r\\
&~~~~~~~~~~~~\lambda_j = \|\tilde{F}_{(k)}( :,j)\|\\
&~~~~~~~~~~~~F^{(k)}(:,j) = \tilde{F}_k ( :,j)/\lambda_j\\
&~~~~~~~~\texttt{end}\\
&~~~~\texttt{end}
\end{align}
```


# Tensor contraction


The `einsum` notation.
* The `einsum` notation for matrix multiplication $C_{ik} := A_{ij}B_{jk}$ is `"ij,jk->ik"`.
* The `einsum` notation for element-wise multiplication is `i,i->i`.
* Guess, what are
    * `ii->`
    * `ii->i`
    * `i->ii`
    * `,,->`
    * `ijb,jkb->ikb`
    * `ij,ik,il->jkl`


ein"ij, jk -> ik"([1 2; 3 4], [5 6; 7 8])


## The backward rule of tensor contraction


The backward rule for matrix multiplication is
* `C = ein"ij,jk->ik"(A, B)`
    * `̄A = ein"ik,jk->ij"(̄C, B)`
    * `̄B = ein"ik,jk->ij"(A, ̄C)`
* `v = ein"ii->i"(A)`
    * `̄A = ein"?"(̄v)`


# Probability graph


| **Random variable**  | **Meaning**                     |
|        :---:         | :---                            |
|        A         | Recent trip to Asia             |
|        T         | Patient has tuberculosis        |
|        S         | Patient is a smoker             |
|        L         | Patient has lung cancer         |
|        B         | Patient has bronchitis          |
|        E         | Patient hast T and/or L |
|        X         | Chest X-Ray is positive         |
|        D         | Patient has dyspnoea            |


let
    r = 20
    W = 200
    vars = [
        ("A", 0.0, 0.0), ("S", 0.75, 0.0),
        ("T", 0.0, 0.3), ("L", 0.5, 0.3), ("B", 1.0, 0.3), 
        ("E", 0.25, 0.6), ("X", 0.0, 0.9), ("D", 0.75, 0.9)]
    @drawsvg begin
        origin(200, 0)
        nodes = []
        for (t, x, y) in vars
            push!(nodes, node(circle, Point(x*W+0.15W, y*W+0.15W), r, :stroke))
        end
        for (k, node) in enumerate(nodes)
            LuxorGraphPlot.draw_vertex(node, stroke_color="black",
                fill_color="white", line_width=2, line_style="solid")
            LuxorGraphPlot.draw_text(node.loc, vars[k][1]; fontsize=14, color="black", fontface="")
        end
        for (i, j) in [(1, 3), (2, 4), (2, 5), (3, 6), (4, 6), (5, 8), (6, 7), (6, 8)]
            LuxorGraphPlot.draw_edge(nodes[i], nodes[j], color="black", line_width=2, line_style="solid", arrow=true)
        end
    end 600 W*1.3
end

A probabilistic graphical model (PGM) illustrates the mathematical modeling of reasoning in the presence of uncertainty. Bayesian networks (above) and Markov random fields are popular types of PGMs. Consider the
Bayesian network shown in the figure above known as the *ASIA network*. It is a simplified example from the context of medical
diagnosis that describes the probabilistic relationships between different
random variables corresponding to possible diseases, symptoms, risk factors and
test results. It consists of a graph ``G = (V,\mathcal{E})`` and a
probability distribution ``P(V)`` where ``G`` is a directed acyclic graph,
``V`` is the set of variables and ``\mathcal{E}`` is the set of edges
connecting the variables. We assume all variables to be discrete (0 or 1). Each variable ``v \in V`` is quantified with a *conditional probability distribution* ``P(v \mid
pa(v))`` where ``pa(v)`` are the parents of ``v``. These conditional
probability distributions together with the graph ``G`` induce a *joint
probability distribution* over ``P(V)``, given by
```math
P(V) = \prod_{v\in V} P(v \mid pa(v)).
```


## The tensor network


A tensor network in physics is also known as the **factor graph** in machine learning, and the **sum-product network** in mathematics."

A tensor network is a multi-linear map from a collection of labelled tensors $\mathcal{T}$ to an output tensor.
It is formally defined as follows.

**Definition:**
    A tensor network is a multi-linear map specified by a triple of $\mathcal{N} = (\Lambda, \mathcal{T}, \boldsymbol{\sigma}_o)$,
    where $\Lambda$ is a set of symbols (or labels),
    $\mathcal{T} = \{T^{(1)}_{\boldsymbol{\sigma}_1}, T^{(2)}_{\boldsymbol{\sigma}_2}, \ldots, T^{(M)}_{\boldsymbol{\sigma}_M}\}$ is a set of tensors as the inputs,
    and $\boldsymbol{\sigma}_o$ is a string of symbols labelling the output tensor.
    Each $T^{(k)}_{\boldsymbol{\sigma_k}} \in \mathcal{T}$ is labelled by a string $\boldsymbol{\sigma}_k \in \Lambda^{r \left(T^{(k)} \right)}$, where $r \left(T^{(k)} \right)$ is the rank of $T^{(k)}$.
    The multi-linear map or the **contraction** on this triple is
```math
\begin{equation}
    O_{\boldsymbol{\sigma}_o} = \sum_{\Lambda \setminus \sigma_o} \prod_{k=1}^{M} T^{(k)}_{\boldsymbol{\sigma_k}},
\end{equation}
```
where the summation runs over all possible configurations over the set of symbols absent in the output tensor.
\end{definition}
For example, the matrix multiplication can be specified as a tensor network
```math
\begin{equation}
\mathcal{N}_{\rm matmul} = \left(\{i,j,k\}, \{A_{ij}, B_{jk}\}, ik\right),
\end{equation}
```
where $A_{ij}$ and $B_{jk}$ are input matrices (two-dimensional tensors), and $(i,k)$ are labels associated to the output.
The contraction is defined as $O_{ik} = \sum_j A_{ij}B_{jk}$, where the subscripts are for tensor indexing, and the tensor dimensions with the same label must have the same size.
The graphical representation of a tensor network is an open hypergraph that having open hyperedges, where an input tensor is mapped to a vertex and a label is mapped to a hyperedge that can connect an arbitrary number of vertices, while the labels appearing in the output tensor are mapped to open hyperedges.


## The partition function
[https://uaicompetition.github.io/uci-2022/competition-entry/tasks/](https://uaicompetition.github.io/uci-2022/competition-entry/tasks/)


## The optimal contraction of a tensor network


eincode = ein"at,ex,sb,sl,tle,ebd,a,s,t,l,b,e,x,d->"

optimized_eincode = optimize_code(eincode, uniformsize(eincode, 2), TreeSA())

contraction_complexity(optimized_eincode, uniformsize(optimized_eincode, 2))

function contract(ancillas...)
    # 0 -> NO
    # 1 -> YES
    AT = [0.98 0.02; 0.95 0.05]
    EX = [0.99 0.01; 0.02 0.98]
    SB = [0.96 0.04; 0.88 0.12]
    SL = [0.99 0.01; 0.92 0.08]
    TLE = zeros(2, 2, 2)
    TLE[1,:,:] .= [1.0 0.0; 0.0 1.0]
    TLE[2,:,:] .= [0.0 1.0; 0.0 1.0]
    EBD = zeros(2, 2, 2)
    EBD[1,:,:] .= [0.8 0.2; 0.3 0.7]
    EBD[2,:,:] .= [0.2 0.8; 0.05 0.95]
    return optimized_eincode(AT, EX, SB, SL, TLE, EBD, ancillas...)[]
end


## The backward rule for factor graph contraction


contract([0.0, 1.0], [1.0, 0.0], [1.0, 1.0], # A, S, T
        [0.0, 1.0], [1.0, 1.0], # L, B
        [1.0, 1.0], # E
        [1.0, 1.0], [1.0, 1.0] # X, D
        )

| **Random variable**  | **Meaning**                     |
|        :---:         | :---                            |
|        A         | Recent trip to Asia             |
|        T         | Patient has tuberculosis        |
|        S         | Patient is a smoker             |
|        L         | Patient has lung cancer         |
|        B         | Patient has bronchitis          |
|        E         | Patient hast T and/or L |
|        X         | Chest X-Ray is positive         |
|        D         | Patient has dyspnoea            |


# Homework
1. What is the einsum notation for outer product of two vectors?
2. What does the einsum notation `"jk,kl,lm,mj->"` stands for?
2. The tensor network `"abc,cde,efg,ghi,ijk,klm,mno->abdfhjlno"` is known as matrix product state in physics or tensor train in mathematics. Please
    1. Draw a diagramatic representation for it.
    2. If we contract it with another tensor network `"pbq,qdr,rfs,sht,tju,ulv,vnw->pbdfhjlnw"`, i.e., computing `abc,cde,efg,ghi,ijk,klm,mno,pbq,qdr,rfs,sht,tju,ulv,vnw->apow`. What is the optimal contraction order in the diagram, and estimate the contraction complexity (degree of freedoms have the same size $n$).
    3. Using `OMEinsum` (check the section "Probability graph") to obtain a contraction order and compare it with your answer.
