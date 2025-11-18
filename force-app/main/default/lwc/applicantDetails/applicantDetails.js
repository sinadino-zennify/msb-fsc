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
    middleName;
    lastName;
    suffix;
    nickname;
    dateOfBirth;
    mothersMaidenName;
    taxIdType;
    taxId;
    
    // Citizenship Fields
    isUSCitizen; // Picklist: Yes, No (Required)
    isUSResident; // Picklist: Yes, No (Conditional - shown when isUSCitizen = No)
    countryOfResidence; // Picklist (Conditional - shown when isUSResident = No)
    
    // Employment Fields
    employer;
    occupation;
    
    // Organization Role Fields (for business applications)
    organizationRole;
    ownershipPercentage;
    isControlPerson; // Picklist: Yes, No
    roles = ['Primary Applicant']; // Default to Primary Applicant, hidden from UI

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
    
    // Address Lookup Configuration
    showAddressLookup = true; // Enable address autocomplete via Google Maps Places API

    // Identity Documents (Track array for persistence)
    identityDocuments = [];
    showIdentityDocumentModal = false;
    currentDocument = {};
    editingDocumentId = null;

    // Event Handlers - Personal Identity
    handleSalutationChange(event) {
        this.salutation = event.target.value;
        this.emitPayloadChange();
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        this.emitPayloadChange();
    }

    handleMiddleNameChange(event) {
        this.middleName = event.target.value;
        this.emitPayloadChange();
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
        this.emitPayloadChange();
    }

    handleSuffixChange(event) {
        this.suffix = event.target.value;
        this.emitPayloadChange();
    }

    handleNicknameChange(event) {
        this.nickname = event.target.value;
        this.emitPayloadChange();
    }

    handleOccupationChange(event) {
        this.occupation = event.target.value;
        this.emitPayloadChange();
    }

    handleMothersMaidenNameChange(event) {
        this.mothersMaidenName = event.target.value;
        this.emitPayloadChange();
    }

    handleUSCitizenChange(event) {
        this.isUSCitizen = event.target.value;
        // If US Citizen = Yes, clear dependent fields
        if (this.isUSCitizen === 'Yes') {
            this.isUSResident = null;
            this.countryOfResidence = null;
        }
        this.emitPayloadChange();
    }

    handleUSResidentChange(event) {
        this.isUSResident = event.target.value;
        // If US Resident = Yes, clear Country of Residence
        if (this.isUSResident === 'Yes') {
            this.countryOfResidence = null;
        }
        this.emitPayloadChange();
    }

    handleCountryOfResidenceChange(event) {
        this.countryOfResidence = event.target.value;
        this.emitPayloadChange();
    }

    handleEmployerChange(event) {
        this.employer = event.target.value;
        this.emitPayloadChange();
    }

    handleOrganizationRoleChange(event) {
        this.organizationRole = event.target.value;
        this.emitPayloadChange();
    }

    handleOwnershipPercentageChange(event) {
        this.ownershipPercentage = event.target.value;
        this.emitPayloadChange();
    }

    handleControlPersonChange(event) {
        this.isControlPerson = event.target.value;
        this.emitPayloadChange();
    }

    handleRolesChange(event) {
        // Multi-select picklist - event.detail.value is an array
        this.roles = event.detail.value || [];
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
    // Handle lightning-input-address change (auto-populates street, city, province, country, postalCode)
    handleAddressChange(event) {
        // lightning-input-address provides address object with all fields
        // When show-address-lookup is enabled, selecting from autocomplete populates all fields
        const address = event.detail;
        
        // Update individual fields from the address object
        // Support both 'street' and 'addressLine1' field names
        this.mailingStreetLine1 = address.street || address.addressLine1 || '';
        this.mailingCity = address.city || '';
        this.mailingState = address.province || ''; // province = state in US
        this.mailingCountry = address.country || '';
        this.mailingPostalCode = address.postalCode || '';
        
        this.emitPayloadChange();
    }

    handleMailingStreetLine2Change(event) {
        this.mailingStreetLine2 = event.target.value;
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

    // Identity Documents Handlers
    handleAddIdentityDocument() {
        this.currentDocument = {
            id: null,
            idType: '',
            idNumber: '',
            issuingAuthority: '',
            issueDate: '',
            expirationDate: ''
        };
        this.editingDocumentId = null;
        this.showIdentityDocumentModal = true;
    }

    handleEditIdentityDocument(event) {
        const docId = event.target.dataset.id;
        const doc = this.identityDocuments.find(d => d.id === docId);
        if (doc) {
            this.currentDocument = { ...doc };
            this.editingDocumentId = docId;
            this.showIdentityDocumentModal = true;
        }
    }

    handleDeleteIdentityDocument(event) {
        const docId = event.target.dataset.id;
        this.identityDocuments = this.identityDocuments.filter(d => d.id !== docId);
        this.emitPayloadChange();
    }

    handleModalFieldChange(event) {
        const field = event.target.dataset.field;
        this.currentDocument = {
            ...this.currentDocument,
            [field]: event.target.value
        };
    }

    handleSaveDocument() {
        // Validate required fields
        if (!this.currentDocument.idType || 
            !this.currentDocument.idNumber || 
            !this.currentDocument.issuingAuthority || 
            !this.currentDocument.issueDate || 
            !this.currentDocument.expirationDate) {
            // Show error message
            return;
        }

        if (this.editingDocumentId) {
            // Update existing document
            this.identityDocuments = this.identityDocuments.map(doc => 
                doc.id === this.editingDocumentId ? { ...this.currentDocument } : doc
            );
        } else {
            // Add new document
            const newDoc = {
                ...this.currentDocument,
                id: `doc-${Date.now()}` // Generate unique ID
            };
            this.identityDocuments = [...this.identityDocuments, newDoc];
        }

        this.handleCloseModal();
        this.emitPayloadChange();
    }

    handleCloseModal() {
        this.showIdentityDocumentModal = false;
        this.currentDocument = {};
        this.editingDocumentId = null;
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
            middleName: this.middleName,
            lastName: this.lastName,
            suffix: this.suffix,
            nickname: this.nickname,
            birthDate: this.dateOfBirth, // Apex expects 'birthDate'
            mothersMaidenName: this.mothersMaidenName,
            taxIdType: this.taxIdType,
            taxId: this.taxId,
            
            // Citizenship
            isUSCitizen: this.isUSCitizen,
            isUSResident: this.isUSResident,
            countryOfResidence: this.countryOfResidence,
            
            // Employment
            employer: this.employer,
            occupation: this.occupation,
            
            // Organization Roles
            organizationRole: this.organizationRole,
            ownershipPercentage: this.ownershipPercentage,
            isControlPerson: this.isControlPerson,
            roles: Array.isArray(this.roles) ? this.roles.join(';') : this.roles, // Multi-select as semicolon-separated string
            
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
            
            // Identity Documents
            identityDocuments: this.identityDocuments
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

    get suffixOptions() {
        return [
            { label: 'Jr.', value: 'Jr.' },
            { label: 'Sr.', value: 'Sr.' },
            { label: 'II', value: 'II' },
            { label: 'III', value: 'III' },
            { label: 'IV', value: 'IV' }
        ];
    }

    get occupationOptions() {
        return [
            { label: 'Employed', value: 'Employed' },
            { label: 'Self-Employed', value: 'Self-Employed' },
            { label: 'Retired', value: 'Retired' },
            { label: 'Student', value: 'Student' },
            { label: 'Unemployed', value: 'Unemployed' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get taxIdTypeOptions() {
        return [
            { label: 'SSN', value: 'SSN' },
            { label: 'ITIN', value: 'ITIN' },
            { label: 'Foreign Tax ID', value: 'Foreign Tax ID' }
        ];
    }

    get organizationRoleOptions() {
        return [
            { label: 'Business Owner', value: 'Business Owner' },
            { label: 'Partner', value: 'Partner' },
            { label: 'Officer', value: 'Officer' },
            { label: 'Director', value: 'Director' },
            { label: 'Shareholder', value: 'Shareholder' },
            { label: 'Authorized Signer', value: 'Authorized Signer' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get rolesOptions() {
        return [
            { label: 'Primary Applicant', value: 'Primary Applicant' },
            { label: 'Co-Applicant', value: 'Co-Applicant' },
            { label: 'Authorized Signer', value: 'Authorized Signer' },
            { label: 'Beneficial Owner', value: 'Beneficial Owner' },
            { label: 'Control Person', value: 'Control Person' }
        ];
    }

    get citizenshipOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    get countryOptions() {
        return [
            { label: 'United States', value: 'United States' },
            { label: 'Canada', value: 'Canada' },
            { label: 'Mexico', value: 'Mexico' },
            { label: 'United Kingdom', value: 'United Kingdom' },
            { label: 'France', value: 'France' },
            { label: 'Germany', value: 'Germany' },
            { label: 'Italy', value: 'Italy' },
            { label: 'Spain', value: 'Spain' },
            { label: 'Australia', value: 'Australia' },
            { label: 'Japan', value: 'Japan' },
            { label: 'China', value: 'China' },
            { label: 'India', value: 'India' },
            { label: 'Brazil', value: 'Brazil' },
            { label: 'Argentina', value: 'Argentina' },
            { label: 'Colombia', value: 'Colombia' },
            { label: 'Chile', value: 'Chile' },
            { label: 'South Africa', value: 'South Africa' },
            { label: 'Nigeria', value: 'Nigeria' },
            { label: 'Egypt', value: 'Egypt' },
            { label: 'Russia', value: 'Russia' },
            { label: 'South Korea', value: 'South Korea' },
            { label: 'Singapore', value: 'Singapore' },
            { label: 'Other', value: 'Other' }
        ];
    }

    // Computed properties for conditional rendering
    get showUSResident() {
        return this.isUSCitizen === 'No';
    }

    get showCountryOfResidence() {
        return this.isUSCitizen === 'No' && this.isUSResident === 'No';
    }

    // Identity Document Type Options (based on IdDocumentType field from IdentityDocument object)
    get idDocumentTypeOptions() {
        return [
            { label: "Driver's License", value: "Driver's License" },
            { label: 'Passport', value: 'Passport' },
            { label: 'State ID', value: 'State ID' },
            { label: 'Military ID', value: 'Military ID' }
        ];
    }

    // Computed properties for Identity Documents
    get hasIdentityDocuments() {
        return this.identityDocuments && this.identityDocuments.length > 0;
    }

    get modalTitle() {
        return this.editingDocumentId ? 'Edit Identity Document' : 'Add Identity Document';
    }

    // Process documents for display (add labels and masked values)
    get processedIdentityDocuments() {
        return this.identityDocuments.map(doc => {
            const typeOption = this.idDocumentTypeOptions.find(opt => opt.value === doc.idType);
            return {
                ...doc,
                idTypeLabel: typeOption ? typeOption.label : doc.idType,
                idNumberMasked: this.maskIdNumber(doc.idNumber)
            };
        });
    }

    // Helper method to mask ID numbers for display
    maskIdNumber(idNumber) {
        if (!idNumber || idNumber.length < 4) {
            return idNumber;
        }
        const lastFour = idNumber.slice(-4);
        const masked = 'X'.repeat(Math.max(0, idNumber.length - 4));
        return masked + lastFour;
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
        
        // Tax ID validation (required + 9 digits only)
        if (!this.taxId) {
            messages.push('Tax ID Number is required.');
        } else if (!this.validateTaxIdFormat(this.taxId)) {
            messages.push('Tax ID must be 9 digits.');
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
        
        // Identity Documents validation (CIP Requirement: At least 1 ID required)
        if (!this.identityDocuments || this.identityDocuments.length === 0) {
            messages.push('⚠️ CIP Requirement: At least one government-issued ID must be provided.');
        }
        
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }
    
    // Validation helper methods
    validateTaxIdFormat(taxId) {
        // Validate 9 digits only (allow masked with asterisks)
        const digitsOnly = taxId.replace(/\D/g, '');
        if (/^[*]{9}$/.test(taxId)) {
            return true;
        }
        return digitsOnly.length === 9;
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
        this.middleName = null;
        this.lastName = null;
        this.suffix = null;
        this.nickname = null;
        this.dateOfBirth = null;
        this.mothersMaidenName = null;
        this.taxIdType = null;
        this.taxId = null;
        
        // Citizenship
        this.isUSCitizen = null;
        this.isUSResident = null;
        this.countryOfResidence = null;
        
        // Employment
        this.employer = null;
        this.occupation = null;
        
        // Organization Roles
        this.organizationRole = null;
        this.ownershipPercentage = null;
        this.isControlPerson = null;
        this.roles = ['Primary Applicant']; // Reset to default
        
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
        
        // Identity Documents
        this.identityDocuments = [];
        
        this.emitPayloadChange();
    }

    applyValue(incomingValue) {
        // eslint-disable-next-line no-console
        console.log('🔍 ApplicantDetails applyValue called with:', JSON.stringify(incomingValue, null, 2));
        
        // Personal Identity
        this.salutation = incomingValue.salutation;
        this.firstName = incomingValue.firstName;
        this.middleName = incomingValue.middleName;
        this.lastName = incomingValue.lastName;
        this.suffix = incomingValue.suffix;
        this.nickname = incomingValue.nickname;
        this.dateOfBirth = incomingValue.birthDate || incomingValue.dateOfBirth;
        this.mothersMaidenName = incomingValue.mothersMaidenName;
        this.taxIdType = incomingValue.taxIdType;
        this.taxId = incomingValue.taxId;
        
        // Citizenship
        // Convert Boolean values to "Yes"/"No" strings for picklist display
        if (typeof incomingValue.isUSCitizen === 'boolean') {
            this.isUSCitizen = incomingValue.isUSCitizen ? 'Yes' : 'No';
        } else {
            this.isUSCitizen = incomingValue.isUSCitizen; // Already a string ("Yes"/"No")
        }
        
        if (typeof incomingValue.isUSResident === 'boolean') {
            this.isUSResident = incomingValue.isUSResident ? 'Yes' : 'No';
        } else {
            this.isUSResident = incomingValue.isUSResident; // Already a string ("Yes"/"No") or null
        }
        
        this.countryOfResidence = incomingValue.countryOfResidence;
        
        // Employment
        this.employer = incomingValue.employer;
        this.occupation = incomingValue.occupation;
        
        // Organization Roles
        this.organizationRole = incomingValue.organizationRole;
        
        // Ownership Percentage: Convert from decimal (0.50) to whole number (50) for display
        // Salesforce stores as 0.50 (50%), but UI displays as 50
        if (incomingValue.ownershipPercentage != null) {
            const ownershipPercentage = parseFloat(incomingValue.ownershipPercentage);
            // If value is < 1, it's in decimal format (0.50), convert to whole number (50)
            if (ownershipPercentage < 1 && ownershipPercentage > 0) {
                this.ownershipPercentage = (ownershipPercentage * 100).toFixed(2);
            } else {
                this.ownershipPercentage = ownershipPercentage;
            }
        } else {
            this.ownershipPercentage = null;
        }
        
        // Is Control Person: Picklist value (Yes/No)
        this.isControlPerson = incomingValue.isControlPerson || null;
        
        // Handle roles as string (semicolon-separated) or array
        if (incomingValue.roles) {
            this.roles = Array.isArray(incomingValue.roles) 
                ? incomingValue.roles 
                : (typeof incomingValue.roles === 'string' ? incomingValue.roles.split(';') : ['Primary Applicant']);
        } else {
            this.roles = ['Primary Applicant']; // Default
        }

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

        // Identity Documents
        if (incomingValue.identityDocuments && Array.isArray(incomingValue.identityDocuments)) {
            this.identityDocuments = [...incomingValue.identityDocuments];
        }

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
