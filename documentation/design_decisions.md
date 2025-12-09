# Design Decisions – Medication Safety Checker

This document explains all major design choices made during the development of the Medication Safety Checker system.  
Each decision supports accuracy, normalization, performance, and extendability.

---

## 1. Use of a Normalized Relational Model (3NF)

### ✔ Decision:
All tables were designed to meet **Third Normal Form (3NF)**.

### ✔ Reason:
- Avoid data duplication  
- Improve consistency  
- Support scalable additions  
- Prevent update anomalies  

### ✔ Impact:
Reduces storage waste and simplifies future enhancements (e.g., medicine categories, new interactions).

---

## 2. Separation of PRESCRIPTION and PRESCRIPTION_DETAIL

### ✔ Decision:
The prescription was split into:
- PRESCRIPTION (header)
- PRESCRIPTION_DETAIL (lines)

### ✔ Reason:
A prescription can contain **multiple medicines**, therefore a one-to-many relationship was required.

### ✔ Impact:
Supports detailed tracking and easier auditing.

---

## 3. Dedicated INTERACTION Table

### ✔ Decision:
A separate INTERACTION table stores known risky medicine combinations.

### ✔ Reason:
- Allows quick lookup using med1_id and med2_id  
- Supports severity classification  
- Easy to update without affecting other tables  

### ✔ Impact:
Centralized interaction rules improve performance and maintain accuracy.

---

## 4. Use of Triggers for Automation

### ✔ Decision:
Triggers were used to:
- Check interactions automatically  
- Insert alerts into ALERT_LOG  
- Audit updates to prescription details  

### ✔ Reason:
Triggers ensure **automatic safety logic** even if the user forgets to run validation manually.

### ✔ Impact:
The system becomes safer, more reliable, and requires no additional application layer.

---

## 5. Alert Logging Mechanism

### ✔ Decision:
All dangerous interactions are recorded in ALERT_LOG.

### ✔ Reason:
- Provides historical tracking  
- Supports BI dashboards and reporting  
- Allows doctors to review past alerts  

### ✔ Impact:
Improves transparency and patient safety.

---

## 6. Audit Table for Updates

### ✔ Decision:
A dedicated AUDIT table stores old and new values.

### ✔ Reason:
To track changes and support security auditing.

### ✔ Impact:
Helps identify who changed a prescription and when.

---

## 7. Use of Surrogate Primary Keys (IDENTITY Columns)

### ✔ Decision:
Numeric IDENTITY columns were used for all primary keys.

### ✔ Reason:
- Simple, fast indexing  
- Avoids complex composite keys  
- Needed for foreign key references  

### ✔ Impact:
Consistent key design across all tables.

---

## 8. Including Severity_Level in INTERACTION

### ✔ Decision:
Severity levels include: Minor, Moderate, Major.

### ✔ Reason:
Different interactions require different responses.

### ✔ Impact:
Allows more accurate clinical recommendations.

---

## 9. Including Manufacturer, Category, Dosage Form in Medicine

### ✔ Decision:
Additional attributes were included for realistic detail.

### ✔ Reason:
Useful for:
- Analytics  
- Future BI dashboards  
- Medicine classification  

---

## 10. BI and Reporting Considerations

### ✔ Decision:
Separate ALERT_LOG acts as the **fact table**, while:
- PATIENT, DOCTOR, MEDICINE act as **dimensions**.

### ✔ Reason:
Enables future reporting such as:
- Most dangerous interactions  
- Doctors generating the most alerts  
- Patients at highest risk  

---

## 11. Use of OEM Express for Monitoring

### ✔ Decision:
OEM Express was used even though the interface is limited.

### ✔ Reason:
Oracle XE does not include full OEM Cloud Control.

### ✔ Impact:
Still provides:
- Instance overview  
- Performance page  
- Storage monitoring  

Enough for the practicum requirements.

---
## 12. Restriction Rule Implementation
To enforce institutional policies on data access, the system implements a  DML restriction rule:
- Employees cannot INSERT, UPDATE, or DELETE data on weekdays (Monday–Friday).

- Employees cannot modify data on public holidays occurring within the upcoming month.

- A dedicated public_holidays table stores upcoming public holiday dates.

- the trigger (for ex: trg_medicine_restrict) validates the system date and blocks operations when necessary.
- the trigger raises controlled errors (RAISE_APPLICATION_ERROR) to notify the user of the restriction reason

This guarantees controlled and secure data modification consistent with organizational policies.

---
## Conclusion
The design decisions were guided by:
- Practical healthcare needs  
- Data accuracy  
- System safety  
- Scalability  
- Best PL/SQL practices  

Together, these decisions create a robust medication safety platform with strong foundations for future development.
