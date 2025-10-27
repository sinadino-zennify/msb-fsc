public with sharing class WizardPersistenceService {
    
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
        
        // For prototype: if no applicationId provided, use the recordId as a placeholder
        // In production, this would create a proper ApplicationForm record
        if (applicationId == null) {
            System.debug('PROTOTYPE MODE: No application ID provided, using placeholder persistence');
            response.savedIds.put('placeholder', UserInfo.getUserId()); // Use current user ID as placeholder
            System.debug('Step payload persisted (prototype): ' + JSON.serialize(payload));
            return response;
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
            // Route to appropriate step handler based on stepDeveloperName
            if (stepDeveloperName.contains('Applicant')) {
                return upsertApplicantStep(applicationId, payload, response);
            } else if (stepDeveloperName.contains('Product')) {
                return upsertProductStep(applicationId, payload, response);
            } else if (stepDeveloperName.contains('Review')) {
                return upsertReviewStep(applicationId, payload, response);
            } else {
                response.success = false;
                response.messages.add(new ErrorMessage('UNKNOWN_STEP', 'Unknown step: ' + stepDeveloperName, null));
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
    
    private static PersistenceResponse upsertReviewStep(Id applicationId, Map<String, Object> payload, PersistenceResponse response) {
        // Simulate successful persistence for review step
        response.savedIds.put('applicationForm', applicationId);
        
        // Log the payload for debugging
        System.debug('Review step payload: ' + JSON.serialize(payload));
        
        return response;
    }
}
