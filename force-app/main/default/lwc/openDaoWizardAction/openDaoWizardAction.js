import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    isConsoleNavigation,
    getFocusedTabInfo,
    openSubtab,
    getAllTabInfo,
    focusTab
} from 'lightning/platformWorkspaceApi';

export default class OpenDaoWizardAction extends LightningElement {
    @api recordId;
    opened = false;

    async connectedCallback() {
        if (this.opened) return; // Prevent double execution
        this.opened = true;

        try {
            const inConsole = await isConsoleNavigation();

            if (inConsole) {
                // Check if wizard tab is already open for this record
                const existingTab = await this.findExistingWizardTab();
                
                if (existingTab) {
                    // Focus existing tab instead of opening new one
                    await this.focusExistingTab(existingTab.tabId);
                } else {
                    // Open new sub-tab
                    await this.openWizardSubtab();
                }
            } else {
                // Fallback: non-console navigation
                await this.openWizardInCurrentTab();
            }
        } catch (error) {
            console.error('Error opening DAO Wizard:', error);
            this.showToast('Error', 'Unable to open DAO Wizard: ' + error.message, 'error');
        } finally {
            // Always close the action modal
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    async findExistingWizardTab() {
        try {
            const allTabs = await getAllTabInfo();
            return allTabs.find(tab => 
                tab.pageReference?.attributes?.apiName === 'DAO_Wizard' &&
                tab.pageReference?.state?.c__recordId === this.recordId
            );
        } catch (error) {
            console.debug('Could not check existing tabs:', error);
            return null;
        }
    }

    async focusExistingTab(tabId) {
        await focusTab({ tabId });
    }

    async openWizardSubtab() {
        const parentTab = await getFocusedTabInfo();
        
        await openSubtab({
            parentTabId: parentTab.tabId,
            pageReference: {
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'DAO_Wizard'
                },
                state: {
                    c__recordId: this.recordId
                }
            },
            focus: true
        });
    }

    async openWizardInCurrentTab() {
        // Fallback for non-console environments
        const url = `/lightning/n/DAO_Wizard?c__recordId=${this.recordId}`;
        window.open(url, '_self');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
