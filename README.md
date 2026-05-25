# Food-Nutrient-Analyzer
<div align="center">

<img src="https://img.shields.io/badge/R-Shiny-276DC3?style=for-the-badge&logo=r&logoColor=white" />
<img src="https://img.shields.io/badge/ML-K--Means%20Clustering-FF6B35?style=for-the-badge&logo=scikit-learn&logoColor=white" />
<img src="https://img.shields.io/badge/Data-USDA%20FoodData-4CAF50?style=for-the-badge&logo=databricks&logoColor=white" />
<img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" />
<img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" />

<br/><br/>

# 🥗 NutriViz — Smart Food Nutrition Analyzer

### *An end-to-end R data science project: USDA data pipeline → K-Means Clustering → Interactive Shiny Dashboard*

<br/>

> **Explore, compare, and cluster thousands of real foods by their nutritional content — powered by the USDA FoodData Central database.**

</div>

---

## 📌 Overview

**NutriViz** is a complete data science project that takes raw USDA food data, cleans and transforms it through a multi-file merging pipeline, applies **K-Means Machine Learning** to discover natural food groups, and delivers results through an **interactive Shiny web app** where users can search any food, set a custom quantity, and instantly see a calorie and nutrient breakdown.

This project covers the full data science workflow — from raw messy data all the way to a deployed interactive product.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 **Multi-Food Search** | Search and compare multiple foods simultaneously |
| ⚖️ **Custom Quantity Engine** | Enter any gram value; all nutrients scale automatically |
| 📊 **Color-Coded Calorie Chart** | Green → Low, Yellow → Moderate, Red → High calorie foods |
| 🧠 **K-Means Clustering** | Groups 78,000+ foods into 5 natural clusters by nutrient profile |
| 🔗 **Correlation Heatmap** | Visual matrix showing relationships between Energy, Protein, Fat & Carbs |
| 📋 **Nutrient Breakdown Table** | Tabular view of Energy (kcal), Protein (g), Fat (g), Carbs (g) |

---

## 🧠 Machine Learning — K-Means Clustering

Foods are grouped automatically into **5 clusters** based on their macronutrient profile using K-Means algorithm.

```
┌──────────────────────────────────────────────────────────────────┐
│               NutriViz ML Pipeline                               │
├──────────────────────────────────────────────────────────────────┤
│  RAW DATA         →  MERGE & PIVOT  →  SCALE  →  K-MEANS        │
│  food.csv              3-table join    Z-score    5 centers      │
│  food_nutrient.csv     wide format     normalize  set.seed(123)  │
│  nutrient.csv                                                     │
└──────────────────────────────────────────────────────────────────┘
```

### Clustering Details

| Parameter | Value |
|---|---|
| **Algorithm** | K-Means (`kmeans`) |
| **Clusters (k)** | 5 |
| **Features used** | Energy (kcal), Protein (g), Fat (g), Carbohydrates (g) |
| **Preprocessing** | Z-score standardization via `scale()` |
| **Reproducibility** | `set.seed(123)` |

### What the Clusters Represent

| Cluster | Food Profile | Example Foods |
|---|---|---|
| 🟢 1 | Low calorie, low fat | Vegetables, leafy greens |
| 🔵 2 | Moderate carb, low fat | Fruits, light grains |
| 🟡 3 | High protein, moderate fat | Meats, fish, eggs |
| 🟠 4 | High fat, moderate protein | Nuts, seeds, oils |
| 🔴 5 | High carb, high energy | Baked goods, processed foods |

---

## 🗂️ Project Structure

```
food_nutrients/
│
├── app.R                              # Shiny web application (UI + Server)
│
├── clean_code.R                       # Full pipeline: load → merge → cluster → export
├── nutrients_analysis.R               # EDA: correlation matrix + cluster visualization
│
├── data/
│   ├── food.csv                       # USDA FoodData Central — 78,000+ food items
│   ├── food_nutrient.csv              # 159,000+ nutrient measurement records
│   └── nutrient.csv                   # Nutrient ID reference table (478 nutrient types)
│
├── FINAL_Nutrient_Analysis_Results.csv  # Cleaned, clustered output (ready for Shiny)
└── Rplot.png                            # Exported cluster visualization
```

---

## 📦 Tech Stack

| Layer | Tools |
|---|---|
| **Language** | R |
| **Web Framework** | Shiny, shinythemes |
| **Machine Learning** | K-Means Clustering (base R `kmeans`) |
| **Data Wrangling** | tidyverse, data.table, dplyr |
| **Visualization** | ggplot2, corrplot |
| **Data Source** | USDA FoodData Central |

---

## 🗃️ Dataset

| File | Rows | Description |
|---|---|---|
| `food.csv` | ~78,000 | Food items with FDC ID, description, category |
| `food_nutrient.csv` | ~159,000 | Nutrient measurements linked by FDC ID |
| `nutrient.csv` | 478 | Nutrient name/unit lookup table |
| `FINAL_Nutrient_Analysis_Results.csv` | 107 | Final cleaned & clustered dataset |

> **Source:** [USDA FoodData Central](https://fdc.nal.usda.gov/) — the official US government food composition database.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have **R (≥ 4.1.0)** and **RStudio** installed.

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/NutriViz.git
cd NutriViz
```

### 2. Install Required Packages

```r
install.packages(c(
  "shiny",
  "shinythemes",
  "tidyverse",
  "data.table",
  "ggplot2",
  "corrplot"
))
```

### 3. Run the Analysis Pipeline (optional — output already included)

```r
# Step 1: Clean data, run K-Means, export results
source("clean_code.R")

# Step 2: Generate correlation heatmap and cluster plot
source("nutrients_analysis.R")
```

### 4. Launch the Shiny App

```r
shiny::runApp("app.R")
```

The app opens in your browser at `http://127.0.0.1:PORT`

---

## 🎯 How to Use the App

1. **Search Foods** — type any food name in the search box (supports multiple selections)
2. **Set Grams** — enter a quantity (e.g., 150g, 250g, 1000g)
3. **Read the Chart** — bar chart auto-colors by calorie level (green/yellow/red)
4. **Check the Table** — see exact values for Energy, Protein, Fat, and Carbs
5. **Compare Side-by-Side** — add multiple foods to compare their full profiles

---

## 📈 Data Pipeline — Step by Step

```r
# 1. Load 3 USDA source files
food           ← food.csv          (what foods exist)
food_nutrient  ← food_nutrient.csv (nutrient measurements)
nutrient       ← nutrient.csv      (nutrient names)

# 2. Filter only the 4 key nutrients
needed_ids = [1008=Energy, 1003=Protein, 1004=Fat, 1005=Carbs]

# 3. Three-way merge on fdc_id and nutrient_id

# 4. Pivot wide — one row per food, one column per nutrient

# 5. Remove NA rows, deduplicate

# 6. Scale → K-Means (k=5) → Assign cluster labels

# 7. Export FINAL_Nutrient_Analysis_Results.csv → Power the Shiny App
```

---

## 🔭 Future Scope

- [ ] Deploy on [shinyapps.io](https://shinyapps.io) for public access
- [ ] Add more nutrients (Fiber, Sugar, Sodium, Vitamins)
- [ ] Implement **Elbow Method** to find optimal number of clusters
- [ ] Add daily intake tracker with RDA (Recommended Dietary Allowance) benchmarks
- [ ] Support food image display using USDA food photos
- [ ] Build a meal planner that selects foods to hit a calorie target

---

## 👨‍💻 Author

**Sundaram** — B.Tech Student | Data Science & ML Enthusiast

[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=flat-square&logo=github)](https://github.com/YOUR_USERNAME)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://linkedin.com/in/YOUR_PROFILE)

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

*Built with ❤️ using R | Data from USDA FoodData Central*

⭐ **If this project helped you, please give it a star!** ⭐

</div>
