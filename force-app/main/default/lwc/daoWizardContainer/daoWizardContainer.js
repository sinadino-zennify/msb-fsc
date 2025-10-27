import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { getFocusedTabInfo, setTabLabel, setTabIcon, isConsoleNavigation } from 'lightning/platformWorkspaceApi';
import getSteps from '@salesforce/apex/WizardConfigService.getSteps';
import upsertStep from '@salesforce/apex/WizardPersistenceService.upsertStep';

export default class DaoWizardContainer extends LightningElement {
    @api recordId;
    @api wizardApiName = 'DAO_Business_InBranch';

    steps = [];
    currentIndex = 0;
    payloadByStep = new Map();
    isLoading = false;
    error;

    @wire(CurrentPageReference)
    capturePageState(pageRef) {
        if (pageRef?.state) {
            // Support both hosting contexts (record page or app page via state)
            this.recordId = this.recordId || pageRef.state.c__recordId || pageRef.state.recordId || null;
        }
    }

    @wire(getSteps, { wizardApiName: '$wizardApiName' })
    wiredSteps({ error, data }) {
        if (data) {
            this.steps = data;
            this.error = undefined;
            this.updateTabInfo(); // Set tab label/icon when data loads
        } else if (error) {
            this.error = error;
            this.steps = [];
            this.showToast('Error', 'Failed to load wizard steps: ' + error.body.message, 'error');
        }
    }

    async updateTabInfo() {
        try {
            if (await isConsoleNavigation()) {
                const tabInfo = await getFocusedTabInfo();
                await setTabLabel({ 
                    tabId: tabInfo.tabId, 
                    label: 'DAO Wizard' 
                });
                await setTabIcon({ 
                    tabId: tabInfo.tabId, 
                    icon: 'utility:form', 
                    iconAlt: 'DAO Wizard' 
                });
            }
        } catch (error) {
            // Silently fail if not in console or other issues
            console.debug('Could not update tab info:', error);
        }
    }

    get currentStep() {
        return this.steps.length > 0 ? this.steps[this.currentIndex] : null;
    }

    get isFirst() {
        return this.currentIndex === 0;
    }

    get isLast() {
        return this.currentIndex === this.steps.length - 1;
    }


    get progressSteps() {
        return this.steps.map((step, index) => ({
            ...step,
            isActive: index === this.currentIndex,
            isCompleted: index < this.currentIndex,
            stepNumber: index + 1
        }));
    }

    get nextButtonLabel() {
        return this.isLast ? 'Complete' : 'Next';
    }

    get currentStepDeveloperName() {
        return this.currentStep ? this.currentStep.developerName : '';
    }


    get currentStepPayload() {
        return this.currentStep ? this.payloadByStep.get(this.currentStep.developerName) : null;
    }

    handlePayloadChange(event) {
        const { payload } = event.detail;
        if (this.currentStep) {
            this.payloadByStep.set(this.currentStep.developerName, payload);
        }
    }

    async handleNext() {
        if (!this.currentStep) return;

        this.isLoading = true;
        try {
            // Client-side validation
            const stepComponent = this.template.querySelector('c-dao-wizard-step-router');
            const validationResult = stepComponent ? stepComponent.validate() : { isValid: true, messages: [] };

            if (!validationResult.isValid) {
                this.showToast('Validation Error', validationResult.messages.join(', '), 'error');
                return;
            }

            // Persist step data
            const payload = this.payloadByStep.get(this.currentStep.developerName) || {};
            const persistenceResult = await upsertStep({
                applicationId: this.recordId, // Will be null for prototype testing
                stepDeveloperName: this.currentStep.developerName,
                payload: payload
            });

            if (!persistenceResult.success) {
                const errorMessages = persistenceResult.messages.map(msg => msg.message).join(', ');
                this.showToast('Save Error', errorMessages, 'error');
                return;
            }

            // Navigate to next step or complete
            if (this.isLast) {
                this.dispatchEvent(new CustomEvent('completed', {
                    detail: { 
                        applicationId: this.recordId,
                        finalPayload: Object.fromEntries(this.payloadByStep)
                    }
                }));
                this.showToast('Success', 'Wizard completed successfully!', 'success');
            } else {
                this.currentIndex++;
            }

        } catch (error) {
            this.showToast('Error', 'An unexpected error occurred: ' + error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handlePrevious() {
        if (!this.isFirst) {
            this.currentIndex--;
        }
    }

    handleSaveAndExit() {
        const payload = this.payloadByStep.get(this.currentStep?.developerName) || {};
        this.dispatchEvent(new CustomEvent('saveandexit', {
            detail: {
                applicationId: this.recordId,
                currentStep: this.currentStep?.developerName,
                currentPayload: payload,
                allPayloads: Object.fromEntries(this.payloadByStep)
            }
        }));
        this.showToast('Info', 'Progress saved. You can resume later.', 'info');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
