import { LightningElement, api } from 'lwc';

export default class ReviewAndSubmit extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    confirmed = false;

    connectedCallback() {
        if (this.value) {
            this.confirmed = this.value.confirmed || false;
        }
    }

    handleConfirmChange(event) {
        this.confirmed = event.target.checked;
        this.emitPayloadChange();
    }

    emitPayloadChange() {
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: { 
                payload: this.payload,
                isDirty: true
            }
        }));
    }

    get payload() {
        return {
            confirmed: this.confirmed
        };
    }

    @api validate() {
        const messages = [];
        if (!this.confirmed) {
            messages.push('You must confirm the information before proceeding.');
        }
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        this.confirmed = false;
        this.emitPayloadChange();
    }
}
