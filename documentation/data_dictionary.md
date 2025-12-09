# Data Dictionary — Medication Safety Checker

> Oracle types shown. Adjust sizes if needed.

### PATIENT
| Column | Type | PK/FK | Nullable | Description |
|---|---:|:---:|:---:|---|
| patient_id | NUMBER | PK | NO | Unique patient identifier |
| full_name | VARCHAR2(200) |  | NO | Patient full name |
| date_of_birth | DATE |  | YES | Date of birth |
| gender | VARCHAR2(10) |  | YES | Gender |
| contact_info | VARCHAR2(200) |  | YES | Contact details |
| allergies | VARCHAR2(1000) |  | YES | Free-text allergy notes |
| medical_conditions | VARCHAR2(1000) |  | YES | Free-text medical conditions |

---

### DOCTOR
| Column | Type | PK/FK | Nullable | Description |
|---|---:|:---:|:---:|---|
| doctor_id | NUMBER | PK | NO | Unique doctor id |
| full_name | VARCHAR2(200) |  | NO | Doctor name |
| specialization | VARCHAR2(100) |  | YES | Medical specialty |
| contact_info | VARCHAR2(200) |  | YES | Contact details |

---

### MEDICINE
| Column | Type | PK/FK | Nullable | Description |
|---|---:|:---:|:---:|---|
| med_id | NUMBER | PK | NO | Medicine identifier |
| med_name | VARCHAR2(200) |  | NO | Medicine name |
| composition | VARCHAR2(500) |  | YES | Active ingredients |
| category | VARCHAR2(100) |  | YES | e.g., Analgesic |
| dosage_form | VARCHAR2(50) |  | YES | Tablet, syrup |
| strength | VARCHAR2(50) |  | YES | e.g., 500 mg |
| manufacturer | VARCHAR2(200) |  | YES | Manufacturer |
| is_active | CHAR(1) |  | NO | 'Y' or 'N' - active flag |

---

### PRESCRIPTION
| Column | Type | PK/FK | Nullable | Description |
|---|---:|:---:|:---:|---|
| pres_id | NUMBER | PK | NO | Prescription id |
| patient_id | NUMBER | FK → PATIENT(patient_id) | NO | Patient |
| doctor_id | NUMBER | FK → DOCTOR(doctor_id) | YES | Prescriber |
| pres_date | DATE |  | NO | Date of prescription |
| remarks | VARCHAR2(500) |  | YES | Optional notes |

---

### PRESCRIPTION_DETAIL
| Column | Type | PK/FK | Nullable | Description |
|---|---:|:---:|:---:|---|
| detail_id | NUMBER | PK | NO | Detail line id |
| pres_id | NUMBER | FK → PRESCRIPTION(pres_id) | NO | Parent prescription |
| med_id | NUMBER | FK → MEDICINE(med_id) | NO | Medicine prescribed |
| dose | VARCHAR2(50) |  | YES | e.g., 1 tablet |
| frequency | VARCHAR2(50) |  | YES | e.g., twice/day |
| duration_days | NUMBER |  | YES | Number of days |

---

### INTERACTION
| Column | Type | PK/FK | Nullable | Description |
|---|---:|:---:|:---:|---|
| interaction_id | NUMBER | PK | NO | Interaction id |
| med1_id | NUMBER | FK → MEDICINE(med_id) | NO | Medicine 1 (canonical order) |
| med2_id | NUMBER | FK → MEDICINE(med_id) | NO | Medicine 2 (canonical order) |
| severity_level | VARCHAR2(20) |  | NO | 'Minor'/'Moderate'/'Major' |
| effect_description | VARCHAR2(1000) |  | YES | Clinical effect |
| management_advice | VARCHAR2(1000) |  | YES | How to manage the interaction |

---

### ALERT_LOG
| Column | Type | PK/FK | Nullable | Description |
|---|---:|:---:|:---:|---|
| alert_id | NUMBER | PK | NO | Alert identifier |
| patient_id | NUMBER | FK → PATIENT(patient_id) | YES | Affected patient |
| pres_id | NUMBER | FK → PRESCRIPTION(pres_id) | YES | Related prescription |
| med1_id | NUMBER | FK → MEDICINE(med_id) | YES | First med in pair |
| med2_id | NUMBER | FK → MEDICINE(med_id) | YES | Second med |
| alert_date | TIMESTAMP |  | NO | When alert was created |
| severity_level | VARCHAR2(20) |  | YES | Copied from INTERACTION |
| message | VARCHAR2(1000) |  | YES | Alert text |
| handled_by | NUMBER | FK → DOCTOR(doctor_id) | YES | Who handled it |
