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
        
        if (payload == null || payload.isEmpty()) {
            System.debug('ERROR: Payload is null or empty');
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
            Applicant applicant = null;
            List<Applicant> existingApplicants = [
                SELECT Id, ApplicationFormId, Type
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
                System.debug('Creating new Applicant (Individual)');
            }
            
            // Personal Identity fields
            applicant.Salutation = (String) payload.get('salutation');
            applicant.FirstName = (String) payload.get('firstName');
            applicant.MiddleName = (String) payload.get('middleName');
            applicant.LastName = (String) payload.get('lastName');
            applicant.Suffix = (String) payload.get('suffix');
            
            // Birth Date
            String birthDateStr = (String) payload.get('birthDate');
            if (String.isNotBlank(birthDateStr)) {
                applicant.BirthDate = Date.valueOf(birthDateStr);
            } else {
                applicant.BirthDate = null; // Clear the field if not provided
            }
            
            // Tax ID
            applicant.Tax_ID__c = (String) payload.get('taxId');
            applicant.Tax_ID_Type__c = (String) payload.get('taxIdType');
            
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
            applicant.Mailing_Country__c = (String) payload.get('mailingCountry');
            
            // Government ID
            applicant.Government_ID_Type__c = (String) payload.get('governmentIdType');
            applicant.Government_ID_Number__c = (String) payload.get('governmentIdNumber');
            applicant.ID_Issuing_Country__c = (String) payload.get('idIssuingCountry');
            applicant.ID_Issuing_State__c = (String) payload.get('idIssuingState');
            
            // ID Dates
            String idIssueDateStr = (String) payload.get('idIssueDate');
            if (String.isNotBlank(idIssueDateStr)) {
                applicant.ID_Issue_Date__c = Date.valueOf(idIssueDateStr);
            } else {
                applicant.ID_Issue_Date__c = null; // Clear the field if not provided
            }
            
            String idExpirationDateStr = (String) payload.get('idExpirationDate');
            if (String.isNotBlank(idExpirationDateStr)) {
                applicant.ID_Expiration_Date__c = Date.valueOf(idExpirationDateStr);
            } else {
                applicant.ID_Expiration_Date__c = null; // Clear the field if not provided
            }
            
            // Upsert Applicant with CRUD/FLS checks
            System.debug('About to upsert Applicant (Person): ' + applicant);
            upsert as user applicant;
            System.debug('SUCCESS: Upserted Applicant with ID: ' + applicant.Id);
            
            response.savedIds.put('applicant', applicant.Id);
            response.savedIds.put('applicationForm', applicationId);
            System.debug('Response savedIds: ' + response.savedIds);
            
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
            // Simulate successful persistence for product step
            response.savedIds.put('applicationForm', applicationId);
            System.debug('Response savedIds: ' + response.savedIds);
            
            // Log the payload for debugging
            System.debug('Product step payload: ' + JSON.serialize(payload));
            
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
            applicant.BusinessEntityType = (String) payload.get('businessType');
            applicant.Business_Tax_ID__c = (String) payload.get('taxId');
            
            // Parse date string to Date
            String dateEstStr = (String) payload.get('dateEstablished');
            if (String.isNotBlank(dateEstStr)) {
                applicant.Date_Established__c = Date.valueOf(dateEstStr);
            }
            
            applicant.Business_Registration_State__c = (String) payload.get('stateOfIncorporation');
            
            // Industry & Classification fields
            applicant.NAICS_Code__c = (String) payload.get('naicsCodeId'); // Lookup ID
            applicant.Industry_Type__c = (String) payload.get('industryType');
            applicant.Business_Description__c = (String) payload.get('businessDescription');
            
            // Contact Information fields
            applicant.Business_Phone__c = (String) payload.get('businessPhone');
            applicant.Business_Email__c = (String) payload.get('businessEmail');
            applicant.Business_Home_Phone__c = (String) payload.get('businessHomePhone');
            applicant.Business_Mobile_Phone__c = (String) payload.get('businessMobilePhone');
            applicant.Business_Website__c = (String) payload.get('businessWebsite');
            
            // Primary Contact fields - store name/title for NEW contact OR reference to EXISTING PersonAccount
            if (primaryContactType == 'new') {
                // Store name and title for later PersonAccount creation
                applicant.Primary_Contact_Name__c = (String) payload.get('primaryContactName');
                applicant.Primary_Contact_Title__c = (String) payload.get('primaryContactTitle');
                applicant.Primary_Contact_PersonAccount__c = null; // Clear any existing reference
            } else if (primaryContactType == 'existing' && String.isNotBlank(selectedContactId)) {
                // Store reference to existing PersonAccount
                applicant.Primary_Contact_PersonAccount__c = selectedContactId;
                // Clear name/title fields since we're using an existing contact
                applicant.Primary_Contact_Name__c = null;
                applicant.Primary_Contact_Title__c = null;
            }
            
            // Business Address fields
            applicant.Business_Street_Line_1__c = (String) payload.get('businessStreetLine1');
            applicant.Business_Street_Line_2__c = (String) payload.get('businessStreetLine2');
            applicant.Business_City__c = (String) payload.get('businessCity');
            applicant.Business_State__c = (String) payload.get('businessState');
            applicant.Business_Postal_Code__c = (String) payload.get('businessPostalCode');
            applicant.Business_Country__c = (String) payload.get('businessCountry');
            
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
        // Simulate successful persistence for additional applicants step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Additional step payload: ' + JSON.serialize(payload));
        
        return response;
    }
    
    private static PersistenceResponse upsertServicesStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        // Simulate successful persistence for services step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Services step payload: ' + JSON.serialize(payload));
        
        return response;
    }
    
    private static PersistenceResponse upsertDocumentsStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        // Simulate successful persistence for documents step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Documents step payload: ' + JSON.serialize(payload));
        
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
    
}
