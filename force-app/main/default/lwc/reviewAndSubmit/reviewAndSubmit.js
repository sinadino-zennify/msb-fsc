import { LightningElement, api } from 'lwc';

export default class ReviewAndSubmit extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    confirmed = false;

    connectedCallback() {
        if (this.value && this.value.confirmed !== undefined) {
            this.confirmed = this.value.confirmed || false;
        }
    }

    handleConfirmChange(event) {
        this.confirmed = event.target.checked;
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
            confirmed: this.confirmed
        };
    }

    // Summary helpers
    get hasSummary() {
        // When Review step receives the entire payload map, it will be a plain object with step keys
        return this.value && !this.value.confirmed && Object.keys(this.value).length > 0;
    }

    get summarySections() {
        if (!this.hasSummary) {
            return [];
        }
        
        console.log('Review value:', JSON.stringify(this.value, null, 2));
        
        const sections = [];
        let sectionId = 0;
        
        Object.keys(this.value).forEach((stepKey) => {
            const stepPayload = this.value[stepKey];
            console.log(`Processing step: ${stepKey}`, stepPayload);
            
            if (!stepPayload || typeof stepPayload !== 'object' || Object.keys(stepPayload).length === 0) {
                return;
            }

            // Format each step based on its key - check for various naming patterns
            const keyUpper = stepKey.toUpperCase();
            let section = null;
            
            if (keyUpper.includes('ADDITIONAL') && !keyUpper.includes('SERVICE')) {
                section = this.formatAdditionalApplicants(stepPayload);
            } else if (keyUpper.includes('PRODUCT')) {
                section = this.formatProductSelection(stepPayload);
            } else if (keyUpper.includes('SERVICE')) {
                section = this.formatAdditionalServices(stepPayload);
            } else if (keyUpper.includes('DOCUMENT')) {
                section = this.formatDocumentUpload(stepPayload);
            } else if (keyUpper.includes('BUSINESS') && !keyUpper.includes('ADDITIONAL') && !keyUpper.includes('PRODUCT') && !keyUpper.includes('DOCUMENT') && !keyUpper.includes('APPLICANT')) {
                section = this.formatBusinessDetails(stepPayload);
            } else if (keyUpper.includes('APPLICANT') && !keyUpper.includes('ADDITIONAL')) {
                section = this.formatApplicantDetails(stepPayload);
            } else {
                // Generic fallback
                section = this.formatGenericSection(stepKey, stepPayload);
            }
            
            if (section) {
                section.uniqueKey = `section-${sectionId++}`;
                sections.push(section);
            }
        });
        
        console.log('Formatted sections:', sections);
        return sections;
    }

    formatBusinessDetails(data) {
        const details = [
            data.businessName ? `Business Name: ${data.businessName}` : null,
            data.legalName ? `Legal Name: ${data.legalName}` : null,
            data.dba ? `DBA: ${data.dba}` : null,
            data.taxId ? `Tax ID: ${data.taxId}` : null,
            data.businessType ? `Business Type: ${data.businessType}` : null,
            (data.industryType || data.industry) ? `Industry: ${data.industryType || data.industry}` : null,
            (data.businessStreet || data.street) ? `Street: ${data.businessStreet || data.street}` : null,
            (data.businessCity || data.city) ? `City: ${data.businessCity || data.city}` : null,
            (data.businessState || data.state) ? `State: ${data.businessState || data.state}` : null,
            (data.businessPostalCode || data.postalCode) ? `Postal Code: ${data.businessPostalCode || data.postalCode}` : null,
            (data.businessPhone || data.phone) ? `Phone: ${data.businessPhone || data.phone}` : null,
            (data.businessEmail || data.email) ? `Email: ${data.businessEmail || data.email}` : null,
            data.businessWebsite ? `Website: ${data.businessWebsite}` : null,
            data.yearEstablished ? `Year Established: ${data.yearEstablished}` : null,
            data.numberOfEmployees ? `Number of Employees: ${data.numberOfEmployees}` : null,
            data.businessDescription ? `Description: ${data.businessDescription}` : null
        ].filter(d => d);
        
        return {
            label: 'business',
            title: 'Business Details',
            icon: 'standard:account',
            items: [{
                id: 'business-info',
                title: data.businessName || 'Business Information',
                details: details
            }]
        };
    }

    formatApplicantDetails(data) {
        const details = [
            data.firstName ? `First Name: ${data.firstName}` : null,
            data.lastName ? `Last Name: ${data.lastName}` : null,
            data.email ? `Email: ${data.email}` : null,
            data.phone ? `Phone: ${data.phone}` : null,
            data.dateOfBirth ? `Date of Birth: ${data.dateOfBirth}` : null,
            data.ssn ? `SSN: ***-**-${data.ssn.slice(-4)}` : null,
            data.mailingStreet ? `Street: ${data.mailingStreet}` : null,
            data.mailingCity ? `City: ${data.mailingCity}` : null,
            data.mailingState ? `State: ${data.mailingState}` : null,
            data.mailingPostalCode ? `Postal Code: ${data.mailingPostalCode}` : null
        ].filter(d => d);
        
        return {
            label: 'applicant',
            title: 'Applicant Details',
            icon: 'standard:contact',
            items: [{
                id: 'applicant-info',
                title: `${data.firstName || ''} ${data.lastName || ''}`.trim() || 'Applicant Information',
                details: details
            }]
        };
    }

    formatAdditionalApplicants(data) {
        // Check if data is an array or has an applicants property
        const applicantsArray = Array.isArray(data) ? data : (data.applicants || []);
        
        if (applicantsArray.length === 0) {
            return null;
        }
        
        return {
            label: 'additionalApplicants',
            title: 'Additional Applicants',
            icon: 'standard:team_member',
            items: applicantsArray.map(app => ({
                id: app.id || `app-${app.firstName}-${app.lastName}`,
                title: `${app.firstName} ${app.lastName} - ${app.role}`,
                details: [
                    `Email: ${app.email}`,
                    `Phone: ${app.phone}`,
                    app.ownershipPercentage ? `Ownership: ${app.ownershipPercentage}%` : null,
                    app.mailingStreet ? `Address: ${app.mailingStreet}, ${app.mailingCity || ''}, ${app.mailingState || ''} ${app.mailingPostalCode || ''}`.trim() : null
                ].filter(d => d)
            }))
        };
    }

    formatProductSelection(data) {
        const details = [
            (data.productCode || data.productType) ? `Product Code: ${data.productCode || data.productType}` : null,
            data.accountType ? `Account Type: ${data.accountType}` : null
        ].filter(d => d);
        
        return {
            label: 'product',
            title: 'Product Selection',
            icon: 'standard:product',
            items: [{
                id: 'product-info',
                title: data.productCode || data.productType || 'Product Information',
                details: details
            }]
        };
    }

    formatAdditionalServices(data) {
        if (!data.selectedServices || data.selectedServices.length === 0) {
            return null;
        }
        
        return {
            label: 'services',
            title: 'Additional Services',
            icon: 'standard:service_contract',
            items: data.selectedServices.map((service, idx) => ({
                id: `service-${idx}`,
                title: service,
                details: []
            }))
        };
    }

    formatDocumentUpload(data) {
        // Check if data has documents property or documentCount
        const docs = data.documents || [];
        const docCount = data.documentCount || 0;
        
        if (docs.length === 0 && docCount === 0) {
            return null;
        }
        
        // If we have a count but no documents array, show count only
        if (docs.length === 0 && docCount > 0) {
            return {
                label: 'documents',
                title: 'Documents',
                icon: 'standard:file',
                fields: [
                    { label: 'Document Count', value: String(docCount) }
                ]
            };
        }
        
        return {
            label: 'documents',
            title: 'Documents',
            icon: 'standard:file',
            items: docs.map(doc => ({
                id: doc.id || doc.name,
                title: doc.name,
                details: [
                    doc.type ? `Type: ${doc.type}` : null,
                    doc.fileName ? `File: ${doc.fileName}` : null,
                    doc.description ? `Description: ${doc.description}` : null,
                    doc.fileSize ? `Size: ${doc.fileSize}` : null
                ].filter(d => d)
            }))
        };
    }

    formatGenericSection(stepKey, data) {
        const fields = [];
        Object.keys(data).forEach(key => {
            if (typeof data[key] !== 'object') {
                fields.push({
                    label: key.replace(/([A-Z])/g, ' $1').trim(),
                    value: String(data[key])
                });
            }
        });
        
        return {
            label: stepKey,
            title: stepKey.replace(/_/g, ' ').replace(/([A-Z])/g, ' $1').trim(),
            icon: 'standard:record',
            fields: fields
        };
    }

    @api validate() {
        const messages = [];
        if (!this.confirmed) {
            messages.push('You must confirm the information before proceeding.');
        }
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        this.confirmed = false;
        this.emitPayloadChange();
    }
}
