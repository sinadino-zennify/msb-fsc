# ST-002 Clarifying Questions - 2025-11-10

**Date**: 2025-11-10  
**Context**: Reviewing ST-002 (Persist Application Data) before implementation  
**Status**: Questions raised, awaiting clarification

---

## 🤔 Questions Raised

### 1. Entry Point Context & ApplicationForm Creation

**Q1.1: ApplicationForm creation by entry point**
- **Opportunity entry**: Set `ApplicationForm.OpportunityId` AND `ApplicationForm.AccountId` (from Opportunity.AccountId)?
- **Account entry**: Set only `ApplicationForm.AccountId`? (No OpportunityId)
- **ApplicationForm entry**: ApplicationForm already exists, just update it?

**Q1.2: Timing of ApplicationForm creation**
- Should we create it **immediately on wizard load** (before any step is saved)?
- Or create it **on first step save** (when user clicks Next/Save)?
- What if user launches from ApplicationForm entry point? (ApplicationForm already exists)

### 2. Business Account Handling

**Q2.1: ACR removal implications**
- We're **NOT creating AccountContactRelations at all** in ST-002?
- Or we're deferring ACR creation to a future story?
- How will we link PersonAccounts to Business Accounts without ACRs?

**Q2.2: Person Account entry points**
- For Opportunity → Person Account, Account → Person Account scenarios:
  - Do we skip Business Information step entirely?
  - Do we still create a Business Account, or leave `ApplicationForm.AccountId` null?
  - Or do we create a "shell" Business Account for the Person?

### 3. Primary Applicant vs Additional Applicants

**Q3.1: Distinguishing Primary from Additional**
- Is there an `IsPrimary` field on Applicant object?
- Or is the first Applicant always considered primary?
- Does the Personal Information step create the "Primary Applicant"?

**Q3.2: ACR references in tasks**
- Task 3.1 mentions "create/update Applicant + PersonAccount + ACR" but ACR was removed from acceptance criteria
- Should ACR be removed from all tasks?

### 4. Applicant ↔ PersonAccount Relationship

**Q4.1: Applicant.AccountId field**
- Does `Applicant.AccountId` point to the PersonAccount's **AccountId**?
- Or does it point to the Business Account?
- Can you clarify the Applicant object structure?

**Q4.2: PersonAccount dual identity**
- When we create a PersonAccount, we get both an AccountId and a ContactId
- Which one do we store on Applicant?

### 5. Upsert Logic & Duplicate Detection

**Q5.1: PersonAccount duplicate detection**
- Should we query by email to find existing PersonAccount?
- Or use an external ID field?
- What happens if we find a duplicate - update it or error?

**Q5.2: Business Account upsert logic**
- If launched from Opportunity, we have `Opportunity.AccountId` - do we always update that Account?
- If launched from Account, we have the AccountId - do we always update that Account?
- When do we create a NEW Business Account vs update existing?

### 6. Important Notes Section Confusion

The Important Notes section says:
> "Always have a Business Account tied to Opportunity"

But ST-003 shows we can have:
- Opportunity → Person Account (no Business Account)
- Account → Person Account (no Business Account)

**Q6.1: Business Account optionality**
- Should Important Notes be updated to reflect that Business Account is **optional** depending on entry point?

### 7. Field Mappings

**Q7.1: Field mapping documentation**
- Do these files exist?
  - `/docs/01-foundation/business-account-field-mapping.md`
  - `/docs/01-foundation/personaccount-address-mapping.md`
- Should we check them to understand the field mappings?

### 8. Applicant Object Fields

**Q8.1: Applicant object structure**
- Is it a standard FSC object or custom?
- What fields exist on the Applicant object?
- What fields do we need to map from the wizard to Applicant?
- Does it have fields like FirstName, LastName, Email, etc., or does it just link to PersonAccount?

---

## 🎯 Key Concerns Summary

1. **Entry point handling** - Need clarity on how ApplicationForm creation differs by entry point
2. **ACR removal** - Implications for linking PersonAccounts to Business Accounts
3. **Business Account optionality** - Person Account scenarios don't need Business Account
4. **Applicant object structure** - Need to understand Applicant fields and relationships
5. **Upsert vs Create logic** - When to update existing records vs create new ones

---

## 📝 Next Steps

- [ ] User to review and answer questions
- [ ] Update ST-002 based on answers
- [ ] Clarify data model relationships
- [ ] Document Applicant object structure
- [ ] Update Important Notes section for accuracy

---

**Created by**: AI Agent  
**Reviewed by**: [Pending]
