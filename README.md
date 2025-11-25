# 🇰🇷 Dynamic Party Competition in Korea (2004–2024)

### **An Agent-Based Analysis of Party Competition — Extending Laver’s (2005) Party Competition Model to Korean Politics**

**Author:** Jihun Kang
**Institution:** Dongguk University, Department of Political Science
**Funding:** *This project was supported by the **Woon-Kyung Foundation Research Grant (운경재단 연구지원사업)**.*
**Period:** March 2025 – December 2025
<!-- Badges -->
<p align="left">
  <!-- Language / Platform -->
  <img src="https://img.shields.io/badge/Code-NetLogo-blue.svg" alt="NetLogo Code">
  <img src="https://img.shields.io/badge/Analysis-Python%20%7C%20Jupyter-green.svg" alt="Python | Jupyter">

  <!-- Research Field -->
  <img src="https://img.shields.io/badge/Field-Computational%20Social%20Science-brightgreen.svg" alt="Computational Social Science">
  <img src="https://img.shields.io/badge/Method-ABM%20(Multi--Party%20Competition)-orange.svg" alt="ABM Methods">

  <!-- Dataset -->
  <img src="https://img.shields.io/badge/Data-Korean%20National%20Assembly%202004–2024-critical.svg" alt="Korean Election Data">

  <!-- Grant -->
  <img src="https://img.shields.io/badge/Grant-Woon--Kyung%20Foundation%20Research-blueviolet.svg" alt="Woon-Kyung Grant">

  <!-- Status -->
  <img src="https://img.shields.io/badge/Status-Working%20Paper%20%7C%20Public%20Model-yellow.svg" alt="Status">

  <!-- License -->
  <img src="https://img.shields.io/badge/License-Research%20Use%20Only-lightgrey.svg" alt="Research Use Only">

</p>

---

## 📘 Project Overview

This repository contains the full research assets for the project:

### **“한국 정당 경쟁의 장기 동학(2004–2024):

Laver(2005)·Laver & Sergenti(2011)의 정당 경쟁 ABM 확장”**

The project extends the classic **Laver–Sergenti (2011)** Agent-Based Model of party competition and adapts it to the structure of **Korean proportional representation elections** from **2004 to 2024** (17th–22nd National Assembly Elections).

The goal is to analyze:

* Long-term strategic adaptation of Korean political parties
* The interaction between voter distribution and party positioning
* Convergence, polarization, and evolutionary patterns across electoral cycles
* Whether empirical voting outcomes can be reproduced through micro-level party strategies

All simulations, datasets, results, and documentation are included for transparency and reproducibility.

---

## 🏛️ Funding Acknowledgment

This research was conducted with the support of the:

### 🎖 **Woon-Kyung Foundation Research Grant (운경재단 연구지원 사업)**

The study is officially documented in the working paper below:

📄 **Woon-Kyung Foundation Working Paper (Korean)**  
*“한국 정당 경쟁의 장기 동학(2004–2024)”*  
[View PDF](./Woonkyung_WorkingPaper%20(IN%20KOREAN).pdf)


---

## 📂 Repository Structure

```
.
│
├── Model/
│   └── Party Competition Korea.nlogo (Extended Laver–Sergenti Model)
│   └── README.md (Model documentation & instructions)
│
├── Data/
│   └── SIM_DATA_Processing.ipynb (Data processing pipeline)
│   └── README.md (Dataset description & AI assistance notice)
│
├── Results/
│   ├── Sim_Result.pdf (Full tables & figures)
│   └── README.md (Explanation of simulation results)
│
├── Woonkyung_WorkingPaper (IN KOREAN).pdf
├── LICENSE
└── README.md (You are here)
```

---

## 🧠 Core Components

### **1. Extended Agent-Based Model (ABM)**

* Built on Laver’s (2005) and Laver & Sergenti’s (2011) foundations
* Adds:

  * Endogenous party birth & death
  * Korean-specific voter distributions (two-cluster bivariate normals)
  * Unified run-level logging (system, party, birth, death)
  * Over 180 rule-species combinations (S/A/H/P/E families)

### **2. Data Processing (ANALYSIS-READY)**

* Large voter distribution datasets processed via Jupyter Notebook
* Transparency note included: AI-assisted coding (Vibe coding / GPT-assisted)

### **3. Simulation Results (17th–22nd Elections)**

* Actual vs. simulated vote shares
* Party positioning & strategic species composition
* System-level metrics:

  * Voter misery
  * Mean eccentricity
  * Mean policy loss
  * ENP (Effective Number of Parties)
  * Convergence patterns

A comprehensive summary is available in 📊 **Simulation Results (17th–22nd Elections)**  
[Woonkyung_Sim_Result.pdf — Full Tables & Figures](./Results/Woonkyung_Sim_Result.pdf)

---

## 🔎 Key Research Findings

(From the full project report)

* **Korean PR elections can be reproduced with high accuracy** using ABM-based evolutionary logic.
* **Parties consistently converge toward the center**, despite polarized voter clusters.
* The model captures **elite defection**, **new party emergence**, and **strategic imitation**.
* The 22nd election shows a strong **punishment vote** pattern that the model successfully simulates.
* Elections involving large exogenous shocks (e.g., COVID-19 in 2020) show lower model fit—indicating real-world deviations from purely strategic competition.

For full interpretation and figures, see:
📊 **Simulation Results (17th–22nd Elections)**  
[Woonkyung_Sim_Result.pdf — Full Tables & Figures](./Results/Woonkyung_Sim_Result.pdf)

---

## 🎯 Purpose of Public Release

This repository aims to:

* Provide a **reproducible** ABM framework for Korean political competition
* Serve as a **computational political science resource**
* Enable future researchers to explore:

  * Party strategy evolution
  * Voter–party spatial interactions
  * Multi-party system dynamics
* Support transparency for the Woon-Kyung Foundation research project

---

## 📚 Citation

Please cite the project as:

```
Kang, Ji-Hun (2025).
An Agent-Based Analysis of Party Competition—Extending Laver’s (2005) Party
Competition in Korean Party Politics 2004–2024.
Woon-Kyung Foundation Research Grant Project.
```

---

## 📬 Contact

For questions or collaboration inquiries:

**Jihun Kang**
Email: [jihun9965@gmail.com](mailto:jihun9965@gmail.com)
