# Schema Description

This document explains every table, column, key, relationship, and purpose in your Medication Interaction & Prescription Safety System.

---

## 1. **PATIENT**

Stores basic demographic and medical information about patients.

### **Table: `patient`**

| Column               | Type           | Description                                          |
| -------------------- | -------------- | ---------------------------------------------------- |
| `patient_id`         | NUMBER (PK)    | Unique identifier for each patient (auto‑generated). |
| `full_name`          | VARCHAR2(200)  | Patient's full name.                                 |
| `date_of_birth`      | DATE           | Birth date of the patient.                           |
| `gender`             | VARCHAR2(10)   | Gender (M/F/Other).                                  |
| `contact_info`       | VARCHAR2(200)  | Phone number, email, etc.                            |
| `allergies`          | VARCHAR2(1000) | Known allergies.                                     |
| `medical_conditions` | VARCHAR2(1000) | Chronic conditions or notes.                         |

### **Purpose**

Represents the people receiving prescriptions. Other tables link to this through `patient_id`.

---

## 2. **DOCTOR**

Stores information about medical professionals who issue prescriptions.

### **Table: `doctor`**

| Column           | Type          | Description                           |
| ---------------- | ------------- | ------------------------------------- |
| `doctor_id`      | NUMBER (PK)   | Unique auto‑generated doctor ID.      |
| `full_name`      | VARCHAR2(200) | Name of the doctor.                   |
| `specialization` | VARCHAR2(100) | Medical specialty (e.g., Cardiology). |
| `contact_info`   | VARCHAR2(200) | Email or phone number.                |

### **Purpose**

Doctors author prescriptions and handle alerts.

---

## 3. **MEDICINE**

Stores metadata about medications.

### **Table: `medicine`**

| Column         | Type          | Description                             |
| -------------- | ------------- | --------------------------------------- |
| `med_id`       | NUMBER (PK)   | Unique ID for each drug.                |
| `med_name`     | VARCHAR2(200) | Commercial/standard name.               |
| `composition`  | VARCHAR2(500) | Active ingredients.                     |
| `category`     | VARCHAR2(100) | Drug category (Analgesic, Antibiotic…). |
| `dosage_form`  | VARCHAR2(50)  | Tablet, capsule, injection, etc.        |
| `strength`     | VARCHAR2(50)  | Example: 500 mg.                        |
| `manufacturer` | VARCHAR2(200) | Pharma producer name.                   |
| `is_active`    | CHAR(1)       | 'Y' = available, 'N' = discontinued.    |

### **Purpose**

Provides structured drug information used for prescriptions and interaction checks.

---

## 4. **PRESCRIPTION** (Header)

Represents the main prescription issued for a patient.

### **Table: `prescription`**

| Column       | Type          | Description               |
| ------------ | ------------- | ------------------------- |
| `pres_id`    | NUMBER (PK)   | Unique auto‑generated ID. |
| `patient_id` | NUMBER (FK)   | Links to `patient`.       |
| `doctor_id`  | NUMBER (FK)   | Links to `doctor`.        |
| `pres_date`  | DATE          | Default = current date.   |
| `remarks`    | VARCHAR2(500) | Optional notes.           |

### **Purpose**

Acts as the parent record for detailed medication lines.

---

## 5. **PRESCRIPTION_DETAIL** (Line Items)

Represents each medicine included in a prescription.

### **Table: `prescription_detail`**

| Column          | Type         | Description                     |
| --------------- | ------------ | ------------------------------- |
| `detail_id`     | NUMBER (PK)  | Unique line identifier.         |
| `pres_id`       | NUMBER (FK)  | Links to prescription header.   |
| `med_id`        | NUMBER (FK)  | Medication being prescribed.    |
| `dose`          | VARCHAR2(50) | Example: "1 tablet".            |
| `frequency`     | VARCHAR2(50) | Example: "twice daily".         |
| `duration_days` | NUMBER       | Number of days treatment lasts. |

### **Purpose**

Allows each prescription to contain multiple drugs.

---

## 6. **INTERACTION**

Stores known interaction pairs between medicines.

### **Table: `interaction`**

| Column               | Type           | Description               |
| -------------------- | -------------- | ------------------------- |
| `interaction_id`     | NUMBER (PK)    | Auto‑generated ID.        |
| `med1_id`            | NUMBER (FK)    | First medicine ID.        |
| `med2_id`            | NUMBER (FK)    | Second medicine ID.       |
| `severity_level`     | VARCHAR2(20)   | Minor / Moderate / Major. |
| `effect_description` | VARCHAR2(1000) | Pharmacological impact.   |
| `management_advice`  | VARCHAR2(1000) | Recommended action.       |

### **Important Rule**

* Pairs are always stored as **med1_id < med2_id** (canonical rule).
* Enforced by logic in functions, procedures, and the package.

### **Purpose**

Defines dangerous/important interactions used for safety alerts.

---

## 7. **ALERT_LOG**

Stores alerts generated by triggers, procedures, or package logic.

### **Table: `alert_log`**

| Column           | Type           | Description                           |
| ---------------- | -------------- | ------------------------------------- |
| `alert_id`       | NUMBER (PK)    | Unique alert ID.                      |
| `patient_id`     | NUMBER (FK)    | Patient affected.                     |
| `pres_id`        | NUMBER (FK)    | Prescription where conflict happened. |
| `med1_id`        | NUMBER (FK)    | First medicine in interaction.        |
| `med2_id`        | NUMBER (FK)    | Second medicine in interaction.       |
| `alert_date`     | TIMESTAMP      | When alert occurred.                  |
| `severity_level` | VARCHAR2(20)   | Minor/Moderate/Major.                 |
| `message`        | VARCHAR2(1000) | Explanation text.                     |
| `handled_by`     | NUMBER (FK)    | Doctor responsible.                   |

### **Purpose**

Tracks medication conflicts for audit, BI dashboards, reporting, or decision‑making.

---

## 8. **PUBLIC_HOLIDAYS**

Table enforcing business rules that **no INSERT/UPDATE/DELETE is allowed on weekdays or holidays**.

### **Table: `public_holidays`**

| Column         | Type         | Description          |
| -------------- | ------------ | -------------------- |
| `holiday_date` | DATE (PK)    | Date of holiday.     |
| `description`  | VARCHAR2(30) | Holiday description. |

### **Purpose**

Used by DML‑restriction triggers (`trg_patient_restrict`, `trg_doctor_restrict`, `trg_medicine_restrict`) to enforce the project’s critical business rule.

---

## 9. **Relationships Summary**

### **One‑to‑Many**

* **PATIENT → PRESCRIPTION**
* **DOCTOR → PRESCRIPTION**
* **PRESCRIPTION → PRESCRIPTION_DETAIL**

### **Many‑to‑Many (resolved via interaction/alert tables)**

* **MEDICINE ↔ MEDICINE** (via INTERACTION)
* **PRESCRIPTION ↔ MEDICINE** (via PRESCRIPTION_DETAIL)

### **Audit/Logs**

* `alert_log` stores generated alerts.
* Additional audit tables exist only if implemented (`prescription_detail_audit`).

---

## 10. **High‑Level Schema Diagram (Text Summary)**

```
PATIENT (1) ----- (M) PRESCRIPTION (1) ----- (M) PRESCRIPTION_DETAIL ----- (M) MEDICINE

MEDICINE (M) ---- (M) MEDICINE  via INTERACTION

ALERT_LOG → references: patient, prescription, medicine, doctor

PUBLIC_HOLIDAYS → used by DML restriction triggers
```

---


