# Session Notes - 2025-11-11

## Summary
- Refined Business Details data staging to Applicant, removed Account/Contact upserts during wizard.
- Fixed Business Account and Primary Contact lookups in `businessDetails` LWC.
- Replaced SW_ Account field references with Applicant fields.
- Created new Applicant fields and updated mappings.
- Enabled and aligned Record Type filtering.
- Deployed all changes to `msb-sbox` for testing.

## Deployments
- 13:01 UTC: Enabled IndustriesBusiness RecordType + LWC filter
  - Deployment ID: 0AfWE00000EwdiT0AR
- 13:27 UTC: New Applicant fields + Apex + LWC
  - Deployment ID: 0AfWE00000EwgMz0AJ
- 13:33 UTC: Lookup matching fixes (record picker)
  - Deployment ID: 0AfWE00000EwgwT0AR
- 13:37 UTC: Simplified matchingInfo to only use Name
  - Deployment ID: 0AfWE00000EwhNt0AJ
- 13:44 UTC: New PersonAccount lookup field + Apex logic
  - Deployment ID: 0AfWE00000EwhR80AJ

## Object/Field Changes (Applicant)
- Created: `Doing_Business_As__c` (Text 255)
- Created: `Business_Registration_State__c` (Text 2)
- Existing: `Date_Established__c` (Date)
- Created: `Primary_Contact_PersonAccount__c` (Lookup to Account)

## LWC: businessDetails
- Account lookup
  - Filter: `RecordType.DeveloperName = 'IndustriesBusiness'`
  - Display: Name, Phone, BillingCity
  - Matching: Name only (to satisfy record picker constraints)
- Primary Contact lookup
  - Object: `Account` (PersonAccount)
  - Filter: `IsPersonAccount = true`
  - Display: Name, PersonEmail, Phone
  - Matching: Name only
- Removed all references to `SW_` fields from UI population logic.

## Apex: WizardPersistenceService
- `upsertBusinessStep`
  - Map business identity to Applicant:
    - `Doing_Business_As__c`, `Business_Registration_State__c`, `Date_Established__c`
  - Primary Contact handling:
    - New: store `Primary_Contact_Name__c`, `Primary_Contact_Title__c`; clear `Primary_Contact_PersonAccount__c`
    - Existing: store `Primary_Contact_PersonAccount__c`; clear `Primary_Contact_Name__c`, `Primary_Contact_Title__c`
  - Keeps linking `ApplicationForm.AccountId` only when an existing Business Account is selected.
- `getAccountDetails`
  - Query only standard fields (Name, Phone, Website, Billing*, AnnualRevenue, NumberOfEmployees, Industry)
  - Removed `SW_` fields which are PersonAccount-only.

## Field Mappings
- Updated `/docs/01-foundation/field-mappings.csv`:
  - DBA -> `Applicant.Doing_Business_As__c`
  - Date Established -> `Applicant.Date_Established__c`
  - State of Incorporation -> `Applicant.Business_Registration_State__c`
  - Removed `SW_` Account field references

## Record Types
- Verified `IndustriesBusiness` (DeveloperName) is active.
- UI lookup filter uses `IndustriesBusiness`. API-based RecordType reassignment for test Accounts is blocked by profile; testing is performed with default-accessible Accounts as needed.

## Notes / Follow-ups
- Step 5.5/6.x (Tax ID encryption) not addressed in this session.
- If needed, grant profile access to `IndustriesBusiness` for record editing/assignment.
- Consider adding UI cue when Existing Primary Contact is selected (read-only Name/Title inputs).

## Testing Instructions
1. Refresh the app.
2. Business Account toggle: select Existing, search for sample Accounts.
3. Primary Contact toggle: select Existing, search PersonAccounts.
4. For New Primary Contact, enter Name/Title and persist; verify values on Applicant.
5. For Existing Primary Contact, select a PersonAccount; verify `Primary_Contact_PersonAccount__c` is populated and Name/Title are cleared.
