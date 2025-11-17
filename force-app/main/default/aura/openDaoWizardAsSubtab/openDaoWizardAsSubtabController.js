({
    openWizardSubtab: function(component, event, helper) {
        // Close the quick action modal immediately to prevent flash
        $A.get('e.force:closeQuickAction').fire();
        
        var workspaceAPI = component.find("workspace");
        var recordId = component.get("v.recordId");

        // Get the currently focused tab (the record page where the button was clicked)
        workspaceAPI.getFocusedTabInfo()
            .then(function(focusedTab) {
                console.log('Current focused tab:', focusedTab);
                
                // Open wizard as a subtab under the focused tab
                return workspaceAPI.openSubtab({
                    parentTabId: focusedTab.tabId,
                    pageReference: {
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'DAO_Wizard_Container'
                        },
                        state: {
                            c__recordId: recordId
                        }
                    },
                    focus: true
                });
            })
            .then(function(tabId) {
                console.log('Wizard tab opened successfully as subtab:', tabId);
            })
            .catch(function(error) {
                console.error('Error opening wizard tab:', error);
                
                // Fallback: If subtab fails, try opening as primary tab
                workspaceAPI.openTab({
                    pageReference: {
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'DAO_Wizard_Container'
                        },
                        state: {
                            c__recordId: recordId
                        }
                    },
                    focus: true
                }).then(function() {
                    console.log('Wizard opened as primary tab (fallback)');
                }).catch(function(fallbackError) {
                    console.error('Fallback also failed:', fallbackError);
                });
            });
    }
})
