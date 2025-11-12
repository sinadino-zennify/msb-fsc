# Scripts Directory

Utility scripts for {{PROJECT_NAME}}.

---

## 📋 Available Scripts

### `test-api-template.apex`

**Purpose**: Test script template for validating API payload parsing  
**Usage**:
```bash
sf apex run --file scripts/test-api-template.apex --target-org {{ORG_ALIAS}}
```

**Customize**:
1. Update the JSON payload to match your field mappings
2. Replace `YourPayloadClass` with your actual DTO class name
3. Add field validation logic

### `create-applicants.apex`

**Purpose**: Seed primary and secondary `Applicant` records (and matching PersonAccounts) for a specific `ApplicationForm`.  
**Usage**:
```bash
sf apex run --file scripts/create-applicants.apex --target-org <ORG_ALIAS>
```

**Customize**:
1. Update the `applicationFormId` inside the script for the target record.
2. Adjust the sample applicant seed data (names, dates, IDs, addresses) as needed.
3. Add or remove entries from the seed list to match your testing scenarios.

---

## ✍️ Creating New Scripts

1. Add your script to this directory
2. Make it executable: `chmod +x script-name.sh`
3. Document it in this README
4. Add usage examples

---

## 📚 Script Guidelines

- Use bash for shell scripts
- Use Apex for Salesforce operations
- Add error handling
- Include usage comments
- Test before committing

---

**Last Updated**: 2025-01-16

