# Apex: Wizard Config + Validation Services

## WizardConfigService.cls

```apex
public with sharing class WizardConfigService {
    public class WizardStepDTO {
        @AuraEnabled public String developerName;
        @AuraEnabled public String label;
        @AuraEnabled public String componentBundle;
        @AuraEnabled public Boolean skippable;
        @AuraEnabled public String validatorClasses; // semicolon-separated
        @AuraEnabled public Integer order;
    }

    @AuraEnabled(cacheable=true)
    public static List<WizardStepDTO> getSteps(String wizardApiName) {
        if (String.isBlank(wizardApiName)) return new List<WizardStepDTO>();
        List<WizardStepDTO> out = new List<WizardStepDTO>();
        for (Wizard_Step__mdt s : [
            SELECT DeveloperName, StepLabel__c, ComponentBundle__c, Skippable__c, ValidatorClasses__c, Order__c
            FROM Wizard_Step__mdt
            WHERE WizardApiName__c = :wizardApiName
            ORDER BY Order__c ASC
        ]) {
            WizardStepDTO dto = new WizardStepDTO();
            dto.developerName   = s.DeveloperName;
            dto.label           = String.isBlank(s.StepLabel__c) ? s.DeveloperName : s.StepLabel__c;
            dto.componentBundle = s.ComponentBundle__c;
            dto.skippable       = s.Skippable__c;
            dto.validatorClasses= s.ValidatorClasses__c;
            dto.order           = (Integer)s.Order__c;
            out.add(dto);
        }
        return out;
    }
}
```

## WizardValidationService.cls

```apex
public with sharing class WizardValidationService {
    public class ValidationMessage {
        @AuraEnabled public String code;
        @AuraEnabled public String message;
        @AuraEnabled public String fieldApiName;
        public ValidationMessage(String code, String message, String fieldApiName) {
            this.code = code; this.message = message; this.fieldApiName = fieldApiName;
        }
    }
    public class ValidationResponse {
        @AuraEnabled public Boolean isValid = true;
        @AuraEnabled public List<ValidationMessage> messages = new List<ValidationMessage>();
        public void add(String code, String message, String fieldApiName) {
            isValid = false; messages.add(new ValidationMessage(code, message, fieldApiName));
        }
    }

    public interface WizardValidator {
        ValidationResponse validate(Id applicationId, String stepDeveloperName, Map<String,Object> payload);
    }

    @AuraEnabled
    public static ValidationResponse validateStep(Id applicationId, String validatorClasses, String stepDeveloperName, Map<String,Object> payload) {
        ValidationResponse aggregate = new ValidationResponse();
        if (String.isBlank(validatorClasses)) return aggregate;

        for (String className : validatorClasses.split(';')) {
            className = className.trim();
            if (className.isBlank()) continue;

            Type t = Type.forName(className);
            if (t == null) {
                aggregate.add('CONFIG_CLASS_NOT_FOUND', 'Validator class not found: ' + className, null);
                continue;
            }
            Object o = t.newInstance();
            if (!(o instanceof WizardValidator)) {
                aggregate.add('CONFIG_CLASS_WRONG_TYPE', className + ' does not implement WizardValidator.', null);
                continue;
            }
            ValidationResponse r = ((WizardValidator)o).validate(applicationId, stepDeveloperName, payload);
            if (r != null && !r.isValid) {
                aggregate.isValid = false;
                aggregate.messages.addAll(r.messages);
            }
        }
        return aggregate;
    }
}
```

## Example Validator: OfacNameScreeningValidator.cls

```apex
public with sharing class OfacNameScreeningValidator implements WizardValidationService.WizardValidator {
    public WizardValidationService.ValidationResponse validate(Id applicationId, String stepDeveloperName, Map<String,Object> payload) {
        WizardValidationService.ValidationResponse res = new WizardValidationService.ValidationResponse();
        String legalName = (String)payload.get('legalName');
        if (String.isBlank(legalName)) {
            res.add('REQ_LEGAL_NAME', 'Legal Name is required before OFAC screening.', 'legalName');
        }
        // TODO: call MuleSoft or direct Named Credential → FIS Code Connect
        // If match: res.add('OFAC_HIT', 'Potential OFAC match found. Manual review required.', null);
        return res;
    }
}
```
