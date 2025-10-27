public with sharing class WizardConfigService {
    
    public class WizardStepDTO {
        @AuraEnabled public String developerName { get; set; }
        @AuraEnabled public String wizardApiName { get; set; }
        @AuraEnabled public Integer order { get; set; }
        @AuraEnabled public String componentBundle { get; set; }
        @AuraEnabled public String stepLabel { get; set; }
        @AuraEnabled public String validatorClasses { get; set; }
        @AuraEnabled public Boolean skippable { get; set; }
        @AuraEnabled public String helpText { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<WizardStepDTO> getSteps(String wizardApiName) {
        if (String.isBlank(wizardApiName)) {
            return new List<WizardStepDTO>();
        }
        
        List<WizardStepDTO> steps = new List<WizardStepDTO>();
        
        for (Wizard_Step__mdt step : [
            SELECT DeveloperName, WizardApiName__c, Order__c, ComponentBundle__c, 
                   StepLabel__c, ValidatorClasses__c, Skippable__c, HelpText__c
            FROM Wizard_Step__mdt 
            WHERE WizardApiName__c = :wizardApiName 
            ORDER BY Order__c ASC
        ]) {
            WizardStepDTO dto = new WizardStepDTO();
            dto.developerName = step.DeveloperName;
            dto.wizardApiName = step.WizardApiName__c;
            dto.order = Integer.valueOf(step.Order__c);
            dto.componentBundle = step.ComponentBundle__c;
            dto.stepLabel = String.isNotBlank(step.StepLabel__c) ? step.StepLabel__c : step.DeveloperName;
            dto.validatorClasses = step.ValidatorClasses__c;
            dto.skippable = step.Skippable__c != null ? step.Skippable__c : false;
            dto.helpText = step.HelpText__c;
            steps.add(dto);
        }
        
        return steps;
    }
}
