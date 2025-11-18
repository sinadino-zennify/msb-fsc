import { LightningElement, api, track } from 'lwc';

export default class AdditionalApplicants extends LightningElement {
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
        this._value = val;
        if (val && val.applicants && !this.hasAppliedInitialValue) {
            this.applicants = val.applicants.map((app, index) => ({
                ...app,
                id: app.id || `applicant-${Date.now()}-${index}`
            }));
            this.hasAppliedInitialValue = true;
        }
    }

    @track applicants = [];
    @track showModal = false;
    @track editingIndex = -1;
    @track currentApplicant = {};

    // Identity Document Modal State
    @track showDocumentModal = false;
    @track currentDocument = {};
    @track editingDocumentId = null;

    // Address Lookup Configuration
    showAddressLookup = true;

    // Lifecycle Hooks
    connectedCallback() {
        // Value will be set via @api setter
    }

    // Modal Management - Applicant
    handleAddApplicant() {
        this.currentApplicant = this.getEmptyApplicant();
        this.editingIndex = -1;
        this.showModal = true;
    }

    handleEditApplicant(event) {
        const index = parseInt(event.currentTarget.dataset.index, 10);
        // Deep clone to avoid mutating the original
        this.currentApplicant = JSON.parse(JSON.stringify(this.applicants[index]));
        this.editingIndex = index;
        this.showModal = true;
    }

    handleCloseModal() {
        this.showModal = false;
        this.currentApplicant = {};
        this.editingIndex = -1;
    }

    handleSaveApplicant() {
        // Trigger validation on all input fields within the modal to show errors
        const modalContainer = this.template.querySelector('.slds-modal__container');
        let allValid = true;
        
        if (modalContainer) {
            const allInputs = modalContainer.querySelectorAll('lightning-input, lightning-combobox, lightning-dual-listbox, lightning-input-address');
            
            allInputs.forEach(input => {
                if (input && input.reportValidity) {
                    const isValid = input.reportValidity();
                    if (!isValid) {
                        allValid = false;
                    }
                }
            });
        }
        
        // Also run our custom validation
        const validation = this.validateCurrentApplicant();
        
        if (validation.isValid && allValid) {
            const applicantToSave = { ...this.currentApplicant };
            
            // Ensure ID exists
            if (!applicantToSave.id) {
                applicantToSave.id = `applicant-${Date.now()}`;
            }

            if (this.editingIndex >= 0) {
                // Edit existing
                this.applicants[this.editingIndex] = applicantToSave;
            } else {
                // Add new
                this.applicants.push(applicantToSave);
            }
            
            this.applicants = [...this.applicants]; // Trigger reactivity
            this.handleCloseModal();
            this.emitPayloadChange();
        } else {
            // Show validation errors
            validation.messages.forEach(message => {
                // eslint-disable-next-line no-console
                console.error(message);
            });
            // Dispatch error event to show in UI
            this.dispatchEvent(new CustomEvent('validationerror', {
                detail: { messages: validation.messages }
            }));
        }
    }

    handleDeleteApplicant(event) {
        const index = parseInt(event.currentTarget.dataset.index, 10);
        this.applicants.splice(index, 1);
        this.applicants = [...this.applicants]; // Trigger reactivity
        this.emitPayloadChange();
    }

    // Modal Management - Identity Document
    handleAddDocument() {
        this.currentDocument = this.getEmptyDocument();
        this.editingDocumentId = null;
        this.showDocumentModal = true;
    }

    handleEditDocument(event) {
        const uniqueId = event.detail.value;
        const doc = this.currentApplicant.identityDocuments.find(d => d.uniqueId === uniqueId);
        if (doc) {
            this.currentDocument = { ...doc };
            this.editingDocumentId = uniqueId;
            this.showDocumentModal = true;
        }
    }

    handleDeleteDocument(event) {
        const uniqueId = event.detail.value;
        this.currentApplicant.identityDocuments = this.currentApplicant.identityDocuments.filter(
            d => d.uniqueId !== uniqueId
        );
        // Trigger reactivity
        this.currentApplicant = { ...this.currentApplicant };
    }

    handleCloseDocumentModal() {
        this.showDocumentModal = false;
        this.currentDocument = {};
        this.editingDocumentId = null;
    }

    handleSaveDocument() {
        const validation = this.validateCurrentDocument();
        if (validation.isValid) {
            const docToSave = { ...this.currentDocument };
            
            // Mask ID number for display
            docToSave.maskedIdNumber = this.maskIdNumber(docToSave.idNumber);
            
            // Ensure uniqueId exists
            if (!docToSave.uniqueId) {
                docToSave.uniqueId = `doc-${Date.now()}`;
            }

            if (!this.currentApplicant.identityDocuments) {
                this.currentApplicant.identityDocuments = [];
            }

            if (this.editingDocumentId) {
                // Edit existing
                const index = this.currentApplicant.identityDocuments.findIndex(
                    d => d.uniqueId === this.editingDocumentId
                );
                if (index >= 0) {
                    this.currentApplicant.identityDocuments[index] = docToSave;
                }
            } else {
                // Add new
                this.currentApplicant.identityDocuments.push(docToSave);
            }
            
            // Trigger reactivity
            this.currentApplicant = { ...this.currentApplicant };
            this.handleCloseDocumentModal();
            this.emitPayloadChange();
        } else {
            // Show validation errors
            validation.messages.forEach(message => {
                // eslint-disable-next-line no-console
                console.error(message);
            });
            // Dispatch error event to show in UI
            this.dispatchEvent(new CustomEvent('validationerror', {
                detail: { messages: validation.messages }
            }));
        }
    }

    handleDocumentFieldChange(event) {
        const field = event.target.dataset.field || event.currentTarget.dataset.field;
        this.currentDocument[field] = event.target.value;
    }

    // Form Field Handlers - Personal Identity
    handleSalutationChange(event) {
        this.currentApplicant.salutation = event.target.value;
    }

    handleFirstNameChange(event) {
        this.currentApplicant.firstName = event.target.value;
    }

    handleMiddleNameChange(event) {
        this.currentApplicant.middleName = event.target.value;
    }

    handleLastNameChange(event) {
        this.currentApplicant.lastName = event.target.value;
    }

    handleSuffixChange(event) {
        this.currentApplicant.suffix = event.target.value;
    }

    handleNicknameChange(event) {
        this.currentApplicant.nickname = event.target.value;
    }

    handleDateOfBirthChange(event) {
        this.currentApplicant.dateOfBirth = event.target.value;
    }

    handleMothersMaidenNameChange(event) {
        this.currentApplicant.mothersMaidenName = event.target.value;
    }

    // Form Field Handlers - Tax Information
    handleTaxIdTypeChange(event) {
        this.currentApplicant.taxIdType = event.target.value;
    }

    handleTaxIdChange(event) {
        this.currentApplicant.taxId = event.target.value;
    }

    // Form Field Handlers - Citizenship
    handleUSCitizenChange(event) {
        this.currentApplicant.isUSCitizen = event.target.value;
        // Reset dependent fields
        if (this.currentApplicant.isUSCitizen === 'Yes') {
            this.currentApplicant.isUSResident = null;
            this.currentApplicant.countryOfResidence = null;
        }
    }

    handleUSResidentChange(event) {
        this.currentApplicant.isUSResident = event.target.value;
        // Reset dependent field
        if (this.currentApplicant.isUSResident === 'Yes') {
            this.currentApplicant.countryOfResidence = null;
        }
    }

    handleCountryOfResidenceChange(event) {
        this.currentApplicant.countryOfResidence = event.target.value;
    }

    // Form Field Handlers - Government ID
    handleIdIssuingCountryChange(event) {
        this.currentApplicant.idIssuingCountry = event.target.value;
    }

    handleIdIssuingStateChange(event) {
        this.currentApplicant.idIssuingState = event.target.value;
    }

    handleIdIssueDateChange(event) {
        this.currentApplicant.idIssueDate = event.target.value;
    }

    handleIdExpirationDateChange(event) {
        this.currentApplicant.idExpirationDate = event.target.value;
    }

    // Form Field Handlers - Employment
    handleEmployerChange(event) {
        this.currentApplicant.employer = event.target.value;
    }

    handleOccupationChange(event) {
        this.currentApplicant.occupation = event.target.value;
    }

    // Form Field Handlers - Organization Roles
    handleOrganizationRoleChange(event) {
        this.currentApplicant.organizationRole = event.target.value;
    }

    handleOwnershipPercentageChange(event) {
        this.currentApplicant.ownershipPercentage = event.target.value;
    }

    handleControlPersonChange(event) {
        this.currentApplicant.isControlPerson = event.target.value;
    }

    handleRolesChange(event) {
        this.currentApplicant.roles = event.target.value;
    }

    // Form Field Handlers - Address
    handleAddressChange(event) {
        const addressData = event.detail;
        
        // Handle both street and addressLine1 for robustness
        this.currentApplicant.mailingStreetLine1 = addressData.street || addressData.addressLine1 || '';
        this.currentApplicant.mailingCity = addressData.city || '';
        this.currentApplicant.mailingState = addressData.province || '';
        this.currentApplicant.mailingCountry = addressData.country || '';
        this.currentApplicant.mailingPostalCode = addressData.postalCode || '';
    }

    handleMailingStreetLine2Change(event) {
        this.currentApplicant.mailingStreetLine2 = event.target.value;
    }

    // Form Field Handlers - Contact Information
    handleEmailChange(event) {
        this.currentApplicant.email = event.target.value;
    }

    handleHomePhoneChange(event) {
        this.currentApplicant.homePhone = event.target.value;
    }

    handleWorkPhoneChange(event) {
        this.currentApplicant.workPhone = event.target.value;
    }

    handleMobilePhoneChange(event) {
        this.currentApplicant.mobilePhone = event.target.value;
    }

    // Utility Methods
    getEmptyApplicant() {
        return {
            id: null,
            salutation: '',
            firstName: '',
            middleName: '',
            lastName: '',
            suffix: '',
            nickname: '',
            dateOfBirth: '',
            mothersMaidenName: '',
            taxIdType: '',
            taxId: '',
            isUSCitizen: '',
            isUSResident: '',
            countryOfResidence: '',
            idIssuingCountry: '',
            idIssuingState: '',
            idIssueDate: '',
            idExpirationDate: '',
            employer: '',
            occupation: '',
            organizationRole: '',
            ownershipPercentage: '',
            isControlPerson: '',
            roles: [],
            identityDocuments: [],
            mailingStreetLine1: '',
            mailingStreetLine2: '',
            mailingCity: '',
            mailingState: '',
            mailingPostalCode: '',
            mailingCountry: '',
            email: '',
            homePhone: '',
            workPhone: '',
            mobilePhone: ''
        };
    }

    getEmptyDocument() {
        return {
            uniqueId: null,
            idType: '',
            idNumber: '',
            issuingAuthority: '',
            issueDate: '',
            expirationDate: '',
            maskedIdNumber: ''
        };
    }

    validateCurrentApplicant() {
        const messages = [];
        
        // Personal Identity validation
        if (!this.currentApplicant.firstName) {
            messages.push('First Name is required.');
        }
        if (!this.currentApplicant.lastName) {
            messages.push('Last Name is required.');
        }
        
        // Date of Birth validation (required + not future + 18+ years old)
        if (!this.currentApplicant.dateOfBirth) {
            messages.push('Date of Birth is required.');
        } else {
            if (this.validateFutureDate(this.currentApplicant.dateOfBirth)) {
                messages.push('Date of Birth cannot be a future date.');
            } else if (!this.validateMinimumAge(this.currentApplicant.dateOfBirth, 18)) {
                messages.push('Applicant must be at least 18 years old.');
            }
        }
        
        if (!this.currentApplicant.taxIdType) {
            messages.push('Tax ID Type is required.');
        }
        
        // Tax ID validation (required + format based on type)
        if (!this.currentApplicant.taxId) {
            messages.push('Tax ID Number is required.');
        } else if (this.currentApplicant.taxIdType === 'SSN' && !this.validateSSNFormat(this.currentApplicant.taxId)) {
            messages.push('SSN must be 9 digits in format XXX-XX-XXXX.');
        } else if (this.currentApplicant.taxIdType === 'EIN' && !this.validateEINFormat(this.currentApplicant.taxId)) {
            messages.push('EIN must be 9 digits in format XX-XXXXXXX.');
        }
        
        // Citizenship Status validation
        if (!this.currentApplicant.isUSCitizen) {
            messages.push('Is US Citizen is required.');
        }
        
        // Conditional validation for Is US Resident
        if (this.showUSResident && !this.currentApplicant.isUSResident) {
            messages.push('Is US Resident is required when Is US Citizen is No.');
        }
        
        // Conditional validation for Country of Residence
        if (this.showCountryOfResidence && !this.currentApplicant.countryOfResidence) {
            messages.push('Country of Residence is required when Is US Resident is No.');
        }
        
        // Contact Information validation
        if (!this.currentApplicant.email) {
            messages.push('Email is required.');
        } else if (!this.validateEmailFormat(this.currentApplicant.email)) {
            messages.push('Email must be a valid email address.');
        }
        
        if (!this.currentApplicant.mobilePhone) {
            messages.push('Mobile Phone is required.');
        } else if (!this.validatePhoneFormat(this.currentApplicant.mobilePhone)) {
            messages.push('Mobile Phone must be a valid phone number (10 digits).');
        }
        
        // Optional phone validation
        if (this.currentApplicant.homePhone && !this.validatePhoneFormat(this.currentApplicant.homePhone)) {
            messages.push('Home Phone must be a valid phone number (10 digits).');
        }
        if (this.currentApplicant.workPhone && !this.validatePhoneFormat(this.currentApplicant.workPhone)) {
            messages.push('Work Phone must be a valid phone number (10 digits).');
        }
        
        // Mailing Address validation
        if (!this.currentApplicant.mailingStreetLine1) {
            messages.push('Street Address Line 1 is required.');
        }
        if (!this.currentApplicant.mailingCity) {
            messages.push('City is required.');
        }
        if (!this.currentApplicant.mailingState) {
            messages.push('State is required.');
        }
        if (!this.currentApplicant.mailingPostalCode) {
            messages.push('ZIP Code is required.');
        } else if (!this.validateZipCodeFormat(this.currentApplicant.mailingPostalCode)) {
            messages.push('ZIP Code must be 5 or 9 digits (XXXXX or XXXXX-XXXX).');
        }
        
        // Identity Documents validation (CIP Requirement: At least 1 ID required)
        if (!this.currentApplicant.identityDocuments || this.currentApplicant.identityDocuments.length === 0) {
            messages.push('⚠️ CIP Requirement: At least one government-issued ID must be provided.');
        }
        
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    validateCurrentDocument() {
        const messages = [];
        
        if (!this.currentDocument.idType) {
            messages.push('ID Type is required.');
        }
        if (!this.currentDocument.idNumber) {
            messages.push('ID Number is required.');
        }
        if (!this.currentDocument.issuingAuthority) {
            messages.push('Issuing Authority is required.');
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

    maskIdNumber(idNumber) {
        if (!idNumber) return '';
        const lastFour = idNumber.slice(-4);
        return `***-**-${lastFour}`;
    }

    emitPayloadChange() {
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: { 
                payload: this.payload,
                isDirty: true
            }
        }));
    }

    get todayDate() {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        return today.toISOString().split('T')[0];
    }

    // Computed Properties - Conditional Display
    get showUSResident() {
        return this.currentApplicant.isUSCitizen === 'No';
    }

    get showCountryOfResidence() {
        return this.currentApplicant.isUSCitizen === 'No' && 
               this.currentApplicant.isUSResident === 'No';
    }

    get hasIdentityDocuments() {
        return this.currentApplicant.identityDocuments && 
               this.currentApplicant.identityDocuments.length > 0;
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
        return this.editingIndex >= 0 ? 'Update Applicant' : 'Add Applicant';
    }

    get documentModalTitle() {
        return this.editingDocumentId ? 'Edit Identity Document' : 'Add Identity Document';
    }

    get saveDocumentButtonLabel() {
        return this.editingDocumentId ? 'Update' : 'Add';
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
            { label: 'I', value: 'I' },
            { label: 'II', value: 'II' },
            { label: 'III', value: 'III' },
            { label: 'IV', value: 'IV' }
        ];
    }

    get taxIdTypeOptions() {
        return [
            { label: 'SSN', value: 'SSN' },
            { label: 'EIN', value: 'EIN' },
            { label: 'ITIN', value: 'ITIN' }
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
            { label: 'Canada', value: 'Canada' },
            { label: 'Mexico', value: 'Mexico' },
            { label: 'United Kingdom', value: 'United Kingdom' },
            { label: 'Germany', value: 'Germany' },
            { label: 'France', value: 'France' },
            { label: 'Italy', value: 'Italy' },
            { label: 'Spain', value: 'Spain' },
            { label: 'Japan', value: 'Japan' },
            { label: 'China', value: 'China' },
            { label: 'India', value: 'India' },
            { label: 'Brazil', value: 'Brazil' },
            { label: 'Australia', value: 'Australia' },
            { label: 'South Korea', value: 'South Korea' },
            { label: 'Russia', value: 'Russia' },
            { label: 'South Africa', value: 'South Africa' },
            { label: 'Argentina', value: 'Argentina' },
            { label: 'Netherlands', value: 'Netherlands' },
            { label: 'Switzerland', value: 'Switzerland' },
            { label: 'Sweden', value: 'Sweden' },
            { label: 'Poland', value: 'Poland' },
            { label: 'Belgium', value: 'Belgium' },
            { label: 'Norway', value: 'Norway' },
            { label: 'Austria', value: 'Austria' },
            { label: 'Israel', value: 'Israel' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get organizationRoleOptions() {
        return [
            { label: 'Partner', value: 'Partner' },
            { label: 'Officer', value: 'Officer' },
            { label: 'Director', value: 'Director' },
            { label: 'Shareholder', value: 'Shareholder' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get rolesOptions() {
        return [
            { label: 'Co-Applicant', value: 'Co-Applicant' },
            { label: 'Authorized Signer', value: 'Authorized Signer' },
            { label: 'Control Person', value: 'Control Person' },
            { label: 'Guarantor', value: 'Guarantor' },
            { label: 'ATM Holder', value: 'ATM Holder' },
            { label: 'Administrator', value: 'Administrator' },
            { label: 'Beneficial Owner', value: 'Beneficial Owner' },
            { label: 'Bookkeeper', value: 'Bookkeeper' },
            { label: 'Controller', value: 'Controller' },
            { label: 'Custodian', value: 'Custodian' },
            { label: 'Director', value: 'Director' },
            { label: 'Employee', value: 'Employee' },
            { label: 'Executive', value: 'Executive' },
            { label: 'Fiduciary', value: 'Fiduciary' },
            { label: 'General Partner', value: 'General Partner' },
            { label: 'Limited Partner', value: 'Limited Partner' },
            { label: 'Manager', value: 'Manager' },
            { label: 'Member', value: 'Member' },
            { label: 'Officer', value: 'Officer' },
            { label: 'Owner', value: 'Owner' },
            { label: 'President', value: 'President' },
            { label: 'Secretary', value: 'Secretary' },
            { label: 'Shareholder', value: 'Shareholder' },
            { label: 'Signer', value: 'Signer' },
            { label: 'Treasurer', value: 'Treasurer' },
            { label: 'Trustee', value: 'Trustee' },
            { label: 'Vice President', value: 'Vice President' }
        ];
    }

    get idDocumentTypeOptions() {
        return [
            { label: 'Driver License', value: 'Driver License' },
            { label: 'Passport', value: 'Passport' },
            { label: 'State ID', value: 'State ID' },
            { label: 'Military ID', value: 'Military ID' },
            { label: 'Tribal ID', value: 'Tribal ID' }
        ];
    }


    // API Methods
    @api validate() {
        const messages = [];
        
        // Validate each applicant in the list
        if (this.applicants && this.applicants.length > 0) {
            this.applicants.forEach((applicant, index) => {
                // Store current applicant temporarily to use validation logic
                const previousApplicant = { ...this.currentApplicant };
                this.currentApplicant = applicant;
                
                const validation = this.validateCurrentApplicant();
                if (!validation.isValid) {
                    validation.messages.forEach(message => {
                        messages.push(`Applicant ${index + 1}: ${message}`);
                    });
                }
                
                // Restore previous applicant
                this.currentApplicant = previousApplicant;
            });
        }
        
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        this.applicants = [];
        this.showModal = false;
        this.currentApplicant = {};
        this.editingIndex = -1;
        this.showDocumentModal = false;
        this.currentDocument = {};
        this.editingDocumentId = null;
        this.hasAppliedInitialValue = false;
        this.emitPayloadChange();
    }
}
