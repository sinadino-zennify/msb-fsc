import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getFocusedTabInfo, setTabLabel, setTabIcon, isConsoleNavigation, openSubtab, closeTab, refreshTab } from 'lightning/platformWorkspaceApi';
import getSteps from '@salesforce/apex/WizardConfigService.getSteps';
import upsertStep from '@salesforce/apex/WizardPersistenceService.upsertStep';

export default class DaoWizardContainer extends NavigationMixin(LightningElement) {
    @api recordId;
    @api wizardApiName = 'DAO_Business_InBranch';

    steps = [];
    currentIndex = 0;
    payloadByStep = new Map();
    isLoading = false;
    error;
    applicationFormId; // Store the ApplicationForm ID after creation
    devMode = false;
    
    connectedCallback() {
        // Log initial recordId passed by the host record page (Opportunity or ApplicationForm)
        // Useful to verify the container receives the context record id
        // eslint-disable-next-line no-console
        console.log('daoWizardContainer connected. Initial recordId:', this.recordId);
    }

    @wire(CurrentPageReference)
    capturePageState(pageRef) {
        if (pageRef?.state) {
            // Support both hosting contexts (record page or app page via state)
            this.recordId = this.recordId || pageRef.state.c__recordId || pageRef.state.recordId || null;
            this.devMode = this.devMode || pageRef.state.c__dev === '1' || pageRef.state.dev === '1';
            // eslint-disable-next-line no-console
            console.log('daoWizardContainer page state resolved recordId:', this.recordId, 'state:', JSON.stringify(pageRef.state));
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
        return this.isLast ? 'Submit' : 'Next';
    }

    get currentStepDeveloperName() {
        return this.currentStep ? this.currentStep.developerName : '';
    }


    get currentStepPayload() {
        return this.currentStep ? this.payloadByStep.get(this.currentStep.developerName) : null;
    }

    get currentStepValue() {
        // For the Review step, provide all payloads so it can render a summary
        if (this.currentStep && this.currentStep.componentBundle === 'reviewAndSubmit') {
            return Object.fromEntries(this.payloadByStep);
        }
        return this.currentStepPayload;
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

            if (!validationResult.isValid && !this.devMode) {
                this.showToast('Validation Error', validationResult.messages.join(', '), 'error');
                return;
            }

            // Persist step data
            let payload = this.payloadByStep.get(this.currentStep.developerName) || {};
            if (this.devMode && (!payload || Object.keys(payload).length === 0)) {
                payload = { __devBypass: true };
            }
            let persistenceResult = { success: true, messages: [], savedIds: null };
            try {
                persistenceResult = await upsertStep({
                    applicationId: this.applicationFormId, // Don't use recordId - it's the Opportunity, not ApplicationForm
                    stepDeveloperName: this.currentStep.developerName,
                    payload: payload
                });
            } catch (e) {
                if (!this.devMode) throw e;
            }

            if (!persistenceResult.success) {
                if (!this.devMode) {
                    const errorMessages = persistenceResult.messages.map(msg => msg.message).join(', ');
                    this.showToast('Save Error', errorMessages, 'error');
                    return;
                }
            }

            // Capture ApplicationForm ID if this is the first step
            if (persistenceResult.savedIds && persistenceResult.savedIds.applicationForm) {
                this.applicationFormId = persistenceResult.savedIds.applicationForm;
                console.log('ApplicationForm created with ID:', this.applicationFormId);
            }

            // Navigate to next step or complete
            if (this.isLast) {
                // eslint-disable-next-line no-console
                console.log('🎯 Wizard completed! applicationFormId:', this.applicationFormId);
                
                this.dispatchEvent(new CustomEvent('completed', {
                    detail: { 
                        applicationId: this.applicationFormId || this.recordId,
                        finalPayload: Object.fromEntries(this.payloadByStep)
                    }
                }));
                this.showToast('Success', 'Application submitted successfully!', 'success');
                
                // Redirect to ApplicationForm record
                if (this.applicationFormId) {
                    // eslint-disable-next-line no-console
                    console.log('🚀 Calling navigateToRecord with:', this.applicationFormId);
                    this.navigateToRecord(this.applicationFormId);
                } else {
                    // eslint-disable-next-line no-console
                    console.warn('⚠️ No applicationFormId available for navigation');
                }
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

    async handleSaveAndExit() {
        // eslint-disable-next-line no-console
        console.log('💾 Save & Exit triggered. applicationFormId:', this.applicationFormId);
        
        if (!this.currentStep) {
            this.showToast('Error', 'No current step to save', 'error');
            return;
        }

        this.isLoading = true;
        try {
            // Save current step data first
            const payload = this.payloadByStep.get(this.currentStep.developerName) || {};
            // eslint-disable-next-line no-console
            console.log('💾 Saving current step data before exit:', this.currentStep.developerName);
            
            const persistenceResult = await upsertStep({
                applicationId: this.applicationFormId, // Don't use recordId - it's the Opportunity, not ApplicationForm
                stepDeveloperName: this.currentStep.developerName,
                payload: payload
            });

            // Capture ApplicationForm ID if this created it
            if (persistenceResult.savedIds && persistenceResult.savedIds.applicationForm) {
                this.applicationFormId = persistenceResult.savedIds.applicationForm;
                // eslint-disable-next-line no-console
                console.log('💾 ApplicationForm ID captured:', this.applicationFormId);
            }

            this.dispatchEvent(new CustomEvent('saveandexit', {
                detail: {
                    applicationId: this.applicationFormId || this.recordId,
                    currentStep: this.currentStep.developerName,
                    currentPayload: payload,
                    allPayloads: Object.fromEntries(this.payloadByStep)
                }
            }));
            this.showToast('Info', 'Progress saved. You can resume later.', 'info');
            
            // Redirect to ApplicationForm record if available
            if (this.applicationFormId) {
                // eslint-disable-next-line no-console
                console.log('🚀 Calling navigateToRecord from Save & Exit with:', this.applicationFormId);
                this.navigateToRecord(this.applicationFormId);
            } else {
                // eslint-disable-next-line no-console
                console.warn('⚠️ No applicationFormId available for navigation on Save & Exit');
            }
        } catch (error) {
            // eslint-disable-next-line no-console
            console.error('❌ Error saving on exit:', error);
            this.showToast('Error', 'Failed to save progress: ' + (error.body?.message || error.message), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async navigateToRecord(recordId) {
        // eslint-disable-next-line no-console
        console.log('🔍 navigateToRecord called with recordId:', recordId);
        
        try {
            const inConsole = await isConsoleNavigation();
            // eslint-disable-next-line no-console
            console.log('🔍 isConsoleNavigation result:', inConsole);
            
            if (inConsole) {
                const tabInfo = await getFocusedTabInfo();
                // eslint-disable-next-line no-console
                console.log('🔍 Current tab info:', JSON.stringify(tabInfo, null, 2));
                
                // Strategy: Close current wizard tab and open ApplicationForm as a sibling
                // This works better than trying to open a subtab under a subtab
                
                // First, open the new record tab
                // eslint-disable-next-line no-console
                console.log('🔍 Opening ApplicationForm record as subtab under parent');
                
                // If wizard is a subtab, get its parent and open ApplicationForm as sibling
                if (tabInfo.isSubtab && tabInfo.parentTabId) {
                    // eslint-disable-next-line no-console
                    console.log('🔍 Wizard is a subtab. Parent:', tabInfo.parentTabId);
                    
                    await openSubtab({
                        parentTabId: tabInfo.parentTabId,
                        pageReference: {
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: recordId,
                                actionName: 'view'
                            }
                        },
                        focus: true
                    });
                    
                    // eslint-disable-next-line no-console
                    console.log('✅ ApplicationForm subtab opened as sibling');
                    
                    // Close the wizard tab after a brief delay
                    setTimeout(async () => {
                        try {
                            await closeTab({ tabId: tabInfo.tabId });
                            // eslint-disable-next-line no-console
                            console.log('✅ Wizard tab closed');
                        } catch (closeError) {
                            // eslint-disable-next-line no-console
                            console.warn('⚠️ Could not close wizard tab:', closeError);
                        }
                    }, 500);
                } else {
                    // Wizard is a primary tab, open ApplicationForm as subtab under it
                    // eslint-disable-next-line no-console
                    console.log('🔍 Wizard is a primary tab. Opening ApplicationForm as subtab');
                    
                    await openSubtab({
                        parentTabId: tabInfo.tabId,
                        pageReference: {
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: recordId,
                                actionName: 'view'
                            }
                        },
                        focus: true
                    });
                    // eslint-disable-next-line no-console
                    console.log('✅ ApplicationForm subtab opened');
                }
            } else {
                // Non-console: use standard navigation
                // eslint-disable-next-line no-console
                console.log('🔍 Using standard navigation (non-console)');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recordId,
                        actionName: 'view'
                    }
                });
                // eslint-disable-next-line no-console
                console.log('✅ Standard navigation called');
            }
        } catch (error) {
            // eslint-disable-next-line no-console
            console.error('❌ Error navigating to record:', error);
            // eslint-disable-next-line no-console
            console.error('❌ Error stack:', error.stack);
            // Fallback to standard navigation
            // eslint-disable-next-line no-console
            console.log('🔄 Falling back to standard navigation');
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    actionName: 'view'
                }
            });
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
