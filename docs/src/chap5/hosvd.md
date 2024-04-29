## Higher order SVD

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
\begin{align*}
&\texttt{Repeat:}\\
&~~~~\texttt{for} ~~k = l,\ldots,d\\
&~~~~~~~~\text{Compute the SVD}\\
&~~~~~~~~~~~~A(k) (U_d \otimes \ldots \otimes U_{k+1} \otimes U_{k-1} \otimes \ldots \otimes U_1) = \tilde{U}_k\Sigma_kV_k^T\\
&~~~~~~~~U_k = \tilde{U}_k(:,1:r_k)\\
&~~~~\texttt{end}
\end{align*}
```

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

