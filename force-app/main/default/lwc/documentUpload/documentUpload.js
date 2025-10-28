import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DocumentUpload extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value = {};

    @track documents = [];
    @track showModal = false;
    @track currentDocument = {};
    @track editingIndex = -1;

    // Document type options
    documentTypeOptions = [
        { label: 'Driver\'s License', value: 'drivers_license' },
        { label: 'Passport', value: 'passport' },
        { label: 'State ID', value: 'state_id' },
        { label: 'Social Security Card', value: 'ssn_card' },
        { label: 'Birth Certificate', value: 'birth_certificate' },
        { label: 'Articles of Incorporation', value: 'articles_incorporation' },
        { label: 'Operating Agreement', value: 'operating_agreement' },
        { label: 'Tax ID Letter', value: 'tax_id_letter' },
        { label: 'Business License', value: 'business_license' },
        { label: 'Bank Statement', value: 'bank_statement' },
        { label: 'Utility Bill', value: 'utility_bill' },
        { label: 'Other', value: 'other' }
    ];

    connectedCallback() {
        // Initialize documents from existing value
        if (this.value && this.value.documents) {
            this.documents = [...this.value.documents];
        }
    }

    get hasDocuments() {
        return this.documents.length > 0;
    }

    get modalTitle() {
        return this.editingIndex >= 0 ? 'Edit Document' : 'Add Document';
    }

    get saveButtonLabel() {
        return this.editingIndex >= 0 ? 'Update Document' : 'Add Document';
    }

    get acceptedFormats() {
        return '.pdf,.jpg,.jpeg,.png,.gif,.doc,.docx';
    }

    handleAddDocument() {
        this.currentDocument = {
            id: Date.now().toString(),
            name: '',
            type: '',
            description: '',
            fileName: '',
            fileSize: 0,
            uploadDate: new Date().toISOString().split('T')[0]
        };
        this.editingIndex = -1;
        this.showModal = true;
    }

    handleEditDocument(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.currentDocument = { ...this.documents[index] };
        this.editingIndex = index;
        this.showModal = true;
    }

    handleDeleteDocument(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.documents.splice(index, 1);
        this.dispatchPayloadChange();
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Document deleted successfully',
            variant: 'success'
        }));
    }

    handleCloseModal() {
        this.showModal = false;
        this.currentDocument = {};
        this.editingIndex = -1;
    }

    handleNameChange(event) {
        this.currentDocument.name = event.target.value;
    }

    handleTypeChange(event) {
        this.currentDocument.type = event.target.value;
    }

    handleDescriptionChange(event) {
        this.currentDocument.description = event.target.value;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            const file = uploadedFiles[0];
            this.currentDocument.fileName = file.name;
            this.currentDocument.fileSize = file.size;
            this.currentDocument.contentDocumentId = file.documentId;
            
            // Auto-populate name if empty
            if (!this.currentDocument.name) {
                this.currentDocument.name = file.name.split('.')[0];
            }
        }
    }

    handleSaveDocument() {
        // Validate required fields
        if (!this.currentDocument.name || !this.currentDocument.type) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill in all required fields',
                variant: 'error'
            }));
            return;
        }

        if (this.editingIndex >= 0) {
            // Update existing document
            this.documents[this.editingIndex] = { ...this.currentDocument };
        } else {
            // Add new document
            this.documents.push({ ...this.currentDocument });
        }

        this.dispatchPayloadChange();
        this.handleCloseModal();

        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: this.editingIndex >= 0 ? 'Document updated successfully' : 'Document added successfully',
            variant: 'success'
        }));
    }

    dispatchPayloadChange() {
        const payload = this.payload;
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: { payload }
        }));
    }

    @api
    get payload() {
        return {
            documents: this.documents,
            documentCount: this.documents.length
        };
    }

    @api
    validate() {
        // This step is optional, so always return true
        return {
            isValid: true,
            errorMessage: null
        };
    }

    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    getDocumentTypeLabel(value) {
        const option = this.documentTypeOptions.find(opt => opt.value === value);
        return option ? option.label : value;
    }
}
