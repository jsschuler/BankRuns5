# Proof Sketches

Notation used throughout: $N$ = number of agents, $\delta$ = deposit (homogeneous
case), $\delta_i$ = deposit of agent $i$ (heterogeneous case), $\mathcal{V}_k$ =
vault balance after $k$ withdrawals, $q = 1 - p_0 \in (0,1)$.

---

## Theorem 0 — DD Fragility Inflation

**Setup.**
- $N$ agents, deposit normalized to 1.
- Investment technology: 1 unit at $t=1$ yields $R>1$ at $t=3$, or $r \in (0,1)$
  if liquidated at $t=2$.
- Early withdrawal contract: $c_1 = 1 + r_1$, $r_1 \geq 0$.
- Sequential service. If fraction $f$ withdraws at $t=2$, bank liquidates $fc_1/r$
  of investment. Solvency requires $fc_1/r \leq 1$, i.e.\ $f \leq r/c_1$.
- Residual payoff to late withdrawers:

$$c_2(f) \;=\; \frac{R\!\left(1 - \dfrac{fc_1}{r}\right)}{1-f}
\qquad \text{for } f < 1,\; fc_1 \leq r$$

**Theorem.** The good equilibrium (only type-1 agents, fraction $\lambda$, withdraw)
is locally stable if and only if $\lambda < f^*(c_1)$, where

$$\boxed{f^*(c_1) \;=\; \frac{r(R - c_1)}{c_1(R-r)}}$$

The stability gap between the realistic contract ($c_1 = 1$, $r_1 = 0$) and the
DD contract ($c_1 = 1+r_1$, $r_1 > 0$) is

$$\boxed{\Delta f^* \;=\; f^*(1) - f^*(1+r_1) \;=\; \frac{rR\,r_1}{(1+r_1)(R-r)}}$$

with $\Delta f^* > 0$ for all $r_1 > 0$, strictly increasing in $r_1$, and
$\Delta f^* \to 0$ as $r_1 \to 0$.

**Proof.**

*Step 1: Stability condition.*
A marginal type-2 agent prefers to stay iff $c_2(\lambda) > c_1$:

$$\frac{R\!\left(1 - \dfrac{\lambda c_1}{r}\right)}{1 - \lambda} > c_1$$

$$R\!\left(1 - \frac{\lambda c_1}{r}\right) > c_1(1-\lambda)$$

$$R - \frac{R\lambda c_1}{r} > c_1 - c_1\lambda$$

$$R - c_1 > \frac{R\lambda c_1}{r} - c_1\lambda \;=\; \lambda c_1\!\left(\frac{R}{r} - 1\right)
\;=\; \lambda c_1 \cdot \frac{R - r}{r}$$

$$\lambda \;<\; \frac{r(R - c_1)}{c_1(R - r)} \;=\; f^*(c_1) \qquad \square_1$$

Note: requires $R > c_1$ (otherwise $f^* \leq 0$ and the good equilibrium is never
stable). For the DD contract $c_1 = 1 + r_1$, this means $R > 1 + r_1$, which is
assumed to hold.

*Step 2: Monotonicity in $c_1$.*

$$\frac{df^*}{dc_1} \;=\; \frac{d}{dc_1}\!\left[\frac{r(R-c_1)}{c_1(R-r)}\right]
\;=\; \frac{r}{R-r}\cdot\frac{d}{dc_1}\!\left[\frac{R}{c_1} - 1\right]
\;=\; \frac{r}{R-r}\cdot\left(-\frac{R}{c_1^2}\right)
\;=\; -\frac{rR}{c_1^2(R-r)} \;<\; 0 \qquad \square_2$$

*Step 3: Stability gap.*

$$\Delta f^* \;=\; \frac{r(R-1)}{R-r} - \frac{r(R-1-r_1)}{(1+r_1)(R-r)}$$

$$=\; \frac{r}{R-r}\!\left[(R-1) - \frac{R-1-r_1}{1+r_1}\right]$$

$$=\; \frac{r}{R-r}\cdot\frac{(R-1)(1+r_1) - (R-1-r_1)}{1+r_1}$$

$$=\; \frac{r}{R-r}\cdot\frac{(R-1) + (R-1)r_1 - R + 1 + r_1}{1+r_1}$$

$$=\; \frac{r}{R-r}\cdot\frac{r_1(R-1) + r_1}{1+r_1}
\;=\; \frac{r}{R-r}\cdot\frac{r_1 R}{1+r_1}
\;=\; \frac{rR\,r_1}{(1+r_1)(R-r)} \qquad \square_3$$

**Remark.** The bad equilibrium ($f \to 1$) exists under both contracts whenever
$c_1 > r$ (bank insolvent if all run). The artifact does not create the bad
equilibrium; it shrinks the basin of attraction of the good one by $\Delta f^*$.

---

## Lemma 1 — Binary Payoff (Homogeneous Deposits)

**Setup.** $N$ agents each with deposit $\delta > 0$. Vault initialized at
$C\delta$ where $C = \lfloor \rho N \rfloor \in \mathbb{Z}_{\geq 0}$. Each
withdrawal reduces the vault by exactly $\delta$.

**Lemma.** $P(\text{partial payment}) = 0$ exactly. Agent payoffs are Bernoulli:
$\delta$ with probability $p_S$, $0$ otherwise.

**Proof.**

After $k$ withdrawals the vault is

$$\mathcal{V}_k \;=\; C\delta - k\delta \;=\; (C - k)\,\delta
\quad\Longrightarrow\quad
\mathcal{V}_k \in \{0,\,\delta,\,2\delta,\,\ldots,\,C\delta\}$$

at every point in time. Agent $i$'s payoff upon withdrawal is
$\min(\delta, \mathcal{V}_k)$. Since $\mathcal{V}_k$ is always an integer multiple
of $\delta$, the event $0 < \mathcal{V}_k < \delta$ is empty. Therefore payoffs
are in $\{0, \delta\}$. $\square$

**Corollary.** $E[\text{payoff}] = p_S \cdot \delta$, so maximising expected payoff
is equivalent to maximising $p_S = P(\text{full deposit})$. This justifies the
decision rules in Model 3 (closed-form $p_S$) and Model 4 (Monte Carlo).

---

## Lemma 2 — Queue Dominance (Full Payoff, Any Deposit Distribution)

**Lemma.** For any agent $i$, any simulation state, and any deposit distribution:

$$E\bigl[\min(\delta_i,\,\mathcal{V}_{k_0})\bigr]
\;\geq\;
E\bigl[\min(\delta_i,\,\mathcal{V}_{k_0+m})\bigr]
\quad \forall\; m \geq 1$$

where $k_0$ is the current withdrawal count ("withdraw now'') and $k_0 + m$ is
the position after $m$ additional withdrawals ("wait'').

In particular:
$$P(\mathcal{V}_{k_0} \geq \delta_i) \;\geq\; P(\mathcal{V}_{k_0+m} \geq \delta_i)$$

**Proof.**

Each withdrawal weakly reduces the vault:

$$\mathcal{V}_{k_0} \;\geq\; \mathcal{V}_{k_0+m} \quad \text{a.s.}$$

since $\mathcal{V}_{k+1} = \mathcal{V}_k - \delta_j \leq \mathcal{V}_k$ for every
withdrawing agent $j$. The function $v \mapsto \min(\delta_i, v)$ is weakly
increasing, so

$$\min(\delta_i, \mathcal{V}_{k_0}) \;\geq\; \min(\delta_i, \mathcal{V}_{k_0+m})
\quad \text{a.s.}$$

Taking expectations preserves the inequality. The probability statement follows
by applying the argument to the indicator $\mathbf{1}(v \geq \delta_i)$, which is
also weakly increasing in $v$. $\square$

**Corollary (Heterogeneous Deposits).** Lemma 2 holds for any deposit distribution
without modification. In particular, partial payment terms
$E[\mathcal{V}\cdot\mathbf{1}(0<\mathcal{V}<\delta_i)]$ need not vanish; they
cannot overturn the comparison because Lemma 2 applies to the total payoff. The
heterogeneous extension of Lemma 1 is subsumed by this result.

---

## Theorem 1 — Monotone Response (Model 3)

**Setup.**
- Representativeness mapping ($m = $ degree of node $i$, $x = $ withdrawn
  neighbours):

$$\tau(x,m,N) \;=\; \left\lfloor \frac{Nx}{m} \right\rceil
\;\in\; \{0,1,\ldots,N\}, \qquad \tau = 0 \text{ if } m = 0$$

- Survival probability ($0 < q < 1$, $0 \leq \tau \leq C < N$):

$$p_S(\tau,C,N,q) \;=\;
\frac{1 - q^{C+1-\tau}}{1 - q^{N-\tau}}, \qquad
p_S = 0 \text{ if } \tau > C$$

- Agent $i$ withdraws iff $p_S < 1$.

**Theorem.** The withdrawal decision is monotone non-decreasing in $x$: if agent
$i$ withdraws given $x$ withdrawn neighbours, they also withdraw given any $x' > x$.

**Proof.**

*Step 1.* $\tau(x,m,N)$ is weakly increasing in $x$ for fixed $m, N$ (nearest-integer
rounding preserves order).

*Step 2.* $p_S(\tau,C,N,q)$ is weakly decreasing in $\tau$ for $\tau \leq C$.
Set $a = C+1-\tau > 0$ and $b = N - \tau > a$ (since $C < N$). Then

$$p_S \;=\; \frac{1 - q^a}{1 - q^b}$$

Incrementing $\tau$ by 1 sends $a \mapsto a-1$ and $b \mapsto b-1$. We show
$p_S(\tau+1) \leq p_S(\tau)$, i.e.\

$$\frac{1-q^{a-1}}{1-q^{b-1}} \;\leq\; \frac{1-q^a}{1-q^b}$$

Both denominators are positive (since $0 < q < 1$). Cross-multiplying:

$$(1-q^{a-1})(1-q^b) \;\leq\; (1-q^a)(1-q^{b-1})$$

Expanding and cancelling the common terms $1$, $-q^{a-1}$... wait, expand fully:

$$\text{LHS} \;=\; 1 - q^{a-1} - q^b + q^{a+b-1}$$
$$\text{RHS} \;=\; 1 - q^a - q^{b-1} + q^{a+b-1}$$

The $1$ and $q^{a+b-1}$ terms cancel. The inequality reduces to:

$$-q^{a-1} - q^b \;\leq\; -q^a - q^{b-1}$$

$$q^a - q^{a-1} \;\leq\; q^b - q^{b-1}$$

$$q^{a-1}(q - 1) \;\leq\; q^{b-1}(q - 1)$$

Since $q - 1 < 0$, divide both sides and reverse the inequality:

$$q^{a-1} \;\geq\; q^{b-1}$$

Since $a - 1 < b - 1$ and $0 < q < 1$, this holds. $\square$

*Conclusion.* More withdrawn neighbours $\Rightarrow$ weakly higher $\tau$
$\Rightarrow$ weakly lower $p_S$ $\Rightarrow$ withdrawal triggered weakly sooner.

---

## Theorem 2 — Reserve Ratio Monotonicity (Model 3)

**Theorem.** In Model 3, $p_S(\tau, C, N, q)$ is strictly increasing in $C$ for
$\tau \leq C < N-1$, and the expected endogenous withdrawal count is weakly
decreasing in $\rho$.

**Proof.**

Incrementing $C$ by 1 sends $a = C+1-\tau \mapsto C+2-\tau = a+1$, leaving
$b = N-\tau$ unchanged. Then:

$$p_S(C+1) - p_S(C)
\;=\; \frac{1-q^{a+1}}{1-q^b} - \frac{1-q^a}{1-q^b}
\;=\; \frac{q^a - q^{a+1}}{1-q^b}
\;=\; \frac{q^a(1-q)}{1-q^b} \;>\; 0$$

for $\tau \leq C < N-1$ (so $a \geq 1$, $b \geq 2$, and $q^a > 0$). Hence
$p_S$ is strictly increasing in $C$.

Since $C = \lfloor \rho N \rfloor$ is non-decreasing in $\rho$, higher $\rho$
$\Rightarrow$ larger $C$ $\Rightarrow$ higher $p_S$ for all $\tau$
$\Rightarrow$ fewer agents cross the withdrawal threshold
$\Rightarrow$ weakly smaller cascade. $\square$

**Conjectured corollary.** There exists $\rho^* \in (0,1)$ such that for
$\rho > \rho^*$ the expected endogenous cascade size is zero. $\rho^*$ depends on
$N$, $p_0$, and the exogenous shock distribution. *(To be formalised.)*

---

## Theorem 3 — Cascade Fixed Point (Full Network Model)

**Setup.** $N$ agents with deposits $\{\delta_i\}_{i=1}^N$ on network $G =
([N], E)$. Let $S \subseteq [N]$ be a withdrawal set. For $i \notin S$, let
$x_i(S) = |\{j \in S : (i,j) \in E\}|$ be the number of withdrawn neighbours
and $m_i = \deg(i)$.

Define the (deterministic) best-response map:

$$\mathcal{B}(S) \;=\; S \;\cup\;
\Bigl\{i \notin S :
P\!\bigl(\text{full}\mid\text{WD now},S\bigr) > P\!\bigl(\text{full}\mid\text{stay},S\bigr)
\Bigr\}$$

**Theorem.** The cascade dynamics converge to the unique minimal fixed point
$S^* \supseteq S_0$ (where $S_0$ is the exogenous withdrawal set) satisfying:

1. $\forall\, i \in S^* \setminus S_0$:
   $P(\text{full}\mid\text{WD now},\,S^*\!\setminus\!\{i\}) >
    P(\text{full}\mid\text{stay},\,S^*\!\setminus\!\{i\})$
2. $\forall\, i \notin S^*$:
   $P(\text{full}\mid\text{WD now},\,S^*) \leq
    P(\text{full}\mid\text{stay},\,S^*)$

**Proof.**

*Step 1: Monotonicity of $\mathcal{B}$.*
Let $S \subseteq S'$. For any $i \notin S'$ (hence $i \notin S$):

- More agents have withdrawn under $S'$ than $S$, so
  $\mathcal{V}^{S'} \leq \mathcal{V}^{S}$ a.s.
- By Lemma 2, $P(\text{full}\mid\text{WD now}, S') \geq
  P(\text{full}\mid\text{stay}, S')$ and the gap
  $P(\text{full}\mid\text{WD now},S') - P(\text{full}\mid\text{stay},S')$
  is weakly larger under $S'$ than $S$.
- Therefore $i \in \mathcal{B}(S) \Rightarrow i \in \mathcal{B}(S')$,
  giving $\mathcal{B}(S) \subseteq \mathcal{B}(S')$.

*Step 2: Fixed point existence.*
$(2^{[N]}, \subseteq)$ is a complete lattice. $\mathcal{B}$ is monotone (Step 1).
By Tarski's fixed point theorem, $\mathcal{B}$ has a least fixed point $S^*$.

*Step 3: Convergence.*
Define $S_0 \subseteq S_1 \subseteq \cdots$ by $S_{t+1} = \mathcal{B}(S_t)$.
The sequence is non-decreasing (since $\mathcal{B}(S) \supseteq S$) and bounded
above by $[N]$, so it stabilises in at most $N$ steps at a fixed point. Since
$S_0 \subseteq S^*$ and $\mathcal{B}$ is monotone, every $S_t \subseteq S^*$,
so the limit is $S^*$. $\square$

**Corollary (No-Run Condition).** $S^* = S_0$ iff for all $i \notin S_0$:

$$P(\text{full deposit}\mid\text{WD now},\,S_0) \;=\;
  P(\text{full deposit}\mid\text{stay},\,S_0) \;=\; 1$$

**Extension to stochastic best responses (Model 4).**
In Model 4, $P(\text{full}\mid\cdot)$ is estimated via Monte Carlo with
depth $= 1000$. Let $\hat{p}_i(S)$ and $\hat{q}_i(S)$ denote the estimators
for WD-now and stay respectively. These are unbiased:

$$E[\hat{p}_i(S)] \;=\; P(\text{full}\mid\text{WD now},\,S),
\qquad
E[\hat{q}_i(S)] \;=\; P(\text{full}\mid\text{stay},\,S)$$

by the law of large numbers. Define the inclusion probability
$\pi_i(S) = P(i \in \mathcal{B}(S))$. By the unbiasedness and monotonicity
argument in Step 1 applied in expectation:

$$S \subseteq S' \;\Longrightarrow\; \pi_i(S) \leq \pi_i(S') \quad \forall\, i$$

so the expected best-response map $\bar{\mathcal{B}}$ is monotone, and Tarski
applies. The cascade $E[|S_t|]$ is non-decreasing, bounded by $N$, and converges
to $E[|S^*|]$. $\square$

**Contrast with DD.** The DD bad equilibrium is the *maximal* fixed point of a
coordination map, selected by sunspot. $S^*$ here is the *minimal* fixed point,
selected by rational network updating.

---

## Proposition — High-Degree Trigger

**Proposition.** Let $|S_0^{\mathrm{hub}}| = |S_0^{\mathrm{unif}}| = n_0$.
Suppose $S_0^{\mathrm{hub}}$ consists of the $n_0$ highest-degree nodes and
$S_0^{\mathrm{unif}}$ is a uniform random sample of $n_0$ nodes. Then:

$$E\!\left[|S^*(S_0^{\mathrm{hub}})|\right] \;\geq\;
  E\!\left[|S^*(S_0^{\mathrm{unif}})|\right]$$

**Proof sketch.**

*Step 1: Degree FSD.*
For any threshold $d$:

$$\frac{|\{i \in S_0^{\mathrm{hub}} : \deg(i) \geq d\}|}{n_0}
\;\geq\;
\frac{|\{i \in [N] : \deg(i) \geq d\}|}{N}
\;=\; P(\deg(U) \geq d)$$

where $U$ is uniform on $[N]$. So the degree distribution of shocked nodes under
$S_0^{\mathrm{hub}}$ first-order stochastically dominates that under
$S_0^{\mathrm{unif}}$.

*Step 2: Cascade monotonicity in shocked-node degree.*
Withdrawing node $j$ raises $\tau_i$ by $N/m_i$ for each neighbour $i$ of $j$,
affecting $\deg(j)$ agents simultaneously. By Theorem 1, each affected agent $i$
has weakly higher probability of withdrawing. Hence the marginal contribution of
node $j$ to $E[|S^*|]$ is weakly increasing in $\deg(j)$.

*Step 3: FSD coupling.*
By Steps 1 and 2 and the monotonicity of $\mathcal{B}$ (Theorem 3), construct a
coupling of $S_0^{\mathrm{hub}}$ and $S_0^{\mathrm{unif}}$ such that each shocked
node in $S_0^{\mathrm{hub}}$ has degree $\geq$ the corresponding node in
$S_0^{\mathrm{unif}}$. The cascade under $S_0^{\mathrm{hub}}$ then dominates
sample-path-wise. $\square$

**Note.** Step 3 requires a formal coupling construction; this is the least
complete step in the proof.

**Empirical instantiation.** SVB (March 2023): Founders Fund and major VC firms
were high-degree nodes in the tech-startup depositor network. Their withdrawal was
simultaneously observed by hundreds of portfolio companies, triggering the cascade
consistent with this proposition.
