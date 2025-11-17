# Scripts Directory

Utility scripts that support the Main Street Bank DAO wizard project. Use the commands below as-is or adapt them for your org aliases / record IDs.

---

## 📋 Quick Reference

| Script | Purpose | How to Run |
| --- | --- | --- |
| `init-dao-project.sh` | Replaces template placeholders (project name, client, org alias, etc.) across the repo during first-time setup | `./scripts/init-dao-project.sh` |
| `jira_xml_to_md.py` | Converts a JIRA XML export into Markdown story files grouped by status | `python scripts/jira_xml_to_md.py <xml_path> [output_dir]` |
| `wizard-form-fill.js` | Browser-console helper that auto-populates DAO wizard forms for smoke testing | Paste into DevTools Console while the wizard is open |
| `test-api-template.apex` | Starter Apex script for validating inbound API payload parsing against `field-mappings.csv` | `sf apex run --file scripts/test-api-template.apex --target-org <alias>` |
| `create-applicants.apex` | Seeds rich Applicant data (primary + co-applicant) for a specific `ApplicationForm` with optional PersonAccount scaffolding | `sf apex run --file scripts/create-applicants.apex --target-org <alias>` |
| `apex/create-test-applicants.apex` | Lightweight Applicant generator that meets minimum required fields for quick UI testing | `sf apex run --file scripts/apex/create-test-applicants.apex --target-org <alias>` |

---

## 🛠️ Script Details

### `init-dao-project.sh`
- **What it does**: Prompts for project metadata, then replaces all `{{PLACEHOLDER}}` tokens across docs, configs, and metadata files.
- **When to use**: Cloning the accelerator or spinning up a fresh client project.
- **Notes**: Runs `sed -i` (macOS compatible). Make sure the script is executable (`chmod +x scripts/init-dao-project.sh`).

### `jira_xml_to_md.py`
- **What it does**: Parses a single JIRA XML export, cleans HTML, and generates Markdown story files under `docs/02-requirements/<status>/`.
- **Usage**:
  ```bash
  python scripts/jira_xml_to_md.py exports/MSB-24.xml docs/02-requirements
  ```
- **Customize**: Update the output directory or extend `generate_markdown` if you need different frontmatter.

### `wizard-form-fill.js`
- **What it does**: Traverses the DAO wizard DOM, matches labels to a data map, and populates fields automatically (Business + Applicant steps).
- **Usage**:
  1. Open the DAO wizard in Salesforce.
  2. Copy the entire script.
  3. Paste into the browser console (Chrome DevTools → Console).
  4. Run `window.DAO_WIZARD_FILLER.logLabels()` to inspect labels if something doesn’t populate.
- **Customize**: Edit the `DATA` object inside the script to match the field values you want to inject.

### `test-api-template.apex`
- **What it does**: Provides a JSON payload sample and stub logic for deserializing into your DTO classes.
- **Usage**:
  ```bash
  sf apex run --file scripts/test-api-template.apex --target-org msb-sbox
  ```
- **Customize**:
  1. Replace `YourPayloadClass` with the DTO you’re validating.
  2. Swap the JSON body so it mirrors `docs/01-foundation/field-mappings.csv`.
  3. Add assertions or additional logging before promoting to a real test harness.

### `create-applicants.apex`
- **What it does**: Seeds detailed Applicant records (names, phones, addresses, tax info, IDs) tied to a single `ApplicationForm`.
- **Usage**:
  ```bash
  sf apex run --file scripts/create-applicants.apex --target-org msb-sbox
  ```
- **Customize**:
  - Update `applicationFormId` at the top of the runner.
  - Modify the `ApplicantSeed` entries to match your scenario.
  - Uncomment the PersonAccount block if you also want linked Person Accounts.

### `apex/create-test-applicants.apex`
- **What it does**: Minimal variant that inserts three Applicants with only the required CIP/KYC fields populated.
- **Usage**:
  ```bash
  sf apex run --file scripts/apex/create-test-applicants.apex --target-org msb-sbox
  ```
- **Customize**: Adjust the hard-coded `applicationFormId` and sample data as needed.

---

## ✍️ Creating New Scripts

1. Add your script to `scripts/` (or a subfolder such as `scripts/apex/`).
2. Make it executable if it’s a shell script (`chmod +x scripts/<name>.sh`).
3. Document the purpose and usage in this README.
4. Keep sample data aligned with `docs/01-foundation/field-mappings.csv`.

---

## 📚 Script Guidelines

- Prefer bash for shell automation, Apex for org seeding, and Python/Node for data transforms.
- Always include inline comments for required IDs or environment variables.
- Add error handling (e.g., `set -e` in bash, try/catch in Apex).
- Test against a scratch or sandbox org before committing.

---

**Last Updated**: 2025-11-14

