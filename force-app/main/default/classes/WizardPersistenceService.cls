public with sharing class WizardPersistenceService {

    // Functional interface for our step handlers
    private interface IStepHandler {
        PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response);
    }

    /**
     * Handler map to route stepDeveloperName to the correct logic.
     * 
     * IMPORTANT: When adding a new step to any wizard:
     * 1. Create a private method for the step's logic (e.g., upsertCollateralStep)
     * 2. Create a new inner class implementing IStepHandler that calls your method
     * 3. Register the step's exact DeveloperName in this map with its handler instance
     * 
     * Example:
     *   'DAO_Business_InBranch_Collateral' => new CollateralStepHandler()
     */
    private static final Map<String, IStepHandler> stepHandlers = new Map<String, IStepHandler>{
        'DAO_Business_InBranch_Applicant' => new ApplicantStepHandler(),
        'DAO_Business_InBranch_Business' => new BusinessStepHandler(),
        'DAO_Business_InBranch_Product' => new ProductStepHandler(),
        'DAO_Business_InBranch_Additional' => new AdditionalStepHandler(),
        'DAO_Business_InBranch_Relationship' => new RelationshipStepHandler(),
        'DAO_Business_InBranch_Services' => new ServicesStepHandler(),
        'DAO_Business_InBranch_Documents' => new DocumentsStepHandler(),
        'DAO_Business_InBranch_Review' => new ReviewStepHandler()
        // Add new step handlers here
    };

    // Inner classes implementing the handler logic
    private class ApplicantStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertApplicantStep(applicationId, payload, response);
        }
    }
    private class BusinessStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertBusinessStep(applicationId, payload, response);
        }
    }
    private class ProductStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertProductStep(applicationId, payload, response);
        }
    }
    private class AdditionalStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertAdditionalStep(applicationId, payload, response);
        }
    }
    private class RelationshipStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertRelationshipStep(applicationId, payload, response);
        }
    }
    private class ServicesStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertServicesStep(applicationId, payload, response);
        }
    }
    private class DocumentsStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertDocumentsStep(applicationId, payload, response);
        }
    }
    private class ReviewStepHandler implements IStepHandler {
        public PersistenceResponse handle(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
            return upsertReviewStep(applicationId, payload, response);
        }
    }
    
    public class PersistenceResponse {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public List<ErrorMessage> messages { get; set; }
        @AuraEnabled public Map<String, Id> savedIds { get; set; }
        
        public PersistenceResponse() {
            this.success = true;
            this.messages = new List<ErrorMessage>();
            this.savedIds = new Map<String, Id>();
        }
    }
    
    public class ErrorMessage {
        @AuraEnabled public String code { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String fieldApiName { get; set; }
        
        public ErrorMessage(String code, String message, String fieldApiName) {
            this.code = code;
            this.message = message;
            this.fieldApiName = fieldApiName;
        }
    }
    
    // Helper method to validate Salesforce ID format
    private static Boolean isValidSalesforceId(String idStr) {
        if (String.isBlank(idStr)) {
            return false;
        }
        
        // Check length (must be exactly 15 or 18 characters)
        if (idStr.length() != 15 && idStr.length() != 18) {
            return false;
        }
        
        // Check if it contains only alphanumeric characters (Salesforce IDs are base62)
        Pattern idPattern = Pattern.compile('^[a-zA-Z0-9]{15}$|^[a-zA-Z0-9]{18}$');
        return idPattern.matcher(idStr).matches();
    }
    
    /**
     * Validate that a value is valid for a restricted picklist field
     * @param value The value to validate
     * @param fieldDescribe The DescribeFieldResult for the picklist field
     * @return true if the value is valid for the picklist, false otherwise
     */
    private static Boolean isValidPicklistValue(String value, Schema.DescribeFieldResult fieldDescribe) {
        if (String.isBlank(value)) {
            return false;
        }
        
        // Get all picklist values
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        
        // Check if the value exists in the picklist
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == value && entry.isActive()) {
                return true;
            }
        }
        
        return false;
    }
    
    @AuraEnabled(cacheable=false)
    public static PersistenceResponse upsertStep(Id applicationId, String stepDeveloperName, Map<String, Object> payload, Id contextRecordId) {
        System.debug('=== WizardPersistenceService.upsertStep START ===');
        System.debug('Input applicationId: ' + applicationId);
        System.debug('Input contextRecordId: ' + contextRecordId);
        System.debug('Input stepDeveloperName: ' + stepDeveloperName);
        System.debug('Input payload: ' + JSON.serializePretty(payload));
        
        PersistenceResponse response = new PersistenceResponse();
        
        // If no applicationId provided, create ApplicationForm record regardless of step
        if (applicationId == null) {
            System.debug('No applicationId provided. Creating new ApplicationForm record.');
            try {
                ApplicationForm newApp = createApplicationForm(payload, contextRecordId);
                System.debug('About to insert ApplicationForm: ' + newApp);
                insert newApp;
                System.debug('Created ApplicationForm with ID: ' + newApp.Id);
                response.savedIds.put('applicationForm', newApp.Id);
                System.debug('Response savedIds: ' + response.savedIds);
                // Update applicationId for subsequent processing
                applicationId = newApp.Id;
            } catch (Exception e) {
                System.debug('ERROR in upsertStep: ' + e.getMessage());
                System.debug('Exception Type: ' + e.getTypeName());
                System.debug('Stack Trace: ' + e.getStackTraceString());
                response.success = false;
                response.messages.add(new ErrorMessage('CREATE_APP_ERROR', 'Failed to create ApplicationForm: ' + e.getMessage(), null));
                System.debug('=== WizardPersistenceService.upsertStep END (Error) ===');
                return response;
            }
        }
        
        if (String.isBlank(stepDeveloperName)) {
            System.debug('ERROR: Step developer name is blank');
            response.success = false;
            response.messages.add(new ErrorMessage('MISSING_STEP_NAME', 'Step developer name is required', null));
            System.debug('=== WizardPersistenceService.upsertStep END (Error) ===');
            return response;
        }
        
        // Allow empty payloads for optional steps like Additional Applicants
        if (payload == null || payload.isEmpty()) {
            System.debug('WARNING: Payload is null or empty for step: ' + stepDeveloperName);
            
            // Additional Applicants step is optional - allow empty payload
            if (stepDeveloperName == 'DAO_Business_InBranch_Additional') {
                System.debug('Additional Applicants step with empty payload - this is allowed');
                response.savedIds.put('applicationForm', applicationId);
                System.debug('=== WizardPersistenceService.upsertStep END (Success - Empty Additional) ===');
                return response;
            }
            
            // For other steps, payload is required
            response.success = false;
            response.messages.add(new ErrorMessage('MISSING_PAYLOAD', 'Payload is required', null));
            System.debug('=== WizardPersistenceService.upsertStep END (Error) ===');
            return response;
        }
        
        try {
            // Use a handler map to route to the correct step logic
            System.debug('╔════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ HANDLER ROUTING');
            System.debug('╠════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ Looking up handler for step: "' + stepDeveloperName + '"');
            System.debug('║ Available handlers: ' + stepHandlers.keySet());
            System.debug('╚════════════════════════════════════════════════════════════════════════════════');
            
            IStepHandler handler = stepHandlers.get(stepDeveloperName);
            System.debug('🎯 Handler found: ' + (handler != null ? 'YES' : 'NULL'));

            if (handler != null) {
                System.debug('▶️ Executing handler for step: ' + stepDeveloperName);
                PersistenceResponse handlerResponse = handler.handle(applicationId, payload, response);
                
                // Update ApplicationForm with StepKey__c (current step) for resume functionality
                // This stores where the user left off in the application process
                try {
                    ApplicationForm appForm = [SELECT Id, StepKey__c FROM ApplicationForm WHERE Id = :applicationId WITH USER_MODE LIMIT 1];
                    appForm.StepKey__c = stepDeveloperName;
                    update as user appForm;
                    System.debug('Updated ApplicationForm.StepKey__c = ' + stepDeveloperName + ' for resume functionality');
                } catch (Exception stepKeyEx) {
                    System.debug('WARNING: Could not update ApplicationForm.StepKey__c: ' + stepKeyEx.getMessage());
                    // Don't fail the entire operation if StepKey update fails
                }
                
                System.debug('╔════════════════════════════════════════════════════════════════════════════════');
                System.debug('║ HANDLER RESPONSE');
                System.debug('╠════════════════════════════════════════════════════════════════════════════════');
                System.debug('║ Success: ' + handlerResponse.success);
                System.debug('║ Messages: ' + handlerResponse.messages.size());
                System.debug('║ SavedIds: ' + handlerResponse.savedIds);
                System.debug('║ Full Response: ' + JSON.serializePretty(handlerResponse));
                System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                System.debug('=== WizardPersistenceService.upsertStep END (Success) ===');
                return handlerResponse;
            } else {
                System.debug('╔════════════════════════════════════════════════════════════════════════════════');
                System.debug('║ ❌ ERROR: No handler registered for step: ' + stepDeveloperName);
                System.debug('║ Available handlers: ' + stepHandlers.keySet());
                System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                response.success = false;
                response.messages.add(new ErrorMessage('UNKNOWN_STEP', 'No handler registered for step: ' + stepDeveloperName, null));
                System.debug('=== WizardPersistenceService.upsertStep END (Error) ===');
                return response;
            }
        } catch (DmlException e) {
            System.debug('DML EXCEPTION: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            response.success = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('DML Error ' + i + ': ' + e.getDmlMessage(i));
                System.debug('DML Fields ' + i + ': ' + e.getDmlFieldNames(i));
                response.messages.add(new ErrorMessage(
                    'DML_ERROR', 
                    e.getDmlMessage(i), 
                    e.getDmlFieldNames(i).isEmpty() ? null : String.join(e.getDmlFieldNames(i), ',')
                ));
            }
            System.debug('=== WizardPersistenceService.upsertStep END (DML Error) ===');
            return response;
        } catch (Exception e) {
            System.debug('UNEXPECTED EXCEPTION: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            response.success = false;
            response.messages.add(new ErrorMessage('UNEXPECTED_ERROR', e.getMessage(), null));
            System.debug('=== WizardPersistenceService.upsertStep END (Exception) ===');
            return response;
        }
    }
    
    private static PersistenceResponse upsertApplicantStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        System.debug('--- upsertApplicantStep START ---');
        System.debug('ApplicationId: ' + applicationId);
        System.debug('Payload: ' + JSON.serializePretty(payload));
        
        try {
            // Query for existing Applicant record (Type='Individual') for this ApplicationForm
            // Include Is_US_Citizen__c and Is_US_Resident__c to ensure proper update
            Applicant applicant = null;
            List<Applicant> existingApplicants = [
                SELECT Id, ApplicationFormId, Type, Is_US_Citizen__c, Is_US_Resident__c
                FROM Applicant
                WHERE ApplicationFormId = :applicationId
                AND Type = 'Individual'
                WITH USER_MODE
                LIMIT 1
            ];
            
            if (!existingApplicants.isEmpty()) {
                applicant = existingApplicants[0];
                System.debug('Found existing Applicant (Individual) with ID: ' + applicant.Id);
            } else {
                applicant = new Applicant();
                applicant.ApplicationFormId = applicationId;
                applicant.Type = 'Individual'; // Valid values: 'Individual' (PersonAccount) or 'Business' (Business Account)
                applicant.Role__c = 'Primary Applicant'; // Default role for primary applicant (hidden from UI)
                System.debug('Creating new Applicant (Individual)');
            }
            
            // Personal Identity fields
            applicant.Salutation = (String) payload.get('salutation');
            applicant.FirstName = (String) payload.get('firstName');
            applicant.MiddleName = (String) payload.get('middleName');
            applicant.LastName = (String) payload.get('lastName');
            applicant.Suffix = (String) payload.get('suffix');
            applicant.Nickname__c = (String) payload.get('nickname');
            applicant.Occupation__c = (String) payload.get('occupation');
            applicant.Mothers_Maiden_Name__c = (String) payload.get('mothersMaidenName');
            
            // Birth Date - Add error handling for Date parsing
            String birthDateStr = (String) payload.get('birthDate');
            if (String.isNotBlank(birthDateStr)) {
                try {
                    applicant.BirthDate = Date.valueOf(birthDateStr.trim());
                } catch (Exception e) {
                    System.debug('Error parsing Birth Date: ' + birthDateStr + ' - ' + e.getMessage());
                    applicant.BirthDate = null;
                }
            } else {
                applicant.BirthDate = null; // Clear the field if not provided
            }
            
            // Tax ID
            applicant.Tax_ID__c = (String) payload.get('taxId');
            applicant.Tax_ID_Type__c = (String) payload.get('taxIdType');
            
            // Citizenship Status
            // Convert "Yes"/"No" strings or Boolean values to Boolean for Checkbox fields
            // Is_US_Citizen__c and Is_US_Resident__c are Checkbox (Boolean) fields
            // CRITICAL: Always explicitly set these fields to ensure they are persisted during upsert
            // Checkbox fields must be explicitly set to a Boolean value to be saved
            Boolean isUSCitizenSet = false;
            Object usCitizenObj = payload.get('isUSCitizen');
            if (usCitizenObj != null) {
                if (usCitizenObj instanceof Boolean) {
                    applicant.Is_US_Citizen__c = (Boolean) usCitizenObj;
                    isUSCitizenSet = true;
                    System.debug('✅ Set Is_US_Citizen__c = ' + applicant.Is_US_Citizen__c + ' from Boolean payload value');
                } else if (usCitizenObj instanceof String) {
                    String usCitizenStr = (String) usCitizenObj;
                    if (String.isNotBlank(usCitizenStr)) {
                        applicant.Is_US_Citizen__c = 'Yes'.equalsIgnoreCase(usCitizenStr.trim());
                        isUSCitizenSet = true;
                        System.debug('✅ Set Is_US_Citizen__c = ' + applicant.Is_US_Citizen__c + ' from payload value: "' + usCitizenStr + '"');
                    }
                }
            }
            // If not set from payload, explicitly set based on existing value (for updates) or false (for new)
            if (!isUSCitizenSet) {
                if (applicant.Id != null && applicant.Is_US_Citizen__c != null) {
                    // Preserve existing value for updates when not in payload
                    System.debug('📌 Preserving existing Is_US_Citizen__c = ' + applicant.Is_US_Citizen__c + ' (not in payload)');
                } else {
                    // Explicitly set to false for new records or when existing value is null
                    applicant.Is_US_Citizen__c = false;
                    System.debug('✅ Set Is_US_Citizen__c = false (default for new/null)');
                }
            }
            
            Boolean isUSResidentSet = false;
            Object usResidentObj = payload.get('isUSResident');
            if (usResidentObj != null) {
                if (usResidentObj instanceof Boolean) {
                    applicant.Is_US_Resident__c = (Boolean) usResidentObj;
                    isUSResidentSet = true;
                    System.debug('✅ Set Is_US_Resident__c = ' + applicant.Is_US_Resident__c + ' from Boolean payload value');
                } else if (usResidentObj instanceof String) {
                    String usResidentStr = (String) usResidentObj;
                    if (String.isNotBlank(usResidentStr)) {
                        applicant.Is_US_Resident__c = 'Yes'.equalsIgnoreCase(usResidentStr.trim());
                        isUSResidentSet = true;
                        System.debug('✅ Set Is_US_Resident__c = ' + applicant.Is_US_Resident__c + ' from payload value: "' + usResidentStr + '"');
                    }
                }
            }
            // If not set from payload, explicitly set based on existing value (for updates) or false (for new)
            if (!isUSResidentSet) {
                if (applicant.Id != null && applicant.Is_US_Resident__c != null) {
                    // Preserve existing value for updates when not in payload
                    System.debug('📌 Preserving existing Is_US_Resident__c = ' + applicant.Is_US_Resident__c + ' (not in payload)');
                } else {
                    // Explicitly set to false for new records or when existing value is null
                    applicant.Is_US_Resident__c = false;
                    System.debug('✅ Set Is_US_Resident__c = false (default for new/null)');
                }
            }
            
            applicant.Country_Of_Residence__c = (String) payload.get('countryOfResidence');
            
            // Employment
            applicant.Employer__c = (String) payload.get('employer');
            
            // Organization Roles
            applicant.Organization_Role__c = (String) payload.get('organizationRole');
            
            // Is Control Person: Convert "Yes"/"No" strings to Boolean for Checkbox field
            // Handle both String ("Yes"/"No") and Boolean types from JSON payload
            Object isControlPersonObj = payload.get('isControlPerson');
            if (isControlPersonObj != null) {
                if (isControlPersonObj instanceof Boolean) {
                    // This shouldn't happen if it's a Checkbox, but handle it anyway
                    applicant.Is_Control_Person__c = (Boolean) isControlPersonObj ? 'Yes' : 'No';
                } else if (isControlPersonObj instanceof String) {
                    String isControlPersonStr = (String) isControlPersonObj;
                    if (String.isNotBlank(isControlPersonStr)) {
                        applicant.Is_Control_Person__c = isControlPersonStr.trim(); // Store as "Yes" or "No" for Picklist
                    } else {
                        applicant.Is_Control_Person__c = null;
                    }
                } else {
                    applicant.Is_Control_Person__c = null;
                }
            } else {
                applicant.Is_Control_Person__c = null;
            }
            
            // Ownership Percentage: Convert whole number (50) to decimal (0.50) for Percent field
            // User enters 50, we store as 0.50 (which displays as 50%)
            Object ownershipPercentageObj = payload.get('ownershipPercentage');
            if (ownershipPercentageObj != null) {
                Decimal ownershipPercentage;
                // Handle both String and Decimal types from JSON payload
                if (ownershipPercentageObj instanceof String) {
                    String ownershipPercentageStr = (String) ownershipPercentageObj;
                    if (String.isNotBlank(ownershipPercentageStr)) {
                        ownershipPercentage = Decimal.valueOf(ownershipPercentageStr);
                    } else {
                        ownershipPercentage = null;
                    }
                } else if (ownershipPercentageObj instanceof Decimal) {
                    ownershipPercentage = (Decimal) ownershipPercentageObj;
                } else if (ownershipPercentageObj instanceof Integer) {
                    ownershipPercentage = Decimal.valueOf((Integer) ownershipPercentageObj);
                } else if (ownershipPercentageObj instanceof Long) {
                    ownershipPercentage = Decimal.valueOf((Long) ownershipPercentageObj);
                } else {
                    ownershipPercentage = null;
                }
                
                if (ownershipPercentage != null) {
                    // If value is > 1, assume it's a whole number (50) and convert to decimal (0.50)
                    if (ownershipPercentage > 1) {
                        applicant.Ownership_Percentage__c = ownershipPercentage / 100;
                    } else {
                        applicant.Ownership_Percentage__c = ownershipPercentage;
                    }
                } else {
                    applicant.Ownership_Percentage__c = null;
                }
            } else {
                applicant.Ownership_Percentage__c = null;
            }
            
            // Roles__c is a MultiselectPicklist - expects semicolon-separated string
            Object rolesObj = payload.get('roles');
            if (rolesObj != null) {
                if (rolesObj instanceof String) {
                    applicant.Roles__c = String.isNotBlank((String) rolesObj) ? (String) rolesObj : null;
                } else if (rolesObj instanceof List<Object>) {
                    // Handle array format - convert to semicolon-separated string
                    List<String> rolesList = new List<String>();
                    for (Object role : (List<Object>) rolesObj) {
                        if (role != null && String.isNotBlank(String.valueOf(role))) {
                            rolesList.add(String.valueOf(role));
                        }
                    }
                    applicant.Roles__c = rolesList.isEmpty() ? null : String.join(rolesList, ';');
                } else {
                    applicant.Roles__c = null;
                }
            } else {
                applicant.Roles__c = null;
            }
            
            // Contact Information
            applicant.Email = (String) payload.get('email');
            applicant.Home_Phone__c = (String) payload.get('homePhone');
            applicant.Work_Phone__c = (String) payload.get('workPhone');
            applicant.Mobile_Phone__c = (String) payload.get('mobilePhone');
            
            // Mailing Address
            applicant.Mailing_Street_Line_1__c = (String) payload.get('mailingStreetLine1');
            applicant.Mailing_Street_Line_2__c = (String) payload.get('mailingStreetLine2');
            applicant.Mailing_City__c = (String) payload.get('mailingCity');
            applicant.Mailing_State__c = (String) payload.get('mailingState');
            applicant.Mailing_Postal_Code__c = (String) payload.get('mailingPostalCode');
            
            // Normalize country name to match restricted picklist values
            // Mailing_Country__c only accepts: USA, Canada, Mexico, Other
            String mailingCountry = (String) payload.get('mailingCountry');
            applicant.Mailing_Country__c = normalizeMailingCountry(mailingCountry);
            
            // Government ID
            applicant.Government_ID_Type__c = (String) payload.get('governmentIdType');
            applicant.Government_ID_Number__c = (String) payload.get('governmentIdNumber');
            
            // Normalize ID Issuing Country to match restricted picklist values
            // ID_Issuing_Country__c only accepts: USA, Canada, Mexico, Other
            String idIssuingCountry = (String) payload.get('idIssuingCountry');
            applicant.ID_Issuing_Country__c = normalizeMailingCountry(idIssuingCountry); // Same normalization logic
            
            applicant.ID_Issuing_State__c = (String) payload.get('idIssuingState');
            
            // ID Dates - Add error handling for Date parsing
            String idIssueDateStr = (String) payload.get('idIssueDate');
            if (String.isNotBlank(idIssueDateStr)) {
                try {
                    applicant.ID_Issue_Date__c = Date.valueOf(idIssueDateStr.trim());
                } catch (Exception e) {
                    System.debug('Error parsing ID Issue Date: ' + idIssueDateStr + ' - ' + e.getMessage());
                    applicant.ID_Issue_Date__c = null;
                }
            } else {
                applicant.ID_Issue_Date__c = null; // Clear the field if not provided
            }
            
            String idExpirationDateStr = (String) payload.get('idExpirationDate');
            if (String.isNotBlank(idExpirationDateStr)) {
                try {
                    applicant.ID_Expiration_Date__c = Date.valueOf(idExpirationDateStr.trim());
                } catch (Exception e) {
                    System.debug('Error parsing ID Expiration Date: ' + idExpirationDateStr + ' - ' + e.getMessage());
                    applicant.ID_Expiration_Date__c = null;
                }
            } else {
                applicant.ID_Expiration_Date__c = null; // Clear the field if not provided
            }
            
            // Upsert Applicant with CRUD/FLS checks - MUST be done before Identity Documents
            System.debug('About to upsert Applicant (Person): ' + applicant);
            upsert as user applicant;
            
            // Verify Applicant was successfully saved and has an Id
            if (applicant.Id == null) {
                throw new AuraHandledException('Failed to save Applicant: Applicant Id is null after upsert');
            }
            
            System.debug('SUCCESS: Upserted Applicant with ID: ' + applicant.Id);
            
            response.savedIds.put('applicant', applicant.Id);
            response.savedIds.put('applicationForm', applicationId);
            System.debug('Response savedIds: ' + response.savedIds);
            
            // Handle Identity Documents (CIP Requirement) - AFTER Applicant is created
            // This ensures applicant.Id is available for Applicant__c field on IdentityDocument
            List<Object> identityDocumentsPayload = (List<Object>) payload.get('identityDocuments');
            if (identityDocumentsPayload != null && !identityDocumentsPayload.isEmpty()) {
                System.debug('Processing ' + identityDocumentsPayload.size() + ' identity documents for Applicant ID: ' + applicant.Id);
                
                // Get AccountId from ApplicationForm for RelatedLegalEntityId field
                // IdentityDocument requires "Related Entity/Person" which must be an Account or PersonAccount
                // Applications can only start from Opportunity, Account, or PersonAccount
                // Since we're not creating PersonAccount or Business Account, we use the AccountId from ApplicationForm
                Id accountId = null;
                try {
                    ApplicationForm appForm = [
                        SELECT AccountId 
                        FROM ApplicationForm 
                        WHERE Id = :applicationId 
                        WITH USER_MODE 
                        LIMIT 1
                    ];
                    accountId = appForm.AccountId;
                    System.debug('Retrieved AccountId from ApplicationForm: ' + accountId);
                } catch (Exception appFormEx) {
                    System.debug('Error querying ApplicationForm for AccountId: ' + appFormEx.getMessage());
                    // Continue - will log error if AccountId is null when setting RelatedLegalEntityId
                }
                
                // Query existing IdentityDocument records for this Applicant
                // Applicant.Id must be set (verified above) before querying
                List<IdentityDocument> existingDocs = new List<IdentityDocument>();
                try {
                    existingDocs = [
                        SELECT Id, Name, IdDocumentType, IssuingAuthority, Issuing_Authority_State__c, 
                               IssueDate, ExpirationDate, Applicant__c, RelatedLegalEntityId
                        FROM IdentityDocument
                        WHERE Applicant__c = :applicant.Id
                        WITH USER_MODE
                    ];
                    System.debug('Found ' + existingDocs.size() + ' existing IdentityDocument records');
                } catch (Exception queryEx) {
                    System.debug('Error querying existing IdentityDocuments: ' + queryEx.getMessage());
                    System.debug('Stack trace: ' + queryEx.getStackTraceString());
                    // Continue with empty list - will create new documents
                    existingDocs = new List<IdentityDocument>();
                }
                
                Map<String, IdentityDocument> existingDocsMap = new Map<String, IdentityDocument>();
                for (IdentityDocument doc : existingDocs) {
                    existingDocsMap.put(doc.Name, doc);
                }
                
                List<IdentityDocument> docsToUpsert = new List<IdentityDocument>();
                Set<String> processedIdNumbers = new Set<String>();
                
                // Process each identity document from payload
                for (Object docObj : identityDocumentsPayload) {
                    // Convert Map<ANY,ANY> to Map<String,Object> safely
                    // JSON deserialization sometimes returns Map<ANY,ANY> instead of Map<String,Object>
                    Map<String, Object> docMap = new Map<String, Object>();
                    Map<Object, Object> rawMap = (Map<Object, Object>) docObj;
                    for (Object key : rawMap.keySet()) {
                        docMap.put(String.valueOf(key), rawMap.get(key));
                    }
                    
                    String idNumber = (String) docMap.get('idNumber');
                    
                    if (String.isBlank(idNumber)) {
                        continue; // Skip if no ID number
                    }
                    
                    processedIdNumbers.add(idNumber);
                    
                    IdentityDocument doc;
                    if (existingDocsMap.containsKey(idNumber)) {
                        // Update existing document
                        doc = existingDocsMap.get(idNumber);
                        System.debug('Updating existing IdentityDocument with Name: ' + idNumber);
                        // Ensure Applicant__c is set (in case it wasn't before)
                        if (doc.Applicant__c == null && applicant.Id != null) {
                            doc.Applicant__c = applicant.Id;
                        }
                        // Ensure RelatedLegalEntityId is set (required field)
                        if (doc.RelatedLegalEntityId == null && accountId != null) {
                            doc.RelatedLegalEntityId = accountId;
                        }
                    } else {
                        // Create new document - Applicant must be saved first (verified above)
                        doc = new IdentityDocument();
                        doc.Name = idNumber; // ID Number stored in Name field
                        doc.Applicant__c = applicant.Id; // Link to Applicant (Id must be set after upsert)
                        // RelatedLegalEntityId is required - must reference Account or PersonAccount
                        // We use AccountId from ApplicationForm (applications can only start from Opportunity/Account/PersonAccount)
                        if (accountId != null) {
                            doc.RelatedLegalEntityId = accountId;
                            System.debug('Creating new IdentityDocument with Name: ' + idNumber + ', Applicant__c: ' + applicant.Id + ', RelatedLegalEntityId: ' + accountId);
                        } else {
                            System.debug('WARNING: AccountId is null - RelatedLegalEntityId will be null. This may cause validation error.');
                        }
                    }
                    
                    // Map fields from payload to IdentityDocument
                    doc.IdDocumentType = (String) docMap.get('idType');
                    String issuingAuthorityFull = (String) docMap.get('issuingAuthority');
                    
                    // Parse issuing authority to extract state and country
                    // Format expected: "State, Country" (e.g., "CA, USA", "NY, USA")
                    // IssuingAuthority should contain only the Country
                    // Issuing_Authority_State__c should contain only the State
                    if (String.isNotBlank(issuingAuthorityFull)) {
                        String[] parts = issuingAuthorityFull.split(',');
                        if (parts.size() > 1) {
                            // Has both state and country: "CA, USA"
                            String state = parts[0].trim(); // First part is the state
                            String country = parts[1].trim(); // Second part is the country
                            doc.Issuing_Authority_State__c = state;
                            doc.IssuingAuthority = country; // Store only country in IssuingAuthority
                            System.debug('Parsed Issuing Authority: "' + issuingAuthorityFull + '" -> State: "' + state + '", Country: "' + country + '"');
                        } else if (parts.size() == 1) {
                            // Only one part - assume it's the country if no comma
                            String value = parts[0].trim();
                            doc.IssuingAuthority = value; // Store as country
                            doc.Issuing_Authority_State__c = null; // No state provided
                            System.debug('Issuing Authority has no comma - storing as country only: "' + value + '"');
                        }
                    } else {
                        doc.IssuingAuthority = null;
                        doc.Issuing_Authority_State__c = null;
                    }
                    
                    // Parse dates
                    String issueDateStr = (String) docMap.get('issueDate');
                    if (String.isNotBlank(issueDateStr)) {
                        doc.IssueDate = Date.valueOf(issueDateStr);
                    }
                    
                    String expirationDateStr = (String) docMap.get('expirationDate');
                    if (String.isNotBlank(expirationDateStr)) {
                        doc.ExpirationDate = Date.valueOf(expirationDateStr);
                    }
                    
                    docsToUpsert.add(doc);
                }
                
                // Upsert identity documents
                if (!docsToUpsert.isEmpty()) {
                    try {
                        upsert as user docsToUpsert;
                        System.debug('Upserted ' + docsToUpsert.size() + ' IdentityDocument records');
                        
                        // Add IDs to response
                        List<Id> docIds = new List<Id>();
                        for (IdentityDocument doc : docsToUpsert) {
                            docIds.add(doc.Id);
                        }
                        response.savedIds.put('identityDocuments', String.join(docIds, ','));
                    } catch (Exception upsertEx) {
                        System.debug('Error upserting IdentityDocuments: ' + upsertEx.getMessage());
                        System.debug('Stack trace: ' + upsertEx.getStackTraceString());
                        // Re-throw with more context
                        throw new AuraHandledException('Failed to save Identity Documents: ' + upsertEx.getMessage());
                    }
                }
                
                // Delete removed documents (documents that exist but weren't in the payload)
                List<IdentityDocument> docsToDelete = new List<IdentityDocument>();
                for (IdentityDocument existingDoc : existingDocs) {
                    if (!processedIdNumbers.contains(existingDoc.Name)) {
                        docsToDelete.add(existingDoc);
                    }
                }
                
                if (!docsToDelete.isEmpty()) {
                    delete as user docsToDelete;
                    System.debug('Deleted ' + docsToDelete.size() + ' removed IdentityDocument records');
                }
            }
            
            System.debug('--- upsertApplicantStep END (Success) ---');
            return response;
        } catch (Exception e) {
            System.debug('ERROR in upsertApplicantStep: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            response.success = false;
            response.messages.add(new ErrorMessage('APPLICANT_UPSERT_ERROR', 'Failed to upsert Applicant: ' + e.getMessage(), null));
            System.debug('--- upsertApplicantStep END (Error) ---');
            return response;
        }
    }
    
    private static PersistenceResponse upsertProductStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        System.debug('--- upsertProductStep START ---');
        System.debug('ApplicationId: ' + applicationId);
        System.debug('Payload: ' + JSON.serializePretty(payload));
        
        try {
            // Extract products array from payload
            List<Object> productsObj = (List<Object>) payload.get('products');
            
            if (productsObj == null || productsObj.isEmpty()) {
                System.debug('No products in payload, skipping save');
                response.savedIds.put('applicationForm', applicationId);
                return response;
            }
            
            // Get existing ApplicationFormProducts
            Map<Id, ApplicationFormProduct> existingMap = new Map<Id, ApplicationFormProduct>();
            for (ApplicationFormProduct afp : [
                SELECT Id, ProductId, FundingAmount__c
                FROM ApplicationFormProduct
                WHERE ApplicationFormId = :applicationId
            ]) {
                existingMap.put(afp.ProductId, afp);
            }
            
            List<ApplicationFormProduct> toUpsert = new List<ApplicationFormProduct>();
            Set<Id> productIdsToKeep = new Set<Id>();
            
            // Process each product from payload
            for (Object prodObj : productsObj) {
                // Convert Map<ANY,ANY> to Map<String,Object> safely
                // JSON deserialization sometimes returns Map<ANY,ANY> instead of Map<String,Object>
                Map<String, Object> prodMap = new Map<String, Object>();
                Map<Object, Object> rawMap = (Map<Object, Object>) prodObj;
                for (Object key : rawMap.keySet()) {
                    prodMap.put(String.valueOf(key), rawMap.get(key));
                }
                
                Id productId = (Id) prodMap.get('productId');
                Object fundingAmountObj = prodMap.get('fundingAmount');
                String recordIdStr = (String) prodMap.get('id');
                
                if (productId == null) continue;
                
                productIdsToKeep.add(productId);
                
                ApplicationFormProduct afp;
                if (String.isNotBlank(recordIdStr)) {
                    // Update existing by record ID
                    afp = new ApplicationFormProduct(Id = (Id) recordIdStr);
                } else if (existingMap.containsKey(productId)) {
                    // Update by Product2Id match
                    afp = existingMap.get(productId);
                } else {
                    // Create new
                    afp = new ApplicationFormProduct();
                    afp.ApplicationFormId = applicationId;
                    afp.ProductId = productId;
                }
                
                // Handle fundingAmount - convert empty strings to null
                Decimal fundingAmount = null;
                if (fundingAmountObj != null) {
                    if (fundingAmountObj instanceof String) {
                        String fundingStr = (String) fundingAmountObj;
                        if (String.isNotBlank(fundingStr)) {
                            fundingAmount = Decimal.valueOf(fundingStr);
                        }
                    } else if (fundingAmountObj instanceof Decimal) {
                        fundingAmount = (Decimal) fundingAmountObj;
                    } else if (fundingAmountObj instanceof Integer) {
                        fundingAmount = Decimal.valueOf((Integer) fundingAmountObj);
                    } else if (fundingAmountObj instanceof Long) {
                        fundingAmount = Decimal.valueOf((Long) fundingAmountObj);
                    }
                }
                
                afp.FundingAmount__c = fundingAmount;
                toUpsert.add(afp);
            }
            
            // Upsert products
            if (!toUpsert.isEmpty()) {
                upsert toUpsert;
                System.debug('Upserted ' + toUpsert.size() + ' ApplicationFormProduct records');
            }
            
            // Delete removed products
            List<ApplicationFormProduct> toDelete = new List<ApplicationFormProduct>();
            for (ApplicationFormProduct afp : existingMap.values()) {
                if (!productIdsToKeep.contains(afp.ProductId)) {
                    toDelete.add(afp);
                }
            }
            
            if (!toDelete.isEmpty()) {
                delete toDelete;
                System.debug('Deleted ' + toDelete.size() + ' ApplicationFormProduct records');
            }
            
            response.savedIds.put('applicationForm', applicationId);
            System.debug('--- upsertProductStep END (Success) ---');
            return response;
            
        } catch (Exception e) {
            System.debug('ERROR in upsertProductStep: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            response.success = false;
            response.messages.add(new ErrorMessage('PRODUCT_STEP_ERROR', 'Failed to save product details: ' + e.getMessage(), null));
            System.debug('--- upsertProductStep END (Error) ---');
            return response;
        }
    }
    
    private static PersistenceResponse upsertBusinessStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        System.debug('╔════════════════════════════════════════════════════════════════════════════════');
        System.debug('║ upsertBusinessStep START');
        System.debug('╠════════════════════════════════════════════════════════════════════════════════');
        System.debug('║ ApplicationId: ' + applicationId);
        System.debug('║ Payload keys: ' + payload.keySet());
        System.debug('║ Payload size: ' + payload.size());
        System.debug('║ Full Payload: ' + JSON.serializePretty(payload));
        System.debug('╚════════════════════════════════════════════════════════════════════════════════');
        
        try {
            String businessAccountType = (String) payload.get('businessAccountType');
            System.debug('📋 businessAccountType: ' + businessAccountType);
            String selectedAccountId = (String) payload.get('selectedAccountId');
            String primaryContactType = (String) payload.get('primaryContactType');
            String selectedContactId = (String) payload.get('selectedContactId');
            System.debug('📋 selectedAccountId: ' + selectedAccountId);
            System.debug('📋 primaryContactType: ' + primaryContactType);
            System.debug('📋 selectedContactId: ' + selectedContactId);
            
            System.debug('🔍 Querying for existing Business Applicant...');
            System.debug('🔍 Query WHERE ApplicationFormId = ' + applicationId + ' AND Type = Business');
            
            // Query for existing Applicant record (Type='Business') for this ApplicationForm
            Applicant applicant = null;
            List<Applicant> existingApplicants = [
                SELECT Id, ApplicationFormId, Type, AccountId
                FROM Applicant
                WHERE ApplicationFormId = :applicationId
                AND Type = 'Business'
                WITH USER_MODE
                LIMIT 1
            ];
            
            System.debug('🔍 Query returned ' + existingApplicants.size() + ' records');
            
            if (!existingApplicants.isEmpty()) {
                applicant = existingApplicants[0];
                System.debug('✅ Found existing Applicant (Business) with ID: ' + applicant.Id);
            } else {
                applicant = new Applicant();
                applicant.ApplicationFormId = applicationId;
                applicant.Type = 'Business'; // Valid values: 'Individual' (PersonAccount) or 'Business' (Business Account)
                System.debug('🆕 Creating new Applicant (Business)');
                System.debug('🆕 Set ApplicationFormId: ' + applicant.ApplicationFormId);
                System.debug('🆕 Set Type: ' + applicant.Type);
            }
            
            // Link to existing Account if selected (for reference only - Account not modified)
            if (businessAccountType == 'existing' && String.isNotBlank(selectedAccountId)) {
                applicant.AccountId = selectedAccountId;
            }
            
            // Business Identity fields
            applicant.BusinessEntityName = (String) payload.get('businessName');
            applicant.Doing_Business_As__c = (String) payload.get('dbaName');
            
            // Validate and set BusinessEntityType (required field, restricted picklist)
            String businessType = (String) payload.get('businessType');
            System.debug('║ 📋  businessType: ' + businessType);
            if (String.isBlank(businessType)) {
                response.success = false;
                response.messages.add(new ErrorMessage('BUSINESS_TYPE_REQUIRED', 'Business Type is required.', 'businessType'));
                System.debug('║ ❌ Validation Error: Business Type is required');
                System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                return response;
            }
            
            // Validate that the value is valid for the BusinessEntityType picklist
            Schema.DescribeFieldResult businessTypeField = Schema.SObjectType.Applicant.fields.getMap().get('BusinessEntityType').getDescribe();
            if (!isValidPicklistValue(businessType, businessTypeField)) {
                response.success = false;
                // Get valid values for error message
                List<String> validValues = new List<String>();
                for (Schema.PicklistEntry entry : businessTypeField.getPicklistValues()) {
                    if (entry.isActive()) {
                        validValues.add(entry.getValue());
                    }
                }
                String validValuesStr = String.join(validValues, ', ');
                response.messages.add(new ErrorMessage(
                    'BUSINESS_TYPE_INVALID', 
                    'Invalid Business Type "' + businessType + '". Valid values are: ' + validValuesStr, 
                    'businessType'
                ));
                System.debug('║ ❌ Validation Error: Invalid Business Type: ' + businessType);
                System.debug('║ Valid values: ' + validValuesStr);
                System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                return response;
            }
            
            applicant.BusinessEntityType = businessType;
            
            applicant.Business_Tax_ID__c = (String) payload.get('taxId');
            
            // Parse date string to Date
            String dateEstStr = (String) payload.get('dateEstablished');
            if (String.isNotBlank(dateEstStr)) {
                applicant.Date_Established__c = Date.valueOf(dateEstStr);
            }
            
            applicant.Business_Registration_State__c = (String) payload.get('stateOfIncorporation');
            
            // Industry & Classification fields
            // NAICS_Code__c is a lookup field - store the ID from naicsCodeId
            String naicsCodeId = (String) payload.get('naicsCodeId');
            if (String.isNotBlank(naicsCodeId)) {
                applicant.NAICS_Code__c = naicsCodeId; // This is a lookup field (Id)
            }
            applicant.Industry_Type__c = (String) payload.get('industryType');
            applicant.Business_Description__c = (String) payload.get('businessDescription');
            
            // Contact Information fields
            applicant.Business_Phone__c = (String) payload.get('businessPhone');
            applicant.Business_Email__c = (String) payload.get('businessEmail');
            applicant.Business_Home_Phone__c = (String) payload.get('businessHomePhone');
            applicant.Business_Mobile_Phone__c = (String) payload.get('businessMobilePhone');
            applicant.Business_Website__c = (String) payload.get('businessWebsite');
            
            // Primary Contact fields - store name/title for NEW contact OR reference to EXISTING PersonAccount
            // Validate: Either existing PersonAccount OR new contact name/title must be provided
            if (primaryContactType == 'new') {
                // For new contact, validate that name and title are provided
                String primaryContactName = (String) payload.get('primaryContactName');
                String primaryContactTitle = (String) payload.get('primaryContactTitle');
                
                if (String.isBlank(primaryContactName)) {
                    response.success = false;
                    response.messages.add(new ErrorMessage('PRIMARY_CONTACT_NAME_REQUIRED', 'Primary Contact Name is required when creating a new contact.', 'primaryContactName'));
                    System.debug('║ ❌ Validation Error: Primary Contact Name is required');
                    System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                    return response;
                }
                
                if (String.isBlank(primaryContactTitle)) {
                    response.success = false;
                    response.messages.add(new ErrorMessage('PRIMARY_CONTACT_TITLE_REQUIRED', 'Primary Contact Title is required when creating a new contact.', 'primaryContactTitle'));
                    System.debug('║ ❌ Validation Error: Primary Contact Title is required');
                    System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                    return response;
                }
                
                // Store name and title for later PersonAccount creation
                applicant.Primary_Contact_Name__c = primaryContactName;
                applicant.Primary_Contact_Title__c = primaryContactTitle;
                applicant.Primary_Contact_PersonAccount__c = null; // Clear any existing reference
            } else if (primaryContactType == 'existing') {
                // For existing contact, validate that a PersonAccount was selected
                if (String.isBlank(selectedContactId)) {
                    response.success = false;
                    response.messages.add(new ErrorMessage('PRIMARY_CONTACT_SELECTION_REQUIRED', 'Please select an existing contact or create a new one.', 'selectedContactId'));
                    System.debug('║ ❌ Validation Error: Existing contact must be selected');
                    System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                    return response;
                }
                
                // Store reference to existing PersonAccount
                applicant.Primary_Contact_PersonAccount__c = selectedContactId;
                // Clear name/title fields since we're using an existing contact
                applicant.Primary_Contact_Name__c = null;
                applicant.Primary_Contact_Title__c = null;
            } else {
                // Invalid primaryContactType
                response.success = false;
                response.messages.add(new ErrorMessage('PRIMARY_CONTACT_TYPE_INVALID', 'Primary Contact Type must be either "new" or "existing".', 'primaryContactType'));
                System.debug('║ ❌ Validation Error: Invalid Primary Contact Type: ' + primaryContactType);
                System.debug('╚════════════════════════════════════════════════════════════════════════════════');
                return response;
            }
            
            // Business Address fields
            applicant.Business_Street_Line_1__c = (String) payload.get('businessStreetLine1');
            applicant.Business_Street_Line_2__c = (String) payload.get('businessStreetLine2');
            applicant.Business_City__c = (String) payload.get('businessCity');
            applicant.Business_State__c = (String) payload.get('businessState');
            applicant.Business_Postal_Code__c = (String) payload.get('businessPostalCode');
            // Business Country: Normalize to match restricted picklist values (USA, CAN, MEX)
            String businessCountry = (String) payload.get('businessCountry');
            applicant.Business_Country__c = normalizeBusinessCountry(businessCountry);
            
            // Financial & Operational fields
            Object annualRevObj = payload.get('annualRevenue');
            if (annualRevObj != null) {
                applicant.Annual_Revenue__c = Decimal.valueOf(String.valueOf(annualRevObj));
            }
            applicant.Number_of_Employees__c = (String) payload.get('numberOfEmployees');
            
            // Upsert Applicant with CRUD/FLS checks
            System.debug('╔════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ ABOUT TO UPSERT APPLICANT (Business)');
            System.debug('╠════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ Applicant.Id: ' + applicant.Id);
            System.debug('║ Applicant.ApplicationFormId: ' + applicant.ApplicationFormId);
            System.debug('║ Applicant.Type: ' + applicant.Type);
            System.debug('║ Applicant.BusinessEntityName: ' + applicant.BusinessEntityName);
            System.debug('║ Applicant.AccountId: ' + applicant.AccountId);
            System.debug('║ Full Applicant: ' + JSON.serializePretty(applicant));
            System.debug('╚════════════════════════════════════════════════════════════════════════════════');
            
            upsert as user applicant;
            
            System.debug('╔════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ ✅ SUCCESS: Upserted Applicant (Business)');
            System.debug('╠════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ Applicant.Id: ' + applicant.Id);
            System.debug('║ Operation: ' + (existingApplicants.isEmpty() ? 'INSERT' : 'UPDATE'));
            System.debug('╚════════════════════════════════════════════════════════════════════════════════');
            
            response.savedIds.put('applicant', applicant.Id);
            response.savedIds.put('applicationForm', applicationId);
            System.debug('📦 Response savedIds: ' + response.savedIds);
            
            // Update ApplicationForm with Account linkage ONLY if existing Business Account selected
            if (businessAccountType == 'existing' && String.isNotBlank(selectedAccountId)) {
                System.debug('🔗 Linking ApplicationForm to Account: ' + selectedAccountId);
                ApplicationForm appForm = [SELECT Id FROM ApplicationForm WHERE Id = :applicationId WITH USER_MODE LIMIT 1];
                appForm.AccountId = selectedAccountId;
                System.debug('🔗 About to update ApplicationForm: ' + appForm);
                update as user appForm;
                System.debug('✅ SUCCESS: Updated ApplicationForm.AccountId');
                response.savedIds.put('linkedAccount', selectedAccountId);
            }
            
            System.debug('╔════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ upsertBusinessStep END (Success)');
            System.debug('║ Applicant ID: ' + applicant.Id);
            System.debug('╚════════════════════════════════════════════════════════════════════════════════');
            return response;
        } catch (Exception e) {
            System.debug('╔════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ ❌ ERROR in upsertBusinessStep');
            System.debug('╠════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ Error Message: ' + e.getMessage());
            System.debug('║ Exception Type: ' + e.getTypeName());
            System.debug('║ Line Number: ' + e.getLineNumber());
            System.debug('║ Stack Trace:');
            System.debug(e.getStackTraceString());
            System.debug('╚════════════════════════════════════════════════════════════════════════════════');
            response.success = false;
            response.messages.add(new ErrorMessage(
                'PERSISTENCE_ERROR',
                'Error saving business details: ' + e.getMessage(),
                null
            ));
        }
        
        System.debug('╔════════════════════════════════════════════════════════════════════════════════');
        System.debug('║ upsertBusinessStep FINAL RETURN');
        System.debug('║ Success: ' + response.success);
        System.debug('║ Messages: ' + response.messages.size());
        System.debug('║ SavedIds: ' + response.savedIds);
        System.debug('╚════════════════════════════════════════════════════════════════════════════════');
        return response;
    }
    
    private static PersistenceResponse upsertAdditionalStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        System.debug('--- upsertAdditionalStep START ---');
        System.debug('ApplicationId: ' + applicationId);
        System.debug('Payload: ' + JSON.serializePretty(payload));
        
        try {
            // Extract applicants array from payload
            List<Object> applicantsPayload = (List<Object>) payload.get('applicants');
            
            if (applicantsPayload == null || applicantsPayload.isEmpty()) {
                System.debug('No additional applicants in payload. Returning success.');
        response.savedIds.put('applicationForm', applicationId);
                return response;
            }
            
            System.debug('Processing ' + applicantsPayload.size() + ' additional applicants');
            
            // Query existing additional applicants for this ApplicationForm (Type != 'Individual' or Role != 'Primary Applicant')
            Map<String, Applicant> existingApplicantsMap = new Map<String, Applicant>();
            List<Applicant> existingApplicants = [
                SELECT Id, ApplicationFormId, FirstName, LastName, MiddleName, Email, 
                       Is_US_Citizen__c, Is_US_Resident__c
                FROM Applicant
                WHERE ApplicationFormId = :applicationId
                AND (Type != 'Individual' OR Role__c != 'Primary Applicant')
                WITH USER_MODE
            ];
            
            // Map existing applicants by email (as unique identifier)
            for (Applicant existing : existingApplicants) {
                if (String.isNotBlank(existing.Email)) {
                    existingApplicantsMap.put(existing.Email.toLowerCase(), existing);
                }
            }
            
            List<Applicant> applicantsToUpsert = new List<Applicant>();
            List<Id> applicantIds = new List<Id>();
            
            // Process each applicant in the payload
            for (Object applicantObj : applicantsPayload) {
                // Convert Map<ANY,ANY> to Map<String,Object> safely
                // JSON deserialization sometimes returns Map<ANY,ANY> instead of Map<String,Object>
                Map<String, Object> applicantPayload = new Map<String, Object>();
                Map<Object, Object> rawMap = (Map<Object, Object>) applicantObj;
                for (Object key : rawMap.keySet()) {
                    applicantPayload.put(String.valueOf(key), rawMap.get(key));
                }
                
                // Determine if this is an update or insert based on email
                String email = (String) applicantPayload.get('email');
                Applicant applicant;
                
                if (String.isNotBlank(email) && existingApplicantsMap.containsKey(email.toLowerCase())) {
                    applicant = existingApplicantsMap.get(email.toLowerCase());
                    System.debug('Found existing Applicant with email: ' + email);
                } else {
                    applicant = new Applicant();
                    applicant.ApplicationFormId = applicationId;
                    applicant.Type = 'Individual'; // Set Type so they appear in relationship assignment
                    applicant.Role__c = 'Additional Applicant'; // Set role for additional applicants
                    System.debug('Creating new Applicant for email: ' + email);
                }
                
                // Personal Identity fields
                applicant.Salutation = (String) applicantPayload.get('salutation');
                applicant.FirstName = (String) applicantPayload.get('firstName');
                applicant.MiddleName = (String) applicantPayload.get('middleName');
                applicant.LastName = (String) applicantPayload.get('lastName');
                applicant.Suffix = (String) applicantPayload.get('suffix');
                applicant.Nickname__c = (String) applicantPayload.get('nickname');
                
                // Date of Birth
                String dobStr = (String) applicantPayload.get('dateOfBirth');
                if (String.isNotBlank(dobStr)) {
                    try {
                        applicant.BirthDate = Date.valueOf(dobStr);
                    } catch (Exception e) {
                        System.debug('Error parsing dateOfBirth: ' + e.getMessage());
                    }
                }
                
                applicant.Mothers_Maiden_Name__c = (String) applicantPayload.get('mothersMaidenName');
                
                // Tax ID
                applicant.Tax_ID__c = (String) applicantPayload.get('taxId');
                applicant.Tax_ID_Type__c = (String) applicantPayload.get('taxIdType');
                
                // Citizenship Status - same Boolean conversion logic as primary applicant
                Boolean isUSCitizenSet = false;
                Object usCitizenObj = applicantPayload.get('isUSCitizen');
                if (usCitizenObj != null) {
                    if (usCitizenObj instanceof Boolean) {
                        applicant.Is_US_Citizen__c = (Boolean) usCitizenObj;
                        isUSCitizenSet = true;
                    } else if (usCitizenObj instanceof String) {
                        String usCitizenStr = (String) usCitizenObj;
                        if (String.isNotBlank(usCitizenStr)) {
                            applicant.Is_US_Citizen__c = 'Yes'.equalsIgnoreCase(usCitizenStr.trim());
                            isUSCitizenSet = true;
                        }
                    }
                }
                if (!isUSCitizenSet && applicant.Id == null) {
                    applicant.Is_US_Citizen__c = false;
                }
                
                Boolean isUSResidentSet = false;
                Object usResidentObj = applicantPayload.get('isUSResident');
                if (usResidentObj != null) {
                    if (usResidentObj instanceof Boolean) {
                        applicant.Is_US_Resident__c = (Boolean) usResidentObj;
                        isUSResidentSet = true;
                    } else if (usResidentObj instanceof String) {
                        String usResidentStr = (String) usResidentObj;
                        if (String.isNotBlank(usResidentStr)) {
                            applicant.Is_US_Resident__c = 'Yes'.equalsIgnoreCase(usResidentStr.trim());
                            isUSResidentSet = true;
                        }
                    }
                }
                if (!isUSResidentSet && applicant.Id == null) {
                    applicant.Is_US_Resident__c = false;
                }
                
                applicant.Country_Of_Residence__c = (String) applicantPayload.get('countryOfResidence');
                
                // Employment
                applicant.Employer__c = (String) applicantPayload.get('employer');
                applicant.Occupation__c = (String) applicantPayload.get('occupation');
                
                // Organization Roles
                applicant.Organization_Role__c = (String) applicantPayload.get('organizationRole');
                
                // Is Control Person: Picklist value (Yes/No)
                applicant.Is_Control_Person__c = (String) applicantPayload.get('isControlPerson');
                
                // Ownership Percentage: Same conversion logic as primary
                Object ownershipObj = applicantPayload.get('ownershipPercentage');
                if (ownershipObj != null) {
                    Decimal ownershipPercentage;
                    if (ownershipObj instanceof String) {
                        String ownershipStr = (String) ownershipObj;
                        if (String.isNotBlank(ownershipStr)) {
                            ownershipPercentage = Decimal.valueOf(ownershipStr);
                        } else {
                            ownershipPercentage = null;
                        }
                    } else if (ownershipObj instanceof Integer) {
                        ownershipPercentage = Decimal.valueOf((Integer) ownershipObj);
                    } else if (ownershipObj instanceof Long) {
                        ownershipPercentage = Decimal.valueOf((Long) ownershipObj);
                    } else if (ownershipObj instanceof Decimal) {
                        ownershipPercentage = (Decimal) ownershipObj;
                    } else {
                        ownershipPercentage = null;
                    }
                    
                    if (ownershipPercentage != null && ownershipPercentage > 1) {
                        ownershipPercentage = ownershipPercentage / 100;
                    }
                    applicant.Ownership_Percentage__c = ownershipPercentage;
                }
                
                // Roles (Multi-select picklist): Handle both String and List<Object>
                Object rolesObj = applicantPayload.get('roles');
                if (rolesObj != null) {
                    if (rolesObj instanceof String) {
                        applicant.Roles__c = (String) rolesObj;
                    } else if (rolesObj instanceof List<Object>) {
                        List<String> rolesList = new List<String>();
                        for (Object roleItem : (List<Object>) rolesObj) {
                            rolesList.add(String.valueOf(roleItem));
                        }
                        applicant.Roles__c = String.join(rolesList, ';');
                    }
                }
                
                // Government ID
                String idIssuingCountry = (String) applicantPayload.get('idIssuingCountry');
                applicant.ID_Issuing_Country__c = normalizeMailingCountry(idIssuingCountry);
                applicant.ID_Issuing_State__c = (String) applicantPayload.get('idIssuingState');
                
                // ID Dates
                String idIssueDateStr = (String) applicantPayload.get('idIssueDate');
                if (String.isNotBlank(idIssueDateStr)) {
                    try {
                        applicant.ID_Issue_Date__c = Date.valueOf(idIssueDateStr);
                    } catch (Exception e) {
                        System.debug('Error parsing idIssueDate: ' + e.getMessage());
                    }
                }
                
                String idExpirationDateStr = (String) applicantPayload.get('idExpirationDate');
                if (String.isNotBlank(idExpirationDateStr)) {
                    try {
                        applicant.ID_Expiration_Date__c = Date.valueOf(idExpirationDateStr);
                    } catch (Exception e) {
                        System.debug('Error parsing idExpirationDate: ' + e.getMessage());
                    }
                }
                
                // Mailing Address
                applicant.Mailing_Street_Line_1__c = (String) applicantPayload.get('mailingStreetLine1');
                applicant.Mailing_Street_Line_2__c = (String) applicantPayload.get('mailingStreetLine2');
                applicant.Mailing_City__c = (String) applicantPayload.get('mailingCity');
                applicant.Mailing_State__c = (String) applicantPayload.get('mailingState');
                applicant.Mailing_Postal_Code__c = (String) applicantPayload.get('mailingPostalCode');
                
                String mailingCountry = (String) applicantPayload.get('mailingCountry');
                applicant.Mailing_Country__c = normalizeMailingCountry(mailingCountry);
                
                // Contact Information
                applicant.Email = (String) applicantPayload.get('email');
                applicant.Home_Phone__c = (String) applicantPayload.get('homePhone');
                applicant.Work_Phone__c = (String) applicantPayload.get('workPhone');
                applicant.Mobile_Phone__c = (String) applicantPayload.get('mobilePhone');
                // Note: Preferred_Contact_Method__c field doesn't exist on Applicant object
                
                applicantsToUpsert.add(applicant);
            }
            
            // Upsert all applicants
            if (!applicantsToUpsert.isEmpty()) {
                System.debug('Upserting ' + applicantsToUpsert.size() + ' additional applicants');
                upsert applicantsToUpsert;
                
                // Collect applicant IDs
                for (Applicant app : applicantsToUpsert) {
                    applicantIds.add(app.Id);
                }
                
                response.savedIds.put('applicants', String.join(applicantIds, ','));
                System.debug('Upserted additional applicants with IDs: ' + applicantIds);
            }
            
            // Now process Identity Documents for each applicant
            for (Integer i = 0; i < applicantsPayload.size(); i++) {
                // Safely convert Map<ANY,ANY> to Map<String, Object>
                Map<String, Object> applicantPayload;
                try {
                    // Try direct cast first
                    applicantPayload = (Map<String, Object>) applicantsPayload[i];
                } catch (TypeException e) {
                    // If direct cast fails, manually convert
                    applicantPayload = new Map<String, Object>();
                    Map<Object, Object> rawMap = (Map<Object, Object>) applicantsPayload[i];
                    for (Object key : rawMap.keySet()) {
                        applicantPayload.put(String.valueOf(key), rawMap.get(key));
                    }
                }
                
                Applicant applicant = applicantsToUpsert[i];
                
                List<Object> identityDocumentsPayload = (List<Object>) applicantPayload.get('identityDocuments');
                if (identityDocumentsPayload != null && !identityDocumentsPayload.isEmpty()) {
                    processIdentityDocuments(applicant.Id, applicationId, identityDocumentsPayload);
                }
            }
            
            response.savedIds.put('applicationForm', applicationId);
            
        } catch (Exception e) {
            System.debug('ERROR in upsertAdditionalStep: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            response.success = false;
            response.messages.add(new ErrorMessage('ADDITIONAL_APPLICANTS_ERROR', 'Failed to save additional applicants: ' + e.getMessage(), null));
        }
        
        System.debug('--- upsertAdditionalStep END ---');
        return response;
    }
    
    // Helper method to process identity documents (reused from upsertApplicantStep)
    private static void processIdentityDocuments(Id applicantId, Id applicationId, List<Object> identityDocumentsPayload) {
        System.debug('Processing ' + identityDocumentsPayload.size() + ' identity documents for Applicant: ' + applicantId);
        
        // Get AccountId from ApplicationForm for RelatedLegalEntityId field
        Id accountId = null;
        try {
            ApplicationForm appForm = [
                SELECT AccountId 
                FROM ApplicationForm 
                WHERE Id = :applicationId 
                WITH USER_MODE 
                LIMIT 1
            ];
            accountId = appForm.AccountId;
            System.debug('Retrieved AccountId from ApplicationForm: ' + accountId);
        } catch (Exception appFormEx) {
            System.debug('Error querying ApplicationForm for AccountId: ' + appFormEx.getMessage());
        }
        
        // Query existing identity documents for this applicant
        List<IdentityDocument> existingDocs = [
            SELECT Id, Name, IdDocumentType, IssuingAuthority, Issuing_Authority_State__c, 
                   IssueDate, ExpirationDate, Applicant__c, RelatedLegalEntityId
            FROM IdentityDocument
            WHERE Applicant__c = :applicantId
            WITH USER_MODE
        ];
        
        Map<String, IdentityDocument> existingDocsMap = new Map<String, IdentityDocument>();
        for (IdentityDocument existingDoc : existingDocs) {
            existingDocsMap.put(existingDoc.Name, existingDoc);
        }
        
        List<IdentityDocument> docsToUpsert = new List<IdentityDocument>();
        
        for (Object docObj : identityDocumentsPayload) {
            Map<String, Object> docMap;
            
            if (docObj instanceof Map<Object, Object>) {
                docMap = new Map<String, Object>();
                for (Object key : ((Map<Object, Object>) docObj).keySet()) {
                    docMap.put(String.valueOf(key), ((Map<Object, Object>) docObj).get(key));
                }
            } else {
                docMap = (Map<String, Object>) docObj;
            }
            
            String idNumber = (String) docMap.get('idNumber');
            if (String.isBlank(idNumber)) {
                continue;
            }
            
            IdentityDocument doc;
            if (existingDocsMap.containsKey(idNumber)) {
                doc = existingDocsMap.get(idNumber);
                if (doc.Applicant__c == null && applicantId != null) {
                    doc.Applicant__c = applicantId;
                }
                if (doc.RelatedLegalEntityId == null && accountId != null) {
                    doc.RelatedLegalEntityId = accountId;
                }
            } else {
                doc = new IdentityDocument();
                doc.Name = idNumber;
                doc.Applicant__c = applicantId;
                if (accountId != null) {
                    doc.RelatedLegalEntityId = accountId;
                }
            }
            
            doc.IdDocumentType = (String) docMap.get('idType');
            String issuingAuthorityFull = (String) docMap.get('issuingAuthority');
            
            if (String.isNotBlank(issuingAuthorityFull)) {
                String[] parts = issuingAuthorityFull.split(',');
                if (parts.size() > 0) {
                    String state = parts[0].trim();
                    doc.Issuing_Authority_State__c = state;
                }
                if (parts.size() > 1) {
                    String country = parts[1].trim();
                    doc.IssuingAuthority = country;
                }
            }
            
            String issueDateStr = (String) docMap.get('issueDate');
            if (String.isNotBlank(issueDateStr)) {
                try {
                    doc.IssueDate = Date.valueOf(issueDateStr);
                } catch (Exception e) {
                    System.debug('Error parsing issueDate: ' + e.getMessage());
                }
            }
            
            String expirationDateStr = (String) docMap.get('expirationDate');
            if (String.isNotBlank(expirationDateStr)) {
                try {
                    doc.ExpirationDate = Date.valueOf(expirationDateStr);
                } catch (Exception e) {
                    System.debug('Error parsing expirationDate: ' + e.getMessage());
                }
            }
            
            docsToUpsert.add(doc);
        }
        
        if (!docsToUpsert.isEmpty()) {
            System.debug('Upserting ' + docsToUpsert.size() + ' identity documents');
            upsert docsToUpsert;
        }
    }
    
    private static PersistenceResponse upsertServicesStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        // Simulate successful persistence for services step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Services step payload: ' + JSON.serialize(payload));
        
        return response;
    }
    
    private static PersistenceResponse upsertDocumentsStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        System.debug('╔════════════════════════════════════════════════════════════════════════════════');
        System.debug('║ upsertDocumentsStep START');
        System.debug('╠════════════════════════════════════════════════════════════════════════════════');
        System.debug('║ ApplicationForm ID: ' + applicationId);
        System.debug('║ ApplicationForm ID Type: ' + (applicationId != null ? String.valueOf(applicationId).length() + ' chars' : 'null'));
        System.debug('║ Payload: ' + JSON.serializePretty(payload));
        System.debug('╚════════════════════════════════════════════════════════════════════════════════');
        
        // Validate applicationId
        if (applicationId == null) {
            System.debug('ERROR: ApplicationForm ID is null. Cannot link documents without an ApplicationForm.');
            response.success = false;
            response.messages.add(new ErrorMessage('DOCUMENTS_ERROR', 'ApplicationForm must be created before uploading documents.', null));
            return response;
        }
        
        // Additional validation: Check if it's a valid Salesforce ID
        String appIdStr = String.valueOf(applicationId);
        if (appIdStr.length() != 15 && appIdStr.length() != 18) {
            System.debug('ERROR: Invalid ApplicationForm ID format: ' + appIdStr);
            response.success = false;
            response.messages.add(new ErrorMessage('DOCUMENTS_ERROR', 'Invalid ApplicationForm ID: ' + appIdStr + '. Please ensure the application is saved before uploading documents.', null));
            return response;
        }
        
        try {
            // Extract documents array from payload
            List<Object> documentsPayload = (List<Object>) payload.get('documents');
            
            if (documentsPayload == null || documentsPayload.isEmpty()) {
                System.debug('No documents in payload. Skipping document processing.');
                response.savedIds.put('applicationForm', applicationId);
                return response;
            }
            
            System.debug('Processing ' + documentsPayload.size() + ' documents');
            
            // Collect ContentDocumentIds to link
            Set<Id> contentDocumentIds = new Set<Id>();
            Map<Id, Map<String, Object>> documentMetadata = new Map<Id, Map<String, Object>>();
            
            for (Object docObj : documentsPayload) {
                Map<String, Object> docMap;
                
                if (docObj instanceof Map<Object, Object>) {
                    docMap = new Map<String, Object>();
                    for (Object key : ((Map<Object, Object>) docObj).keySet()) {
                        docMap.put(String.valueOf(key), ((Map<Object, Object>) docObj).get(key));
                    }
                } else {
                    docMap = (Map<String, Object>) docObj;
                }
                
                String contentDocIdStr = (String) docMap.get('contentDocumentId');
                if (String.isNotBlank(contentDocIdStr)) {
                    // Validate that it's a real Salesforce ID (exactly 15 or 18 chars)
                    // Skip temporary IDs from LWC (like "1", "123456789", etc.)
                    if ((contentDocIdStr.length() == 15 || contentDocIdStr.length() == 18) && isValidSalesforceId(contentDocIdStr)) {
                        try {
                            Id contentDocId = Id.valueOf(contentDocIdStr);
                            contentDocumentIds.add(contentDocId);
                            documentMetadata.put(contentDocId, docMap);
                            System.debug('Found ContentDocument: ' + contentDocId + ' | Name: ' + docMap.get('name'));
                        } catch (Exception e) {
                            System.debug('WARNING: Skipping invalid ContentDocument ID: ' + contentDocIdStr + ' | Error: ' + e.getMessage());
                        }
                    } else {
                        System.debug('INFO: Skipping temporary/invalid ContentDocument ID: ' + contentDocIdStr + ' (not a valid Salesforce ID format)');
                    }
                }
            }
            
            if (contentDocumentIds.isEmpty()) {
                System.debug('No ContentDocumentIds found in payload. Documents may not have been uploaded yet.');
                response.savedIds.put('applicationForm', applicationId);
                return response;
            }
            
            System.debug('Found ' + contentDocumentIds.size() + ' ContentDocuments to link');
            
            // Query existing ContentDocumentLinks to avoid duplicates
            List<ContentDocumentLink> existingLinks = [
                SELECT Id, ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :contentDocumentIds
                  AND LinkedEntityId = :applicationId
                WITH USER_MODE
            ];
            
            Set<Id> alreadyLinkedDocIds = new Set<Id>();
            for (ContentDocumentLink link : existingLinks) {
                alreadyLinkedDocIds.add(link.ContentDocumentId);
            }
            
            System.debug('Already linked documents: ' + alreadyLinkedDocIds.size());
            
            // Create ContentDocumentLinks for documents not yet linked to ApplicationForm
            List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
            
            for (Id contentDocId : contentDocumentIds) {
                if (!alreadyLinkedDocIds.contains(contentDocId)) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = contentDocId;
                    cdl.LinkedEntityId = applicationId;
                    cdl.ShareType = 'V'; // Viewer permission
                    cdl.Visibility = 'AllUsers'; // Visible to all users with access to the record
                    linksToInsert.add(cdl);
                    
                    Map<String, Object> metadata = documentMetadata.get(contentDocId);
                    System.debug('Creating link for: ' + contentDocId + ' | Name: ' + metadata.get('name') + ' | Type: ' + metadata.get('type'));
                }
            }
            
            if (!linksToInsert.isEmpty()) {
                System.debug('Inserting ' + linksToInsert.size() + ' ContentDocumentLinks');
                insert as user linksToInsert;
                System.debug('✅ SUCCESS: Inserted ' + linksToInsert.size() + ' ContentDocumentLinks');
                
                // Add linked document IDs to response
                List<String> linkedDocIds = new List<String>();
                for (ContentDocumentLink link : linksToInsert) {
                    linkedDocIds.add(link.ContentDocumentId);
                }
                response.savedIds.put('linkedDocuments', String.join(linkedDocIds, ','));
            } else {
                System.debug('All documents already linked to ApplicationForm');
            }
            
            response.savedIds.put('applicationForm', applicationId);
            response.savedIds.put('documentCount', String.valueOf(contentDocumentIds.size()));
            
            System.debug('╔════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ ✅ upsertDocumentsStep END (Success)');
            System.debug('║ Linked ' + linksToInsert.size() + ' documents to ApplicationForm');
            System.debug('╚════════════════════════════════════════════════════════════════════════════════');
            
        } catch (Exception e) {
            System.debug('╔════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ ❌ ERROR in upsertDocumentsStep');
            System.debug('╠════════════════════════════════════════════════════════════════════════════════');
            System.debug('║ Exception Type: ' + e.getTypeName());
            System.debug('║ Message: ' + e.getMessage());
            System.debug('║ Line: ' + e.getLineNumber());
            System.debug('║ Stack Trace: ' + e.getStackTraceString());
            System.debug('╚════════════════════════════════════════════════════════════════════════════════');
            
            response.success = false;
            response.messages.add(new ErrorMessage('DOCUMENTS_ERROR', 'Failed to link documents: ' + e.getMessage(), null));
        }
        
        return response;
    }
    
    private static PersistenceResponse upsertReviewStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        // Simulate successful persistence for review step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Review step payload: ' + JSON.serialize(payload));
        
        return response;
    }
    
    private static ApplicationForm createApplicationForm(Map<String, Object> payload, Id contextRecordId) {
        ApplicationForm app = new ApplicationForm();
        
        // Set required fields
        app.UsageType = 'Onboarding'; // Required field - set to Onboarding by default
        app.Stage = 'Initiated';
        app.SubmissionDate = System.today();
        
        // Generate unique DAO Application ID
        app.DAOApplicationId__c = 'DAO-' + System.currentTimeMillis();
        
        // StepKey__c will be set in upsertStep method after ApplicationForm is created
        
        // Set context lookups based on the record the wizard was launched from
        if (contextRecordId != null) {
            String objectType = contextRecordId.getSObjectType().getDescribe().getName();
            System.debug('Context record type: ' + objectType);
            
            if (objectType == 'Opportunity') {
                app.OpportunityId = contextRecordId;
                System.debug('Set ApplicationForm.OpportunityId = ' + contextRecordId);
                
                // Also query and set AccountId from the Opportunity
                try {
                    Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :contextRecordId WITH USER_MODE LIMIT 1];
                    if (opp.AccountId != null) {
                        app.AccountId = opp.AccountId;
                        System.debug('Set ApplicationForm.AccountId from Opportunity.AccountId = ' + opp.AccountId);
                    }
                } catch (Exception e) {
                    System.debug('Could not query Opportunity.AccountId: ' + e.getMessage());
                }
            } else if (objectType == 'Account') {
                app.AccountId = contextRecordId;
                System.debug('Set ApplicationForm.AccountId = ' + contextRecordId);
            }
        }
        
        // Map other available fields as needed
        // Note: Name field is auto-generated and not writeable
        
        return app;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getNaicsDetails(Id naicsId) {
        try {
            NAICS__c naics = [SELECT Code__c, Description__c FROM NAICS__c WHERE Id = :naicsId WITH USER_MODE LIMIT 1];
            return new Map<String, String>{
                'code' => naics.Code__c,
                'title' => naics.Description__c
            };
        } catch (Exception e) {
            System.debug('Error fetching NAICS details: ' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Account getAccountDetails(Id accountId) {
        try {
            // Query standard Account fields only - SW_ fields are PersonAccount-only
            // Business-specific fields (DBA, Date Established, Registration State) are stored on Applicant
            Account acc = [
                SELECT Name, Phone, Website,
                       BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                       AnnualRevenue, NumberOfEmployees, Industry, Business_Type__c
                FROM Account 
                WHERE Id = :accountId 
                WITH USER_MODE 
                LIMIT 1
            ];
            return acc;
        } catch (Exception e) {
            System.debug('Error fetching Account details: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Normalizes country names to match restricted picklist values for Mailing_Country__c
     * Valid picklist values: USA, Canada, Mexico, Other
     * @param countryName The country name from the address component (e.g., "United States", "US", etc.)
     * @return The normalized country value that matches the picklist API value
     */
    private static String normalizeMailingCountry(String countryName) {
        if (String.isBlank(countryName)) {
            return null;
        }
        
        String normalized = countryName.trim();
        
        // Map common country name variations to picklist values
        // Mailing_Country__c only accepts: USA, Canada, Mexico, Other
        if (normalized.equalsIgnoreCase('United States') || 
            normalized.equalsIgnoreCase('US') || 
            normalized.equalsIgnoreCase('U.S.') ||
            normalized.equalsIgnoreCase('U.S.A.') ||
            normalized.equalsIgnoreCase('United States of America')) {
            return 'USA';
        }
        
        if (normalized.equalsIgnoreCase('Canada') || 
            normalized.equalsIgnoreCase('CA') ||
            normalized.equalsIgnoreCase('CAN')) {
            return 'Canada';
        }
        
        if (normalized.equalsIgnoreCase('Mexico') || 
            normalized.equalsIgnoreCase('MX') ||
            normalized.equalsIgnoreCase('MEX')) {
            return 'Mexico';
        }
        
        // If it's one of the valid values, return the exact API value
        if (normalized.equalsIgnoreCase('USA')) {
            return 'USA';
        }
        if (normalized.equalsIgnoreCase('Canada')) {
            return 'Canada';
        }
        if (normalized.equalsIgnoreCase('Mexico')) {
            return 'Mexico';
        }
        if (normalized.equalsIgnoreCase('Other')) {
            return 'Other';
        }
        
        // For any other country not in the picklist, default to "Other"
        return 'Other';
    }
    
    /**
     * Normalizes country names to match restricted picklist values for Business_Country__c
     * Valid picklist values: USA, CAN, MEX
     * @param countryName The country name from the address component (e.g., "United States", "US", etc.)
     * @return The normalized country value that matches the picklist API value
     */
    private static String normalizeBusinessCountry(String countryName) {
        if (String.isBlank(countryName)) {
            return null;
        }
        
        String normalized = countryName.trim();
        
        // Map common country name variations to picklist values
        // Business_Country__c only accepts: USA, CAN, MEX
        if (normalized.equalsIgnoreCase('United States') || 
            normalized.equalsIgnoreCase('US') || 
            normalized.equalsIgnoreCase('U.S.') ||
            normalized.equalsIgnoreCase('U.S.A.') ||
            normalized.equalsIgnoreCase('United States of America') ||
            normalized.equalsIgnoreCase('USA')) {
            return 'USA';
        }
        
        if (normalized.equalsIgnoreCase('Canada') || 
            normalized.equalsIgnoreCase('CA') ||
            normalized.equalsIgnoreCase('CAN')) {
            return 'CAN';
        }
        
        if (normalized.equalsIgnoreCase('Mexico') || 
            normalized.equalsIgnoreCase('MX') ||
            normalized.equalsIgnoreCase('MEX')) {
            return 'MEX';
        }
        
        return normalized; // Return as-is if no mapping found
    }
    
    private static PersistenceResponse upsertRelationshipStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        System.debug('--- upsertRelationshipStep START ---');
        System.debug('ApplicationId: ' + applicationId);
        System.debug('Payload: ' + JSON.serializePretty(payload));
        
        try {
            // Extract assignments array from payload
            List<Object> assignmentsObj = (List<Object>) payload.get('assignments');
            
            if (assignmentsObj == null || assignmentsObj.isEmpty()) {
                System.debug('No role assignments in payload, skipping save');
                response.savedIds.put('applicationForm', applicationId);
                return response;
            }
            
            // Get existing role assignments
            Map<String, ApplicationProductPartyRole__c> existingMap = new Map<String, ApplicationProductPartyRole__c>();
            for (ApplicationProductPartyRole__c role : [
                SELECT Id, ApplicationFormProduct__c, Applicant__c, Role__c
                FROM ApplicationProductPartyRole__c
                WHERE ApplicationForm__c = :applicationId
            ]) {
                String key = String.valueOf(role.ApplicationFormProduct__c) + '_' + String.valueOf(role.Applicant__c);
                existingMap.put(key, role);
            }
            
            List<ApplicationProductPartyRole__c> toUpsert = new List<ApplicationProductPartyRole__c>();
            Set<String> keysToKeep = new Set<String>();
            
            // Process each assignment from payload
            for (Object assignmentObj : assignmentsObj) {
                // Convert Map<ANY,ANY> to Map<String,Object> safely
                Map<String, Object> assignmentMap = new Map<String, Object>();
                Map<Object, Object> rawMap = (Map<Object, Object>) assignmentObj;
                for (Object key : rawMap.keySet()) {
                    assignmentMap.put(String.valueOf(key), rawMap.get(key));
                }
                
                Id productId = (Id) assignmentMap.get('productId');
                Id applicantId = (Id) assignmentMap.get('applicantId');
                List<Object> rolesObj = (List<Object>) assignmentMap.get('roles');
                
                if (productId == null || applicantId == null || rolesObj == null || rolesObj.isEmpty()) {
                    continue;
                }
                
                // Convert roles list to semicolon-separated string
                List<String> rolesList = new List<String>();
                for (Object roleObj : rolesObj) {
                    rolesList.add(String.valueOf(roleObj));
                }
                String rolesStr = String.join(rolesList, ';');
                
                String key = String.valueOf(productId) + '_' + String.valueOf(applicantId);
                keysToKeep.add(key);
                
                ApplicationProductPartyRole__c role;
                String recordIdStr = (String) assignmentMap.get('id');
                if (String.isNotBlank(recordIdStr)) {
                    // Update existing by record ID
                    role = new ApplicationProductPartyRole__c(Id = (Id) recordIdStr);
                } else if (existingMap.containsKey(key)) {
                    // Update by product+applicant match
                    role = existingMap.get(key);
                } else {
                    // Create new
                    role = new ApplicationProductPartyRole__c();
                    role.ApplicationForm__c = applicationId;
                    role.ApplicationFormProduct__c = productId;
                    role.Applicant__c = applicantId;
                }
                
                role.Role__c = rolesStr;
                toUpsert.add(role);
            }
            
            // Upsert assignments
            if (!toUpsert.isEmpty()) {
                upsert toUpsert;
                System.debug('Upserted ' + toUpsert.size() + ' ApplicationProductPartyRole records');
            }
            
            // Delete removed assignments
            List<ApplicationProductPartyRole__c> toDelete = new List<ApplicationProductPartyRole__c>();
            for (String key : existingMap.keySet()) {
                if (!keysToKeep.contains(key)) {
                    toDelete.add(existingMap.get(key));
                }
            }
            
            if (!toDelete.isEmpty()) {
                delete toDelete;
                System.debug('Deleted ' + toDelete.size() + ' ApplicationProductPartyRole records');
            }
            
            response.savedIds.put('applicationForm', applicationId);
            System.debug('--- upsertRelationshipStep END (Success) ---');
            return response;
            
        } catch (Exception e) {
            System.debug('ERROR in upsertRelationshipStep: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            response.success = false;
            response.messages.add(new ErrorMessage('RELATIONSHIP_STEP_ERROR', 'Failed to save relationship assignments: ' + e.getMessage(), null));
            System.debug('--- upsertRelationshipStep END (Error) ---');
            return response;
        }
    }
    
}