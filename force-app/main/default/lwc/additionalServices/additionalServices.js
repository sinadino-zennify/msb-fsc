import { LightningElement, api, track } from 'lwc';

export default class AdditionalServices extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value = {};

    @track selectedServices = new Set();

    // Dummy additional services data
    serviceOptions = [
        { label: 'Online Banking', value: 'online_banking', description: 'Access your accounts 24/7 online' },
        { label: 'Mobile Banking', value: 'mobile_banking', description: 'Banking on-the-go with our mobile app' },
        { label: 'Bill Pay Service', value: 'bill_pay', description: 'Pay bills directly from your account' },
        { label: 'Wire Transfer Service', value: 'wire_transfer', description: 'Send and receive wire transfers' },
        { label: 'ACH Services', value: 'ach_services', description: 'Automated Clearing House transactions' },
        { label: 'Merchant Services', value: 'merchant_services', description: 'Accept credit card payments' },
        { label: 'Overdraft Protection', value: 'overdraft_protection', description: 'Protect against insufficient funds' },
        { label: 'Remote Deposit Capture', value: 'remote_deposit', description: 'Deposit checks remotely' },
        { label: 'Cash Management', value: 'cash_management', description: 'Advanced cash flow management tools' },
        { label: 'Positive Pay', value: 'positive_pay', description: 'Fraud prevention for checks' },
        { label: 'Account Reconciliation', value: 'account_reconciliation', description: 'Automated account reconciliation' },
        { label: 'Treasury Management', value: 'treasury_management', description: 'Comprehensive treasury solutions' }
    ];

    connectedCallback() {
        // Initialize selected services from existing value
        if (this.value && this.value.selectedServices) {
            this.selectedServices = new Set(this.value.selectedServices);
        }
    }

    handleServiceChange(event) {
        const serviceValue = event.target.value;
        const isChecked = event.target.checked;

        if (isChecked) {
            this.selectedServices.add(serviceValue);
        } else {
            this.selectedServices.delete(serviceValue);
        }

        // Trigger change event
        this.dispatchPayloadChange();
    }

    dispatchPayloadChange() {
        const payload = this.payload;
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: { payload }
        }));
    }

    @api
    get payload() {
        return {
            selectedServices: Array.from(this.selectedServices),
            serviceCount: this.selectedServices.size
        };
    }

    @api
    validate() {
        // This step is optional, so always return true
        return {
            isValid: true,
            errorMessage: null
        };
    }

    get hasSelectedServices() {
        return this.selectedServices.size > 0;
    }

    get selectedServiceCount() {
        return this.selectedServices.size;
    }

    isServiceSelected(serviceValue) {
        return this.selectedServices.has(serviceValue);
    }
}
