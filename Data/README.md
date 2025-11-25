# 📁 Data Directory

This directory contains the **data resources** used for the project *Dynamic Party Competition in Korea*.
Due to file size limits and redistribution policies, **raw data files are not stored directly in this repository**.

---

## 📥 1. Accessing the Original Data (Large File)

The primary dataset used in the analysis is **over 100MB** and is therefore hosted externally.

You can download the original dataset from the following link:

🔗 **Google Drive (Raw Dataset)**
[https://drive.google.com/file/d/1fIx96fZKnX44ei-dunB_Jr0pYh7VPqMO/view?usp=drive_link](https://drive.google.com/file/d/1fIx96fZKnX44ei-dunB_Jr0pYh7VPqMO/view?usp=drive_link)

---

## ⚙️ 2. Data Processing Workflow

The file:

```
SIM_DATA_Processing.ipynb
```

contains all processing, cleaning, and restructuring steps required to prepare the data for the simulation and analysis.

### 📌 Notes on the Workflow

* The notebook includes **data cleaning**, **variable construction**, **summary generation**, and **export** steps.
* All processing is designed to be **fully reproducible** once the raw dataset is placed in the correct directory.
* The notebook uses Python (Jupyter Notebook), with standard scientific packages (`pandas`, `numpy`, `matplotlib`, etc.).

---

## 🤖 3. Use of AI Assistance (Transparency Notice)

Parts of the data processing workflow were developed with assistance from **AI coding tools**
  – Used for code generation, debugging, and pipeline optimization
  – All logic was reviewed, finalized, and validated by the project author

AI assistance was used **only for coding support**, not for producing or altering the underlying dataset.
All analytical decisions and interpretations were made by the author.

---

## 📂 4. Folder Structure

```
/Data/
│
├── README.md                 ← This file
├── SIM_DATA_Processing.ipynb ← Jupyter Notebook for preprocessing
└── (Raw data file not included — download via Google Drive link)
```

Place the downloaded raw dataset into this folder **before running the notebook**.

---

## 📎 5. Reproducibility

To reproduce the processed dataset:

1. Download the raw data from the provided Google Drive link
2. Save it inside `/Data/`
3. Open and run the Jupyter notebook:

```
SIM_DATA_Processing.ipynb
```

All intermediate and final outputs will be generated automatically.


