# Business Account Field Mapping

**Date**: 2025-11-05  
**Purpose**: Document how wizard Business Information fields map to Account (Business) standard fields

---

## 📊 Business Information Step Field Mappings

### Current LWC Implementation → Account Standard Fields

| Section | UI Field Label | LWC Variable | Account API Name | Field Type | Notes |
|---------|----------------|--------------|------------------|------------|-------|
| **Business Profile** | Business Name | `businessName` | `Name` | Text(255) | Standard - Required |
| **Business Profile** | Business Type | `businessType` | `Type` | Picklist | Standard - Values: Corporation, LLC, Partnership, etc. |
| **Business Profile** | Year Established | `yearEstablished` | `YearStarted` | Text(4) | Standard - Format: YYYY |
| **Business Profile** | Number of Employees | `numberOfEmployees` | `NumberOfEmployees` | Number(8,0) | Standard - Ranges: 1-10, 11-50, etc. |
| **Business Profile** | Industry Type | `industryType` | `Industry` | Picklist | Standard - Agriculture, Finance, Technology, etc. |
| **Business Profile** | Business Website | `businessWebsite` | `Website` | URL(255) | Standard - Format: https://www.example.com |
| **Business Profile** | Business Description | `businessDescription` | `Description` | Long Text Area(32000) | Standard - Max 500 chars in wizard |
| **Contact Information** | Business Email | `businessEmail` | `Business_Email__c` | Email | **Custom** - No standard business email field |
| **Contact Information** | Business Phone (Primary) | `businessWorkPhone` | `Phone` | Phone | Standard - Primary phone field |
| **Contact Information** | Business Phone (Home) | `businessHomePhone` | `Business_Home_Phone__c` | Phone | **Custom** |
| **Contact Information** | Business Phone (Mobile) | `businessMobilePhone` | `Business_Mobile_Phone__c` | Phone | **Custom** |
| **Business Address** | Street Address Line 1 | `businessStreetLine1` | `BillingStreet` | Text(255) | **Compound field** - stores both lines |
| **Business Address** | Street Address Line 2 | `businessStreetLine2` | `BillingStreet` | Text(255) | **Compound field** - appended to line 1 |
| **Business Address** | City | `businessCity` | `BillingCity` | Text(40) | Standard |
| **Business Address** | State | `businessState` | `BillingState` | Text(80) | Standard |
| **Business Address** | ZIP Code | `businessPostalCode` | `BillingPostalCode` | Text(20) | Standard |
| **Business Address** | Country | `businessCountry` | `BillingCountry` | Text(80) | Standard |
| **Tax Information** | Federal Tax ID (EIN) | `taxId` | `FinServ__TaxID__c` | Text(18) | **FSC Field** - Encrypted in production |
| **Tax Information** | Tax ID Type | `taxIdType` | `Business_Tax_ID_Type__c` | Picklist | **Custom** - EIN, Foreign Tax ID |

---

## 🔄 How to Handle Compound Address Fields

### BillingStreet (Compound Field)
Account uses a **compound address field** for `BillingStreet` that combines:
- Street Line 1
- Street Line 2 (optional)

**When saving to Salesforce:**
```javascript
// Combine line 1 and line 2 with newline separator
const billingStreet = businessStreetLine2 
    ? `${businessStreetLine1}\n${businessStreetLine2}` 
    : businessStreetLine1;

// Save to Account
BillingStreet = billingStreet;
```

**When reading from Salesforce:**
```javascript
// Split BillingStreet by newline
const streetParts = account.BillingStreet?.split('\n') || [];
businessStreetLine1 = streetParts[0] || '';
businessStreetLine2 = streetParts[1] || '';
```

---

## 📋 Complete Account Address API Names

### BillingAddress (Compound Address)
- `BillingStreet` - Street address (includes line 1 and line 2)
- `BillingCity` - City
- `BillingState` - State/Province
- `BillingPostalCode` - ZIP/Postal Code
- `BillingCountry` - Country
- `BillingLatitude` - Latitude (geolocation)
- `BillingLongitude` - Longitude (geolocation)
- `BillingGeocodeAccuracy` - Geocode accuracy

### ShippingAddress (Compound Address)
- `ShippingStreet` - Street address (includes line 1 and line 2)
- `ShippingCity` - City
- `ShippingState` - State/Province
- `ShippingPostalCode` - ZIP/Postal Code
- `ShippingCountry` - Country
- `ShippingLatitude` - Latitude
- `ShippingLongitude` - Longitude
- `ShippingGeocodeAccuracy` - Geocode accuracy

---

## 🎯 Recommendations for ST-002

### When Populating from Account → Business Information Step

**SOQL Query:**
```sql
SELECT 
    Id,
    Name,
    Type,
    YearStarted,
    NumberOfEmployees,
    Industry,
    Website,
    Description,
    Phone,
    BillingStreet,
    BillingCity,
    BillingState,
    BillingPostalCode,
    BillingCountry,
    FinServ__TaxID__c,
    Business_Email__c,
    Business_Home_Phone__c,
    Business_Mobile_Phone__c,
    Business_Tax_ID_Type__c
FROM Account
WHERE Id = :accountId
    AND IsPersonAccount = false
WITH USER_MODE
```

**Mapping Logic:**
```javascript
// Split compound street field
const streetParts = account.BillingStreet?.split('\n') || [];

const businessInfo = {
    // Business Profile
    businessName: account.Name,
    businessType: account.Type,
    yearEstablished: account.YearStarted,
    numberOfEmployees: account.NumberOfEmployees,
    industryType: account.Industry,
    businessWebsite: account.Website,
    businessDescription: account.Description,
    
    // Contact Information
    businessEmail: account.Business_Email__c,
    businessWorkPhone: account.Phone,
    businessHomePhone: account.Business_Home_Phone__c,
    businessMobilePhone: account.Business_Mobile_Phone__c,
    
    // Business Address
    businessStreetLine1: streetParts[0] || '',
    businessStreetLine2: streetParts[1] || '',
    businessCity: account.BillingCity,
    businessState: account.BillingState,
    businessPostalCode: account.BillingPostalCode,
    businessCountry: account.BillingCountry,
    
    // Tax Information
    taxId: account.FinServ__TaxID__c,
    taxIdType: account.Business_Tax_ID_Type__c
};
```

### When Saving from Business Information Step → Account

**Combine street lines:**
```javascript
const billingStreet = payload.businessStreetLine2 
    ? `${payload.businessStreetLine1}\n${payload.businessStreetLine2}` 
    : payload.businessStreetLine1;

const accountToUpdate = {
    Id: accountId,
    // Business Profile
    Name: payload.businessName,
    Type: payload.businessType,
    YearStarted: payload.yearEstablished,
    NumberOfEmployees: payload.numberOfEmployees,
    Industry: payload.industryType,
    Website: payload.businessWebsite,
    Description: payload.businessDescription,
    
    // Contact Information
    Business_Email__c: payload.businessEmail,
    Phone: payload.businessWorkPhone,
    Business_Home_Phone__c: payload.businessHomePhone,
    Business_Mobile_Phone__c: payload.businessMobilePhone,
    
    // Business Address
    BillingStreet: billingStreet,
    BillingCity: payload.businessCity,
    BillingState: payload.businessState,
    BillingPostalCode: payload.businessPostalCode,
    BillingCountry: payload.businessCountry,
    
    // Tax Information
    FinServ__TaxID__c: payload.taxId,
    Business_Tax_ID_Type__c: payload.taxIdType
};
```

---

## 📊 Field Status Summary

### ✅ Standard Account Fields (13 fields)
- `Name` - Business Name
- `Type` - Business Type
- `YearStarted` - Year Established
- `NumberOfEmployees` - Number of Employees
- `Industry` - Industry Type
- `Website` - Business Website
- `Description` - Business Description
- `Phone` - Business Phone (Primary)
- `BillingStreet` - Street Address (compound)
- `BillingCity` - City
- `BillingState` - State
- `BillingPostalCode` - ZIP Code
- `BillingCountry` - Country

### ✅ FSC Fields (1 field)
- `FinServ__TaxID__c` - Federal Tax ID (EIN)

### ✅ Custom Fields Created (4 fields)
- `Business_Email__c` - Business Email
- `Business_Home_Phone__c` - Business Phone (Home)
- `Business_Mobile_Phone__c` - Business Phone (Mobile)
- `Business_Tax_ID_Type__c` - Tax ID Type

---

## ⚠️ Important Notes

1. **Compound Fields**: `BillingStreet` is a compound field that stores both line 1 and line 2 separated by newline (`\n`)

2. **Field Lengths**:
   - `Name`: 255 characters
   - `BillingStreet`: 255 characters total (both lines combined)
   - `BillingCity`: 40 characters
   - `BillingState`: 80 characters
   - `BillingPostalCode`: 20 characters
   - `BillingCountry`: 80 characters
   - `Description`: 32,000 characters (wizard limits to 500)
   - `Website`: 255 characters
   - `YearStarted`: 4 characters (YYYY format)

3. **Required Fields**: 
   - `Name` is the only required field by default in Salesforce
   - Wizard marks additional fields as required for business logic

4. **State and Country Picklists**: If State and Country Picklists are enabled in your org, `BillingState` and `BillingCountry` will be picklist fields instead of text fields

5. **Tax ID Encryption**: `FinServ__TaxID__c` should be encrypted in production environments for PII protection

6. **NumberOfEmployees**: 
   - Standard field is a Number type
   - Wizard uses ranges (1-10, 11-50, etc.) which need to be converted
   - Consider storing the range as text or mapping to midpoint values

---

## 🔄 NumberOfEmployees Conversion

**Wizard Range → Account Number Mapping:**
```javascript
const employeeRangeToNumber = {
    '1-10': 5,
    '11-50': 30,
    '51-100': 75,
    '101-500': 300,
    '500+': 1000
};

// When saving
NumberOfEmployees = employeeRangeToNumber[payload.numberOfEmployees];

// When reading
const numberToEmployeeRange = (num) => {
    if (num <= 10) return '1-10';
    if (num <= 50) return '11-50';
    if (num <= 100) return '51-100';
    if (num <= 500) return '101-500';
    return '500+';
};

numberOfEmployees = numberToEmployeeRange(account.NumberOfEmployees);
```

---

## 📝 Fields NOT in Current LWC (From Template)

These fields from the field-mappings-template.csv are **not** currently in the Business Information step:

### Organization - Tax & Classification
- ❌ `Tax_Country__c` - Tax Country (Default: USA)

### Organization - Industry & Risk
- ❌ `Sic` - SIC Code (Standard field available)
- ❌ `SicDesc` - SIC Description (Standard field available)
- ❌ `NaicsCode` - NAICS Code (Standard field available)
- ❌ `NaicsDesc` - NAICS Description (Standard field available)
- ❌ `BSA_CIP_Rating__c` - BSA/CIP Rating (Custom - not created)
- ❌ `BSA_Rating_Date__c` - Rating Date (Custom - not created)
- ❌ `Next_BSA_Rating_Date__c` - Next Rating Date (Custom - not created)

**Note**: These fields can be added in future enhancements if needed for compliance or risk assessment.

---

**Reference**: [Salesforce Account Object Documentation](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_account.htm)
