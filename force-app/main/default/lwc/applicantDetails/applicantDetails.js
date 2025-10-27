import { LightningElement, api } from 'lwc';

export default class ApplicantDetails extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    // Personal Information Fields
    firstName;
    lastName;
    email;
    phone;
    dateOfBirth;
    ssn;
    mailingStreet;
    mailingCity;
    mailingState;
    mailingPostalCode;

    connectedCallback() {
        if (this.value) {
            this.firstName = this.value.firstName;
            this.lastName = this.value.lastName;
            this.email = this.value.email;
            this.phone = this.value.phone;
            this.dateOfBirth = this.value.dateOfBirth;
            this.ssn = this.value.ssn;
            this.mailingStreet = this.value.mailingStreet;
            this.mailingCity = this.value.mailingCity;
            this.mailingState = this.value.mailingState;
            this.mailingPostalCode = this.value.mailingPostalCode;
        }
    }

    // Event Handlers
    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        this.emitPayloadChange();
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
        this.emitPayloadChange();
    }

    handleEmailChange(event) {
        this.email = event.target.value;
        this.emitPayloadChange();
    }

    handlePhoneChange(event) {
        this.phone = event.target.value;
        this.emitPayloadChange();
    }

    handleDateOfBirthChange(event) {
        this.dateOfBirth = event.target.value;
        this.emitPayloadChange();
    }

    handleSsnChange(event) {
        this.ssn = event.target.value;
        this.emitPayloadChange();
    }

    handleMailingStreetChange(event) {
        this.mailingStreet = event.target.value;
        this.emitPayloadChange();
    }

    handleMailingCityChange(event) {
        this.mailingCity = event.target.value;
        this.emitPayloadChange();
    }

    handleMailingStateChange(event) {
        this.mailingState = event.target.value;
        this.emitPayloadChange();
    }

    handleMailingPostalCodeChange(event) {
        this.mailingPostalCode = event.target.value;
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
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            phone: this.phone,
            dateOfBirth: this.dateOfBirth,
            ssn: this.ssn,
            mailingStreet: this.mailingStreet,
            mailingCity: this.mailingCity,
            mailingState: this.mailingState,
            mailingPostalCode: this.mailingPostalCode
        };
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

    @api validate() {
        const messages = [];
        if (!this.firstName) {
            messages.push('First Name is required.');
        }
        if (!this.lastName) {
            messages.push('Last Name is required.');
        }
        if (!this.email) {
            messages.push('Email is required.');
        }
        if (!this.phone) {
            messages.push('Phone is required.');
        }
        if (!this.dateOfBirth) {
            messages.push('Date of Birth is required.');
        }
        if (!this.ssn) {
            messages.push('Social Security Number is required.');
        }
        if (!this.mailingStreet) {
            messages.push('Street Address is required.');
        }
        if (!this.mailingCity) {
            messages.push('City is required.');
        }
        if (!this.mailingState) {
            messages.push('State is required.');
        }
        if (!this.mailingPostalCode) {
            messages.push('ZIP Code is required.');
        }
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        this.firstName = null;
        this.lastName = null;
        this.email = null;
        this.phone = null;
        this.dateOfBirth = null;
        this.ssn = null;
        this.mailingStreet = null;
        this.mailingCity = null;
        this.mailingState = null;
        this.mailingPostalCode = null;
        this.emitPayloadChange();
    }
}
