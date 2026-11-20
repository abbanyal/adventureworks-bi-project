# Individual Reflection

**Name:** Ankush Banyal
**Project:** AdventureWorks BI (SQL Server, SQL Server Agent, Power BI)

## What I owned

I worked on this project on my own, so I built every part of the pipeline:

* **Data warehouse (SQL Server):** designed the star schema with one fact table (`fact.Sales`, one row per order line) and five dimensions, each with an Unknown member, and wrote the load scripts.
* **Automation:** wrote the stored procedures, an audit log (`dbo.EtlLog`) and a SQL Server Agent job that runs nightly. This replaced Azure Data Factory, which I had no access to.
* **Power BI model and DAX:** built the relationships, the date table and the measures (Sales, Profit, Margin %, YTD, prior year, YoY %, rolling 3-month average).
* **Report:** three pages (Executive Overview, Product and Customer, Order Detail with drill-through), a tooltip page and bookmarks.
* **Security:** row-level security with a mapping table, a RegionManager role and an Executive role.
* **Evidence and documentation:** reconciliation, ETL, DAX, security and performance tests, a data dictionary, a user guide, a README, a demo recording and the presentation.

## What I learned

* **Reconciliation catches real mistakes.** My first customer dimension labelled 635 store customers as individuals and left their country as Unknown. Revenue still matched, so only a row-level check exposed it. I learned to test each table, not only the grand total, and to fix it in place so surrogate keys stayed stable.
* **Design for repeatable loads.** Dimensions are updated in place and the fact table is reloaded in full, so running the job twice gives the same result. Running it repeatedly and checking the counts proved it.
* **Time intelligence depends on the data.** The data runs from 30 May 2022 to 29 June 2025 and thins out at the end, so a plain year-over-year figure for 2025 looked like a 54% drop. A "comparable period" measure was needed, and I had to explain the limitation instead of hiding it.
* **Row-level security filters through relationships.** I verified it by comparing "View as" results with SQL totals for two managers, which matched to the cent. I also learned its limits: other dimensions can still list names, and roles can only be assigned to real users in the Power BI Service.
* **Version control is part of the work.** Several files I thought I had saved were never in the repository until I checked GitHub myself. Checking the repo, not just my laptop, mattered.
* **Working with an AI assistant.** \[I used Claude as a guide. It explained steps and wrote draft scripts, and I ran, checked and corrected them myself. Some of its early answers were wrong, such as the expected customer counts, and I only caught them by testing against the source data.]

## What I would do differently

* Commit to Git from the first script, and save every SQL script as a file instead of leaving it in a query tab.
* Check the Power BI Service account requirement on day one. Without a work or school account I could not publish or schedule a cloud refresh, so I tested in Desktop and wrote a deployment plan instead.
* Build the Top 10 filter, number formats and slicer behaviour as I went, and take the screenshots after, not before, so that evidence matches the final report.
* Add watermark-based incremental loads and use the product cost history, so cost reflects the date of sale and the load scales beyond a full reload.

## What I would do next

Publish to the Power BI Service with a gateway and a 07:00 refresh, assign real users to the security roles, and move the load to an always-on server so the scheduled job does not depend on my laptop being switched on.

