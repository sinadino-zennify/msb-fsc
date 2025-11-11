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
    public static PersistenceResponse upsertStep(Id applicationId, String stepDeveloperName, Map<String, Object> payload) {
        PersistenceResponse response = new PersistenceResponse();
        
        // If no applicationId provided, create ApplicationForm record regardless of step
        if (applicationId == null) {
            System.debug('No applicationId provided. Creating new ApplicationForm record.');
            try {
                ApplicationForm newApp = createApplicationForm(payload);
                insert newApp;
                response.savedIds.put('applicationForm', newApp.Id);
                System.debug('Created ApplicationForm with ID: ' + newApp.Id);
                // Update applicationId for subsequent processing
                applicationId = newApp.Id;
            } catch (Exception e) {
                response.success = false;
                response.messages.add(new ErrorMessage('CREATE_APP_ERROR', 'Failed to create ApplicationForm: ' + e.getMessage(), null));
                return response;
            }
        }
        
        if (String.isBlank(stepDeveloperName)) {
            response.success = false;
            response.messages.add(new ErrorMessage('MISSING_STEP_NAME', 'Step developer name is required', null));
            return response;
        }
        
        if (payload == null || payload.isEmpty()) {
            response.success = false;
            response.messages.add(new ErrorMessage('MISSING_PAYLOAD', 'Payload is required', null));
            return response;
        }
        
        try {
            // Use a handler map to route to the correct step logic
            IStepHandler handler = stepHandlers.get(stepDeveloperName);

            if (handler != null) {
                return handler.handle(applicationId, payload, response);
            } else {
                response.success = false;
                response.messages.add(new ErrorMessage('UNKNOWN_STEP', 'No handler registered for step: ' + stepDeveloperName, null));
                return response;
            }
        } catch (DmlException e) {
            response.success = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                response.messages.add(new ErrorMessage(
                    'DML_ERROR', 
                    e.getDmlMessage(i), 
                    e.getDmlFieldNames(i).isEmpty() ? null : String.join(e.getDmlFieldNames(i), ',')
                ));
            }
            return response;
        } catch (Exception e) {
            response.success = false;
            response.messages.add(new ErrorMessage('UNEXPECTED_ERROR', e.getMessage(), null));
            return response;
        }
    }
    
    private static PersistenceResponse upsertApplicantStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        // For now, just simulate successful persistence since we don't have the full schema
        // In a real implementation, this would upsert Applicant records with proper CRUD/FLS checks
        
        response.savedIds.put('applicant', applicationId); // Use applicationId as placeholder
        
        // Log the payload for debugging
        System.debug('Applicant step payload: ' + JSON.serialize(payload));
        
        return response;
    }
    
    private static PersistenceResponse upsertProductStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        // Simulate successful persistence for product step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Product step payload: ' + JSON.serialize(payload));
        
        return response;
    }
    
    private static PersistenceResponse upsertBusinessStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        try {
            String businessAccountType = (String) payload.get('businessAccountType');
            String selectedAccountId = (String) payload.get('selectedAccountId');
            String primaryContactType = (String) payload.get('primaryContactType');
            String selectedContactId = (String) payload.get('selectedContactId');
            
            // Create or update Applicant record for Organization
            // Applicant acts as staging area for ALL business data until ApplicationForm is submitted
            Applicant applicant = new Applicant();
            applicant.ApplicationFormId = applicationId;
            applicant.Type = 'Organization';
            
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
            upsert as user applicant;
            
            response.savedIds.put('applicant', applicant.Id);
            response.savedIds.put('applicationForm', applicationId);
            
            // Update ApplicationForm with Account linkage ONLY if existing Business Account selected
            if (businessAccountType == 'existing' && String.isNotBlank(selectedAccountId)) {
                ApplicationForm appForm = [SELECT Id FROM ApplicationForm WHERE Id = :applicationId WITH USER_MODE LIMIT 1];
                appForm.AccountId = selectedAccountId;
                update as user appForm;
                response.savedIds.put('linkedAccount', selectedAccountId);
            }
            
            System.debug('Business step persisted successfully. Applicant ID: ' + applicant.Id);
            
        } catch (Exception e) {
            response.success = false;
            response.messages.add(new ErrorMessage(
                'PERSISTENCE_ERROR',
                'Error saving business details: ' + e.getMessage(),
                null
            ));
            System.debug('Error in upsertBusinessStep: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
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
    
    private static ApplicationForm createApplicationForm(Map<String, Object> payload) {
        ApplicationForm app = new ApplicationForm();
        
        // Set required fields
        app.UsageType = 'Onboarding'; // Required field - set to Onboarding by default
        app.Stage = 'In Progress';
        app.SubmissionDate = System.today();
        
        // Generate unique DAO Application ID
        app.DAOApplicationId__c = 'DAO-' + System.currentTimeMillis();
        
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
                       AnnualRevenue, NumberOfEmployees, Industry
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
