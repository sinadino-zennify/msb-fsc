import { LightningElement, api } from 'lwc';

export default class BusinessDetails extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    // Business Information Fields
    businessName;
    businessType;
    taxId;
    businessPhone;
    businessEmail;
    businessWebsite;
    industryType;
    businessDescription;
    businessStreet;
    businessCity;
    businessState;
    businessPostalCode;
    yearEstablished;
    numberOfEmployees;

    connectedCallback() {
        if (this.value) {
            this.businessName = this.value.businessName;
            this.businessType = this.value.businessType;
            this.taxId = this.value.taxId;
            this.businessPhone = this.value.businessPhone;
            this.businessEmail = this.value.businessEmail;
            this.businessWebsite = this.value.businessWebsite;
            this.industryType = this.value.industryType;
            this.businessDescription = this.value.businessDescription;
            this.businessStreet = this.value.businessStreet;
            this.businessCity = this.value.businessCity;
            this.businessState = this.value.businessState;
            this.businessPostalCode = this.value.businessPostalCode;
            this.yearEstablished = this.value.yearEstablished;
            this.numberOfEmployees = this.value.numberOfEmployees;
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

    handleBusinessPhoneChange(event) {
        this.businessPhone = event.target.value;
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

    handleBusinessStreetChange(event) {
        this.businessStreet = event.target.value;
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
            businessName: this.businessName,
            businessType: this.businessType,
            taxId: this.taxId,
            businessPhone: this.businessPhone,
            businessEmail: this.businessEmail,
            businessWebsite: this.businessWebsite,
            industryType: this.industryType,
            businessDescription: this.businessDescription,
            businessStreet: this.businessStreet,
            businessCity: this.businessCity,
            businessState: this.businessState,
            businessPostalCode: this.businessPostalCode,
            yearEstablished: this.yearEstablished,
            numberOfEmployees: this.numberOfEmployees
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
        if (!this.businessPhone) {
            messages.push('Business Phone is required.');
        }
        if (!this.businessEmail) {
            messages.push('Business Email is required.');
        }
        if (!this.industryType) {
            messages.push('Industry Type is required.');
        }
        if (!this.businessStreet) {
            messages.push('Business Address is required.');
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
        this.businessName = null;
        this.businessType = null;
        this.taxId = null;
        this.businessPhone = null;
        this.businessEmail = null;
        this.businessWebsite = null;
        this.industryType = null;
        this.businessDescription = null;
        this.businessStreet = null;
        this.businessCity = null;
        this.businessState = null;
        this.businessPostalCode = null;
        this.yearEstablished = null;
        this.numberOfEmployees = null;
        this.emitPayloadChange();
    }
}
