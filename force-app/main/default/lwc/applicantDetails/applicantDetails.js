import { LightningElement, api } from 'lwc';

export default class ApplicantDetails extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

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

    connectedCallback() {
        if (this.value) {
            // Personal Identity
            this.salutation = this.value.salutation;
            this.firstName = this.value.firstName;
            this.lastName = this.value.lastName;
            this.dateOfBirth = this.value.dateOfBirth;
            this.taxIdType = this.value.taxIdType;
            this.taxId = this.value.taxId;
            
            // Contact Information
            this.email = this.value.email;
            this.mobilePhone = this.value.mobilePhone;
            this.homePhone = this.value.homePhone;
            this.workPhone = this.value.workPhone;
            
            // Mailing Address
            this.mailingStreetLine1 = this.value.mailingStreetLine1;
            this.mailingStreetLine2 = this.value.mailingStreetLine2;
            this.mailingCity = this.value.mailingCity;
            this.mailingState = this.value.mailingState;
            this.mailingPostalCode = this.value.mailingPostalCode;
            this.mailingCountry = this.value.mailingCountry;
            
            // Government ID
            this.governmentIdType = this.value.governmentIdType;
            this.governmentIdNumber = this.value.governmentIdNumber;
            this.idIssuingCountry = this.value.idIssuingCountry;
            this.idIssuingState = this.value.idIssuingState;
            this.idIssueDate = this.value.idIssueDate;
            this.idExpirationDate = this.value.idExpirationDate;
        }
    }

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
}
