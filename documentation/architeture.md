# System Architecture – Medication Safety Checker

This document describes the system architecture of the **Medication Safety Checker**, a PL/SQL-based solution designed to detect harmful medicine interactions, generate alerts, and audit prescription changes. The architecture includes the presentation layer, application logic layer, data layer, and monitoring layer.

---

##  System Overview
The system enables healthcare stakeholders to:
- Record patient prescriptions
- Automatically detect dangerous medicine combinations
- Generate alerts for risky interactions
- Maintain an audit trail for prescription changes
- Monitor database health and performance

This architecture ensures safety, data integrity, and traceability in medication management.

---

##  Architecture Layers

###  Presentation Layer
The user interacts with the database using:
- **VS Code Oracle Developer Extension**
- **Oracle EM Express** (monitoring only)
- **SQL queries** for inserting prescriptions, updating records, and testing the system

No business logic exists at this layer—only database access and visualization.

---

###  Application Logic Layer (PL/SQL Layer)
This is the core rule-enforcement layer. It includes:

####  **Triggers**
- **CTR_PRESCRIPTION_INTERACTION**  
  Automatically checks for harmful interactions when a medicine is prescribed.
- **AUDIT_PRES_DETAIL_UPDATE**  
  Logs updates to prescription details for traceability.

####  **Functions**
- **check_interaction(med1_id, med2_id)**  
  Returns the severity of a medicine pair (Minor/Moderate/Major).

####  **Procedures** (optional/future extensions)
Used for more complex validation or batch operations.

This layer enforces safety logic automatically without relying on user intervention.

---

###  Data Layer (Relational Database)
Implements the fully normalized (3NF) schema through the following tables:

- **PATIENT**
- **DOCTOR**
- **MEDICINE**
- **PRESCRIPTION**
- **PRESCRIPTION_DETAIL**
- **INTERACTION**
- **ALERT_LOG**
- **PRESCRIPTION_DETAIL_AUDIT**

This layer ensures:
- Referential integrity
- Accurate relationships
- Strong constraints
- Optimized indexes for performance

---

##  Data Flow Architecture

The system uses a structured flow that begins with data entry and ends with monitoring and auditing.  

---

###  Step 1 – Prescription Entry
A doctor records a prescription by inserting into:
- `PRESCRIPTION` – general prescription details  
- `PRESCRIPTION_DETAIL` – each prescribed medicine  

This is the starting point of the data workflow.

---

###  Step 2 – Automatic Interaction Detection
When a medicine is inserted or updated in `PRESCRIPTION_DETAIL`, the trigger  
**CTR_PRESCRIPTION_INTERACTION** fires.

It performs the following:
- Retrieves other medicines in the same prescription
- Checks the `INTERACTION` table
- Determines whether any pair is risky
- Inserts an alert into `ALERT_LOG` if needed

This ensures real-time detection of dangerous combinations.

---

###  Step 3 – Interaction Function Logic
The function `check_interaction(med1_id, med2_id)` allows:
- Manual checking
- Use in BI reports and dashboards
- Query-based validation

It returns a severity level based on the medicine pair.

---

### Step 4 – Audit Logging
When a prescription’s medicine is changed:

```sql
UPDATE prescription_detail SET med_id = ... WHERE detail_id = ...;


## Data flow (Text Diagram)

User inserts prescription
        ↓
PRESCRIPTION + PRESCRIPTION_DETAIL
        ↓
Trigger (CTR_PRESCRIPTION_INTERACTION)
        ↓
Dangerous pair? → Insert into ALERT_LOG
        ↓
If medicine updated → AUDIT trigger logs change
        ↓
OEM Express monitors instance status & performance



---

## Technologies Used

- **Oracle XE 21c** – Database engine  
- **PL/SQL** – triggers, functions  
- **VS Code Oracle Extension** – Development environment  
- **OEM Express** – Monitoring tool  
- **GitHub** – Version control and documentation  

---

##  Conclusion
The architecture of the Medication Safety Checker is built to ensure:
- Data accuracy  
- Automated safety checks  
- Traceability through audits  
- Clear separation of layers  

This foundation supports reliable medication safety screening and scalable extension for future features.


