# 📂 Party Competition Korea — NetLogo Model

This repository contains the **NetLogo source code** for an extended Agent-Based Model (ABM) of party competition in South Korea (2004–2024).  
The model is based on *Laver & Sergenti (2011)* and incorporates **Korean-specific electoral dynamics**, **endogenous party entry/exit**, and **enhanced data logging** for empirical analysis.

---

## 🔍 Overview

This model simulates:

- Strategic movement of political parties in a 2D policy space  
- Voter behavior based on policy proximity and valence  
- Party evolution across repeated PR-style elections  
- Endogenous party birth/death driven by voter dissatisfaction (“misery”)  
- Logging of complete system + party-level metrics for all elections  

The code has been heavily expanded from the original ABM to reflect long-term dynamics in South Korean party competition (2004–2024).

---

## 🆕 Key Extensions from the Original Laver–Sergenti Model

This version introduces several novel mechanisms:

### 1. Korean PR Election Dynamics
- Bimodal voter distributions reflecting Korea’s polarized electorate  
- Adjustable parameters for major/minor blocs (x-mean, y-mean, SD, votes)

### 2. Endogenous Birth–Death Processes
- Parties die when `fitness < survival-threshold`  
- New parties probabilistically emerge in high-misery patches  
- Birth and death fully logged for each election cycle

### 3. Unified Logging System (CSV)
- Exports `system`, `party_status`, `birth`, `death` events  
- Supports empirical reconstruction & validation  
- Includes parameters used in each election cycle (voter distributions, mean positions, σ values)

### 4. Extended Decision Rules

Species implemented:

- **S** – Sticker: maintains its initial position (ideological rigidity)  
- **A** – Aggregator: moves toward the mean position of its supporters  
- **H** – Hunter: repeats a move if it improved utility, otherwise changes direction  
- **P** – Predator: moves toward the largest party  
- **E** – Explorer: locally searches for higher-utility positions  

All rules are automatically parameterized from the rule string (e.g., `"A00010f"`).

### 5. Full Reproducibility Architecture

- Auto-managed `run-number` via `run_counter.txt`  
- Per-election logging of:
  - Effective Number of Parties (ENP)  
  - Mean eccentricity  
  - Mean ideal-point loss  
  - Mean policy shift  
  - Voter misery  
  - Mean `phi` and voter distribution parameters  

---

## ⚠️ IMPORTANT: Fix Hardcoded File Path Before Running

The model writes CSV logs to a local folder.  
You **must** change the hardcoded base path, or file operations will fail.

The `base-path` variable appears in **two** procedures:

- `to setup`
- `to-report get-next-run-number`

Update this line in both places:

```netlogo
;; Original author path
let base-path "C:/Users/jihun/OneDrive/바탕 화면/시뮬레이션 결과"

;; Replace with your local directory, for example:
let base-path "C:/Users/YourName/Documents/SimulationResults"

```
Make sure the target folder exists before running the model.

## 🧠 Model Structure

### **1. Agents**

| Agent     | Description                                                      |
| --------- | ---------------------------------------------------------------- |
| `parties` | Strategic actors moving in a 2D policy space to maximize utility |
| `patches` | Voters represented via spatial density (bivariate normal fields) |

Voter density is generated using (at least) two bivariate-normal subpopulations via `random-pop`, capturing a polarized Korean electorate.

---

### **2. Core Procedures**

| Category     | Procedures                                                                                                  |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| **Setup**    | `setup`, `random-pop`, `initialize-party`, `initialize-party-log`                                           |
| **Campaign** | `go`, `adapt`, `update-support`, `update-utility`                                                           |
| **Rules**    | `stick`, `aggregate`, `hunt`, `sat-hunt`, `predate`, `sat-predate`, `explore`, `sat-explore`                |
| **Election** | `calculate-election-results`, `update-party-measures`, `update-rule-measures`, `party-death`, `party-birth` |
| **Metrics**  | `measure-enp`, `measure-eccentricity`, `measure-misery`                                                     |
| **Logging**  | `log-election-data`, `initialize-party-log`, `get-next-run-number`                                          |

---

## 📊 Voter Utility Function

Voters choose parties using a valence–distance utility:

$$
U_{ij} = \lambda V_j - (1 - \lambda)d(i,j)^2
$$

Where:

- $V_j$: valence of party $j$
- $d(i,j)$: Euclidean distance between voter $i$ and party $j$
- $\lambda$: weight on valence vs. policy distance (`valence-lambda`)

---

## 🔁 Election Cycle Logic

The main loop (`go`) progresses in two phases:

### **1. Campaign Phase** (repeated `campaign-ticks` times)

* Parties adapt according to their rule
* Voters update support based on proximity & valence
* Parties update utilities

### **2. Election Phase** (`calculate-election-results`)

* Update party fitness, age, and policy movement
* Compute system metrics (ENP, misery, eccentricity)
* Log system & party-level data
* Execute party death and birth

---

## 📤 Data Logging Output

The model writes a unified CSV containing four types of events:

### **1. `system`**

System-level metrics:

* Effective Number of Parties (ENP)
* Mean eccentricity
* Voter misery
* Mean phi, policy loss, policy shift
* Parameters of voter distributions

### **2. `party_status`**

Per-party metrics:

* Position (x, y)
* Vote share
* Rule, species, phi
* Fitness
* Ideal-point loss
* Valence

### **3. `birth`**

Metadata for each newly spawned party.

### **4. `death`**

Metadata for eliminated parties.

Each row includes:

* `run-number`
* `election`
* `event_type`
* Party attributes (if applicable)
* System attributes
* Voter distribution parameters

This structure supports full reconstruction of each election run.

---

## 🔗 Model Lineage & Attribution

### **Original Model**

Laver, M., & Sergenti, E. (2011). *Party Competition: An Agent-Based Model.*
Princeton University Press.
[Model Source (Modeling Commons)](https://modelingcommons.org/account/models/294)

### **Extended Model (Korea 2004–2024)**

Kang, Ji-Hun (2025). *An Agent-Based Analysis of Party Competition — Extending Laver & Sergenti for Korean Party Politics 2004–2024.*

---


## 🚀 How to Run

1. Install **NetLogo 6.x or higher**
2. Clone or download this repository
3. Open `Party Competition Korea.nlogo` in NetLogo
4. Update the `base-path` in both `setup` and `get-next-run-number`
5. Click **Setup**
6. Click **Go** to begin the multi-election simulation

CSV logs will be written to the folder you specified in `base-path`.
