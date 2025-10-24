# LWC: Wizard Container (daoWizardContainer)

## daoWizardContainer.html (excerpt)
```html
<template>
  <lightning-card title={title}>
    <lightning-progress-indicator current-step={currentStepDeveloperName} type="base" variant="base">
      <template for:each={steps} for:item="s">
        <lightning-progress-step key={s.developerName} label={s.label} value={s.developerName}></lightning-progress-step>
      </template>
    </lightning-progress-indicator>

    <template if:true={activeStep}>
      <c-dao-wizard-step-router lwc:ref="activeStep" step-config={activeStep} application-id={applicationId} onpayloadchange={handlePayloadChange}></c-dao-wizard-step-router>
    </template>

    <template if:true={errorMessages.length}>
      <c-dao-error-panel messages={errorMessages}></c-dao-error-panel>
    </template>

    <div class="slds-var-p-around_medium slds-grid slds-grid_align-spread">
      <lightning-button label="Previous" onclick={handlePrev} variant="neutral" disabled={isFirst}></lightning-button>
      <div>
        <lightning-button label="Save & Exit" onclick={handleSaveExit} class="slds-m-right_small"></lightning-button>
        <lightning-button label={nextLabel} onclick={handleNext} variant="brand"></lightning-button>
      </div>
    </div>
  </lightning-card>
</template>
```

## daoWizardContainer.js (excerpt)
```js
import { LightningElement, api, wire, track } from 'lwc';
import getSteps from '@salesforce/apex/WizardConfigService.getSteps';
import validateStep from '@salesforce/apex/WizardValidationService.validateStep';

export default class DaoWizardContainer extends LightningElement {
  @api wizardApiName = 'DAO_Business_InBranch';
  @api applicationId;
  @track steps = [];
  @track currentIndex = 0;
  @track payloadByStep = new Map();
  @track errorMessages = [];

  title = 'Deposit Account Opening';

  @wire(getSteps, { wizardApiName: '$wizardApiName' })
  wiredSteps({ data, error }) {
    if (data) this.steps = data;
    if (error) this.errorMessages = [{ message: error.body?.message || 'Failed to load steps.' }];
  }

  get activeStep() { return this.steps[this.currentIndex]; }
  get isFirst() { return this.currentIndex === 0; }
  get isLast() { return this.currentIndex === (this.steps.length - 1); }
  get nextLabel() { return this.isLast ? 'Submit' : 'Next'; }
  get currentStepDeveloperName() { return this.activeStep?.developerName; }

  handlePayloadChange(evt) {
    const devName = this.activeStep.developerName;
    this.payloadByStep.set(devName, evt.detail || {});
  }

  async handlePrev() {
    this.errorMessages = [];
    if (!this.isFirst) this.currentIndex--;
  }

  async handleNext() {
    this.errorMessages = [];

    // client-side validate
    const stepRef = this.refs.activeStep; // lwc:ref
    const clientResult = stepRef?.validate?.();
    if (clientResult && clientResult.isValid === false) {
      this.errorMessages = clientResult.messages || [{ message: 'Please correct the highlighted fields.' }];
      return;
    }

    // server-side validate
    const stepCfg = this.activeStep;
    const payload = this.payloadByStep.get(stepCfg.developerName) || {};
    try {
      const server = await validateStep({
        applicationId: this.applicationId,
        validatorClasses: stepCfg.validatorClasses,
        stepDeveloperName: stepCfg.developerName,
        payload
      });
      if (!server.isValid) {
        this.errorMessages = (server.messages || []).map(m => ({message: m.message, field: m.fieldApiName}));
        return;
      }
    } catch (e) {
      this.errorMessages = [{ message: e?.body?.message || e?.message || 'Server validation failed.' }];
      return;
    }

    // advance or submit
    if (this.isLast) {
      this.dispatchEvent(new CustomEvent('completed', { detail: { payloads: Array.from(this.payloadByStep.entries()) } }));
    } else {
      this.currentIndex++;
    }
  }

  handleSaveExit() {
    this.dispatchEvent(new CustomEvent('saveexit', { detail: { step: this.activeStep?.developerName }}));
  }
}
```

## daoWizardContainer.js-meta.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
  <apiVersion>61.0</apiVersion>
  <isExposed>true</isExposed>
  <targets>
    <target>lightning__RecordPage</target>
    <target>lightning__AppPage</target>
  </targets>
</LightningComponentBundle>
```
