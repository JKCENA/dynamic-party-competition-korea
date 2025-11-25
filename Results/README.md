# 📊 Simulation Results

### *An Agent-Based Analysis of Party Competition—Extending Laver’s (2005) Party Competition in Korean Party Politics 2004–2024*

This directory contains the **simulation outputs** for the extended Agent-Based Model (ABM) of Korean party competition.
The results compare **actual proportional representation vote shares** from the 17th–22nd National Assembly elections (2004–2024) with **simulated outcomes** from the extended Laver–Sergenti model.


---

## 🧠 What the Results Show

The results in this folder document model performance across **18,000 simulations per election**.
Only simulations that matched empirical vote shares within a defined tolerance (“reproduction success”) were retained.

### Major Findings (from the paper)

1. **Voter distributions were consistently polarized**
   Each election is best reproduced when the electorate consists of **two polarized sub-populations**, modeled as bivariate normal clusters.

2. **Parties converge toward the center (0,0)**
   Across all six elections, parties tend to move toward the center of the 2D policy space—even when their real-world campaign messaging is issue-specific.

3. **High predictive accuracy in multiparty competitions (3–4 parties)**
   The extended model fits especially well in elections with **balanced multiparty environments** (e.g., 17th, 19th, 22nd).

4. **22nd National Election (2024): near-perfect reproduction of Jo-guk Innovation Party vote share**
   This demonstrates the model’s ability to quantify the size of the **“regime evaluation / punishment”** voter bloc.

5. **Limitations**

   * Elections driven by **large exogenous shocks** (e.g., COVID-19 in 2020) reduce reproduction success.
   * A risk of **post-hoc interpretation** remains; simulation cannot replace substantive political explanation.

---

## 📑 Structure of the Result Tables (Sim_Result.pdf)

Each election (17th–22nd) includes:

### 1. **Party-level comparison table**

* Actual vote share
* Simulated vote share (mean + SD)
* Difference
* φ (policy–vote tradeoff parameter)
* Fitness
* Ideal point loss
* Valence
* Party coordinates (x, y)
* Main strategy mix (H, P, S, A, E)

### 2. **Plots**

* Scatter of parties vs. voter distribution
* Zoomed region showing convergence tendencies
* Highlights of species composition (strategy frequencies)

### 3. **Summary table across all six elections**

Variables include:

* voter-misery
* mean-eccentricity
* mean-party-policy-loss
* mean-party-policy-shift
* voter distribution parameters (means, SDs)
* valence-lambda
* campaign duration (campaign-ticks)

---

## 📘 How to Interpret These Results

These simulation outputs allow researchers to:

* Examine **how Korean parties adapt** across long-term electoral cycles
* Identify **system-level patterns**: convergence, polarization, oscillation
* Test how party strategies (S/A/H/P/E) influence election outcomes
* Separate **strategic party behavior** from **structural voter constraints**
* Validate whether theoretical claims in Korean politics (e.g., “정권 심판론”, “이념 재편”) are **mechanically reproducible**

These results form the empirical backbone for the analysis presented in the full paper.

---

