import { LightningElement, api } from 'lwc';

export default class BusinessDetails extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    // Business Profile Fields
    businessName;
    businessType;
    yearEstablished;
    numberOfEmployees;
    industryType;
    businessWebsite;
    businessDescription;

    // Contact Information Fields
    businessEmail;
    businessWorkPhone;
    businessHomePhone;
    businessMobilePhone;

    // Business Address Fields
    businessStreetLine1;
    businessStreetLine2;
    businessCity;
    businessState;
    businessPostalCode;
    businessCountry;

    // Tax Information Fields
    taxId;
    taxIdType;

    connectedCallback() {
        if (this.value) {
            // Business Profile
            this.businessName = this.value.businessName;
            this.businessType = this.value.businessType;
            this.yearEstablished = this.value.yearEstablished;
            this.numberOfEmployees = this.value.numberOfEmployees;
            this.industryType = this.value.industryType;
            this.businessWebsite = this.value.businessWebsite;
            this.businessDescription = this.value.businessDescription;
            
            // Contact Information
            this.businessEmail = this.value.businessEmail;
            this.businessWorkPhone = this.value.businessWorkPhone;
            this.businessHomePhone = this.value.businessHomePhone;
            this.businessMobilePhone = this.value.businessMobilePhone;
            
            // Business Address
            this.businessStreetLine1 = this.value.businessStreetLine1;
            this.businessStreetLine2 = this.value.businessStreetLine2;
            this.businessCity = this.value.businessCity;
            this.businessState = this.value.businessState;
            this.businessPostalCode = this.value.businessPostalCode;
            this.businessCountry = this.value.businessCountry;
            
            // Tax Information
            this.taxId = this.value.taxId;
            this.taxIdType = this.value.taxIdType;
        }
    }

    // Event Handlers
    handleBusinessNameChange(event) {
        this.businessName = event.target.value;
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

    handleBusinessWorkPhoneChange(event) {
        this.businessWorkPhone = event.target.value;
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

    handleTaxIdTypeChange(event) {
        this.taxIdType = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessEmailChange(event) {
        this.businessEmail = event.target.value;
        this.emitPayloadChange();
    }

    handleBusinessWebsiteChange(event) {
        this.businessWebsite = event.target.value;
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

    handleYearEstablishedChange(event) {
        this.yearEstablished = event.target.value;
        this.emitPayloadChange();
    }

    handleNumberOfEmployeesChange(event) {
        this.numberOfEmployees = event.target.value;
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
            // Business Profile
            businessName: this.businessName,
            businessType: this.businessType,
            yearEstablished: this.yearEstablished,
            numberOfEmployees: this.numberOfEmployees,
            industryType: this.industryType,
            businessWebsite: this.businessWebsite,
            businessDescription: this.businessDescription,
            
            // Contact Information
            businessEmail: this.businessEmail,
            businessWorkPhone: this.businessWorkPhone,
            businessHomePhone: this.businessHomePhone,
            businessMobilePhone: this.businessMobilePhone,
            
            // Business Address
            businessStreetLine1: this.businessStreetLine1,
            businessStreetLine2: this.businessStreetLine2,
            businessCity: this.businessCity,
            businessState: this.businessState,
            businessPostalCode: this.businessPostalCode,
            businessCountry: this.businessCountry,
            
            // Tax Information
            taxId: this.taxId,
            taxIdType: this.taxIdType
        };
    }

    get businessTypeOptions() {
        return [
            { label: 'Corporation', value: 'Corporation' },
            { label: 'LLC', value: 'LLC' },
            { label: 'Partnership', value: 'Partnership' },
            { label: 'Sole Proprietorship', value: 'Sole Proprietorship' },
            { label: 'Non-Profit', value: 'Non-Profit' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get industryTypeOptions() {
        return [
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

    get employeeRangeOptions() {
        return [
            { label: '1-10', value: '1-10' },
            { label: '11-50', value: '11-50' },
            { label: '51-100', value: '51-100' },
            { label: '101-500', value: '101-500' },
            { label: '500+', value: '500+' }
        ];
    }

    get taxIdTypeOptions() {
        return [
            { label: 'Federal Employer Tax ID (EIN)', value: 'Federal Employer Tax ID (EIN)' },
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

    @api validate() {
        const messages = [];
        if (!this.businessName) {
            messages.push('Business Name is required.');
        }
        if (!this.businessType) {
            messages.push('Business Type is required.');
        }
        if (!this.taxId) {
            messages.push('Tax ID is required.');
        }
        if (!this.businessWorkPhone) {
            messages.push('Business Phone (Primary) is required.');
        }
        if (!this.taxIdType) {
            messages.push('Tax ID Type is required.');
        }
        if (!this.businessEmail) {
            messages.push('Business Email is required.');
        }
        if (!this.industryType) {
            messages.push('Industry Type is required.');
        }
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
        }
        if (!this.yearEstablished) {
            messages.push('Year Established is required.');
        }
        if (!this.numberOfEmployees) {
            messages.push('Number of Employees is required.');
        }
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        // Business Profile
        this.businessName = null;
        this.businessType = null;
        this.yearEstablished = null;
        this.numberOfEmployees = null;
        this.industryType = null;
        this.businessWebsite = null;
        this.businessDescription = null;
        
        // Contact Information
        this.businessEmail = null;
        this.businessWorkPhone = null;
        this.businessHomePhone = null;
        this.businessMobilePhone = null;
        
        // Business Address
        this.businessStreetLine1 = null;
        this.businessStreetLine2 = null;
        this.businessCity = null;
        this.businessState = null;
        this.businessPostalCode = null;
        this.businessCountry = null;
        
        // Tax Information
        this.taxId = null;
        this.taxIdType = null;
        
        this.emitPayloadChange();
    }
}
