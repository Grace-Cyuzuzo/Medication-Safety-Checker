# BI Architecture 

## Source Layer (OLTP)
Comes from the main database:
- PATIENT  
- PRESCRIPTION  
- PRESCRIPTION_DETAIL  
- INTERACTION  
- ALERT_LOG  
- AUDIT tables  

These tables generate real-time operational data.

---

## ETL (Extraction & Transformation)
Raw data is selected using:
- SQL views  
- Aggregation queries (monthly, by doctor, by severity)  
- Joins between prescriptions ↔ alerts ↔ medicines  

Transformations include:
- Risk scoring  
- Severity classification  
- Trend grouping (monthly or weekly)  

---

##  BI Semantic Layer
Provides:
- KPIs  
- Metrics  
- Summary tables  
- Trend datasets  

This layer is used by dashboards.

---

##  Presentation Layer (Dashboards)
Dashboards display:
- Alert trends  
- Doctor performance  
- Patient safety insights  
- High-risk medicine pairs  

Tools (conceptual):  
Power BI / Tableau / Oracle Analytics Cloud (not required to implement, only conceptually).

---


