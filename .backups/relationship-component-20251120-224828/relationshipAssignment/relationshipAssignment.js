import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelationshipData from '@salesforce/apex/RelationshipAssignmentController.getRelationshipData';
import saveRoleAssignments from '@salesforce/apex/RelationshipAssignmentController.saveRoleAssignments';

export default class RelationshipAssignment extends LightningElement {
    // Standard wizard step properties
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    
    // Legacy properties (kept for backward compatibility)
    @api applicationFormId;
    @api workflowType = 'Business';

    _value = {};
    @track products = [];
    @track applicants = [];
    @track assignments = new Map();
    
    isLoading = false;
    error = null;
    hasRendered = false;
    
    // Value setter for wizard resume functionality
    @api
    get value() {
        return this._value;
    }
    
    set value(val) {
        this._value = val || {};
        // If value contains relationship data, process it
        if (val && val.assignments && Array.isArray(val.assignments)) {
            // Store the assignments to be used when building grid
            this.preloadedAssignments = val.assignments;
            // If we already have products and applicants loaded, rebuild the grid
            if (this.products.length > 0 && this.applicants.length > 0) {
                this.buildGridData(this.preloadedAssignments);
            }
        }
    }
    
    // Get the effective application form ID (recordId takes precedence)
    get effectiveApplicationFormId() {
        return this.recordId || this.applicationFormId;
    }

    roleOptions = [
        { label: 'Primary', value: 'Primary' },
        { label: 'Joint', value: 'Joint' },
        { label: 'Authorized Signer', value: 'Authorized Signer' },
        { label: 'Beneficiary', value: 'Beneficiary' }
    ];

    connectedCallback() {
        // eslint-disable-next-line no-console
        console.log('🔌 Component Connected - Loading Data');
        if (this.effectiveApplicationFormId) {
            this.loadRelationshipData();
        }
    }

    renderedCallback() {
        // Refresh data when component becomes visible again
        if (!this.hasRendered && this.effectiveApplicationFormId) {
            this.hasRendered = true;
            // eslint-disable-next-line no-console
            console.log('🎨 First Render - Data already loaded in connectedCallback');
        }
    }

    @api
    refresh() {
        // eslint-disable-next-line no-console
        console.log('🔄 Refresh called - Reloading data');
        this.loadRelationshipData();
    }

    processRelationshipData(data) {
        this.applicants = data.applicants || [];
        this.products = data.products || [];
        
        // eslint-disable-next-line no-console
        console.log('🔍 Relationship Data Loaded:');
        // eslint-disable-next-line no-console
        console.log('Products:', this.products);
        // eslint-disable-next-line no-console
        console.log('Applicants:', this.applicants);
        // eslint-disable-next-line no-console
        console.log('Existing Assignments:', data.existingAssignments);
        
        // Use preloaded assignments from value if available, otherwise use data from Apex
        const assignmentsToUse = this.preloadedAssignments || data.existingAssignments || [];
        
        // Build grid data structure
        this.buildGridData(assignmentsToUse);
        
        // eslint-disable-next-line no-console
        console.log('Grid Data:', this.gridData);
    }

    buildGridData(existingAssignments) {
        // eslint-disable-next-line no-console
        console.log('🏗️ Building Grid Data');
        // eslint-disable-next-line no-console
        console.log('Products:', this.products);
        // eslint-disable-next-line no-console
        console.log('Applicants:', this.applicants);
        // eslint-disable-next-line no-console
        console.log('Existing Assignments:', existingAssignments);
        
        this.gridData = this.products.map(product => {
            const applicantRoles = this.applicants.map(applicant => {
                // Find existing assignment for this product-applicant combination
                const existing = existingAssignments.find(
                    assignment => assignment.productId === product.id && assignment.applicantId === applicant.id
                );
                
                const selectedRoles = existing ? existing.roles : [];
                
                // eslint-disable-next-line no-console
                if (existing) {
                    console.log(`✅ Found existing for Product ${product.id} + Applicant ${applicant.id}:`, existing.roles);
                } else {
                    console.log(`❌ No existing for Product ${product.id} + Applicant ${applicant.id}`);
                }
                
                // Build role checkboxes with checked state
                const roleCheckboxes = this.roleOptions.map(roleOption => ({
                    ...roleOption,
                    checked: selectedRoles.includes(roleOption.value)
                }));
                
                // eslint-disable-next-line no-console
                console.log(`Checkboxes for ${applicant.id}:`, roleCheckboxes);
                
                return {
                    applicantId: applicant.id,
                    selectedRoles: selectedRoles,
                    roleCheckboxes: roleCheckboxes
                };
            });
            
            return {
                productId: product.id,
                productName: product.name,
                productCode: product.productCode,
                fundingAmount: product.fundingAmount,
                applicantRoles: applicantRoles
            };
        });

        // Store assignments in map for easy access
        this.updateAssignmentsMap();
    }

    updateAssignmentsMap() {
        this.assignments = new Map();
        this.gridData.forEach(row => {
            row.applicantRoles.forEach(applicantRole => {
                const key = `${row.productId}_${applicantRole.applicantId}`;
                if (applicantRole.selectedRoles && applicantRole.selectedRoles.length > 0) {
                    this.assignments.set(key, {
                        productId: row.productId,
                        applicantId: applicantRole.applicantId,
                        roles: applicantRole.selectedRoles
                    });
                }
            });
        });
    }

    handleRoleChange(event) {
        const productId = event.currentTarget.dataset.productId;
        const applicantId = event.currentTarget.dataset.applicantId;
        const roleValue = event.currentTarget.dataset.roleValue;
        const isChecked = event.detail.checked;

        // eslint-disable-next-line no-console
        console.log('🔄 Role Change:', { productId, applicantId, roleValue, isChecked });

        // Update gridData with new role selection
        this.gridData = this.gridData.map(row => {
            if (row.productId === productId) {
                return {
                    ...row,
                    applicantRoles: row.applicantRoles.map(applicantRole => {
                        if (applicantRole.applicantId === applicantId) {
                            let updatedRoles = [...(applicantRole.selectedRoles || [])];
                            
                            if (isChecked) {
                                // Add role if not already present
                                if (!updatedRoles.includes(roleValue)) {
                                    updatedRoles.push(roleValue);
                                }
                            } else {
                                // Remove role
                                updatedRoles = updatedRoles.filter(r => r !== roleValue);
                            }
                            
                            // eslint-disable-next-line no-console
                            console.log('Updated Roles for', applicantId, ':', updatedRoles);
                            
                            // Rebuild roleCheckboxes with updated checked state
                            const roleCheckboxes = this.roleOptions.map(roleOption => ({
                                ...roleOption,
                                checked: updatedRoles.includes(roleOption.value)
                            }));
                            
                            return {
                                ...applicantRole,
                                selectedRoles: updatedRoles,
                                roleCheckboxes: roleCheckboxes
                            };
                        }
                        return applicantRole;
                    })
                };
            }
            return row;
        });

        this.updateAssignmentsMap();
        this.emitPayloadChange();
    }

    handleSetPrimaryAsOwner() {
        const primaryApplicant = this.applicants.find(app => app.isPrimary);
        if (!primaryApplicant) {
            this.showToast('Warning', 'No primary applicant found', 'warning');
            return;
        }

        this.gridData = this.gridData.map(row => {
            return {
                ...row,
                applicantRoles: row.applicantRoles.map(applicantRole => {
                    if (applicantRole.applicantId === primaryApplicant.id) {
                        return {
                            ...applicantRole,
                            selectedRoles: ['Primary']
                        };
                    }
                    return applicantRole;
                })
            };
        });

        this.updateAssignmentsMap();
        this.emitPayloadChange();
        this.showToast('Success', 'Primary applicant set as owner on all products', 'success');
    }

    handleClearAll() {
        this.gridData = this.gridData.map(row => {
            return {
                ...row,
                applicantRoles: row.applicantRoles.map(applicantRole => {
                    return {
                        ...applicantRole,
                        selectedRoles: []
                    };
                })
            };
        });

        this.assignments.clear();
        this.emitPayloadChange();
        this.showToast('Success', 'All assignments cleared', 'success');
    }

    loadRelationshipData() {
        if (!this.effectiveApplicationFormId) {
            // eslint-disable-next-line no-console
            console.warn('⚠️ No application form ID available');
            return;
        }
        
        this.isLoading = true;
        getRelationshipData({ applicationFormId: this.effectiveApplicationFormId })
            .then(data => {
                this.processRelationshipData(data);
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error.body?.message || 'Error loading relationship data';
                this.isLoading = false;
                this.showToast('Error', this.error, 'error');
            });
    }

    // Emit payload change for wizard integration
    emitPayloadChange() {
        // eslint-disable-next-line no-console
        console.log('📤 Emitting Payload Change:', this.payload);
        const event = new CustomEvent('payloadchange', {
            detail: { payload: this.payload }
        });
        this.dispatchEvent(event);
    }

    // Payload for wizard persistence
    get payload() {
        const assignmentsList = [];
        this.assignments.forEach((assignment) => {
            assignmentsList.push(assignment);
        });
        return {
            assignments: assignmentsList
        };
    }

    // Validation
    @api validate() {
        const messages = [];
        
        // Check if each product has at least one Primary role assigned
        this.gridData.forEach(row => {
            let hasPrimary = false;
            row.applicantRoles.forEach(applicantRole => {
                if (applicantRole.selectedRoles && applicantRole.selectedRoles.includes('Primary')) {
                    hasPrimary = true;
                }
            });
            
            if (!hasPrimary) {
                messages.push(`Product "${row.productName}" must have at least one Primary owner assigned.`);
            }
        });

        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        this.products = [];
        this.applicants = [];
        this.assignments.clear();
        this.loadRelationshipData();
    }

    // Computed properties
    get showGrid() {
        return !this.isLoading && !this.error && this.gridData && this.gridData.length > 0 && this.applicants.length > 0;
    }

    get showNoProductsMessage() {
        return !this.isLoading && !this.error && (!this.gridData || this.gridData.length === 0);
    }

    // Utility
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}