# Console Sub-Tab Setup Instructions

**Date**: 2025-10-27  
**Purpose**: Configure DAO Wizard to open in console sub-tabs via Lightning Action

---

## 🎯 Overview

This setup enables users to click a Lightning Action button on Account/Contact/Lead records that opens the DAO Wizard in a console sub-tab, providing a seamless multi-tab experience.

## 📋 Setup Steps

### 1. Create Lightning App Page for Wizard

1. **Setup → App Builder → New → App Page**
2. **Page Details**:
   - Label: `DAO Wizard Page`
   - API Name: `DAO_Wizard_Page`
   - Template: `App Page` (1 column)
3. **Add Component**: Drag `daoWizardContainer` to the page
4. **Configure Component**:
   - `wizardApiName`: `DAO_Business_InBranch`
5. **Save & Activate**

### 2. Create Lightning Page Tab

1. **Setup → Tabs → Lightning Page Tabs → New**
2. **Tab Details**:
   - Tab Label: `DAO Wizard`
   - Tab Name: `DAO_Wizard` (important - matches code)
   - Lightning Page: Select `DAO Wizard Page` (created above)
   - Tab Style: Choose appropriate icon (e.g., `form`)
3. **Save**

### 3. Add Quick Action to Object Layouts

#### For Account Object:
1. **Setup → Object Manager → Account**
2. **Page Layouts → Account Layout** (or your custom layout)
3. **Salesforce Mobile and Lightning Experience Actions**
4. **Drag** `Open Dao Wizard Action` from the palette to the actions section
5. **Save**

#### For Contact Object:
1. **Setup → Object Manager → Contact**
2. **Page Layouts → Contact Layout** 
3. **Salesforce Mobile and Lightning Experience Actions**
4. **Drag** `Open Dao Wizard Action` from the palette
5. **Save**

#### For Lead Object:
1. **Setup → Object Manager → Lead**
2. **Page Layouts → Lead Layout**
3. **Salesforce Mobile and Lightning Experience Actions** 
4. **Drag** `Open Dao Wizard Action` from the palette
5. **Save**

### 4. Enable Console Navigation (if not already)

1. **Setup → App Manager**
2. **Edit** your Lightning App (e.g., Sales, Service)
3. **Navigation → Console Navigation**: Enable
4. **Save**

## 🧪 Testing

### Test Scenario 1: Console Environment
1. Navigate to an Account record in a console app
2. Click the **"Open Dao Wizard Action"** button
3. **Expected**: Sub-tab opens with DAO Wizard, tab labeled "DAO Wizard"
4. **Expected**: Wizard shows account's recordId in URL state
5. Click action again on same record
6. **Expected**: Focuses existing tab instead of opening new one

### Test Scenario 2: Non-Console Environment  
1. Navigate to an Account record in standard Lightning
2. Click the **"Open Dao Wizard Action"** button
3. **Expected**: Navigates to DAO Wizard tab in current window

### Test Scenario 3: Wizard Functionality
1. Open wizard via action button
2. **Expected**: Progress indicator shows 3 steps
3. Fill out Applicant Details → Click Next
4. **Expected**: Advances to Product Selection
5. Select product → Click Next  
6. **Expected**: Advances to Review & Submit
7. Check confirmation → Click Complete
8. **Expected**: Success toast, wizard completes

## 🔧 Components Deployed

### LWC Components
- ✅ `daoWizardContainer` - Updated with page state support
- ✅ `openDaoWizardAction` - Lightning Action for sub-tab opening
- ✅ Step components: `applicantDetails`, `productSelection`, `reviewAndSubmit`

### Key Features
- **Page State Capture**: Supports `c__recordId` parameter from URL state
- **Console Integration**: Uses `lightning/platformWorkspaceApi` for sub-tab management
- **Tab Management**: Sets custom tab label and icon
- **Duplicate Prevention**: Focuses existing tab if already open for same record
- **Fallback Support**: Works in non-console environments

## 🚨 Troubleshooting

### Action Button Not Visible
- Check object page layout has the action in Mobile & Lightning Actions
- Verify user has access to the Lightning Page Tab
- Confirm `openDaoWizardAction` is deployed and active

### Sub-tab Not Opening
- Verify console navigation is enabled in the Lightning App
- Check browser console for JavaScript errors
- Confirm Lightning Page Tab API name is exactly `DAO_Wizard`

### Wizard Not Loading Data
- Check `c__recordId` parameter in URL
- Verify `daoWizardContainer` has proper `@wire(CurrentPageReference)` 
- Test SOQL query: `SELECT Id FROM Wizard_Step__mdt WHERE WizardApiName__c = 'DAO_Business_InBranch'`

### Tab Label/Icon Issues
- Requires console environment to work
- Check `lightning/platformWorkspaceApi` imports
- Verify user permissions for workspace API

## 📚 References

- **Components**: `/force-app/main/default/lwc/`
- **Story**: `ST-001-wizard-foundation.md`
- **Architecture**: `ADR-0001-lwc-architecture.md`
- **Salesforce Docs**: [Platform Workspace API](https://developer.salesforce.com/docs/component-library/bundle/lightning-platform-workspace-api)

---

**Next Steps**: Configure additional objects or customize tab labels based on record data.
