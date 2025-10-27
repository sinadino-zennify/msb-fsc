import { LightningElement, api } from 'lwc';

export default class DaoWizardStepRouter extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    get isApplicantDetails() {
        return this.stepConfig?.componentBundle === 'applicantDetails';
    }

    get isBusinessDetails() {
        return this.stepConfig?.componentBundle === 'businessDetails';
    }

    get isProductSelection() {
        return this.stepConfig?.componentBundle === 'productSelection';
    }

    get isReviewAndSubmit() {
        return this.stepConfig?.componentBundle === 'reviewAndSubmit';
    }

    @api validate() {
        const activeStep = this.template.querySelector('[data-step-component]');
        if (activeStep && typeof activeStep.validate === 'function') {
            return activeStep.validate();
        }
        return { isValid: true, messages: [] };
    }

    handlePayloadChange(event) {
        // Pass through payload change events to parent
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: event.detail
        }));
    }
}
