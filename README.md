# Swift_assesment_SQL
Take-Home Assignment - Case Study [Please note that the data sets are hyperlinked]



You are working as a consultant with consumer brands like Kelloggs, Logitech, Kimberly Clark, grow their e-commerce revenue on Amazon, Walmart, and other retailers using data insights, machine-learning-backed recommendations and automated actions. 



Attached below are two tables giving granular data on sales, search ranking, reviews, and so on. The task expects you to analyze the data and provide answers to questions with respect to the data. You are expected to submit your code and supporting document answering the questions and your findings.

Questions 



Identify the most expensive SKU, on average, over the entire time period.
What % of SKUs have generated some revenue in this time period?
 (brownie points - can you identify SKUs that stopped selling completely after July?)



3 Somewhere in this timeframe, there was a Sale Event. Identify the dates.



4. (Dependent on 3) Does having a sale event cannibalize sales in the immediate aftermath? Highlighting a few examples would suffice 



(brownie points - determine a statistical metric to prove/disprove this).



5 . In each category, find the subcategory that has grown slowest relative to the category it is present in. If you were handling the entire portfolio, which of these subcategories would you be most concerned with?



6. Highlight any anomalies/mismatches in the data that you see, if any. (In terms of data quality issues)



7. For SKU Name C120[H:8NV, discuss whether Unit Conversion (Units/Views) is affected by Average Selling Price.



(brownie points - determine a statistical technique to test this)



Deliverable

We’d like to see your insights and the thought process that went behind the analysis, which may or may not be in the same place. You can choose to submit a separate doc, or a notebook, or whatever way you think is the best way to solve the problem.



Data 

1. Sales Data - SKU_Name, Feed_date, Category, SubCategory, Ordered_Revenue, Ordered_Units, Rep_OOS

2. Glance Views - Feed_date, SKU_Name, Views, Units





Ordered_Revenue - Sum of Revenue generated on that day for the SKU

Rep_OOS - % of Views for which the product was Out of Stock

Views - No. of times the product page was viewed by customers

Category - High-level Amazon category that the product belongs to

Sub Category - Level 2 categorization of the product
