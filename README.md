Online Retail Analytics: End-to-End Business Intelligence

Project Goal:
I built this project to show a full data pipeline process. I wanted to start with raw, messy CSV files to a professional, interactive executive dashboard to provide real business insights. I analyzed over 800,000 transactions across 41 countries to find growth opportunities and customer spend patterns.
Coming from a background in clinical data at Medpace (SDTM, ADaM datasets), I have a zero-error mindset when it comes to data integrity and accuracy. This project allowed me to apply that same level of accuracy using commercial data while using my skills in Excel, MySQL, and Power BI.

The Process
1. Advanced Excel Setup and ETL: Before touching a database, I used Excel to build a solid foundation. This was about ensuring the data was accurate from the beginning:
   
   •	Power Query ETL: I cleaned the raw data by removing cancellations, null Customer IDs, and invalid prices.
   
   •	XLOOKUP Integration: I used XLOOKUP and IF statements in Excel to assign each customer a tier based on their purchases
   
   •	Pivot Table Validation: I built four detailed Pivot Tables to verify my initial findings on monthly revenue and top-performing products before continuing with the data


2. Deep-Dive Analysis (MySQL): I moved the cleaned data into a MySQL database using SQL Workbench to perform complex, multi-layered queries. (SQL script is available in the file list above)

   •	Growth Tracking: I used the LAG window function to calculate Month-over-Month revenue changes. This helped me identify exactly when the business was bringing in the most revenue.

   
   •	Customer Tiers: I built a recency model using DATEDIFF to classify customers as Active, Lapsed, or Churned.

   
   •	Market Leaders: I used the RANK function partitioned by Country to instantly find the top product in every individual market, which could be used in making business decisions regarding marketing          and production

   

3. Interactive Dashboards (Power BI): I turned the SQL outputs into a four-page interactive report. (Power BI file is available in the file list above)


   •	Executive Overview: High-level KPIs showing 17.74M in total revenue and global reach.

   
   •	Product Performance: A scatter plot identifying a few "Hero" products (high revenue and low volume)

   
   •	Customer Analysis: A breakdown proving the Pareto Principle. 20% of customers drove 77% of total revenue.

   
   •	Geographic Breakdown: A deep dive into international growth. Western Europe represents an overwhelming percent of total revenue, even without the UK



   
Technical Skills Used
1. Excel (Power Query, XLOOKUP, Pivot Tables, Data Normalization)
2. SQL (CTEs, Window Functions (RANK, LAG), Joins, and Case Statements)
3. Power BI (Star Schema Modeling, DAX (SUMX, CALCULATE, DIVIDE), and Interactive UX)

   
   
________________________________________
How to use this repo

Run the retail_analysis.sql file to set up the database. You will need to update the LOAD DATA path to your local directory, and also create a Country_Region database, assigning the appropriate region to each country

Open the OnlineRetail_Analysis.pbix file to view the interactive dashboard. The 'Images' folder has 4 png files of the 4 dashboards

The raw data can be found on Kaggle at this link: https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci

Connect with me on LinkedIn: https://linkedin.com/in/sam-miller-800401194
