/**
 * @description Applicant details entry component for deposit account opening
 * 
 * DATA MODEL: Uses ApplicationForm, Applicant, Account, FinancialAccount
 * See /docs/01-foundation/data-model.md for complete data model
 * 
 * @author DAO AI Accelerator
 * @date 2025-01-16
 */

import { LightningElement, track, api } from 'lwc';

export default class ApplicantDetails extends LightningElement {
    @api recordId;
    @track applicantData = {
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
    };

    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        this.applicantData = { ...this.applicantData, [field]: value };
    }

    handleNext() {
        // Validate form data
        if (this.validateForm()) {
            this.dispatchEvent(new CustomEvent('next', {
                detail: { applicantData: this.applicantData }
            }));
        }
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent('save', {
            detail: { applicantData: this.applicantData }
        }));
    }

    validateForm() {
        // TODO: Implement form validation
        return true;
    }
}
