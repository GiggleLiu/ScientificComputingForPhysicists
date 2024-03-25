# Tensor Operations

## Einsum notation
The einsum notation is a compact way to specify tensor contractions with a string. In the this notation, an index (subscripts) is represented by a char, and the tensors are represented by the indices. The input tensors and the output tensor are separated by an arrow `->` and input tensors are separated by comma `,`. For example, the matrix multiplication $C_{ik} := \sum_j A_{ij}B_{jk}$ can be written as `"ij,jk->ik"`. The einsum notation is a powerful tool to specify tensor contractions, and it is widely used in physics, machine learning, and mathematics.

!!! note "Example - Einsum notation"
    Unary examples:
    - `"i->"`: sum of the elements of a vector.
    - `"ij->i"`: sum of the rows of a matrix.
    - `"ii->"`: sum of the diagonal elements of a matrix, i.e., the trace.
    - `"ij->"`: sum of the elements of a matrix.
    - `"i->ii"`: create a diagonal matrix.
    - `"i->ij"`: repeat a vector to form a matrix.
    - `"ijk->ikj"`: permute the dimensions of a tensor.

    Binary examples:
    - `"ij,jk->ik"`: matrix multiplication.
    - `"ijb,jkb->ikb"`: batch matrix multiplication.
    - `"ij,ij->ij"`: element-wise multiplication.
    - `"ij,ij->"`: sum of the element-wise multiplication.
    - `"ij,->ij"`: element-wise multiplication by a scalar.

    Nary examples:
    - `"ai,aj,ak->ijk"`: star contraction.
    - `"ia,ajb,bkc,cld,dm->ijklm"`: tensor train contraction.

```@repl tensor
using OMEinsum, SymEngine
catty = fill(Basic(:🐱), 2, 2)
fish = fill(Basic(:🐟), 2, 3, 2)
snake = fill(Basic(:🐍), 3, 3)
medicine = ein"ij,jki,kk->k"(catty, fish, snake)
ein"ik,kj -> ij"(catty, catty) # multiply two matrices `a` and `b`
ein"ij -> "(catty)[] # sum a matrix, output 0-dimensional array
ein"->ii"(asarray(snake[1,1]), size_info=Dict('i'=>5)) # get 5 x 5 identity matrix
```

### The diagrammatic representation

## The spin-glass problem
The spin-glass problem is a combinatorial optimization problem that is widely used in physics, computer science, and mathematics. The problem is to find the ground state of a spin-glass Hamiltonian, which is a function of the spin configuration. The Hamiltonian is defined as
```math
H(\sigma) = -\sum_{i,j} J_{ij} \sigma_i \sigma_j + \sum_i h_i \sigma_i,
```
where $\sigma_i \in \{-1, 1\}$ is the spin variable, $J_{ij}$ is the coupling strength between spins $i$ and $j$, and $h_i$ is the external field acting on spin $i$. The first term is the interaction energy between spins, and the second term is the energy due to the external field. The ground state is the spin configuration that minimizes the Hamiltonian.

```@raw html
<img src="../../assets/images/spinglass.png" width="400" />
```

The thermal equilibrium of the spin-glass system is described by the Boltzmann distribution
```math
P(\sigma) = \frac{1}{Z} e^{-\beta H(\sigma)},
```
where $\beta = 1/T$ is the inverse temperature, and $Z$ is the partition function
```math
Z = \sum_{\sigma} e^{-\beta H(\sigma)}.
```
The partition function is the normalization constant that ensures the probability distribution sums to one. The partition function is a sum over all possible spin configurations, which makes it computationally intractable for large systems.

The partition function can be expressed as a tensor contraction using the einsum notation. The partition function is a sum over all possible spin configurations, which can be represented as a tensor contraction over the spins. The partition function can be written as
```math
Z = \sum_{\sigma} e^{-\beta H(\sigma)} = \sum_{\sigma} e^{\beta \sum_{i,j} J_{ij} \sigma_i \sigma_j + \sum_i h_i \sigma_i} = \sum_{\sigma} \prod_{i,j} e^{\beta J_{ij} \sigma_i \sigma_j} \prod_i e^{h_i \sigma_i}.
```

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

Quiz: compare the size of storage before/after the tucker decomposition.

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
\begin{align*}
&\texttt{Repeat:}\\
&~~~~\texttt{for}~~k= l:d\\ 
&~~~~~~~~\text{Minimize }\| A_{(k)} - \tilde{F}^{(k)} (F^{(d)} \odot \ldots\odot F^{(k+ l)} \odot F^{(k-1)} \odot \ldots \odot F^{(1)})\|_F\\
&~~~~~~~~~~~~\text{ with respect to }\tilde{F}(k).\\
&~~~~~~~~\texttt{for}~~j = l:r\\
&~~~~~~~~~~~~\lambda_j = \|\tilde{F}_{(k)}( :,j)\|\\
&~~~~~~~~~~~~F^{(k)}(:,j) = \tilde{F}_k ( :,j)/\lambda_j\\
&~~~~~~~~\texttt{end}\\
&~~~~\texttt{end}
\end{align*}
```


```@repl tensor
ein"ij, jk -> ik"([1 2; 3 4], [5 6; 7 8])
```

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
A tensor network is a multi-linear map specified by a triple of $\mathcal{N} = (\Lambda, \mathcal{T}, \boldsymbol{\sigma}_o)$, where $\Lambda$ is a set of symbols (or labels), $\mathcal{T} = \{T^{(1)}_{\boldsymbol{\sigma}_1}, T^{(2)}_{\boldsymbol{\sigma}_2}, \ldots, T^{(M)}_{\boldsymbol{\sigma}_M}\}$ is a set of tensors as the inputs,
and $\boldsymbol{\sigma}_o$ is a string of symbols labelling the output tensor.
Each $T^{(k)}_{\boldsymbol{\sigma_k}} \in \mathcal{T}$ is labelled by a string $\boldsymbol{\sigma}_k \in \Lambda^{r \left(T^{(k)} \right)}$, where $r \left(T^{(k)} \right)$ is the rank of $T^{(k)}$.
The multi-linear map or the **contraction** on this triple is

```math
\begin{equation}
    O_{\boldsymbol{\sigma}_o} = \sum_{\Lambda \setminus \sigma_o} \prod_{k=1}^{M} T^{(k)}_{\boldsymbol{\sigma_k}},
\end{equation}
```
where the summation runs over all possible configurations over the set of symbols absent in the output tensor.

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