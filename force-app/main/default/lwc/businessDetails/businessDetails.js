import { LightningElement, api } from 'lwc';
import getNaicsDetails from '@salesforce/apex/WizardPersistenceService.getNaicsDetails';
import getAccountDetails from '@salesforce/apex/WizardPersistenceService.getAccountDetails';

export default class BusinessDetails extends LightningElement {
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
        if (val && !this.hasAppliedInitialValue) {
            this.applyValue(val);
            this.hasAppliedInitialValue = true;
        }
    }

    // Business Account Toggle
    businessAccountType = 'new'; // 'new' or 'existing'
    selectedAccountId;
    
    // Primary Contact Toggle
    primaryContactType = 'new'; // 'new' or 'existing'
    selectedContactId;

    industryTypeOptions = [
        { label: 'Agriculture', value: 'Agriculture' },
        { label: 'Construction', value: 'Construction' },
        { label: 'Education', value: 'Education' },
        { label: 'Finance', value: 'Finance' },
        { label: 'Healthcare', value: 'Healthcare' },
        { label: 'Hospitality', value: 'Hospitality' },
        { label: 'Manufacturing', value: 'Manufacturing' },
        { label: 'Professional Services', value: 'Professional Services' },
        { label: 'Real Estate', value: 'Real Estate' },
        { label: 'Retail', value: 'Retail' },
        { label: 'Technology', value: 'Technology' },
        { label: 'Transportation', value: 'Transportation' },
        { label: 'Other', value: 'Other' }
    ];

    // Business Identity Fields
    businessName;
    dbaName;
    businessType;
    taxId;
    dateEstablished;
    stateOfIncorporation;

    // Industry & Classification Fields
    naicsCodeId; // Record ID for NAICS__c lookup
    naicsCode; // Actual NAICS code value
    naicsDescription;
    industryType;
    businessDescription;

    // Contact Information Fields
    businessPhone;
    businessEmail;
    businessHomePhone;
    businessMobilePhone;
    businessWebsite;
    primaryContactName;
    primaryContactTitle;

    // Financial & Operational Fields
    annualRevenue;
    numberOfEmployees;

    // Business Address Fields
    businessStreetLine1;
    businessStreetLine2;
    businessCity;
    businessState;
    businessPostalCode;
    businessCountry;

    // Event Handlers
    handleBusinessNameChange(event) {
        this.businessName = event.target.value;
        this.emitPayloadChange();
    }

    handleDbaNameChange(event) {
        this.dbaName = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessTypeChange(event) {
        this.businessType = event.target.value;
        this.emitPayloadChange();
    }

    handleTaxIdChange(event) {
        this.taxId = event.target.value;
        this.emitPayloadChange();
    }

    handleDateEstablishedChange(event) {
        this.dateEstablished = event.target.value;
        this.emitPayloadChange();
    }

    handleStateOfIncorporationChange(event) {
        this.stateOfIncorporation = event.target.value;
        this.emitPayloadChange();
    }

    handleNaicsCodeChange(event) {
        this.naicsCodeId = event.detail.recordId;
        if (this.naicsCodeId) {
            // Fetch NAICS details when a record is selected
            this.fetchNaicsDetails(this.naicsCodeId);
        } else {
            // Clear fields if selection is removed
            this.naicsCode = null;
            this.naicsDescription = null;
        }
        this.emitPayloadChange();
    }

    async fetchNaicsDetails(recordId) {
        try {
            const result = await getNaicsDetails({ naicsId: recordId });
            if (result) {
                this.naicsCode = result.code;
                this.naicsDescription = result.title;
                this.emitPayloadChange();
            }
        } catch (error) {
            console.error('Error fetching NAICS details:', error);
        }
    }

    handleBusinessAccountTypeChange(event) {
        console.log('=== handleBusinessAccountTypeChange ===');
        this.businessAccountType = event.detail.value;
        console.log('businessAccountType:', this.businessAccountType);
        if (this.businessAccountType === 'new') {
            // Clear existing account selection and reset fields
            console.log('Clearing fields for new business account');
            this.selectedAccountId = null;
            this.clearAllFields();
        }
        // Reset primary contact toggle when switching account types
        this.primaryContactType = 'new';
        this.selectedContactId = null;
        console.log('primaryContactType reset to:', this.primaryContactType);
        this.emitPayloadChange();
    }

    async handleAccountSelection(event) {
        console.log('=== handleAccountSelection ===');
        this.selectedAccountId = event.detail.recordId;
        console.log('selectedAccountId:', this.selectedAccountId);
        if (this.selectedAccountId) {
            try {
                console.log('Fetching account details...');
                const accountData = await getAccountDetails({ accountId: this.selectedAccountId });
                console.log('Account data received:', JSON.stringify(accountData, null, 2));
                if (accountData) {
                    console.log('Populating fields from account data');
                    // Populate standard Account fields only
                    // Business-specific fields (DBA, Date Established, Registration State) remain empty for manual entry
                    this.businessName = accountData.Name;
                    // Map Business Type from Account picklist when available
                    this.businessType = accountData.Business_Type__c;
                    this.businessPhone = accountData.Phone;
                    this.businessWebsite = accountData.Website;
                    this.businessStreetLine1 = accountData.BillingStreet;
                    this.businessCity = accountData.BillingCity;
                    this.businessState = accountData.BillingState;
                    this.businessPostalCode = accountData.BillingPostalCode;
                    this.businessCountry = accountData.BillingCountry;
                    this.annualRevenue = accountData.AnnualRevenue;
                    // Convert NumberOfEmployees integer to range string
                    if (accountData.NumberOfEmployees) {
                        const numEmp = accountData.NumberOfEmployees;
                        if (numEmp <= 10) this.numberOfEmployees = '1-10';
                        else if (numEmp <= 50) this.numberOfEmployees = '11-50';
                        else if (numEmp <= 100) this.numberOfEmployees = '51-100';
                        else if (numEmp <= 500) this.numberOfEmployees = '101-500';
                        else this.numberOfEmployees = '500+';
                    }
                    console.log('Fields populated successfully');
                    this.emitPayloadChange();
                }
            } catch (error) {
                console.error('ERROR fetching Account details:', error);
                console.error('Error stack:', error.stack);
            }
        } else {
            console.log('No account selected, clearing fields');
            this.clearAllFields();
        }
    }

    handlePrimaryContactTypeChange(event) {
        console.log('=== handlePrimaryContactTypeChange ===');
        this.primaryContactType = event.detail.value;
        console.log('primaryContactType:', this.primaryContactType);
        if (this.primaryContactType === 'new') {
            console.log('Clearing contact fields for new contact');
            this.selectedContactId = null;
            this.primaryContactName = null;
            this.primaryContactTitle = null;
        }
        this.emitPayloadChange();
    }

    handleContactSelection(event) {
        console.log('=== handleContactSelection ===');
        // Store selected PersonAccount ID for reference
        // Primary Contact Name and Title are entered manually (not pre-populated)
        this.selectedContactId = event.detail.recordId;
        console.log('selectedContactId:', this.selectedContactId);
        this.emitPayloadChange();
    }

    clearAllFields() {
        this.businessName = null;
        this.dbaName = null;
        this.businessType = null;
        this.taxId = null;
        this.dateEstablished = null;
        this.stateOfIncorporation = null;
        this.naicsCodeId = null;
        this.naicsCode = null;
        this.naicsDescription = null;
        this.industryType = null;
        this.businessDescription = null;
        this.businessPhone = null;
        this.businessEmail = null;
        this.businessHomePhone = null;
        this.businessMobilePhone = null;
        this.businessWebsite = null;
        this.primaryContactName = null;
        this.primaryContactTitle = null;
        this.annualRevenue = null;
        this.numberOfEmployees = null;
        this.businessStreetLine1 = null;
        this.businessStreetLine2 = null;
        this.businessCity = null;
        this.businessState = null;
        this.businessPostalCode = null;
        this.businessCountry = null;
        this.emitPayloadChange();
    }

    handleIndustryTypeChange(event) {
        this.industryType = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessDescriptionChange(event) {
        this.businessDescription = event.target.value;
        this.emitPayloadChange();
    }

    handlePrimaryContactNameChange(event) {
        this.primaryContactName = event.target.value;
        this.emitPayloadChange();
    }

    handlePrimaryContactTitleChange(event) {
        this.primaryContactTitle = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessPhoneChange(event) {
        this.businessPhone = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessEmailChange(event) {
        this.businessEmail = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessHomePhoneChange(event) {
        this.businessHomePhone = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessMobilePhoneChange(event) {
        this.businessMobilePhone = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessWebsiteChange(event) {
        this.businessWebsite = event.target.value;
        this.emitPayloadChange();
    }

    handleAnnualRevenueChange(event) {
        this.annualRevenue = event.target.value;
        this.emitPayloadChange();
    }

    handleNumberOfEmployeesChange(event) {
        this.numberOfEmployees = event.target.value;
        this.emitPayloadChange();
    }


    handleBusinessStreetLine1Change(event) {
        this.businessStreetLine1 = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessStreetLine2Change(event) {
        this.businessStreetLine2 = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessCountryChange(event) {
        this.businessCountry = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessCityChange(event) {
        this.businessCity = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessStateChange(event) {
        this.businessState = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessPostalCodeChange(event) {
        this.businessPostalCode = event.target.value;
        this.emitPayloadChange();
    }

    emitPayloadChange() {
        console.log('=== BusinessDetails: emitPayloadChange ===');
        console.log('businessType field value:', this.businessType);
        const eventDetail = { 
            payload: this.payload,
            isDirty: true
        };
        console.log('Event detail:', JSON.stringify(eventDetail, null, 2));
        this.dispatchEvent(new CustomEvent('payloadchange', { detail: eventDetail }));
    }

    get payload() {
        console.log('=== BusinessDetails: Building payload getter ===');
        console.log('this.businessType:', this.businessType);
        const payload = {
            // Account and Contact Selection
            businessAccountType: this.businessAccountType,
            selectedAccountId: this.selectedAccountId,
            primaryContactType: this.primaryContactType,
            selectedContactId: this.selectedContactId,
            
            // Business Identity
            businessName: this.businessName,
            dbaName: this.dbaName,
            businessType: this.businessType,
            taxId: this.taxId,
            dateEstablished: this.dateEstablished,
            stateOfIncorporation: this.stateOfIncorporation,
            
            // Industry & Classification
            naicsCodeId: this.naicsCodeId,
            naicsCode: this.naicsCode,
            naicsDescription: this.naicsDescription,
            industryType: this.industryType,
            businessDescription: this.businessDescription,
            
            // Contact Information
            businessPhone: this.businessPhone,
            businessEmail: this.businessEmail,
            businessHomePhone: this.businessHomePhone,
            businessMobilePhone: this.businessMobilePhone,
            businessWebsite: this.businessWebsite,
            primaryContactName: this.primaryContactName,
            primaryContactTitle: this.primaryContactTitle,
            
            // Financial & Operational
            annualRevenue: this.annualRevenue,
            numberOfEmployees: this.numberOfEmployees,
            
            // Business Address
            businessStreetLine1: this.businessStreetLine1,
            businessStreetLine2: this.businessStreetLine2,
            businessCity: this.businessCity,
            businessState: this.businessState,
            businessPostalCode: this.businessPostalCode,
            businessCountry: this.businessCountry
        };
        console.log('=== BusinessDetails: Payload built ===');
        console.log('businessType in payload:', payload.businessType);
        console.log('Full payload:', JSON.stringify(payload, null, 2));
        return payload;
    }

    get businessTypeOptions() {
        return [
            { label: 'Corporation', value: 'Corporation' },
            { label: 'LLC', value: 'LLC' },
            { label: 'Partnership', value: 'Partnership' },
            { label: 'Sole Proprietorship', value: 'Sole Proprietorship' },
            { label: 'Non-Profit', value: 'Non-Profit' },
            { label: 'Trust', value: 'Trust' }
        ];
    }

    stateOptions = [
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
        { label: 'Wyoming', value: 'WY' },
        { label: 'District of Columbia', value: 'DC' },
        { label: 'Puerto Rico', value: 'PR' },
        { label: 'Guam', value: 'GU' },
        { label: 'U.S. Virgin Islands', value: 'VI' },
        { label: 'American Samoa', value: 'AS' },
        { label: 'Northern Mariana Islands', value: 'MP' }
    ];

    get employeeRangeOptions() {
        return [
            { label: '1-10', value: '1-10' },
            { label: '11-50', value: '11-50' },
            { label: '51-100', value: '51-100' },
            { label: '101-500', value: '101-500' },
            { label: '500+', value: '500+' }
        ];
    }

    // Business Account Type Options
    get businessAccountTypeOptions() {
        return [
            { label: 'New Business Account', value: 'new' },
            { label: 'Existing Business Account', value: 'existing' }
        ];
    }

    get isExistingBusinessAccount() {
        return this.businessAccountType === 'existing';
    }

    get accountDisplayInfo() {
        return {
            primaryField: 'Name',
            additionalFields: ['Phone', 'BillingCity']
        };
    }

    get accountMatchingInfo() {
        return {
            primaryField: { fieldPath: 'Name' }
        };
    }

    get accountFilter() {
        return {
            criteria: [
                {
                    fieldPath: 'RecordType.DeveloperName',
                    operator: 'eq',
                    value: 'IndustriesBusiness'
                }
            ]
        };
    }

    // Primary Contact Type Options
    get primaryContactTypeOptions() {
        return [
            { label: 'New Primary Contact', value: 'new' },
            { label: 'Existing Primary Contact', value: 'existing' }
        ];
    }

    get isNewPrimaryContact() {
        return !this.isExistingBusinessAccount || this.primaryContactType === 'new';
    }

    get isExistingPrimaryContact() {
        return this.isExistingBusinessAccount && this.primaryContactType === 'existing';
    }

    get contactDisplayInfo() {
        return {
            primaryField: 'Name',
            additionalFields: ['PersonEmail', 'Phone']
        };
    }

    get contactMatchingInfo() {
        return {
            primaryField: { fieldPath: 'Name' }
        };
    }

    get contactFilter() {
        // Filter for PersonAccounts only (not regular Business Accounts)
        return {
            criteria: [
                {
                    fieldPath: 'IsPersonAccount',
                    operator: 'eq',
                    value: true
                }
            ]
        };
    }

    get naicsDisplayInfo() {
        return {
            primaryField: 'Code__c',
            additionalFields: ['Description__c']
        };
    }

    get naicsMatchingInfo() {
        return {
            primaryField: { fieldPath: 'Code__c' },
            additionalFields: [{ fieldPath: 'Description__c' }]
        };
    }

    get countryOptions() {
        return [
            { label: 'USA', value: 'USA' },
            { label: 'Canada', value: 'Canada' },
            { label: 'Mexico', value: 'Mexico' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get todayDate() {
        // Return today's date in YYYY-MM-DD format for date input max attribute
        const today = new Date();
        return today.toISOString().split('T')[0];
    }

    @api validate() {
        const messages = [];
        
        // Required field validation
        if (!this.businessName) {
            messages.push('Legal Business Name is required.');
        }
        if (!this.businessType) {
            messages.push('Business Type is required.');
        }
        
        // Tax ID validation (required + format)
        if (!this.taxId) {
            messages.push('Federal Tax ID (EIN) is required.');
        } else if (!this.validateTaxIdFormat(this.taxId)) {
            messages.push('Federal Tax ID must be 9 digits in format XX-XXXXXXX.');
        }
        
        // Date Established validation (required + not future)
        if (!this.dateEstablished) {
            messages.push('Date Established is required.');
        } else if (this.validateFutureDate(this.dateEstablished)) {
            messages.push('Date Established cannot be a future date.');
        }
        
        if (!this.stateOfIncorporation) {
            messages.push('State of Incorporation is required.');
        }
        if (!this.naicsCodeId) {
            messages.push('NAICS Code is required.');
        }
        if (!this.industryType) {
            messages.push('Industry Type is required.');
        }
        
        // Business Phone validation (required + format)
        if (!this.businessPhone) {
            messages.push('Business Phone is required.');
        } else if (!this.validatePhoneFormat(this.businessPhone)) {
            messages.push('Business Phone must be a valid phone number (10 digits).');
        }
        
        // Business Email validation (required + format)
        if (!this.businessEmail) {
            messages.push('Business Email is required.');
        } else if (!this.validateEmailFormat(this.businessEmail)) {
            messages.push('Business Email must be a valid email address.');
        }
        
        // Complete Address validation
        if (!this.businessStreetLine1) {
            messages.push('Business Street Address Line 1 is required.');
        }
        if (!this.businessCity) {
            messages.push('Business City is required.');
        }
        if (!this.businessState) {
            messages.push('Business State is required.');
        }
        if (!this.businessPostalCode) {
            messages.push('Business ZIP Code is required.');
        } else if (!this.validateZipCodeFormat(this.businessPostalCode)) {
            messages.push('Business ZIP Code must be 5 or 9 digits (XXXXX or XXXXX-XXXX).');
        }
        
        if (!this.numberOfEmployees) {
            messages.push('Number of Employees is required.');
        }
        
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }
    
    // Validation helper methods
    validateTaxIdFormat(taxId) {
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
    
    validatePhoneFormat(phone) {
        const digitsOnly = phone.replace(/\D/g, '');
        return digitsOnly.length === 10 || digitsOnly.length === 11;
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

    @api reset() {
        // Business Identity
        this.businessName = null;
        this.dbaName = null;
        this.businessType = null;
        this.taxId = null;
        this.dateEstablished = null;
        this.stateOfIncorporation = null;
        
        // Industry & Classification
        this.naicsCodeId = null;
        this.naicsCode = null;
        this.naicsDescription = null;
        this.industryType = null;
        this.businessDescription = null;
        
        // Contact Information
        this.businessPhone = null;
        this.businessEmail = null;
        this.businessHomePhone = null;
        this.businessMobilePhone = null;
        this.businessWebsite = null;
        this.primaryContactName = null;
        this.primaryContactTitle = null;
        
        // Financial & Operational
        this.annualRevenue = null;
        this.numberOfEmployees = null;
        
        // Business Address
        this.businessStreetLine1 = null;
        this.businessStreetLine2 = null;
        this.businessCity = null;
        this.businessState = null;
        this.businessPostalCode = null;
        this.businessCountry = null;
        
        this.emitPayloadChange();
    }

    applyValue(incomingValue) {
        this.businessAccountType = incomingValue.businessAccountType || this.businessAccountType;
        this.selectedAccountId = incomingValue.selectedAccountId;
        this.primaryContactType = incomingValue.primaryContactType || this.primaryContactType;
        this.selectedContactId = incomingValue.selectedContactId;

        // Business Identity
        this.businessName = incomingValue.businessName;
        this.dbaName = incomingValue.dbaName;
        this.businessType = incomingValue.businessType;
        this.taxId = incomingValue.taxId;
        this.dateEstablished = incomingValue.dateEstablished;
        this.stateOfIncorporation = this.getStateValue(incomingValue.stateOfIncorporation);

        // Industry & Classification
        this.naicsCodeId = incomingValue.naicsCodeId;
        this.naicsCode = incomingValue.naicsCode;
        this.naicsDescription = incomingValue.naicsDescription;
        const normalizedIndustry = this.getSupportedIndustry(incomingValue.industryType);
        this.addIndustryOptionIfMissing(normalizedIndustry);
        this.industryType = normalizedIndustry;
        this.businessDescription = incomingValue.businessDescription;

        // Contact Information
        this.businessPhone = incomingValue.businessPhone;
        this.businessEmail = incomingValue.businessEmail;
        this.businessHomePhone = incomingValue.businessHomePhone;
        this.businessMobilePhone = incomingValue.businessMobilePhone;
        this.businessWebsite = incomingValue.businessWebsite;
        this.primaryContactName = incomingValue.primaryContactName;
        this.primaryContactTitle = incomingValue.primaryContactTitle;

        // Financial & Operational
        this.annualRevenue = incomingValue.annualRevenue;
        this.numberOfEmployees = incomingValue.numberOfEmployees;

        // Business Address
        this.businessStreetLine1 = incomingValue.businessStreetLine1;
        this.businessStreetLine2 = incomingValue.businessStreetLine2;
        this.businessCity = incomingValue.businessCity;
        this.businessState = this.getStateValue(incomingValue.businessState);
        this.businessPostalCode = incomingValue.businessPostalCode;
        this.businessCountry = incomingValue.businessCountry;

        this.emitPayloadChange();
    }

    addIndustryOptionIfMissing(value) {
        if (!value) {
            return;
        }

        const exists = this.industryTypeOptions.some(option => option.value === value);
        if (!exists) {
            this.industryTypeOptions = [
                ...this.industryTypeOptions,
                { label: value, value: value }
            ];
        }
    }

    getSupportedIndustry(industry) {
        if (!industry) {
            return null;
        }

        const normalized = industry.toString().trim().toLowerCase();
        const supported = new Map([
            ['agriculture', 'Agriculture'],
            ['construction', 'Construction'],
            ['education', 'Education'],
            ['finance', 'Finance'],
            ['financial services', 'Finance'],
            ['healthcare', 'Healthcare'],
            ['hospitality', 'Hospitality'],
            ['manufacturing', 'Manufacturing'],
            ['professional services', 'Professional Services'],
            ['real estate', 'Real Estate'],
            ['retail', 'Retail'],
            ['technology', 'Technology'],
            ['transportation', 'Transportation']
        ]);

        if (supported.has(normalized)) {
            return supported.get(normalized);
        }

        return 'Other';
    }

    getStateValue(state) {
        if (!state) {
            return null;
        }

        const normalized = state.toString().trim().toLowerCase();
        const match = this.stateOptions.find(option =>
            option.value.toLowerCase() === normalized || option.label.toLowerCase() === normalized
        );

        return match ? match.value : state;
    }
}