# Wizard CMDT Examples

## Wizard_Step__mdt Object

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Wizard Step</label>
    <pluralLabel>Wizard Steps</pluralLabel>
    <visibility>Public</visibility>
    <deploymentStatus>Deployed</deploymentStatus>
    <nameField>
        <type>Text</type>
        <label>Master Label</label>
    </nameField>

    <!-- Grouping key so one org can host multiple wizards (e.g., Business vs Consumer) -->
    <fields>
        <fullName>WizardApiName__c</fullName>
        <label>Wizard API Name</label>
        <type>Text</type>
        <length>80</length>
        <required>true</required>
    </fields>

    <fields>
        <fullName>Order__c</fullName>
        <label>Order</label>
        <type>Number</type>
        <precision>3</precision>
        <scale>0</scale>
        <required>true</required>
    </fields>

    <!-- LWC bundle name (e.g., applicantDetails) -->
    <fields>
        <fullName>ComponentBundle__c</fullName>
        <label>LWC Bundle Name</label>
        <type>Text</type>
        <length>80</length>
        <required>true</required>
    </fields>

    <!-- Optional UX label for progress indicator -->
    <fields>
        <fullName>StepLabel__c</fullName>
        <label>Step Label</label>
        <type>Text</type>
        <length>80</length>
    </fields>

    <!-- Optional: Apex validator class to run on Next (semicolon-separated for multiples) -->
    <fields>
        <fullName>ValidatorClasses__c</fullName>
        <label>Validator Apex Class(es)</label>
        <type>Text</type>
        <length>255</length>
    </fields>

    <fields>
        <fullName>Skippable__c</fullName>
        <label>Skippable</label>
        <type>Checkbox</type>
        <defaultValue>false</defaultValue>
    </fields>

    <fields>
        <fullName>HelpText__c</fullName>
        <label>Help Text</label>
        <type>LongTextArea</type>
        <visibleLines>3</visibleLines>
        <length>32768</length>
    </fields>
</CustomObject>
```

## Example Record

Place under `force-app/main/default/customMetadata/`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>10 - Applicant Details</label>
    <protected>false</protected>
    <values><field>WizardApiName__c</field><value><string>DAO_Business_InBranch</string></value></values>
    <values><field>Order__c</field><value><double>10</double></value></values>
    <values><field>ComponentBundle__c</field><value><string>applicantDetails</string></value></values>
    <values><field>StepLabel__c</field><value><string>Applicant</string></value></values>
    <values><field>ValidatorClasses__c</field><value><string>OfacNameScreeningValidator</string></value></values>
</CustomMetadata>
```
