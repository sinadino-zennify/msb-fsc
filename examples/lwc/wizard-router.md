# LWC: Wizard Step Router (daoWizardStepRouter)

## daoWizardStepRouter.html (excerpt)
```html
<template>
  <template if:true={isApplicantDetails}>
    <c-applicant-details lwc:ref="stepImpl" application-id={applicationId} step-config={stepConfig} onpayloadchange={handlePayloadChange}></c-applicant-details>
  </template>
  <template if:true={isProductSelection}>
    <c-product-selection lwc:ref="stepImpl" application-id={applicationId} step-config={stepConfig} onpayloadchange={handlePayloadChange}></c-product-selection>
  </template>
  <template if:true={isReviewAndSubmit}>
    <c-review-and-submit lwc:ref="stepImpl" application-id={applicationId} step-config={stepConfig} onpayloadchange={handlePayloadChange}></c-review-and-submit>
  </template>
</template>
```

## daoWizardStepRouter.js (excerpt)
```js
import { LightningElement, api } from 'lwc';

export default class DaoWizardStepRouter extends LightningElement {
  @api stepConfig;
  @api applicationId;

  get isApplicantDetails() { return this.stepConfig?.componentBundle === 'applicantDetails'; }
  get isProductSelection() { return this.stepConfig?.componentBundle === 'productSelection'; }
  get isReviewAndSubmit()  { return this.stepConfig?.componentBundle === 'reviewAndSubmit'; }

  @api validate() {
    return this.refs.stepImpl?.validate?.() || { isValid: true, messages: [] };
  }

  handlePayloadChange(e) {
    this.dispatchEvent(new CustomEvent('payloadchange', { detail: e.detail, bubbles: true, composed: true }));
  }
}
```
