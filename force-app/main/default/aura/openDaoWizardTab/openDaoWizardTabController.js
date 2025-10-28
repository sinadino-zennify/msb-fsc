({
    openTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var recordId = component.get("v.recordId");

        workspaceAPI.getEnclosingTabId()
            .then(function (parentTabId) {
                return workspaceAPI.openSubtab({
                    parentTabId: parentTabId,
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
            .then(function (response) {
                // eslint-disable-next-line no-console
                console.log('Subtab opened: ', response);
            })
            .catch(function (error) {
                // eslint-disable-next-line no-console
                console.error('Subtab error: ', error);
            });
    }
})
