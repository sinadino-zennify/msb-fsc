# LWC: Sample Step (Applicant Details)

## applicantDetails.html (excerpt)
```html
<template>
  <lightning-layout multiple-rows>
    <lightning-layout-item size="12" class="slds-p-bottom_small">
      <lightning-input label="Legal Name" value={legalName} required data-id="legalName" onchange={handleChange}></lightning-input>
    </lightning-layout-item>
    <lightning-layout-item size="6">
      <lightning-input label="SSN / EIN" value={taxId} data-id="taxId"
        pattern="^([0-9]{3}-?[0-9]{2}-?[0-9]{4}|[0-9]{2}-?[0-9]{7})$"
        message-when-pattern-mismatch="Enter a valid SSN or EIN"
        onchange={handleChange}></lightning-input>
    </lightning-layout-item>
    <lightning-layout-item size="6">
      <lightning-input label="Date of Birth (if applicable)" type="date" value={dob} data-id="dob" onchange={handleChange}></lightning-input>
    </lightning-layout-item>
  </lightning-layout>
</template>
```

## applicantDetails.js (excerpt)
```js
import { LightningElement, api, track } from 'lwc';

export default class ApplicantDetails extends LightningElement {
  @api applicationId;
  @api stepConfig;
  @track legalName = '';
  @track taxId = '';
  @track dob = '';

  handleChange = (e) => {
    const id = e.target.dataset.id;
    this[id] = e.target.value;
    this.emitPayload();
  };

  emitPayload() {
    this.dispatchEvent(new CustomEvent('payloadchange', {
      detail: { legalName: this.legalName, taxId: this.taxId, dob: this.dob }
    }));
  }

  @api validate() {
    const inputs = [...this.template.querySelectorAll('lightning-input')];
    const allValid = inputs.reduce((valid, i) => i.reportValidity() && valid, true);
    const messages = [];
    if (!this.legalName) messages.push({ message: 'Legal Name is required.', field: 'legalName' });
    return { isValid: allValid && messages.length === 0, messages };
  }
}
```

## applicantDetails.js-meta.xml (excerpt)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
  <apiVersion>61.0</apiVersion>
  <isExposed>false</isExposed>
</LightningComponentBundle>
```
