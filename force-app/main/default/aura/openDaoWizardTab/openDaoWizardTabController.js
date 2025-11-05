({
    openTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var recordId = component.get("v.recordId");

        workspaceAPI.getEnclosingTabId()
            .then(function (parentTabId) {
                if (!parentTabId) {
                    // Fallback: open a primary tab if no parent tab context is available
                    return workspaceAPI.openTab({
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
                }

                // Default: open a subtab under the enclosing parent tab
                return workspaceAPI.openSubtab({
                    parentTabId: parentTabId,
                    pageReference: {
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'DAO_Wizard_Container' // Must match Lightning App Page API Name
                        },
                        state: {
                            c__recordId: recordId
                        }
                    },
                    focus: true
                });
            })
            .then(function (tabId) {
                // eslint-disable-next-line no-console
                console.log('Tab opened successfully:', tabId);
                // Close the quick action modal once navigation succeeds
                $A.get('e.force:closeQuickAction').fire();
            })
            .catch(function (error) {
                // eslint-disable-next-line no-console
                console.error('Error opening tab:', error);
                // Best-effort close to avoid leaving the modal open on failures
                try { $A.get('e.force:closeQuickAction').fire(); } catch (e) { /* no-op */ }
            });
    }
})
