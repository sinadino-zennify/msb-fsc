# FSC-Enabled Scratch Org Setup Guide

**Date**: 2025-01-20  
**Purpose**: Configure scratch orgs with Financial Services Cloud (FSC) features enabled to mimic msb-sbox sandbox  
**Dev Hub**: sinadino-hub  
**Target**: MSB Scratch Org

---

## 🎯 Overview

This guide documents the complete process to create scratch orgs with FSC features enabled, matching the msb-sbox sandbox configuration. This includes installing required packages, configuring features, and verifying FSC objects are available.


---

## 🔧 Step-by-Step Setup

### Step 1: Create Placeholder Insurance Objects (REQUIRED)

**IMPORTANT**: Before installing FSC, you must create placeholder Insurance objects to satisfy package dependencies.

```bash
# Create placeholder objects (these should already exist in your repo)
# - Claim__c
# - InsurancePolicy__c
# - Alert__c (with lookup fields to Claim__c and InsurancePolicy__c)
# - BillingStatement__c (with lookup field to InsurancePolicy__c)
```

**Why This Is Required**:
The FSC package (version 258.0) includes Insurance-specific fields that reference `Claim__c` and `InsurancePolicy__c` objects. Even for banking-only implementations, these placeholder objects must exist in the org before FSC installation, or the package will fail with:
```
CustomField(Alert__c.Claim__c) referenceTo value of 'Claim' does not resolve to a valid sObject type
```

> **Note**: These placeholder objects are intentionally minimal and won't interfere with banking operations. They exist solely to satisfy FSC package dependencies.

---

### Step 2: Configure project-scratch-def.json

The scratch org definition must include FSC features:

```json
{
  "orgName": "MSB Scratch Org",
  "edition": "Enterprise",
  "country": "US",
  "language": "en_US",
  "features": [
    "PersonAccounts",
    "ContactsToMultipleAccounts",
    "ServiceCloud",
    "Communities",
    "FinancialServicesUser:10",
    "DebugApex",
    "StateAndCountryPicklist",
    "Knowledge"
  ],
  "settings": {
    "lightningExperienceSettings": {
      "enableS1DesktopEnabled": true
    },
    "knowledgeSettings": {
      "enableKnowledge": true,
      "defaultLanguage": "en_US",
      "enableLightningKnowledge": true
    }
  }
}
```

**Key Features**:
- **`FinancialServicesUser:10`**: **CRITICAL** - Enables FSC Core Insurance Objects (required for FSC package installation)
- `PersonAccounts`: Required for individual applicant management
- `ServiceCloud`: Enables Service Cloud features
- `Communities`: Enables Experience Cloud (Communities)
- `DebugApex`: Enables Apex debugging capabilities
- `StateAndCountryPicklist`: Enables State and Country/Territory Picklists feature
- `Knowledge`: Enables Salesforce Knowledge feature
- `OmniStudioDesigner` and `OmniStudioRuntime`: **OPTIONAL** - Required only if installing OmniStudio package (add these features if you plan to install OmniStudio)

**Key Settings**:
- `lightningExperienceSettings.enableS1DesktopEnabled`: Enables Lightning Experience desktop features
- `knowledgeSettings.enableKnowledge`: Enables Salesforce Knowledge
- `knowledgeSettings.defaultLanguage`: Sets default Knowledge article language (en_US)
- `knowledgeSettings.enableLightningKnowledge`: Enables Lightning Knowledge interface

> **Important**: 
> - The `FinancialServicesUser` feature with a value (e.g., `:10`) is **required** for FSC package installation. Without this, the package will fail with errors related to Insurance objects (`Claim`, `InsurancePolicy`, etc.).
> - If you plan to install OmniStudio, add `OmniStudioDesigner` and `OmniStudioRuntime` to the features array **before** creating the scratch org to avoid installation errors (see Step 7 and troubleshooting section).

---

### Step 3: Create Scratch Org with FinancialServicesUser Feature

```bash
# Create scratch org with FinancialServicesUser:10 feature
sf org create scratch \
  --definition-file project-scratch-def.json \
  --alias msb-scratch \
  --duration-days 30 \
  --set-default \
  --target-dev-hub sinadino-hub \
  --wait 10

# Verify scratch org created
sf org display --target-org msb-scratch

# Open scratch org
sf org open --target-org msb-scratch
```

**Expected Output**:
- Scratch org created successfully with `FinancialServicesUser:10` feature
- Org ID returned
- Username generated (e.g., `test-xxxxx@example.com`)

> **Critical**: The `FinancialServicesUser:10` feature in `project-scratch-def.json` enables FSC Core Insurance Objects. This is **mandatory** for FSC package installation to succeed.

---

### Step 4: Deploy Placeholder Insurance Objects

Deploy the placeholder objects to the scratch org **before** installing FSC:

```bash
# Deploy placeholder objects first (base objects without lookup fields)
sf project deploy start \
  --source-dir force-app/main/default/objects/Claim__c \
  --source-dir force-app/main/default/objects/InsurancePolicy__c \
  --target-org msb-scratch \
  --wait 5

# Then deploy objects with lookup fields
sf project deploy start \
  --source-dir force-app/main/default/objects/Alert__c \
  --source-dir force-app/main/default/objects/BillingStatement__c \
  --target-org msb-scratch \
  --wait 5
```

**Expected Output**:
- ✅ `Claim__c` deployed
- ✅ `InsurancePolicy__c` deployed
- ✅ `Alert__c` deployed (with `Claim__c` and `Insurance_Policy__c` lookup fields)
- ✅ `BillingStatement__c` deployed (with `InsurancePolicy__c` lookup field)

> **Important**: Deploy base objects (`Claim__c`, `InsurancePolicy__c`) first, then objects with lookup fields (`Alert__c`, `BillingStatement__c`) to avoid dependency errors.

---

### Step 5: Install FSC Managed Package

Now that placeholder objects are deployed and `FinancialServicesUser:10` is enabled, install FSC:

```bash
# Install FSC managed package (version 258.0)
# Use the package version ID from your msb-sbox org or AppExchange
sf package install \
  --package 04t6g000008av3UAAQ \
  --target-org msb-scratch \
  --wait 30 \
  --no-prompt

# Verify installation
sf package installed list --target-org msb-scratch | grep FinServ
```

**Expected Output**:
```
FinServ  258.0  04t6g000008av3UAAQ  Success
```

> **Success Criteria**: The package should install without errors. If you see `CustomField(Alert__c.Claim__c) referenceTo value of 'Claim' does not resolve to a valid sObject type`, verify that:
> 1. `FinancialServicesUser:10` is in `project-scratch-def.json`
> 2. Placeholder objects (`Claim__c`, `InsurancePolicy__c`, `Alert__c`, `BillingStatement__c`) are deployed
> 3. Scratch org was created **after** adding `FinancialServicesUser:10` to the definition

---

### Step 6: Install FSC Extension Package

Install the FSC Extension package after the core FSC package:

```bash
# Install FSC Extension package
sf package install \
  --package 04t1E000001Iql5 \
  --target-org msb-scratch \
  --wait 30 \
  --no-prompt

# Verify installation
sf package installed list --target-org msb-scratch | grep -i "fsc\|extension"
```

**Expected Output**:
```
FinServ  258.0  04t6g000008av3UAAQ  Success
FSC Extension  ...  04t1E000001Iql5  Success
```

> **Note**: The FSC Extension package provides additional FSC features and should be installed after the core FSC package.

---

### Step 7: Assign Required Permission Sets

**CRITICAL**: After FSC installation, assign the following permission sets to enable all FSC features:

```bash
# Get your username
USERNAME=$(sf org display user --target-org msb-scratch --json | grep -o '"username":"[^"]*' | grep -o '[^"]*$')

# Assign FSC permission sets
sf org assign permset --name "Financial_Services_Cloud_Extension" --target-org msb-scratch
sf org assign permset --name "Financial_Services_Cloud_Basic" --target-org msb-scratch
sf org assign permset --name "Financial_Services_Cloud_Standard" --target-org msb-scratch

# Assign custom wizard permission set
sf org assign permset --name "DAO_Wizard_Access" --target-org msb-scratch
```

**Permission Sets Breakdown**:
- **Financial_Services_Cloud_Extension**: Enables FSC Extension features
- **Financial_Services_Cloud_Basic**: Provides basic FSC object and field access
- **Financial_Services_Cloud_Standard**: Enables standard FSC functionality (financial accounts, relationships, etc.)
- **DAO_Wizard_Access**: Grants access to custom wizard components and objects

**Verification**:
```bash
# Verify permission sets are assigned
sf org list perm --target-org msb-scratch
```

---

### Step 8: Install OmniStudio Package (Optional)

If your metadata requires OmniStudio:

> **⚠️ IMPORTANT - Read First**: Before installing OmniStudio, ensure your scratch org has OmniStudio features enabled in `project-scratch-def.json`. If you encounter errors like `"The object type you specified OmniUiCard is invalid"` or `"The object type you specified OmniProcess is invalid"`, see the [OmniStudio Installation Troubleshooting](#issue-omnistudio-package-installation-fails-with-invalid-object-type-errors) section below.

**Option A: If OmniStudio Features Are Already in `project-scratch-def.json`**

```bash
# Install OmniStudio package (latest version - check Salesforce documentation for current version)
# Use the PRODUCTION package version for scratch orgs (not the Sandbox version)
sf package install \
  --package 04t4W000002oVs4QAE \
  --target-org msb-scratch \
  --wait 30 \
  --no-prompt

# Verify installation
sf package installed list --target-org msb-scratch | grep omnistudio
```

**Option B: If OmniStudio Features Are NOT in `project-scratch-def.json`**

1. Add `OmniStudioDesigner` and `OmniStudioRuntime` to your `project-scratch-def.json` features array
2. Delete and recreate your scratch org (see troubleshooting section for details)
3. Then install the package using the command above

> **Important**: 
> - **Use the PRODUCTION package** for scratch orgs. Scratch orgs are development environments, not sandboxes, so use the Production package version.
> - The Sandbox package is specifically for actual Salesforce sandbox orgs (full/partial sandboxes that are copies of production).
> - Package ID and version should be verified against the latest Salesforce OmniStudio Releases documentation.
> - As of Winter '26, the latest version is 258.6 (check [Omnistudio Releases](https://help.salesforce.com) for current version).

---

### Step 9: Deploy Custom Metadata Using package.xml

Deploy wizard application metadata using the `package.xml` manifest for selective, intentional deployment:

```bash
# Deploy using package.xml manifest (RECOMMENDED)
sf project deploy start \
  --manifest package.xml \
  --target-org msb-scratch \
  --wait 30

# Check deployment status if needed
sf project deploy report --target-org msb-scratch
```

**Why Use package.xml?**
- **Selective Deployment**: Only deploys explicitly listed components
- **Better Control**: Avoids deploying unnecessary or problematic metadata
- **Visibility**: Clear documentation of what's being deployed
- **Reduced Errors**: Excludes components that may have dependency issues

**Metadata Included in package.xml**:
- **Custom Objects**: `ApplicationForm`, `Applicant`, `IdentityDocument`, `ApplicationFormProduct`, `Wizard_Step__mdt`, `Account`, `NAICS__c`, `Product2`
- **Global Value Sets**: `COCC_Majors`, `US_States`
- **Apex Classes**: `WizardConfigService`, `WizardPersistenceService`, `WizardDataService`, `ProductSelectionController`
- **LWC Components**: 
  - Wizard Steps: `applicantDetails`, `businessDetails`, `additionalApplicants`, `productSelection`, `additionalServices`, `documentUpload`, `reviewAndSubmit`
  - Supporting: `productCart`, `fundingAmountModal`, `openDaoWizardAction`
  - Container: `daoWizardStepRouter`, `daoWizardContainer`
- **FlexiPages**: `Application_Form_Record_Page3`, `Applicant_Record_Page`, `Identity_Document_Record_Page`, `DAO_Wizard_Container`, `ClientRecordPageBusiness`
- **Custom Metadata**: All 7 `Wizard_Step__mdt` records
- **Permission Sets**: `DAO_Wizard_Access`
- **Custom Applications**: `DAO_Wizard_Container`

> **Note**: The `package.xml` file includes only wizard-related components and their direct dependencies. For full metadata deployment (including FSC extensions and other customizations), use `--source-dir force-app/main/default` instead, but be aware this may deploy additional components that could cause conflicts.

**Alternative: Deploy Everything (Use with Caution)**:
```bash
# Deploy all metadata from force-app/main/default
# WARNING: This may deploy components not included in package.xml
sf project deploy start \
  --source-dir force-app/main/default \
  --target-org msb-scratch \
  --wait 30
```

---

### Step 10: Post-Deployment Configuration

After deploying metadata, configure the scratch org to enable all wizard features:

#### 10.1: Create Lightning Page Tab for DAO Wizard

Create a tab for the `DAO_Wizard_Container` Lightning Page so it can be opened as a navigation item:

1. **Setup → Tabs → Lightning Page Tabs → New**
2. Configure:
   - **Lightning Page**: Select `DAO_Wizard_Container`
   - **Tab Label**: `Application` (or `DAO Wizard`)
   - **Tab Name**: `DAO_Wizard_Container` (must match API name in code)
   - **Tab Style**: Choose an icon (e.g., `form`, `document`, `custom_all`)
3. Click **Save**

**Why This is Needed**: The wizard's quick action uses `standard__navItemPage` navigation, which requires a Tab to exist. Without this tab, clicking the "Application" button on an Account will result in a `PageNotFound` error.

#### 10.2: Add Tab to Branch Management App

Make the DAO Wizard tab visible in the Branch Management app:

1. **Setup → App Manager**
2. Find **Branch Management** app → Click **Edit**
3. **Navigation Items**:
   - Move `DAO_Wizard_Container` (or `Application`) from **Available Items** to **Selected Items**
   - Position it in your desired order (e.g., after Accounts, before Opportunities)
4. Click **Save**

**Verification**: 
- The tab should now appear in your Branch Management app's navigation bar
- Clicking the "Application" button on an Account should open the wizard as a subtab

#### 10.3: Activate DAO_Wizard_Container Application Page

Activate the Lightning Page so it's accessible:

1. **Setup → Lightning App Builder**
2. Find and open **DAO_Wizard_Container**
3. Click **Activation...**
4. Configure:
   - **Lightning Experience**: Select **Add page to app**
   - Choose **Branch Management** app
   - Optionally set as default for the app
5. Click **Save**

**Alternative via CLI**:
```bash
# Open Lightning App Builder directly to the page
sf org open --target-org msb-scratch --path /lightning/setup/FlexiPageList/home
```

#### 10.4: Enable Sample Onboarding Application Template (Optional)

If your implementation uses Onboarding Application templates:

1. **Setup → Feature Settings → Sales → Onboarding Application**
2. Click **Edit**
3. Enable:
   - ☑️ **Enable Sample Onboarding Application Template**
4. Click **Save**

**What This Enables**:
- Pre-built application form templates
- Sample data for testing
- Best practice workflows for onboarding

**Verification**:
```bash
# Query to verify Onboarding Application is enabled
sf apex run --file /dev/stdin --target-org msb-scratch << 'EOF'
System.debug('Onboarding Application enabled: ' + Setup.OnboardingApplicationSettings.IsEnabled);
EOF
```

---

### Step 11: Verify FSC Configuration

Run verification script to confirm FSC objects are available:

```bash
sf apex run --file /dev/stdin --target-org msb-scratch << 'EOF'
System.debug('=== FSC Verification ===');
List<String> fscObjects = new List<String>{
    'FinServ__FinancialAccount__c',
    'FinServ__AccountAccountRelation__c',
    'FinServ__FinancialAccountRole__c',
    'FinServ__Securities__c',
    'FinServ__FinancialGoal__c',
    'FinServ__AssetsAndLiabilities__c',
    'FinServ__Revenue__c',
    'FinServ__ContactContactRelation__c'
};
System.debug('FSC Objects Status:');
for (String obj : fscObjects) {
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj);
    System.debug(obj + ': ' + (objType != null ? 'EXISTS ✓' : 'NOT FOUND ✗'));
}

// Check Person Accounts
Schema.DescribeSObjectResult accountDescribe = Account.SObjectType.getDescribe();
try {
    Schema.RecordTypeInfo personAccountRT = accountDescribe.getRecordTypeInfosByName().get('Person Account');
    System.debug('PersonAccount Enabled: ' + (personAccountRT != null && personAccountRT.isAvailable() ? 'YES ✓' : 'NO ✗'));
} catch (Exception e) {
    System.debug('PersonAccount: NOT FOUND ✗');
}

// Check Financial Account record types
try {
    Schema.SObjectType financialAccountType = Schema.getGlobalDescribe().get('FinServ__FinancialAccount__c');
    if (financialAccountType != null) {
        Schema.DescribeSObjectResult describe = financialAccountType.getDescribe();
        System.debug('Financial Account Record Types:');
        for (Schema.RecordTypeInfo rti : describe.getRecordTypeInfos()) {
            if (rti.isAvailable()) {
                System.debug('  - ' + rti.getName() + ' (Master: ' + rti.isMaster() + ')');
            }
        }
    }
} catch (Exception e) {
    System.debug('Financial Account record types check failed: ' + e.getMessage());
}
EOF
```

**Expected Output**:
- All FSC objects should show `EXISTS ✓`
- PersonAccount should show `YES ✓`
- Financial Account record types listed (ACH, Deposit Products, GL, Loan Products, etc.)

---

### Step 12: Import Sample Data (Optional)

Retrieve and import sample data from msb-sbox to populate the scratch org with reference data:

```bash
# Create data directory if it doesn't exist
mkdir -p data

# Retrieve Wizard_Step__mdt records (custom metadata - must use metadata API)
# Note: Custom metadata is retrieved and deployed via metadata, not data export/import
sf project retrieve start \
  --metadata "CustomMetadata:Wizard_Step__mdt.*" \
  --target-org msb-sbox \
  --output-dir data/wizard-steps

# Export ApplicationForm records
sf data export tree \
  --query "SELECT Id, Name, AccountId, OpportunityId, StepKey__c FROM ApplicationForm LIMIT 50" \
  --target-org msb-sbox \
  --output-dir data/application-forms

# Export Applicant records
sf data export tree \
  --query "SELECT Id, FirstName, LastName, Email__c, ApplicationForm__c, Type__c, Role__c FROM Applicant LIMIT 50" \
  --target-org msb-sbox \
  --output-dir data/applicants

# Export Account records (Business Accounts)
sf data export tree \
  --query "SELECT Id, Name, Type, Phone, Website, Industry, AnnualRevenue FROM Account WHERE IsPersonAccount = false LIMIT 50" \
  --target-org msb-sbox \
  --output-dir data/accounts

# Export PersonAccount records (if Person Accounts enabled)
sf data export tree \
  --query "SELECT Id, FirstName, LastName, PersonEmail, Phone, PersonMailingStreet, PersonMailingCity FROM Account WHERE IsPersonAccount = true LIMIT 50" \
  --target-org msb-sbox \
  --output-dir data/person-accounts

# Export Opportunity records
sf data export tree \
  --query "SELECT Id, Name, AccountId, StageName, Amount, CloseDate FROM Opportunity LIMIT 50" \
  --target-org msb-sbox \
  --output-dir data/opportunities

# Export NAICS__c records (if exists)
# Note: We export Description__c, Code__c, and Name, then transform Name to use Description__c values
sf data export tree \
  --query "SELECT Description__c, Code__c, Name FROM NAICS__c LIMIT 10" \
  --target-org msb-sbox \
  --output-dir data/naics \
  2>/dev/null || echo "NAICS__c records not found or object doesn't exist"

# Transform NAICS__c data: Replace Name with Description__c values before import
# This ensures meaningful names (descriptions) are used instead of auto-generated IDs
python3 << 'EOF'
import json
import sys

# Read the exported JSON file
with open('data/naics/NAICS__c.json', 'r') as f:
    data = json.load(f)

# Transform: Replace Name with Description__c
for record in data['records']:
    if 'Description__c' in record:
        record['Name'] = record['Description__c']

# Write back the transformed data
with open('data/naics/NAICS__c.json', 'w') as f:
    json.dump(data, f, indent=4)

print(f"Successfully transformed {len(data['records'])} NAICS__c records")
EOF

# Export IdentityDocument records
sf data export tree \
  --query "SELECT Id, Document_Type__c, Document_Number__c, Applicant__c, RelatedLegalEntityId FROM IdentityDocument LIMIT 50" \
  --target-org msb-sbox \
  --output-dir data/identity-documents

# Deploy Wizard_Step__mdt records first (custom metadata - must use metadata deployment)
sf project deploy start \
  --source-dir data/wizard-steps \
  --target-org msb-scratch \
  --wait 10

# Import data records to scratch org (maintains relationships via data plan)
# IMPORT ORDER: Parent records before child records to maintain relationships
# 1. Import parent records first (Account, Opportunity, NAICS)
sf data import tree \
  --plan data/accounts/data-plan.json \
  --target-org msb-scratch

sf data import tree \
  --plan data/person-accounts/data-plan.json \
  --target-org msb-scratch 2>/dev/null || echo "Person Accounts data import skipped or failed"

sf data import tree \
  --plan data/opportunities/data-plan.json \
  --target-org msb-scratch

# Import NAICS__c records (using --files since we transformed the data)
sf data import tree \
  --files data/naics/NAICS__c.json \
  --target-org msb-scratch 2>/dev/null || echo "NAICS data import skipped or failed"

# 2. Import child records (ApplicationForm references Account/Opportunity)
sf data import tree \
  --plan data/application-forms/data-plan.json \
  --target-org msb-scratch

# 3. Import Applicant records (references ApplicationForm)
sf data import tree \
  --plan data/applicants/data-plan.json \
  --target-org msb-scratch

# 4. Import IdentityDocument records (references Applicant)
sf data import tree \
  --plan data/identity-documents/data-plan.json \
  --target-org msb-scratch
```

**Important Notes**:
- **Custom Metadata vs Data**: `Wizard_Step__mdt` records are **custom metadata** and must be retrieved/deployed via Metadata API (`sf project retrieve/deploy`), NOT via data export/import
- **Import Order is Critical**: Import parent records (Account, Opportunity, NAICS) **before** child records (ApplicationForm, Applicant, IdentityDocument) to maintain lookup relationships
- **Relationship Preservation**: `sf data export tree` automatically creates a `data-plan.json` that maintains lookup/master-detail relationships during import, but import order still matters
- **Error Handling**: Some exports/imports may fail if objects/records don't exist (handled with `2>/dev/null || echo`). This is expected for optional objects like `NAICS__c`
- **Record Limits**: Adjust `LIMIT` clauses in queries based on your data volume needs. Start with smaller limits (50) and increase as needed
- **Person Accounts**: Person Account records are exported from `Account` object with `IsPersonAccount = true` filter

**Verification**:
```bash
# Verify data imported successfully
sf data query --query "SELECT COUNT() FROM Account" --target-org msb-scratch
sf data query --query "SELECT COUNT() FROM Opportunity" --target-org msb-scratch
sf data query --query "SELECT COUNT() FROM ApplicationForm" --target-org msb-scratch
sf data query --query "SELECT COUNT() FROM Applicant" --target-org msb-scratch
sf data query --query "SELECT COUNT() FROM IdentityDocument" --target-org msb-scratch
sf data query --query "SELECT COUNT() FROM NAICS__c" --target-org msb-scratch 2>/dev/null || echo "NAICS__c object may not exist"

# Verify Wizard_Step__mdt records deployed
sf data query --query "SELECT COUNT() FROM Wizard_Step__mdt" --target-org msb-scratch
```

---

## 🔄 Quick Reference: Complete Setup Sequence

For quick reference, here's the complete sequence in order:

```bash
# 1. Create scratch org with FinancialServicesUser:10
# NOTE: If installing OmniStudio, add "OmniStudioDesigner" and "OmniStudioRuntime" to features in project-scratch-def.json BEFORE this step
sf org create scratch --definition-file project-scratch-def.json --alias msb-scratch --duration-days 30 --set-default --target-dev-hub sinadino-hub --wait 10

# 2. Deploy placeholder Insurance objects (base objects first)
sf project deploy start --source-dir force-app/main/default/objects/Claim__c --source-dir force-app/main/default/objects/InsurancePolicy__c --target-org msb-scratch --wait 5

# 3. Deploy objects with lookup fields
sf project deploy start --source-dir force-app/main/default/objects/Alert__c --source-dir force-app/main/default/objects/BillingStatement__c --target-org msb-scratch --wait 5

# 4. Install FSC package
sf package install --package 04t6g000008av3UAAQ --target-org msb-scratch --wait 30 --no-prompt

# 5. Install FSC Extension package
sf package install --package 04t1E000001Iql5 --target-org msb-scratch --wait 30 --no-prompt

# 6. Assign FSC Permission Sets (CRITICAL - must be done after FSC installation)
sf org assign permset --name "Financial_Services_Cloud_Extension" --target-org msb-scratch
sf org assign permset --name "Financial_Services_Cloud_Basic" --target-org msb-scratch
sf org assign permset --name "Financial_Services_Cloud_Standard" --target-org msb-scratch
sf org assign permset --name "DAO_Wizard_Access" --target-org msb-scratch

# 7. Install OmniStudio (optional) - Use PRODUCTION package, NOT Sandbox
# If you get errors about OmniUiCard or OmniProcess being invalid, ensure OmniStudioDesigner and OmniStudioRuntime are in project-scratch-def.json features
sf package install --package 04t4W000002oVs4QAE --target-org msb-scratch --wait 30 --no-prompt

# 8. Deploy custom metadata
sf project deploy start --manifest package.xml --target-org msb-scratch --wait 30

# 9. Post-Deployment Configuration (UI Steps Required):
# - Create Lightning Page Tab for DAO_Wizard_Container (Setup → Tabs → Lightning Page Tabs → New)
# - Add tab to Branch Management app (Setup → App Manager → Edit Branch Management)
# - Activate DAO_Wizard_Container page (Setup → Lightning App Builder)
# - Enable Sample Onboarding Application Template (Setup → Onboarding Application → Edit)

# 10. Open scratch org
sf org open --target-org msb-scratch
```

---

## 🚨 Troubleshooting

### Issue: FSC Package Installation Fails with Insurance Object Errors

**Symptoms**: 
```
PackageInstallError: CustomField(Alert__c.Claim__c) referenceTo value of 'Claim' does not resolve to a valid sObject type
```

**Root Cause**: FSC package version 258.0 includes Insurance-specific fields that require `Claim__c` and `InsurancePolicy__c` objects to exist.

**Solutions** (ALL THREE REQUIRED):
1. **Add `FinancialServicesUser:10` to `project-scratch-def.json`**:
   ```json
   "features": [
     "PersonAccounts",
     "ContactsToMultipleAccounts",
     "ServiceCloud",
     "Communities",
     "FinancialServicesUser:10"
   ]
   ```
   > **Critical**: The `:10` value is required. This enables FSC Core Insurance Objects.

2. **Create placeholder Insurance objects**:
   - `Claim__c` (base object)
   - `InsurancePolicy__c` (base object)
   - `Alert__c` (with lookup fields to `Claim__c` and `InsurancePolicy__c`)
   - `BillingStatement__c` (with lookup field to `InsurancePolicy__c`)

3. **Deploy placeholder objects BEFORE installing FSC**:
   ```bash
   # Deploy base objects first
   sf project deploy start --source-dir force-app/main/default/objects/Claim__c --source-dir force-app/main/default/objects/InsurancePolicy__c --target-org msb-scratch --wait 5
   
   # Then deploy objects with lookup fields
   sf project deploy start --source-dir force-app/main/default/objects/Alert__c --source-dir force-app/main/default/objects/BillingStatement__c --target-org msb-scratch --wait 5
   ```

4. **Delete and recreate scratch org** if you already created one without `FinancialServicesUser:10`:
   ```bash
   sf org delete scratch --target-org msb-scratch --no-prompt
   sf org create scratch --definition-file project-scratch-def.json --alias msb-scratch --duration-days 30 --set-default --target-dev-hub sinadino-hub --wait 10
   ```

---

### Issue: SignupDuplicateSettingsSpecifiedError

**Symptoms**: 
```
SignupDuplicateSettingsSpecifiedError: Duplicate settings specified in scratch org definition
```

**Solutions**:
1. **Remove duplicate settings**: Check for conflicting settings like `S1DesktopEnabled` in both `orgPreferences` and `lightningExperienceSettings`
2. **Simplify scratch org definition**: Use minimal settings (see Step 2 above)
3. **Remove deprecated features**: Remove `LightningServiceConsole`, `enableAdminLoginAsAnyUser`, etc.

### Issue: Objects Not Deploying

**Symptoms**:
- Deployment fails for FSC-related objects
- Custom fields on `FinServ__FinancialAccount__c` fail to deploy

**Solutions**:
1. **Check API version compatibility**: Ensure source API version (65.0) is supported
2. **Verify package versions**: Ensure FSC package version matches retrieved metadata (258.0)
3. **Deploy in order**: 
   - First: FSC package installation
   - Second: Standard FSC objects
   - Third: Custom FSC extensions

### Issue: Permission Errors

**Symptoms**:
- Cannot access FSC objects
- FSC tabs not visible

**Solutions**:
1. **Assign FSC permission sets**: See Step 6
2. **Check profile settings**: Ensure Admin profile has access
3. **Verify FSC application visibility**: 
   ```bash
   sf data query --query "SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'" --target-org msb-scratch
   ```

### Issue: Person Accounts Not Working

**Symptoms**:
- Cannot create Person Accounts
- Person Account record type missing

**Solutions**:
1. **Verify PersonAccounts feature**: Check `project-scratch-def.json`
2. **Enable in Setup**: Setup → Account Settings → Enable Person Accounts
3. **Check record types**: Verify Person Account record type exists

---

### Issue: OmniStudio Package Installation Fails with Invalid Object Type Errors

**Symptoms**: 
```
PackageInstallError: Encountered errors installing the package! Installation errors: 
1) FlexiPage(FlexCardDesigner) Validation Errors While Saving Record(s), Details: There were custom validation error(s) encountered while saving the affected record(s). The first validation error encountered was "The object type you specified OmniUiCard is invalid.".
2) FlexiPage(Vlocity_OmniScript_Designer) Validation Errors While Saving Record(s), Details: There were custom validation error(s) encountered while saving the affected record(s). The first validation error encountered was "The object type you specified OmniProcess is invalid.".
```

**Root Cause**: OmniStudio requires specific features to be enabled in the scratch org definition to make OmniStudio objects (`OmniUiCard`, `OmniProcess`, etc.) available before the package installation.

**Solutions** (in order of preference):

1. **Add OmniStudio Features to `project-scratch-def.json`** (RECOMMENDED):
   ```json
   {
     "features": [
       "PersonAccounts",
       "ContactsToMultipleAccounts",
       "ServiceCloud",
       "Communities",
       "FinancialServicesUser:10",
       "OmniStudioDesigner",
       "OmniStudioRuntime"
     ]
   }
   ```
   > **Note**: These features are not officially documented but are referenced in the [Salesforce DX documentation](https://developer.salesforce.com/docs/atlas.en-us.238.0.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_def_file_config_values.htm). They enable:
   > - OmniStudio metadata (Dataraptors, Omniscripts, etc.)
   > - Permission Set Licenses: `OmniStudio` (`OmniStudioDesigner`) and `OmniStudio User` (`OmniStudioRuntime`)
   > - Setup menus for Omni Interaction configuration

2. **Alternative: Add InsuranceCalculationUser Feature**:
   ```json
   {
     "features": [
       "PersonAccounts",
       "ContactsToMultipleAccounts",
       "ServiceCloud",
       "Communities",
       "FinancialServicesUser:10",
       "InsuranceCalculationUser"
     ]
   }
   ```
   > **Note**: This feature also enables OmniStudio support. Reference: [Salesforce StackExchange](https://salesforce.stackexchange.com/questions/385339/omnistudio-licenses-for-scratch-org)

3. **Use Org Shape Feature** (for complex scenarios):
   If you have an existing org with OmniStudio already configured, you can create a scratch org based on that org's shape:
   ```bash
   # Enable org shape in source org (one-time setup)
   sf org shape create --target-org msb-sbox
   
   # Create scratch org from org shape
   sf org create scratch --definition-file project-scratch-def.json --target-org msb-sbox --wait 10
   ```
   > **Reference**: [Salesforce DX Org Shape Documentation](https://developer.salesforce.com/docs/atlas.en-us.238.0.sfdx_dev.meta/sfdx_dev/sfdx_dev_shape_enable_org_shape.htm)

**After Adding Features**:
1. Delete existing scratch org (if already created):
   ```bash
   sf org delete scratch --target-org msb-scratch --no-prompt
   ```

2. Create new scratch org with OmniStudio features:
   ```bash
   sf org create scratch \
     --definition-file project-scratch-def.json \
     --alias msb-scratch \
     --duration-days 30 \
     --set-default \
     --target-dev-hub sinadino-hub \
     --wait 10
   ```

3. Verify OmniStudio objects are available (before package install):
   ```bash
   sf apex run --file /dev/stdin --target-org msb-scratch << 'EOF'
   Schema.SObjectType omniProcess = Schema.getGlobalDescribe().get('OmniProcess');
   Schema.SObjectType omniUiCard = Schema.getGlobalDescribe().get('OmniUiCard');
   System.debug('OmniProcess: ' + (omniProcess != null ? 'EXISTS ✓' : 'NOT FOUND ✗'));
   System.debug('OmniUiCard: ' + (omniUiCard != null ? 'EXISTS ✓' : 'NOT FOUND ✗'));
   EOF
   ```

4. Install OmniStudio package:
   ```bash
   sf package install --package 04t4W000002oVs4QAE --target-org msb-scratch --wait 30 --no-prompt
   ```

**References**:
- [Salesforce StackExchange: OmniStudio licenses for Scratch Org](https://salesforce.stackexchange.com/questions/385339/omnistudio-licenses-for-scratch-org)
- [Salesforce DX: Enable Org Shape](https://developer.salesforce.com/docs/atlas.en-us.238.0.sfdx_dev.meta/sfdx_dev/sfdx_dev_shape_enable_org_shape.htm)
- [OmniStudio Releases Documentation](https://help.salesforce.com/s/articleView?id=000394906&type=1)

---

### Issue: Product2 Standard Fields Deployment Errors

**Symptoms**:
```
CustomField(Product2.AvailabilityDate) Could not resolve standard field's name
CustomField(Product2.BasedOnId) 'BasedOnId' does not resolve to a valid sObject type
CustomField(Product2.Type) Could not resolve standard field's name
CustomField(Product2.UnitOfMeasureId) 'UnitOfMeasureId' does not resolve to a valid sObject type
```

**Root Cause**: These are **standard Product2 fields** that require **Revenue Cloud** or **Advanced Product Management** features to be enabled. Scratch orgs without these features cannot deploy these field definitions via metadata.

**Solution**:

1. **Remove the standard field metadata files** (these fields exist automatically in the org, so they don't need to be deployed):
   ```bash
   cd /Users/cristianosinadino/Workspace/Salesforce/Pro/zennify/msb
   
   # Remove standard fields that require Revenue Cloud
   rm -f force-app/main/default/objects/Product2/fields/AvailabilityDate.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/BasedOnId.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/ConfigureDuringSale.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/DiscontinuedDate.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/EndOfLifeDate.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/HelpText.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/IsAssetizable.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/IsSoldOnlyWithOtherProds.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/SpecificationType.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/Type.field-meta.xml
   rm -f force-app/main/default/objects/Product2/fields/UnitOfMeasureId.field-meta.xml
   ```

2. **Deploy global value sets** that Product2 custom fields depend on:
   - Ensure `COCC_Majors` (or similar global value sets) are included in your `package.xml`:
   ```xml
   <types>
       <members>COCC_Majors</members>
       <name>GlobalValueSet</name>
   </types>
   ```

3. **Deploy Product2 with only custom fields**:
   ```bash
   # Deploy Product2 object with custom fields only
   sf project deploy start \
     --source-dir force-app/main/default/objects/Product2 \
     --target-org msb-scratch \
     --wait 10
   ```

**What You're Not Losing**:
- Standard Product2 fields (Name, ProductCode, Description, Family, IsActive, etc.) **still exist** in the org automatically
- Only **custom fields** need to be deployed (Active_BAO__c, Active_CAO__c, COCC_Major__c, etc.)
- The removed field definitions are just metadata - the actual standard fields are built into Salesforce

**Expected Outcome**:
✅ Product2 object deploys successfully with all custom fields
✅ Standard Product2 fields are available automatically

---

### Issue: OmniStudio Conflicts

**Symptoms**:
- Deployment fails after OmniStudio installation
- Metadata conflicts between OmniStudio and custom code

**Solutions**:
1. **Install OmniStudio first**: Before deploying custom metadata
2. **Check version compatibility**: Ensure OmniStudio version (258.7) matches msb-sbox
3. **Review conflict errors**: Resolve field/object name conflicts manually

---

### Issue: PageNotFound Error When Opening Wizard from Account

**Symptoms**:
```
Error: openSubtab() - Error: jobLibrary - Job: preProcessPage, Stage: tasks, Job failed.
An error occurred while processing. resolvePage() - Error determining State from pageReference.
Source: API, Error: PageNotFound
```

**Root Cause**: The `DAO_Wizard_Container` Lightning Page exists, but no **Tab** has been created for it. Navigation actions using `standard__navItemPage` require a Tab to exist with the same API name.

**Solution**:

1. **Create Lightning Page Tab**:
   - Setup → Tabs → Lightning Page Tabs → New
   - Lightning Page: `DAO_Wizard_Container`
   - Tab Label: `Application` (or `DAO Wizard`)
   - Tab Name: `DAO_Wizard_Container` (must match exactly)
   - Tab Style: Choose an icon
   - Save

2. **Add Tab to App**:
   - Setup → App Manager
   - Edit **Branch Management** app
   - Navigation Items → Move `DAO_Wizard_Container` to Selected Items
   - Save

3. **Activate the Page**:
   - Setup → Lightning App Builder
   - Open `DAO_Wizard_Container`
   - Click Activation → Add page to app → Select Branch Management
   - Save

**Verification**:
- Open an Account record
- Click the "Application" button
- The wizard should open as a subtab without errors

---

## ✅ Verification Checklist

Use this checklist to verify your scratch org is properly configured:

- [ ] Scratch org created successfully with `FinancialServicesUser:10` feature
- [ ] Placeholder Insurance objects deployed (`Claim__c`, `InsurancePolicy__c`, `Alert__c`, `BillingStatement__c`)
- [ ] FSC package installed (version 258.0)
- [ ] FSC Extension package installed (`04t1E000001Iql5`)
- [ ] **FSC Permission Sets Assigned** (CRITICAL):
  - [ ] `Financial_Services_Cloud_Extension`
  - [ ] `Financial_Services_Cloud_Basic`
  - [ ] `Financial_Services_Cloud_Standard`
  - [ ] `DAO_Wizard_Access`
- [ ] OmniStudio package installed (Production package, latest version - currently 258.6 as of Winter '26, if needed)
- [ ] `FinServ__FinancialAccount__c` object exists
- [ ] `FinServ__AccountAccountRelation__c` object exists
- [ ] Person Accounts enabled and functional
- [ ] Financial Account record types available (ACH, Deposit Products, GL, Loan Products, etc.)
- [ ] All custom metadata deployed successfully via `package.xml`
- [ ] Custom FSC fields and record types deployed
- [ ] Applicant and ApplicationForm objects deployed
- [ ] IdentityDocument object deployed
- [ ] Product2 object deployed (with custom fields only, standard fields removed)
- [ ] LWC components deployed and functional
- [ ] Apex classes deployed and functional
- [ ] **Post-Deployment Configuration** (CRITICAL):
  - [ ] Lightning Page Tab created for `DAO_Wizard_Container`
  - [ ] Tab added to Branch Management app
  - [ ] `DAO_Wizard_Container` page activated
  - [ ] Sample Onboarding Application Template enabled (if needed)

---

## 📚 References

### Documentation
- **FSC Objects**: `/force-app/main/default/objects/FinServ__*/`
- **Installed Packages**: `/force-app/main/default/installedPackages/`
- **Scratch Org Config**: `/project-scratch-def.json`
- **FSC Features Analysis**: See session notes from 2025-01-20

### Salesforce Resources
- [Financial Services Cloud Setup Guide](https://help.salesforce.com/s/articleView?id=sf.fsc_setup_overview.htm)
- [Scratch Org Definition Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_def_file.htm)
- [Package Installation Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_package_install.htm)

### Package IDs (Update as needed)
- **FSC**: `04t6g000008av3UAAQ` (verify latest version)
- **FSC Extension**: `04t1E000001Iql5` (verify latest version)
- **OmniStudio**: `04t4W000002oVs4QAE` (use **Production** package for scratch orgs; verify latest version - currently 258.6 as of Winter '26)

---

## 📝 Notes

### Key Learnings

1. **FinancialServicesUser Feature is CRITICAL**: The `FinancialServicesUser:10` feature in `project-scratch-def.json` is **mandatory** for FSC package installation. Without it, the package will fail with Insurance object errors. The `:10` value enables FSC Core Insurance Objects.

2. **Placeholder Insurance Objects Required**: Even for banking-only implementations, you must create placeholder Insurance objects (`Claim__c`, `InsurancePolicy__c`, `Alert__c`, `BillingStatement__c`) to satisfy FSC package dependencies. These objects are intentionally minimal and won't interfere with banking operations.

3. **Deployment Order Matters**: 
   - First: Create scratch org with `FinancialServicesUser:10` (and `OmniStudioDesigner`/`OmniStudioRuntime` if installing OmniStudio)
   - Second: Deploy placeholder Insurance objects
   - Third: Install FSC package (`04t6g000008av3UAAQ`)
   - Fourth: Install FSC Extension package (`04t1E000001Iql5`)
   - Fifth: **Assign FSC Permission Sets** (CRITICAL):
     - `Financial_Services_Cloud_Extension`
     - `Financial_Services_Cloud_Basic`
     - `Financial_Services_Cloud_Standard`
     - `DAO_Wizard_Access`
   - Sixth: Install OmniStudio package (if needed) - **requires OmniStudio features in scratch org definition**
   - Seventh: Deploy custom metadata using `package.xml`

4. **FSC Permission Sets Are CRITICAL**: After installing FSC packages, you **must** assign the FSC permission sets to enable full FSC functionality. Without these permission sets, FSC objects and features may not be accessible. This is a common oversight that can cause deployment and functionality issues.

5. **Product2 Standard Fields**: Standard Product2 fields that require Revenue Cloud (e.g., `AvailabilityDate`, `BasedOnId`, `Type`, `UnitOfMeasureId`) **cannot** be deployed via metadata to scratch orgs without Revenue Cloud features. Remove these field definitions from your local metadata - the standard fields will still exist automatically in the org.

6. **OmniStudio Requires Features in Scratch Org Definition**: Unlike FSC, OmniStudio requires specific features (`OmniStudioDesigner` and `OmniStudioRuntime`) to be added to `project-scratch-def.json` **before** creating the scratch org. Without these features, the package installation will fail with errors like `"The object type you specified OmniUiCard is invalid"`. See troubleshooting section for details.

7. **Package Version Compatibility**: Ensure package versions match between msb-sbox and scratch org. For OmniStudio, use the **Production** package version (not Sandbox) when installing in scratch orgs. As of Winter '26, the latest OmniStudio version is 258.6.

8. **Person Accounts Separate**: Person Accounts feature is separate from FSC and must be explicitly enabled.

9. **Dev Hub FSC Installation NOT Required**: Unlike previous assumptions, FSC does **not** need to be installed in the dev hub. The `FinancialServicesUser:10` feature and placeholder objects are sufficient.

10. **Use package.xml for Selective Deployment**: Using a well-structured `package.xml` with explicit component names (rather than wildcards) provides better control and visibility over what's being deployed. See the updated `package.xml` for the recommended structure.

11. **Lightning Page Tab Required for Navigation**: When using `standard__navItemPage` navigation to open Lightning Pages (like `DAO_Wizard_Container`), you must create a Lightning Page Tab with the same API name. Without this tab, navigation from Account buttons will fail with a `PageNotFound` error. This is a common configuration step that's easy to miss during scratch org setup.

### Future Improvements

- [ ] Create automation script for scratch org setup
- [ ] Create data migration scripts from msb-sbox
- [ ] Document FSC-specific settings and preferences
- [ ] Create verification test suite
- [x] Document FSC permission set requirements
- [x] Document Product2 deployment issues and solutions

---

**Last Updated**: 2025-01-20  
**Status**: ✅ **VERIFIED & WORKING**  
**Success**: FSC package successfully installed in scratch org using `FinancialServicesUser:10` feature, placeholder Insurance objects, and proper permission set assignment.  
**Next Steps**: Automate scratch org setup with shell script

