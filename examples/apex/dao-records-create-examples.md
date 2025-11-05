public with sharing class IntakeService {
  public class ApplicantInput {
    @AuraEnabled public Id accountId;         // Person or Business Account
    @AuraEnabled public Id contactId;         // only if classic Contact is used
    @AuraEnabled public String applicantType; // Primary, Co-Applicant, Guarantor
    @AuraEnabled public Boolean createAAR;    // Account↔Account to target business (AAR)
    @AuraEnabled public Boolean createACR;    // Contact↔Account (ACR)
  }
  public class Request {
    @AuraEnabled public String stage;             // e.g., 'In Progress'
    @AuraEnabled public Id targetBusinessId;      // ApplicationForm.AccountId
    @AuraEnabled public List<ApplicantInput> applicants;
  }
  public class Response {
    @AuraEnabled public Id applicationFormId;
    @AuraEnabled public List<Id> applicantIds;
    @AuraEnabled public List<Id> aarIds;
    @AuraEnabled public List<Id> acrIds;
  }

  @AuraEnabled(cacheable=false)
  public static Response createApplication(Request req) {
    if (req == null || req.applicants == null || req.applicants.isEmpty()) {
      throw new AuraHandledException('At least one applicant is required.');
    }

    // Basic error collection for FLS issues
    List<String> flsErrors = new List<String>();

    // CRUD/FLS guards: ApplicationForm
    if (!Schema.sObjectType.ApplicationForm.isCreateable()) {
      throw new AuraHandledException('Insufficient access: cannot create ApplicationForm.');
    }
    Schema.DescribeFieldResult afStageF = ApplicationForm.Stage.getDescribe();
    Schema.DescribeFieldResult afAcctF  = ApplicationForm.AccountId.getDescribe();
    if (req.stage != null && !afStageF.isCreateable()) flsErrors.add('No access to set ApplicationForm.Stage');
    if (req.targetBusinessId != null && !afAcctF.isCreateable()) flsErrors.add('No access to set ApplicationForm.AccountId');
    if (!flsErrors.isEmpty()) throw new AuraHandledException(String.join(flsErrors, ' | '));

    // 1) Create ApplicationForm
    ApplicationForm app = new ApplicationForm();
    if (req.stage != null && afStageF.isCreateable()) app.Stage = req.stage;
    if (req.targetBusinessId != null && afAcctF.isCreateable()) app.AccountId = req.targetBusinessId;
    insert app;

    // Lookup Reciprocal Role (Owner) for AAR
    Id ownerRoleId = [
      SELECT Id FROM FinServ__ReciprocalRole__c WHERE Name = 'Owner' LIMIT 1
    ].Id;

    // CRUD guards: Applicant, AAR, ACR
    if (!Schema.sObjectType.Applicant.isCreateable()) {
      throw new AuraHandledException('Insufficient access: cannot create Applicant.');
    }
    Boolean canCreateAAR = Schema.sObjectType.FinServ__AccountAccountRelation__c.isCreateable();
    Boolean canCreateACR = Schema.sObjectType.AccountContactRelation.isCreateable();

    // FLS for Applicant fields
    Schema.DescribeFieldResult apAppF  = Applicant.ApplicationForm.getDescribe();
    Schema.DescribeFieldResult apAcctF = Applicant.AccountId.getDescribe();
    Schema.DescribeFieldResult apTypeF = Applicant.Applicant_Type__c.getDescribe();

    List<Applicant> apps = new List<Applicant>();
    List<FinServ__AccountAccountRelation__c> aars = new List<FinServ__AccountAccountRelation__c>();
    List<AccountContactRelation> acrs = new List<AccountContactRelation>();

    // 2) Applicants + 3) Relationships
    for (ApplicantInput a : req.applicants) {
      Applicant ap = new Applicant();
      if (apAppF.isCreateable()) ap.ApplicationForm = app.Id;
      if (a.accountId != null && apAcctF.isCreateable()) ap.AccountId = a.accountId;
      if (a.applicantType != null && apTypeF.isCreateable()) ap.Applicant_Type__c = a.applicantType;
      apps.add(ap);

      if (a.createAAR && canCreateAAR && a.accountId != null && req.targetBusinessId != null) {
        aars.add(new FinServ__AccountAccountRelation__c(
          FinServ__Account__c        = a.accountId,
          FinServ__RelatedAccount__c = req.targetBusinessId,
          FinServ__Role__c           = ownerRoleId,
          FinServ__Active__c         = true,
          FinServ__StartDate__c      = Date.today()
        ));
      }
      if (a.createACR && canCreateACR && a.contactId != null && req.targetBusinessId != null) {
        acrs.add(new AccountContactRelation(
          AccountId = req.targetBusinessId,
          ContactId = a.contactId,
          IsActive  = true,
          Roles     = 'Authorized Signer'
        ));
      }
    }

    // DML with error surfacing to the caller (wizard UI)
    try {
      insert apps;
      if (!aars.isEmpty()) insert aars;  // FinServ will manage inverse
      if (!acrs.isEmpty()) insert acrs;
    } catch (DmlException e) {
      throw new AuraHandledException('DML failed: ' + e.getMessage());
    }

    Response r = new Response();
    r.applicationFormId = app.Id;
    r.applicantIds = new List<Id>(); for (Applicant x : apps) r.applicantIds.add(x.Id);
    r.aarIds       = new List<Id>(); for (FinServ__AccountAccountRelation__c x : aars) r.aarIds.add(x.Id);
    r.acrIds       = new List<Id>(); for (AccountContactRelation x : acrs) r.acrIds.add(x.Id);
    return r;
  }
}