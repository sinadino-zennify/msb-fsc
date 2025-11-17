/**
 * Script to create test Applicant records for ApplicationForm
 * ApplicationForm ID: 13XWE000000ZQdx2AG
 * 
 * Based on: /docs/01-foundation/applicant-field-mapping.md
 * 
 * Minimum Required Fields:
 * - FirstName (Required)
 * - LastName (Required)
 * - BirthDate (Required for CIP/KYC)
 * - Mailing_Street_Line_1__c (Required)
 * - ApplicationFormId (Required)
 */

// ApplicationForm ID
Id applicationFormId = '13XWE000000ZQdx2AG';

// Create list of test applicants
List<Applicant> applicantsToInsert = new List<Applicant>();

// Applicant 1: Primary Applicant - John Doe
Applicant applicant1 = new Applicant(
    // Required Fields
    FirstName = 'John',
    LastName = 'Doe',
    BirthDate = Date.newInstance(1985, 6, 15),
    Mailing_Street_Line_1__c = '123 Main Street',
    ApplicationFormId = applicationFormId,
    
    // Optional Person Identity Fields
    MiddleName = 'Michael',
    Suffix = 'Jr.',
    Email = 'john.doe@example.com',
    
    // Optional Address Fields
    Mailing_Street_Line_2__c = 'Apt 4B',
    Mailing_City__c = 'Boston',
    Mailing_State__c = 'MA',
    Mailing_Postal_Code__c = '02101',
    Mailing_Country__c = 'USA',
    
    // Optional Contact Fields
    Mobile_Phone__c = '(617) 555-0101',
    Work_Phone__c = '(617) 555-0102',
    Home_Phone__c = '(617) 555-0103'
);

// Applicant 2: Additional Applicant - Jane Smith
Applicant applicant2 = new Applicant(
    // Required Fields
    FirstName = 'Jane',
    LastName = 'Smith',
    BirthDate = Date.newInstance(1990, 3, 22),
    Mailing_Street_Line_1__c = '456 Oak Avenue',
    ApplicationFormId = applicationFormId,
    
    // Optional Person Identity Fields
    Email = 'jane.smith@example.com',
    
    // Optional Address Fields
    Mailing_City__c = 'Cambridge',
    Mailing_State__c = 'MA',
    Mailing_Postal_Code__c = '02138',
    Mailing_Country__c = 'USA',
    
    // Optional Contact Fields
    Mobile_Phone__c = '(617) 555-0201'
);

// Applicant 3: Additional Applicant - Robert Johnson
Applicant applicant3 = new Applicant(
    // Required Fields
    FirstName = 'Robert',
    LastName = 'Johnson',
    BirthDate = Date.newInstance(1978, 11, 8),
    Mailing_Street_Line_1__c = '789 Elm Street',
    ApplicationFormId = applicationFormId,
    
    // Optional Person Identity Fields
    MiddleName = 'Lee',
    Suffix = 'Sr.',
    Email = 'robert.johnson@example.com',
    
    // Optional Address Fields
    Mailing_Street_Line_2__c = 'Suite 200',
    Mailing_City__c = 'Somerville',
    Mailing_State__c = 'MA',
    Mailing_Postal_Code__c = '02143',
    Mailing_Country__c = 'USA',
    
    // Optional Contact Fields
    Mobile_Phone__c = '(617) 555-0301',
    Work_Phone__c = '(617) 555-0302',
    
    // Optional Identity Fields
    Nickname__c = 'Bob',
    Occupation__c = 'Physician'
);

// Add to list
applicantsToInsert.add(applicant1);
applicantsToInsert.add(applicant2);
applicantsToInsert.add(applicant3);

// Insert applicants
try {
    insert applicantsToInsert;
    
    System.debug('✅ Successfully created ' + applicantsToInsert.size() + ' Applicant records');
    System.debug('');
    
    // Display created records
    for (Applicant app : applicantsToInsert) {
        System.debug('Created Applicant: ' + app.FirstName + ' ' + app.LastName + ' (ID: ' + app.Id + ')');
    }
    
    System.debug('');
    System.debug('ApplicationForm ID: ' + applicationFormId);
    System.debug('Total Applicants: ' + applicantsToInsert.size());
    
} catch (DmlException e) {
    System.debug('❌ Error creating Applicant records:');
    System.debug('Error Message: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
    
    // Display detailed error for each failed record
    for (Integer i = 0; i < e.getNumDml(); i++) {
        System.debug('');
        System.debug('Failed Record #' + (i + 1) + ':');
        System.debug('  Status Code: ' + e.getDmlStatusCode(i));
        System.debug('  Message: ' + e.getDmlMessage(i));
        System.debug('  Fields: ' + e.getDmlFieldNames(i));
    }
}
