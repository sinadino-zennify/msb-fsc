import { LightningElement, api } from 'lwc';

export default class ApplicantDetails extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;

    _value;
    hasAppliedInitialValue = false;

    @api
    get value() {
        return this._value;
    }

    set value(val) {
        // eslint-disable-next-line no-console
        console.log('🔍 ApplicantDetails value setter called with:', JSON.stringify(val, null, 2));
        // eslint-disable-next-line no-console
        console.log('🔍 hasAppliedInitialValue:', this.hasAppliedInitialValue);
        this._value = val;
        if (val && !this.hasAppliedInitialValue) {
            // eslint-disable-next-line no-console
            console.log('🔍 Calling applyValue with:', JSON.stringify(val, null, 2));
            this.applyValue(val);
            this.hasAppliedInitialValue = true;
        }
    }

    // Personal Identity Fields
    salutation;
    firstName;
    lastName;
    dateOfBirth;
    taxIdType;
    taxId;

    // Contact Information Fields
    email;
    mobilePhone;
    homePhone;
    workPhone;

    // Mailing Address Fields
    mailingStreetLine1;
    mailingStreetLine2;
    mailingCity;
    mailingState;
    mailingPostalCode;
    mailingCountry;

    // Government ID Fields
    governmentIdType;
    governmentIdNumber;
    idIssuingCountry;
    idIssuingState;
    idIssueDate;
    idExpirationDate;

    // Event Handlers - Personal Identity
    handleSalutationChange(event) {
        this.salutation = event.target.value;
        this.emitPayloadChange();
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        this.emitPayloadChange();
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
        this.emitPayloadChange();
    }

    handleDateOfBirthChange(event) {
        this.dateOfBirth = event.target.value;
        this.emitPayloadChange();
    }

    handleTaxIdTypeChange(event) {
        this.taxIdType = event.target.value;
        this.emitPayloadChange();
    }

    handleTaxIdChange(event) {
        this.taxId = event.target.value;
        this.emitPayloadChange();
    }

    // Event Handlers - Contact Information
    handleEmailChange(event) {
        this.email = event.target.value;
        this.emitPayloadChange();
    }

    handleMobilePhoneChange(event) {
        this.mobilePhone = event.target.value;
        this.emitPayloadChange();
    }

    handleHomePhoneChange(event) {
        this.homePhone = event.target.value;
        this.emitPayloadChange();
    }

    handleWorkPhoneChange(event) {
        this.workPhone = event.target.value;
        this.emitPayloadChange();
    }

    // Event Handlers - Mailing Address
    handleMailingStreetLine1Change(event) {
        this.mailingStreetLine1 = event.target.value;
        this.emitPayloadChange();
    }

    handleMailingStreetLine2Change(event) {
        this.mailingStreetLine2 = event.target.value;
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

    handleMailingCountryChange(event) {
        this.mailingCountry = event.target.value;
        this.emitPayloadChange();
    }

    // Event Handlers - Government ID
    handleGovernmentIdTypeChange(event) {
        this.governmentIdType = event.target.value;
        this.emitPayloadChange();
    }

    handleGovernmentIdNumberChange(event) {
        this.governmentIdNumber = event.target.value;
        this.emitPayloadChange();
    }

    handleIdIssuingCountryChange(event) {
        this.idIssuingCountry = event.target.value;
        this.emitPayloadChange();
    }

    handleIdIssuingStateChange(event) {
        this.idIssuingState = event.target.value;
        this.emitPayloadChange();
    }

    handleIdIssueDateChange(event) {
        this.idIssueDate = event.target.value;
        this.emitPayloadChange();
    }

    handleIdExpirationDateChange(event) {
        this.idExpirationDate = event.target.value;
        this.emitPayloadChange();
    }

    emitPayloadChange() {
        console.log('=== ApplicantDetails: emitPayloadChange ===');
        console.log('dateOfBirth field value:', this.dateOfBirth);
        const payload = this.payload;
        console.log('Payload being emitted:', JSON.stringify(payload, null, 2));
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: { 
                payload: payload,
                isDirty: true
            }
        }));
    }

    get payload() {
        const payload = {
            // Personal Identity
            salutation: this.salutation,
            firstName: this.firstName,
            lastName: this.lastName,
            birthDate: this.dateOfBirth, // Apex expects 'birthDate'
            taxIdType: this.taxIdType,
            taxId: this.taxId,
            
            // Contact Information
            email: this.email,
            mobilePhone: this.mobilePhone,
            homePhone: this.homePhone,
            workPhone: this.workPhone,
            
            // Mailing Address
            mailingStreetLine1: this.mailingStreetLine1,
            mailingStreetLine2: this.mailingStreetLine2,
            mailingCity: this.mailingCity,
            mailingState: this.mailingState,
            mailingPostalCode: this.mailingPostalCode,
            mailingCountry: this.mailingCountry,
            
            // Government ID
            governmentIdType: this.governmentIdType,
            governmentIdNumber: this.governmentIdNumber,
            idIssuingCountry: this.idIssuingCountry,
            idIssuingState: this.idIssuingState,
            idIssueDate: this.idIssueDate,
            idExpirationDate: this.idExpirationDate
        };
        console.log('=== ApplicantDetails: payload getter ===');
        console.log('birthDate in payload:', payload.birthDate);
        return payload;
    }

    // Picklist Options
    get salutationOptions() {
        return [
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Mrs.', value: 'Mrs.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Dr.', value: 'Dr.' },
            { label: 'Prof.', value: 'Prof.' }
        ];
    }

    get taxIdTypeOptions() {
        return [
            { label: 'SSN', value: 'SSN' },
            { label: 'ITIN', value: 'ITIN' },
            { label: 'Foreign Tax ID', value: 'Foreign Tax ID' }
        ];
    }

    get countryOptions() {
        return [
            { label: 'USA', value: 'USA' },
            { label: 'Canada', value: 'Canada' },
            { label: 'Mexico', value: 'Mexico' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get governmentIdTypeOptions() {
        return [
            { label: "Driver's License", value: "Driver's License" },
            { label: 'Passport', value: 'Passport' },
            { label: 'State ID', value: 'State ID' },
            { label: 'Military ID', value: 'Military ID' }
        ];
    }

    get stateOptions() {
        return [
            { label: 'Alabama', value: 'Alabama' },
            { label: 'Alaska', value: 'Alaska' },
            { label: 'Arizona', value: 'Arizona' },
            { label: 'Arkansas', value: 'Arkansas' },
            { label: 'California', value: 'California' },
            { label: 'Colorado', value: 'Colorado' },
            { label: 'Connecticut', value: 'Connecticut' },
            { label: 'Delaware', value: 'Delaware' },
            { label: 'Florida', value: 'Florida' },
            { label: 'Georgia', value: 'Georgia' },
            { label: 'Hawaii', value: 'Hawaii' },
            { label: 'Idaho', value: 'Idaho' },
            { label: 'Illinois', value: 'Illinois' },
            { label: 'Indiana', value: 'Indiana' },
            { label: 'Iowa', value: 'Iowa' },
            { label: 'Kansas', value: 'Kansas' },
            { label: 'Kentucky', value: 'Kentucky' },
            { label: 'Louisiana', value: 'Louisiana' },
            { label: 'Maine', value: 'Maine' },
            { label: 'Maryland', value: 'Maryland' },
            { label: 'Massachusetts', value: 'Massachusetts' },
            { label: 'Michigan', value: 'Michigan' },
            { label: 'Minnesota', value: 'Minnesota' },
            { label: 'Mississippi', value: 'Mississippi' },
            { label: 'Missouri', value: 'Missouri' },
            { label: 'Montana', value: 'Montana' },
            { label: 'Nebraska', value: 'Nebraska' },
            { label: 'Nevada', value: 'Nevada' },
            { label: 'New Hampshire', value: 'New Hampshire' },
            { label: 'New Jersey', value: 'New Jersey' },
            { label: 'New Mexico', value: 'New Mexico' },
            { label: 'New York', value: 'New York' },
            { label: 'North Carolina', value: 'North Carolina' },
            { label: 'North Dakota', value: 'North Dakota' },
            { label: 'Ohio', value: 'Ohio' },
            { label: 'Oklahoma', value: 'Oklahoma' },
            { label: 'Oregon', value: 'Oregon' },
            { label: 'Pennsylvania', value: 'Pennsylvania' },
            { label: 'Rhode Island', value: 'Rhode Island' },
            { label: 'South Carolina', value: 'South Carolina' },
            { label: 'South Dakota', value: 'South Dakota' },
            { label: 'Tennessee', value: 'Tennessee' },
            { label: 'Texas', value: 'Texas' },
            { label: 'Utah', value: 'Utah' },
            { label: 'Vermont', value: 'Vermont' },
            { label: 'Virginia', value: 'Virginia' },
            { label: 'Washington', value: 'Washington' },
            { label: 'West Virginia', value: 'West Virginia' },
            { label: 'Wisconsin', value: 'Wisconsin' },
            { label: 'Wyoming', value: 'Wyoming' },
            { label: 'District of Columbia', value: 'District of Columbia' },
            { label: 'Puerto Rico', value: 'Puerto Rico' },
            { label: 'Guam', value: 'Guam' },
            { label: 'U.S. Virgin Islands', value: 'U.S. Virgin Islands' },
            { label: 'American Samoa', value: 'American Samoa' },
            { label: 'Northern Mariana Islands', value: 'Northern Mariana Islands' }
        ];
    }

    get todayDate() {
        // Return today's date in YYYY-MM-DD format for date input max attribute
        const today = new Date();
        return today.toISOString().split('T')[0];
    }

    @api validate() {
        const messages = [];
        
        // Personal Identity validation
        if (!this.firstName) {
            messages.push('First Name is required.');
        }
        if (!this.lastName) {
            messages.push('Last Name is required.');
        }
        
        // Date of Birth validation (required + not future + 18+ years old)
        if (!this.dateOfBirth) {
            messages.push('Date of Birth is required.');
        } else {
            if (this.validateFutureDate(this.dateOfBirth)) {
                messages.push('Date of Birth cannot be a future date.');
            } else if (!this.validateMinimumAge(this.dateOfBirth, 18)) {
                messages.push('Applicant must be at least 18 years old.');
            }
        }
        
        if (!this.taxIdType) {
            messages.push('Tax ID Type is required.');
        }
        
        // Tax ID validation (required + format based on type)
        if (!this.taxId) {
            messages.push('Tax ID Number is required.');
        } else if (this.taxIdType === 'SSN' && !this.validateSSNFormat(this.taxId)) {
            messages.push('SSN must be 9 digits in format XXX-XX-XXXX.');
        } else if (this.taxIdType === 'EIN' && !this.validateEINFormat(this.taxId)) {
            messages.push('EIN must be 9 digits in format XX-XXXXXXX.');
        }
        
        // Contact Information validation
        if (!this.email) {
            messages.push('Email is required.');
        } else if (!this.validateEmailFormat(this.email)) {
            messages.push('Email must be a valid email address.');
        }
        
        if (!this.mobilePhone) {
            messages.push('Mobile Phone is required.');
        } else if (!this.validatePhoneFormat(this.mobilePhone)) {
            messages.push('Mobile Phone must be a valid phone number (10 digits).');
        }
        
        // Optional phone validation
        if (this.homePhone && !this.validatePhoneFormat(this.homePhone)) {
            messages.push('Home Phone must be a valid phone number (10 digits).');
        }
        if (this.workPhone && !this.validatePhoneFormat(this.workPhone)) {
            messages.push('Work Phone must be a valid phone number (10 digits).');
        }
        
        // Mailing Address validation
        if (!this.mailingStreetLine1) {
            messages.push('Street Address Line 1 is required.');
        }
        if (!this.mailingCity) {
            messages.push('City is required.');
        }
        if (!this.mailingState) {
            messages.push('State is required.');
        }
        if (!this.mailingPostalCode) {
            messages.push('ZIP Code is required.');
        } else if (!this.validateZipCodeFormat(this.mailingPostalCode)) {
            messages.push('ZIP Code must be 5 or 9 digits (XXXXX or XXXXX-XXXX).');
        }
        
        // Government ID validation
        if (!this.governmentIdType) {
            messages.push('Government ID Type is required.');
        }
        if (!this.governmentIdNumber) {
            messages.push('Government ID Number is required.');
        }
        if (!this.idIssuingCountry) {
            messages.push('ID Issuing Country is required.');
        }
        if (!this.idIssueDate) {
            messages.push('ID Issue Date is required.');
        } else if (this.validateFutureDate(this.idIssueDate)) {
            messages.push('ID Issue Date cannot be a future date.');
        }
        
        if (!this.idExpirationDate) {
            messages.push('ID Expiration Date is required.');
        } else if (this.idIssueDate && !this.validateDateOrder(this.idIssueDate, this.idExpirationDate)) {
            messages.push('ID Expiration Date must be after Issue Date.');
        }
        
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }
    
    // Validation helper methods
    validateSSNFormat(ssn) {
        // Format: XXX-XX-XXXX (9 digits total)
        const ssnPattern = /^\d{3}-\d{2}-\d{4}$/;
        return ssnPattern.test(ssn);
    }
    
    validateEINFormat(ein) {
        // Format: XX-XXXXXXX (9 digits total)
        const einPattern = /^\d{2}-\d{7}$/;
        return einPattern.test(ein);
    }
    
    validateFutureDate(dateString) {
        const selectedDate = new Date(dateString);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        return selectedDate > today;
    }
    
    validateMinimumAge(dateOfBirth, minimumAge) {
        const dob = new Date(dateOfBirth);
        const today = new Date();
        const age = today.getFullYear() - dob.getFullYear();
        const monthDiff = today.getMonth() - dob.getMonth();
        const dayDiff = today.getDate() - dob.getDate();
        
        // Adjust age if birthday hasn't occurred this year
        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            return (age - 1) >= minimumAge;
        }
        return age >= minimumAge;
    }
    
    validatePhoneFormat(phone) {
        // Remove all non-digit characters
        const digitsOnly = phone.replace(/\D/g, '');
        // Must be 10 digits (US format)
        return digitsOnly.length === 10;
    }
    
    validateEmailFormat(email) {
        // Basic email validation
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailPattern.test(email);
    }
    
    validateZipCodeFormat(zipCode) {
        // Format: XXXXX or XXXXX-XXXX
        const zipPattern = /^\d{5}(-\d{4})?$/;
        return zipPattern.test(zipCode);
    }
    
    validateDateOrder(startDate, endDate) {
        const start = new Date(startDate);
        const end = new Date(endDate);
        return end > start;
    }

    @api reset() {
        // Personal Identity
        this.salutation = null;
        this.firstName = null;
        this.lastName = null;
        this.dateOfBirth = null;
        this.taxIdType = null;
        this.taxId = null;
        
        // Contact Information
        this.email = null;
        this.mobilePhone = null;
        this.homePhone = null;
        this.workPhone = null;
        
        // Mailing Address
        this.mailingStreetLine1 = null;
        this.mailingStreetLine2 = null;
        this.mailingCity = null;
        this.mailingState = null;
        this.mailingPostalCode = null;
        this.mailingCountry = null;
        
        // Government ID
        this.governmentIdType = null;
        this.governmentIdNumber = null;
        this.idIssuingCountry = null;
        this.idIssuingState = null;
        this.idIssueDate = null;
        this.idExpirationDate = null;
        
        this.emitPayloadChange();
    }

    applyValue(incomingValue) {
        // eslint-disable-next-line no-console
        console.log('🔍 ApplicantDetails applyValue called with:', JSON.stringify(incomingValue, null, 2));
        
        // Personal Identity
        this.salutation = incomingValue.salutation;
        this.firstName = incomingValue.firstName;
        this.lastName = incomingValue.lastName;
        this.dateOfBirth = incomingValue.birthDate || incomingValue.dateOfBirth;
        this.taxIdType = incomingValue.taxIdType;
        this.taxId = incomingValue.taxId;

        // Contact Information
        this.email = incomingValue.email;
        this.mobilePhone = incomingValue.mobilePhone;
        this.homePhone = incomingValue.homePhone;
        this.workPhone = incomingValue.workPhone;

        // Mailing Address
        this.mailingStreetLine1 = incomingValue.mailingStreetLine1;
        this.mailingStreetLine2 = incomingValue.mailingStreetLine2;
        this.mailingCity = incomingValue.mailingCity;
        this.mailingState = incomingValue.mailingState;
        this.mailingPostalCode = incomingValue.mailingPostalCode;
        this.mailingCountry = incomingValue.mailingCountry;

        // Government ID
        this.governmentIdType = incomingValue.governmentIdType;
        this.governmentIdNumber = incomingValue.governmentIdNumber;
        this.idIssuingCountry = incomingValue.idIssuingCountry;
        this.idIssuingState = incomingValue.idIssuingState;
        this.idIssueDate = incomingValue.idIssueDate;
        this.idExpirationDate = incomingValue.idExpirationDate;

        // eslint-disable-next-line no-console
        console.log('🔍 ApplicantDetails fields after apply:', {
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            mailingCity: this.mailingCity
        });

        this.emitPayloadChange();
    }
}
