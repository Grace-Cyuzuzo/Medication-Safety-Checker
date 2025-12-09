# Constraints Documentation

This document outlines all **constraints** applied across the database schema of the **Medication Safety Checker System**. These constraints enforce data integrity, prevent invalid data states, and ensure the business rules are respected.

---

# 1. **Primary Key (PK) Constraints**

Primary keys uniquely identify each record in a table.

### **patient**

* `patient.patient_id` – PK

### **doctor**

* `doctor.doctor_id` – PK

### **medicine**

* `medicine.med_id` – PK

### **prescription**

* `prescription.pres_id` – PK

### **prescription_detail**

* `prescription_detail.detail_id` – PK

### **interaction**

* `interaction.interaction_id` – PK

### **alert_log**

* `alert_log.alert_id` – PK

### **public_holidays**

* `public_holidays.holiday_date` – PK

---

# 2. **Foreign Key (FK) Constraints**

Foreign keys maintain relationships between tables.

### **prescription**

* `fk_pres_patient` → patient(patient_id)
* `fk_pres_doctor` → doctor(doctor_id)

### **prescription_detail**

* `fk_pd_pres` → prescription(pres_id)
* `fk_pd_med` → medicine(med_id)

### **interaction**

* `fk_int_med1` → medicine(med_id)
* `fk_int_med2` → medicine(med_id)

### **alert_log**

* `fk_alert_patient` → patient(patient_id)
* `fk_alert_pres` → prescription(pres_id)
* `fk_alert_med1` → medicine(med_id)
* `fk_alert_med2` → medicine(med_id)
* `fk_alert_handledby` → doctor(doctor_id)

---

# 3. **Unique Constraints**

### **interaction**

* `ux_medpair` (med1_id, med2_id)

  * Prevents duplicate interaction pairs.
  * Enforced using canonical ordering (LEAST/GREATEST).

---

# 4. **Check Constraints**

These ensure valid values in a column.

### **medicine**

* `CHECK (is_active IN ('Y','N'))`

### **interaction**

* `CHECK (severity_level IN ('Minor','Moderate','Major'))`

### **prescription_detail**

* `CHECK (duration_days >= 0)`

---

# 5. **Index Constraints (Performance Optimization)**

Indexes improve query performance.

### **prescription**

* `ix_pres_patient` on patient_id

### **prescription_detail**

* `ix_pd_pres` on pres_id
* `ix_pd_med` on med_id

### **interaction**

* `ix_int_meds` on (med1_id, med2_id)

### **alert_log**

* `ix_alert_date` on alert_date
* `ix_alert_meds` on (med1_id, med2_id)

---

# 6. **Business Rule Constraints (Triggers)**

These enforce higher-level rules that normal constraints cannot.

## **6.1 Automatic Drug Interaction Alerts**

* Trigger: `ctr_prescription_interaction`
* Event: INSERT/UPDATE on prescription_detail
* Enforces:

  * Auto-detection of interactions
  * Auto-insertion into alert_log

## **6.2 Weekday & Public Holiday Restriction Rule (CRITICAL REQUIREMENT)**

Employees **CANNOT INSERT/UPDATE/DELETE** on:

* Weekdays (Mon–Fri)
* Public Holidays within the next 30 days

Applied to:

* `trg_patient_restrict`
* `trg_doctor_restrict`
* `trg_medicine_restrict`

These triggers use:

* `TO_CHAR(SYSDATE, 'DY')` for weekday check
* `public_holidays` table for holiday validation

---

# 7. **Auditing Constraints**

(If audit table present)

* `prescription_detail_audit` table captures:

  * Old values
  * New values
  * User
  * Timestamp

Trigger name may vary but enforces:

* BEFORE UPDATE
* Logs changes for accountability

---

# 8. **Data Integrity Enforcement Summary**

| Category | Purpose                           |
| -------- | --------------------------------- |
| PK       | Uniqueness of each row            |
| FK       | Referential integrity             |
| UNIQUE   | Prevent duplicates                |
| CHECK    | Validate allowed values           |
| INDEX    | Improve performance               |
| TRIGGERS | Apply business rules & automation |
| AUDIT    | Track changes                     |

---

# 9. Final Notes

This database ensures:

* **Data consistency** (through PK, FK, CHECK)
* **Performance optimization** (indexes)
* **Safety logic** (interaction triggers)
* **Compliance with operational policies** (weekday/holiday rules)
* **Traceability** (audit logs)

This completes the system's constraint documentation.
