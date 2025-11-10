# PersonAccount Address Field Mapping

**Date**: 2025-11-05  
**Purpose**: Document how wizard address fields map to PersonAccount standard fields

---

## 📍 Mailing Address Fields

### Current LWC Implementation → PersonAccount Standard Fields

| UI Field Label | LWC Variable | PersonAccount API Name | Field Type | Notes |
|----------------|--------------|------------------------|------------|-------|
| **Street Address Line 1** | `mailingStreetLine1` | `PersonMailingStreet` | Text(255) | **Compound field** - stores both line 1 and line 2 |
| **Street Address Line 2** | `mailingStreetLine2` | `PersonMailingStreet` | Text(255) | **Compound field** - appended to line 1 with newline |
| **City** | `mailingCity` | `PersonMailingCity` | Text(40) | Standard field |
| **State** | `mailingState` | `PersonMailingState` | Text(80) | Standard field |
| **ZIP Code** | `mailingPostalCode` | `PersonMailingPostalCode` | Text(20) | Standard field |
| **Country** | `mailingCountry` | `PersonMailingCountry` | Text(80) | Standard field |

---

## 🔄 How to Handle Compound Address Fields

### PersonMailingStreet (Compound Field)
PersonAccount uses a **compound address field** for `PersonMailingStreet` that combines:
- Street Line 1
- Street Line 2 (optional)

**When saving to Salesforce:**
```javascript
// Combine line 1 and line 2 with newline separator
const mailingStreet = mailingStreetLine2 
    ? `${mailingStreetLine1}\n${mailingStreetLine2}` 
    : mailingStreetLine1;

// Save to PersonAccount
PersonMailingStreet = mailingStreet;
```

**When reading from Salesforce:**
```javascript
// Split PersonMailingStreet by newline
const streetParts = personAccount.PersonMailingStreet?.split('\n') || [];
mailingStreetLine1 = streetParts[0] || '';
mailingStreetLine2 = streetParts[1] || '';
```

---

## 📋 Complete PersonAccount Address API Names

### PersonMailingAddress (Compound Address)
- `PersonMailingStreet` - Street address (includes line 1 and line 2)
- `PersonMailingCity` - City
- `PersonMailingState` - State/Province
- `PersonMailingPostalCode` - ZIP/Postal Code
- `PersonMailingCountry` - Country
- `PersonMailingLatitude` - Latitude (geolocation)
- `PersonMailingLongitude` - Longitude (geolocation)
- `PersonMailingGeocodeAccuracy` - Geocode accuracy

### PersonOtherAddress (Compound Address)
- `PersonOtherStreet` - Street address
- `PersonOtherCity` - City
- `PersonOtherState` - State/Province
- `PersonOtherPostalCode` - ZIP/Postal Code
- `PersonOtherCountry` - Country
- `PersonOtherLatitude` - Latitude
- `PersonOtherLongitude` - Longitude
- `PersonOtherGeocodeAccuracy` - Geocode accuracy

---

## 🏢 Business Account Address Fields (for comparison)

### BillingAddress (Compound Address)
- `BillingStreet` - Street address (includes line 1 and line 2)
- `BillingCity` - City
- `BillingState` - State/Province
- `BillingPostalCode` - ZIP/Postal Code
- `BillingCountry` - Country
- `BillingLatitude` - Latitude
- `BillingLongitude` - Longitude
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

### When Populating from PersonAccount → Personal Information Step

**SOQL Query:**
```sql
SELECT 
    Id,
    Salutation,
    FirstName,
    LastName,
    PersonBirthdate,
    PersonEmail,
    PersonMobilePhone,
    PersonHomePhone,
    PersonMailingStreet,
    PersonMailingCity,
    PersonMailingState,
    PersonMailingPostalCode,
    PersonMailingCountry
FROM Account
WHERE Id = :accountId
    AND IsPersonAccount = true
WITH USER_MODE
```

**Mapping Logic:**
```javascript
// Split compound street field
const streetParts = account.PersonMailingStreet?.split('\n') || [];

const personalInfo = {
    salutation: account.Salutation,
    firstName: account.FirstName,
    lastName: account.LastName,
    dateOfBirth: account.PersonBirthdate,
    email: account.PersonEmail,
    mobilePhone: account.PersonMobilePhone,
    homePhone: account.PersonHomePhone,
    mailingStreetLine1: streetParts[0] || '',
    mailingStreetLine2: streetParts[1] || '',
    mailingCity: account.PersonMailingCity,
    mailingState: account.PersonMailingState,
    mailingPostalCode: account.PersonMailingPostalCode,
    mailingCountry: account.PersonMailingCountry
};
```

### When Saving from Personal Information Step → PersonAccount

**Combine street lines:**
```javascript
const mailingStreet = payload.mailingStreetLine2 
    ? `${payload.mailingStreetLine1}\n${payload.mailingStreetLine2}` 
    : payload.mailingStreetLine1;

const accountToUpdate = {
    Id: accountId,
    Salutation: payload.salutation,
    FirstName: payload.firstName,
    LastName: payload.lastName,
    PersonBirthdate: payload.dateOfBirth,
    PersonEmail: payload.email,
    PersonMobilePhone: payload.mobilePhone,
    PersonHomePhone: payload.homePhone,
    PersonMailingStreet: mailingStreet,
    PersonMailingCity: payload.mailingCity,
    PersonMailingState: payload.mailingState,
    PersonMailingPostalCode: payload.mailingPostalCode,
    PersonMailingCountry: payload.mailingCountry
};
```

---

## ⚠️ Important Notes

1. **Compound Fields**: `PersonMailingStreet` is a compound field that stores both line 1 and line 2 separated by newline (`\n`)

2. **Field Lengths**:
   - `PersonMailingStreet`: 255 characters total (both lines combined)
   - `PersonMailingCity`: 40 characters
   - `PersonMailingState`: 80 characters
   - `PersonMailingPostalCode`: 20 characters
   - `PersonMailingCountry`: 80 characters

3. **Required Fields**: None of the address fields are required by default in Salesforce, but your wizard marks them as required

4. **State Picklist**: If State and Country Picklists are enabled in your org, `PersonMailingState` and `PersonMailingCountry` will be picklist fields instead of text fields

5. **Geolocation**: Salesforce can auto-populate Latitude/Longitude if Data.com Clean is enabled

---

**Reference**: [Salesforce PersonAccount Documentation](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_account.htm)
