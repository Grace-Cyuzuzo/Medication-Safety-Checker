# Normalization Explanation

This document explains the normalization process applied to the **Medication Safety Checker Database Schema**. Each major table is analyzed from **1NF → 2NF → 3NF**, describing how the final structure achieves minimal redundancy, integrity, and optimal relational design.

---

# **1. PATIENT Table Normalization**

### **Attributes:**

patient_id, full_name, date_of_birth, gender, contact_info, allergies, medical_conditions

### **1NF**

* All values are atomic.
* patient_id uniquely identifies each row.

### **2NF**

* No composite primary key → automatically in 2NF.
* All attributes depend on the entire key (patient_id).

### **3NF**

* No transitive dependencies.
* contact_info does not determine other attributes.

### **Conclusion:** Fully normalized.

---

# **2. DOCTOR Table Normalization**

### **Attributes:**

doctor_id, full_name, specialization, contact_info

### **1NF**

* All values atomic.

### **2NF**

* No composite primary key, no partial dependencies.

### **3NF**

* specialization and contact_info depend only on doctor_id.
* No transitive dependencies.

### **Conclusion:** Fully normalized.

---

# **3. MEDICINE Table Normalization**

### **Attributes:**

med_id, med_name, composition, category, dosage_form, strength, manufacturer, is_active

### **1NF**

* All attributes are atomic.

### **2NF**

* Simple primary key → no partial dependencies.

### **3NF**

* manufacturer does NOT determine any other fields.
* No transitive dependency.

### **Conclusion:** Fully normalized.

---

# **4. PRESCRIPTION (Header)**

### **Attributes:**

pres_id, patient_id, doctor_id, pres_date, remarks

### **1NF**

* All values atomic.

### **2NF**

* Single primary key → no partial dependency.

### **3NF**

* doctor_id does not determine patient_id.
* No transitive dependencies.

### **Conclusion:** Fully normalized.

---

# **5. PRESCRIPTION_DETAIL (Lines)**

### **Attributes:**

detail_id, pres_id, med_id, dose, frequency, duration_days

### **1NF**

* All fields are atomic.

### **2NF**

* detail_id is the primary key → no composite key issues.
* Alternative design: (pres_id, med_id) could be composite key, but surrogate is acceptable.

### **3NF**

* dose, frequency, duration_days depend only on detail_id.
* No transitive dependencies.

### **Conclusion:** Fully normalized.

---

# **6. INTERACTION Table**

### **Attributes:**

interaction_id, med1_id, med2_id, severity_level, effect_description, management_advice

### **1NF**

* Atomic fields.

### **2NF**

* Single primary key → no partial dependency.

### **3NF**

* severity_level does not determine effect_description or vice-versa.
* All describe the relationship between med1_id and med2_id.

### **Conclusion:** Fully normalized.

---

# **7. ALERT_LOG Table**

### **Attributes:**

alert_id, patient_id, pres_id, med1_id, med2_id, alert_date, severity_level, message, handled_by

### **1NF**

* All values atomic.

### **2NF**

* Single primary key alert_id → satisfies 2NF.

### **3NF**

* No non-key attribute depends on another non-key attribute.
* severity_level is duplicated from INTERACTION on purpose for audit integrity (acceptable denormalization).

### **Conclusion:** Mostly normalized with intentional denormalization for audit history (industry standard).

---

# **8. PUBLIC_HOLIDAYS Table**

### **Attributes:**

holiday_date, description

### **1NF to 3NF**

* Simple lookup table.
* No dependencies.

### **Conclusion:** Fully normalized.

---

# **Overall Normalization Summary**

✔ **All tables meet 3NF requirements**.
✔ **Lookup/reference tables are clean and minimal.**
✔ **Join tables (INTERACTION, PRESCRIPTION_DETAIL) avoid redundancy.**
✔ **Only ALERT_LOG contains acceptable denormalization** (audit-based).

---

# **Final Decision**

The overall schema is correctly normalized to **Third Normal Form (3NF)**, while strategically allowing certain controlled redundancy for:

* **Audit logs (ALERT_LOG)**
* **Historical integrity**

This ensures **data quality**, **referential integrity**, and **optimal performance**.

---


