import { LightningElement, api, track } from 'lwc';

export default class AdditionalApplicants extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    @track applicants = [];
    @track showModal = false;
    @track editingIndex = -1;
    @track currentApplicant = {};

    connectedCallback() {
        if (this.value && this.value.applicants) {
            this.applicants = [...this.value.applicants];
        }
    }

    // Modal Management
    handleAddApplicant() {
        this.currentApplicant = this.getEmptyApplicant();
        this.editingIndex = -1;
        this.showModal = true;
    }

    handleEditApplicant(event) {
        const index = parseInt(event.currentTarget.dataset.index);
        this.currentApplicant = { ...this.applicants[index] };
        this.editingIndex = index;
        this.showModal = true;
    }

    handleCloseModal() {
        this.showModal = false;
        this.currentApplicant = {};
        this.editingIndex = -1;
    }

    handleSaveApplicant() {
        if (this.validateCurrentApplicant()) {
            if (this.editingIndex >= 0) {
                // Edit existing
                this.applicants[this.editingIndex] = { ...this.currentApplicant };
            } else {
                // Add new
                this.applicants.push({ ...this.currentApplicant });
            }
            this.applicants = [...this.applicants]; // Trigger reactivity
            this.handleCloseModal();
            this.emitPayloadChange();
        }
    }

    handleDeleteApplicant(event) {
        const index = parseInt(event.currentTarget.dataset.index);
        this.applicants.splice(index, 1);
        this.applicants = [...this.applicants]; // Trigger reactivity
        this.emitPayloadChange();
    }

    // Form Field Handlers
    handleFirstNameChange(event) {
        this.currentApplicant.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.currentApplicant.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.currentApplicant.email = event.target.value;
    }

    handlePhoneChange(event) {
        this.currentApplicant.phone = event.target.value;
    }

    handleDateOfBirthChange(event) {
        this.currentApplicant.dateOfBirth = event.target.value;
    }

    handleSsnChange(event) {
        this.currentApplicant.ssn = event.target.value;
    }

    handleRoleChange(event) {
        this.currentApplicant.role = event.target.value;
    }

    handleOwnershipPercentageChange(event) {
        this.currentApplicant.ownershipPercentage = event.target.value;
    }

    handleMailingStreetChange(event) {
        this.currentApplicant.mailingStreet = event.target.value;
    }

    handleMailingCityChange(event) {
        this.currentApplicant.mailingCity = event.target.value;
    }

    handleMailingStateChange(event) {
        this.currentApplicant.mailingState = event.target.value;
    }

    handleMailingPostalCodeChange(event) {
        this.currentApplicant.mailingPostalCode = event.target.value;
    }

    // Utility Methods
    getEmptyApplicant() {
        return {
            firstName: '',
            lastName: '',
            email: '',
            phone: '',
            dateOfBirth: '',
            ssn: '',
            role: '',
            ownershipPercentage: '',
            mailingStreet: '',
            mailingCity: '',
            mailingState: '',
            mailingPostalCode: ''
        };
    }

    validateCurrentApplicant() {
        const required = ['firstName', 'lastName', 'email', 'phone', 'role'];
        for (let field of required) {
            if (!this.currentApplicant[field]) {
                // Show toast or validation message
                return false;
            }
        }
        return true;
    }

    emitPayloadChange() {
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: { 
                payload: this.payload,
                isDirty: true
            }
        }));
    }

    // Getters
    get payload() {
        return {
            applicants: this.applicants
        };
    }

    get hasApplicants() {
        return this.applicants && this.applicants.length > 0;
    }

    get modalTitle() {
        return this.editingIndex >= 0 ? 'Edit Additional Applicant' : 'Add Additional Applicant';
    }

    get saveButtonLabel() {
        return this.editingIndex >= 0 ? 'Update' : 'Add Applicant';
    }

    get roleOptions() {
        return [
            { label: 'Beneficial Owner', value: 'Beneficial Owner' },
            { label: 'Authorized Signer', value: 'Authorized Signer' },
            { label: 'Co-Owner', value: 'Co-Owner' },
            { label: 'Guarantor', value: 'Guarantor' },
            { label: 'Power of Attorney', value: 'Power of Attorney' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get stateOptions() {
        return [
            { label: 'Alabama', value: 'AL' },
            { label: 'Alaska', value: 'AK' },
            { label: 'Arizona', value: 'AZ' },
            { label: 'Arkansas', value: 'AR' },
            { label: 'California', value: 'CA' },
            { label: 'Colorado', value: 'CO' },
            { label: 'Connecticut', value: 'CT' },
            { label: 'Delaware', value: 'DE' },
            { label: 'Florida', value: 'FL' },
            { label: 'Georgia', value: 'GA' },
            { label: 'Hawaii', value: 'HI' },
            { label: 'Idaho', value: 'ID' },
            { label: 'Illinois', value: 'IL' },
            { label: 'Indiana', value: 'IN' },
            { label: 'Iowa', value: 'IA' },
            { label: 'Kansas', value: 'KS' },
            { label: 'Kentucky', value: 'KY' },
            { label: 'Louisiana', value: 'LA' },
            { label: 'Maine', value: 'ME' },
            { label: 'Maryland', value: 'MD' },
            { label: 'Massachusetts', value: 'MA' },
            { label: 'Michigan', value: 'MI' },
            { label: 'Minnesota', value: 'MN' },
            { label: 'Mississippi', value: 'MS' },
            { label: 'Missouri', value: 'MO' },
            { label: 'Montana', value: 'MT' },
            { label: 'Nebraska', value: 'NE' },
            { label: 'Nevada', value: 'NV' },
            { label: 'New Hampshire', value: 'NH' },
            { label: 'New Jersey', value: 'NJ' },
            { label: 'New Mexico', value: 'NM' },
            { label: 'New York', value: 'NY' },
            { label: 'North Carolina', value: 'NC' },
            { label: 'North Dakota', value: 'ND' },
            { label: 'Ohio', value: 'OH' },
            { label: 'Oklahoma', value: 'OK' },
            { label: 'Oregon', value: 'OR' },
            { label: 'Pennsylvania', value: 'PA' },
            { label: 'Rhode Island', value: 'RI' },
            { label: 'South Carolina', value: 'SC' },
            { label: 'South Dakota', value: 'SD' },
            { label: 'Tennessee', value: 'TN' },
            { label: 'Texas', value: 'TX' },
            { label: 'Utah', value: 'UT' },
            { label: 'Vermont', value: 'VT' },
            { label: 'Virginia', value: 'VA' },
            { label: 'Washington', value: 'WA' },
            { label: 'West Virginia', value: 'WV' },
            { label: 'Wisconsin', value: 'WI' },
            { label: 'Wyoming', value: 'WY' }
        ];
    }

    // API Methods
    @api validate() {
        // This step is optional, so always return valid
        return {
            isValid: true,
            messages: []
        };
    }

    @api reset() {
        this.applicants = [];
        this.showModal = false;
        this.currentApplicant = {};
        this.editingIndex = -1;
        this.emitPayloadChange();
    }
}
