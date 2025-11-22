import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class FundingAmountModal extends LightningModal {
    @api product;
    @api existingAmount;
    
    fundingAmount = 0;
    
    connectedCallback() {
        if (this.existingAmount) {
            this.fundingAmount = this.existingAmount;
        }
    }
    
    get modalTitle() {
        return this.product ? `Add ${this.product.name}` : 'Add Product';
    }
    
    get productDescription() {
        return this.product?.description || '';
    }
    
    get showMinimumWarning() {
        return this.fundingAmount > 0 && this.fundingAmount < 100;
    }
    
    get isAddDisabled() {
        return !this.fundingAmount || this.fundingAmount <= 0;
    }
    
    handleAmountChange(event) {
        this.fundingAmount = event.target.value;
    }
    
    handleCancel() {
        this.close();
    }
    
    handleAddToCart() {
        if (this.fundingAmount && this.fundingAmount > 0) {
            this.close({
                product: this.product,
                fundingAmount: parseFloat(this.fundingAmount)
            });
        }
    }
}