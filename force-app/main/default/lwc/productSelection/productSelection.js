import { LightningElement, api } from 'lwc';

export default class ProductSelection extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    productCode;

    connectedCallback() {
        if (this.value) {
            this.productCode = this.value.productCode;
        }
    }

    handleProductChange(event) {
        this.productCode = event.target.value;
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
            productCode: this.productCode
        };
    }

    get productOptions() {
        return [
            { label: 'Business Checking', value: 'BIZ_CHECKING' },
            { label: 'Business Savings', value: 'BIZ_SAVINGS' },
            { label: 'Business Money Market', value: 'BIZ_MM' }
        ];
    }

    @api validate() {
        const messages = [];
        if (!this.productCode) {
            messages.push('Product selection is required.');
        }
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        this.productCode = null;
        this.emitPayloadChange();
    }
}
