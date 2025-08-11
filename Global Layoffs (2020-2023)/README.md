# 📉 Global Layoffs Analysis (2020–2023)

This project is based on the **Layoffs.csv** dataset from [AlexTheAnalyst's Data Analyst Portfolio Project]((https://www.youtube.com/watch?v=rGx1QNdYzvs&list=PLUaB-1hjhk8FE_XZ87vPPSfHqb6OcM0cF)). It explores layoffs around the world between 2020 and 2023, with a focus on cleaning and preparing the data using **PostgreSQL**.

## 🗂️ Dataset Overview

- **Source:** Layoffs.csv (via AlexTheAnalyst)
- **Period:** 2020–2023
- **Columns include:**
  - company
  - company_location
  - industry
  - total_laid_off
  - percentage_laid_off
  - stage
  - country
  - date_laid_off
  - funds_raised_millions

## 🧹 Data Cleaning Steps

Data cleaning was performed using **PostgreSQL**, including the following tasks:

- Removed rows with missing company names or dates
- Converted date fields to proper `DATE` format
- Standardized text (e.g., capitalization and spacing in country and industry names)
- Handled null values and empty strings
- Removed duplicate records

🔗 See the cleaning script: [`Data Cleaning Project.sql`](./Data%20Cleaning%20Project.sql)

## 🧰 Tools Used

- PostgreSQL  
- DBeaver (SQL IDE)  
- Excel (for preliminary inspection)

## 📌 Key Learnings

- Data cleaning techniques in SQL
- Handling missing and inconsistent data
- Preparing datasets for analysis and visualization
- Importance of clean and structured data

## 📊 Exploratory Data Analysis (EDA)

I analyzed global layoffs from 2020 to 2023 by running SQL queries in PostgreSQL.

### Key Questions Answered:
- How did layoffs change year over year?
- Which industries were most affected?
- Which companies laid off employees multiple times?
- How did layoffs vary by funding stage?
- What were the top countries impacted?

### Sample Insights:
- 2022 saw a large spike in layoffs globally.
- Several companies (e.g., Loft, Netflix, Uber) had layoffs across multiple years.
- Some companies with large funding rounds still did layoffs.

🔗 See the EDA script: [`Exploratory Data Analysis.sql`](./Exploratory%20Data%20Analysis.sql)

## 📁 Repository Contents

- `layoffs.csv` – Original dataset
- `Data Cleaning Project.sql` – SQL script used for data cleaning
- `Exploratory Data Analysis.sql` - EDA script
- `README.md` – Project documentation

## 🙌 Credits

Project inspired by [AlexTheAnalyst’s Data Analyst Portfolio Project](https://www.youtube.com/@AlexTheAnalyst).
