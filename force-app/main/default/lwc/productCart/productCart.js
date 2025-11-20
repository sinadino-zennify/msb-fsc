import { LightningElement, api } from 'lwc';

export default class ProductCart extends LightningElement {
    @api cartItems = [];
    
    get hasItems() {
        return this.cartItems && this.cartItems.length > 0;
    }
    
    get cartItemCount() {
        return this.cartItems ? this.cartItems.length : 0;
    }
    
    get totalFunding() {
        if (!this.cartItems || this.cartItems.length === 0) {
            return '$0.00';
        }
        
        const total = this.cartItems.reduce((sum, item) => {
            return sum + (item.fundingAmount || 0);
        }, 0);
        
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(total);
    }
    
    handleEdit(event) {
        const productId = event.currentTarget.dataset.productId;
        this.dispatchEvent(new CustomEvent('edititem', {
            detail: { productId }
        }));
    }
    
    handleRemove(event) {
        const productId = event.currentTarget.dataset.productId;
        this.dispatchEvent(new CustomEvent('removeitem', {
            detail: { productId }
        }));
    }
    
    handleClearAll() {
        this.dispatchEvent(new CustomEvent('clearall'));
    }
}