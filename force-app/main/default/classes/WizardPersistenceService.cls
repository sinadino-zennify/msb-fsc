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
        // Simulate successful persistence for business step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Business step payload: ' + JSON.serialize(payload));
        
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
}
