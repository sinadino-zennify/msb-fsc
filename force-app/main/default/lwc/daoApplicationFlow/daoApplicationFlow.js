/**
 * @description Main container component for the deposit account opening application flow
 * 
 * DATA MODEL: Uses ApplicationForm, Applicant, Account, FinancialAccount
 * See /docs/01-foundation/data-model.md for complete data model
 * 
 * @author DAO AI Accelerator
 * @date 2025-01-16
 */

import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getApplicationData from '@salesforce/apex/DAOApplicationService.getApplicationData';
import saveApplicationData from '@salesforce/apex/DAOApplicationService.saveApplicationData';
import submitApplication from '@salesforce/apex/DAOApplicationService.submitApplication';

export default class DaoApplicationFlow extends NavigationMixin(LightningElement) {
    @track currentStep = 1;
    @track applicationId;
    @track applicationData = {};
    @track isLoading = false;

    // Step configuration
    steps = [
        { id: 1, number: 1, label: 'Applicant Details', cssClass: 'step active' },
        { id: 2, number: 2, label: 'Product Selection', cssClass: 'step' },
        { id: 3, number: 3, label: 'Collateral Entry', cssClass: 'step' },
        { id: 4, number: 4, label: 'Review & Submit', cssClass: 'step' }
    ];

    // Getters for dynamic component rendering
    get showApplicantDetails() {
        return this.currentStep === 1;
    }

    get showProductSelection() {
        return this.currentStep === 2;
    }

    get showCollateralEntry() {
        return this.currentStep === 3;
    }

    get showReviewAndSubmit() {
        return this.currentStep === 4;
    }

    connectedCallback() {
        this.initializeApplication();
    }

    initializeApplication() {
        // TODO: Initialize new application or load existing one
        this.isLoading = true;
        // Implementation will be added in DAOApplicationService
    }

    handleNext(event) {
        if (this.currentStep < 4) {
            this.currentStep++;
            this.updateStepStyles();
        }
    }

    handleBack(event) {
        if (this.currentStep > 1) {
            this.currentStep--;
            this.updateStepStyles();
        }
    }

    handleSave(event) {
        this.isLoading = true;
        // TODO: Implement save functionality
        saveApplicationData({ applicationData: this.applicationData })
            .then(result => {
                this.showToast('Success', 'Application saved successfully', 'success');
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to save application', 'error');
                this.isLoading = false;
            });
    }

    handleSubmit(event) {
        this.isLoading = true;
        submitApplication({ applicationId: this.applicationId })
            .then(result => {
                this.showToast('Success', 'Application submitted successfully', 'success');
                // Navigate to status page or success page
                this.navigateToApplicationStatus(result.applicationId);
            })
            .catch(error => {
                this.showToast('Error', 'Failed to submit application', 'error');
                this.isLoading = false;
            });
    }

    updateStepStyles() {
        this.steps = this.steps.map(step => ({
            ...step,
            cssClass: step.id === this.currentStep ? 'step active' : 
                     step.id < this.currentStep ? 'step completed' : 'step'
        }));
    }

    navigateToApplicationStatus(applicationId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: applicationId,
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
