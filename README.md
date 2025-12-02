# Medication Safety Checker

##  Project Overview
The **Medication Safety Checker** is a PL/SQL–based system designed to detect harmful medicine–medicine interactions within patient prescriptions. It automatically generates alerts, logs interactions, and improves patient safety through automated clinical decision support.

##  Student Information
**Name:** Gatoya Cyuzuzo Grace  
**Student ID:** (Add your ID here)

##  Problem Statement
Prescribing multiple medicines without checking interactions can lead to harmful or even life-threatening adverse effects. Healthcare providers often lack automated tools to quickly identify dangerous medicine combinations. This project aims to provide a database-driven safety mechanism that checks interactions in real time and alerts doctors before dispensing medication.

##  Key Objectives
- Detect known medicine–medicine interactions during prescription entry.  
- Automatically generate alerts with severity levels (Minor, Moderate, Major).  
- Log all interactions and prescription changes for auditing.  
- Provide scalable, normalized database design in 3NF.  
- Support BI analysis of interaction trends, high-risk patients, and frequently interacting medicine pairs.  

##  Quick Start Instructions
1. Clone or download this repository.  
2. Open the `database/scripts/` folder.  
3. Run the scripts in this order:
   - `create_tables.sql`
   - `sample_data.sql`
   - `functions.sql`
   - `procedures.sql`
   - `package_med_checker.sql`
   - `triggers.sql`
4. Use queries in `/queries` to validate system functionality.
5. Review BI documentation for analytics and KPI insights.

##  Documentation Links
- **Data Dictionary:** `/documentation/data_dictionary.md`  
- **Architecture:** `/documentation/architecture.md`  
- **Design Decisions:** `/documentation/design_decisions.md`  
- **Schema Description:** `/database/documentation/schema_description.md`  
- **Normalization Explanation:** `/database/documentation/normalization_explanation.md`  
- **Constraints:** `/database/documentation/constraints.md`  
- **BI Requirements:** `/business_intelligence/bi_requirements.md`  
- **Dashboards:** `/business_intelligence/dashboards.md`  
- **KPIs:** `/business_intelligence/kpi_definitions.md`




