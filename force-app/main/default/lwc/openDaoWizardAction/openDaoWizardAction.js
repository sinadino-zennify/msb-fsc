import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getFocusedTabInfo, openSubtab, openTab } from 'lightning/platformWorkspaceApi';

export default class OpenDaoWizardAction extends LightningElement {
    @api recordId;
    
    @api invoke() {
        // Close the quick action modal immediately to prevent flash
        this.dispatchEvent(new CloseActionScreenEvent());
        
        // This method is called when the action is invoked
        this.openWizardAsSubtab();
    }

    async openWizardAsSubtab() {
        try {
            // Get the currently focused tab (the record page where the button was clicked)
            const focusedTab = await getFocusedTabInfo();
            console.log('LWC: Current focused tab:', JSON.stringify(focusedTab));
            
            // Validate we have a valid parent tab ID
            if (!focusedTab || !focusedTab.tabId) {
                console.warn('LWC: No valid parent tab found, falling back to primary tab');
                throw new Error('No valid parent tab');
            }
            
            // Open wizard as a subtab under the focused tab
            const subtabId = await openSubtab({
                parentTabId: focusedTab.tabId,
                pageReference: {
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'DAO_Wizard_Container'
                    },
                    state: {
                        c__recordId: this.recordId
                    }
                },
                focus: true
            });
            
            console.log('LWC: Wizard opened as subtab:', subtabId);
            
        } catch (error) {
            console.error('LWC: Error opening wizard as subtab:', error);
            
            // Fallback: try opening as primary tab
            try {
                await openTab({
                    pageReference: {
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'DAO_Wizard_Container'
                        },
                        state: {
                            c__recordId: this.recordId
                        }
                    },
                    focus: true
                });
                console.log('LWC: Wizard opened as primary tab (fallback)');
            } catch (fallbackError) {
                console.error('LWC: Fallback also failed:', fallbackError);
            }
        }
    }
}
