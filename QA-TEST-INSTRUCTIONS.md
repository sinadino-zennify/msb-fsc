# QA Test Instructions: ST-003 Wizard Data Pre-population

**Feature**: Pre-populate wizard data from Opportunity and Account records  
**Branch**: `feature/ST-003-pre-populate-wizard-data`  
**Status**: Ready for QA  
**Estimated Test Time**: 20-30 minutes

---

## Overview

When a user launches the DAO wizard from an Opportunity or Account record page, the wizard should automatically pre-fill information based on the related Account (Person or Business) and Primary Contact. This saves time and reduces data entry errors.

---

## Test Scenarios

### ✅ Test 1: Launch from Opportunity with Business Account

**Setup**:
1. Find or create an Opportunity with a related Business Account
2. Ensure the Business Account has:
   - Business name, address, phone, email
   - Optional: Primary Contact set (`FinServ__PrimaryContact__c`)

**Steps**:
1. Navigate to the Opportunity record page
2. Click "New Application" (or equivalent action to launch wizard)
3. Observe the wizard steps

**Expected Results**:
- ✅ Business Information step is pre-filled with:
  - Business name, address, phone, email, website
  - NAICS code (if set), industry type, description
  - Annual revenue, number of employees
- ✅ If Primary Contact exists, Applicant Information step is pre-filled with:
  - Name, email, phone numbers
  - Mailing address
  - Birth date, tax ID (if available)
- ✅ All pre-filled fields are editable
- ✅ Clicking "Next" or "Save & Exit" saves the data correctly

---

### ✅ Test 2: Launch from Opportunity with Person Account

**Setup**:
1. Find or create an Opportunity with a related Person Account
2. Ensure the Person Account has:
   - First name, last name, email, phone
   - Mailing address, birth date

**Steps**:
1. Navigate to the Opportunity record page
2. Click "New Application"
3. Observe the wizard steps

**Expected Results**:
- ✅ Business Information step is **hidden** (not shown in wizard flow)
- ✅ Applicant Information step is pre-filled with:
  - Name, email, phone numbers
  - Mailing address
  - Birth date, tax ID (if available)
- ✅ All pre-filled fields are editable
- ✅ Clicking "Next" or "Save & Exit" saves the data correctly

---

### ✅ Test 3: Launch from Business Account Record Page

**Setup**:
1. Find or create a Business Account with data

**Steps**:
1. Navigate to the Business Account record page
2. Click "New Application"
3. Observe the wizard steps

**Expected Results**:
- ✅ Business Information step is pre-filled with business data
- ✅ If Primary Contact is set, Applicant Information step is pre-filled
- ✅ All pre-filled fields are editable

---

### ✅ Test 4: Launch from Person Account Record Page

**Setup**:
1. Find or create a Person Account with data

**Steps**:
1. Navigate to the Person Account record page
2. Click "New Application"
3. Observe the wizard steps

**Expected Results**:
- ✅ Business Information step is **hidden**
- ✅ Applicant Information step is pre-filled with Person Account data
- ✅ All pre-filled fields are editable

---

### ✅ Test 5: Edit Pre-filled Data

**Setup**:
1. Launch wizard from any entry point with pre-filled data

**Steps**:
1. Edit one or more pre-filled fields (e.g., change email, phone, address)
2. Click "Next" to proceed to next step
3. Click "Previous" to go back
4. Verify edited values are retained
5. Click "Save & Exit"
6. Re-open the ApplicationForm record and verify saved data

**Expected Results**:
- ✅ Edited values are retained when navigating between steps
- ✅ Edited values are saved correctly to the ApplicationForm and Applicant records
- ✅ Pre-filled values can be cleared/deleted

---

### ✅ Test 6: Blank Slate (No Pre-fill)

**Setup**:
1. Launch wizard without a context record (e.g., from app page or with no related Account)

**Steps**:
1. Open the wizard
2. Observe all steps

**Expected Results**:
- ✅ All fields are blank (no pre-filled data)
- ✅ User can manually enter all information
- ✅ Wizard functions normally

---

## Key Fields to Verify

### Applicant Information
- [ ] Salutation, First Name, Last Name
- [ ] Birth Date
- [ ] Tax ID, Tax ID Type
- [ ] Email, Mobile Phone, Home Phone, Work Phone
- [ ] Mailing Address (Street Line 1, Street Line 2, City, State, Postal Code, Country)
- [ ] Government ID (Type, Number, Issuing Country, Issuing State, Issue Date, Expiration Date)

### Business Information
- [ ] Business Name
- [ ] Business Type
- [ ] Tax ID
- [ ] NAICS Code, NAICS Description, Industry Type
- [ ] Business Phone, Email, Website
- [ ] Annual Revenue, Number of Employees
- [ ] Business Address (Street Line 1, Street Line 2, City, State, Postal Code, Country)

---

## Known Limitations (Not Bugs)

1. **No DBA Field**: "Doing Business As" is not pre-filled (no standard field on Account)
2. **No Date Established**: "Date Established" is not pre-filled (no standard field on Account)
3. **No State of Incorporation**: "State of Incorporation" is not pre-filled (no standard field on Account)
4. **BusinessEntityType Picklist**: Some picklist values may not match (tracked as separate follow-up)

---

## Reporting Issues

If you find any issues, please report them with:
- **Entry Point**: Which record type (Opportunity/Account) and Account type (Business/Person)
- **Field Name**: Which field is not pre-filling or saving correctly
- **Expected vs Actual**: What you expected vs what happened
- **Screenshots**: If applicable

---

**Questions?** Contact the development team or refer to `docs/04-implementation/session-notes/2025-11-12-st-003-prepopulation-complete.md` for technical details.

