import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FundingAmountModal from 'c/fundingAmountModal';
import getProducts from '@salesforce/apex/ProductSelectionController.getProducts';
import getExistingProducts from '@salesforce/apex/ProductSelectionController.getExistingProducts';

export default class ProductSelection extends LightningElement {
    @api recordId;
    @api wizardApiName;
    @api stepConfig;
    @api value;

    // State
    isLoading = true;
    error;
    selectedCategory = 'all';
    allProducts = [];
    categories = [];
    cartItems = [];
    productDataMap = new Map();

    connectedCallback() {
        this.loadProducts();
    }

    async loadProducts() {
        try {
            this.isLoading = true;
            this.error = null;

            // Determine workflow type (Business vs Consumer)
            const workflowType = this.wizardApiName?.includes('Business') ? 'Business' : 'Consumer';

            // Load products
            const productData = await getProducts({ workflowType });
            
            if (productData) {
                this.allProducts = productData.allProducts || [];
                this.categories = productData.categories || [];
                
                // Build product lookup map
                this.allProducts.forEach(prod => {
                    this.productDataMap.set(prod.id, prod);
                });
            }

            // Load existing cart items if recordId exists
            if (this.recordId) {
                await this.loadExistingCart();
            }

        } catch (error) {
            this.error = error.body?.message || 'Error loading products';
            this.showToast('Error', this.error, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async loadExistingCart() {
        try {
            const existingItems = await getExistingProducts({ applicationFormId: this.recordId });
            if (existingItems && existingItems.length > 0) {
                this.cartItems = existingItems.map(item => ({
                    id: item.id,
                    productId: item.productId,
                    productName: item.productName,
                    productCode: item.productCode,
                    description: item.description,
                    category: item.category,
                    fundingAmount: item.fundingAmount
                }));
                this.emitPayloadChange();
            }
        } catch (error) {
            console.error('Error loading existing products:', error);
        }
    }

    // Category filtering
    handleCategoryFilter(event) {
        this.selectedCategory = event.currentTarget.dataset.category;
    }

    get hasCategories() {
        return this.categories && this.categories.length > 0;
    }

    get allCategoryVariant() {
        return this.selectedCategory === 'all' ? 'brand' : 'neutral';
    }

    get filteredProducts() {
        if (this.selectedCategory === 'all') {
            return this.allProducts;
        }
        return this.allProducts.filter(p => p.category === this.selectedCategory);
    }

    get hasFilteredProducts() {
        return this.filteredProducts && this.filteredProducts.length > 0;
    }

    // Enrich categories with variant for button styling
    get categories() {
        return this._categories.map(cat => ({
            ...cat,
            variant: cat.name === this.selectedCategory ? 'brand' : 'neutral'
        }));
    }

    set categories(value) {
        this._categories = value || [];
    }

    // Product selection
    async handleProductSelect(event) {
        const productId = event.currentTarget.dataset.productId;
        const product = this.productDataMap.get(productId);
        
        if (!product) return;

        // Check if already in cart
        const existingItem = this.cartItems.find(item => item.productId === productId);
        
        // Open modal for funding amount
        const result = await FundingAmountModal.open({
            size: 'small',
            product: product,
            existingAmount: existingItem?.fundingAmount
        });

        if (result) {
            this.addOrUpdateCartItem(result.product, result.fundingAmount, existingItem?.id);
        }
    }

    addOrUpdateCartItem(product, fundingAmount, existingId) {
        const existingIndex = this.cartItems.findIndex(item => item.productId === product.id);
        
        if (existingIndex >= 0) {
            // Update existing
            this.cartItems[existingIndex] = {
                ...this.cartItems[existingIndex],
                fundingAmount: fundingAmount
            };
        } else {
            // Add new
            this.cartItems.push({
                id: existingId || null,
                productId: product.id,
                productName: product.name,
                productCode: product.productCode,
                description: product.description,
                category: product.category,
                fundingAmount: fundingAmount
            });
        }

        // Trigger reactivity
        this.cartItems = [...this.cartItems];
        this.emitPayloadChange();
        
        this.showToast('Success', `${product.name} ${existingIndex >= 0 ? 'updated' : 'added to cart'}`, 'success');
    }

    // Cart management
    async handleEditCartItem(event) {
        const productId = event.detail.productId;
        const cartItem = this.cartItems.find(item => item.productId === productId);
        const product = this.productDataMap.get(productId);
        
        if (!product || !cartItem) return;

        const result = await FundingAmountModal.open({
            size: 'small',
            product: product,
            existingAmount: cartItem.fundingAmount
        });

        if (result) {
            this.addOrUpdateCartItem(result.product, result.fundingAmount, cartItem.id);
        }
    }

    handleRemoveCartItem(event) {
        const productId = event.detail.productId;
        this.cartItems = this.cartItems.filter(item => item.productId !== productId);
        this.emitPayloadChange();
        this.showToast('Success', 'Product removed from cart', 'success');
    }

    handleClearCart() {
        this.cartItems = [];
        this.emitPayloadChange();
        this.showToast('Success', 'Cart cleared', 'success');
    }

    // Enrich cart items with formatted data for display
    get enrichedCartItems() {
        return this.cartItems.map(item => ({
            ...item,
            formattedAmount: new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(item.fundingAmount || 0),
            categoryIcon: this.getCategoryIcon(item.category)
        }));
    }

    getCategoryIcon(category) {
        const iconMap = {
            'Checkings': 'standard:account',
            'Savings': 'standard:savings',
            'Certificates': 'standard:document',
            'Retirement': 'standard:investment_account'
        };
        return iconMap[category] || 'standard:product';
    }

    // Payload management
    emitPayloadChange() {
        this.dispatchEvent(new CustomEvent('payloadchange', {
            detail: { 
                payload: this.payload,
                isDirty: true
            }
        }));
    }

    get payload() {
        return {
            products: this.cartItems.map(item => ({
                id: item.id,
                productId: item.productId,
                productName: item.productName,
                productCode: item.productCode,
                category: item.category,
                description: item.description,
                fundingAmount: item.fundingAmount
            }))
        };
    }

    // Validation
    @api validate() {
        const messages = [];
        if (!this.cartItems || this.cartItems.length === 0) {
            messages.push('Please select at least one product.');
        }
        return {
            isValid: messages.length === 0,
            messages: messages
        };
    }

    @api reset() {
        this.cartItems = [];
        this.selectedCategory = 'all';
        this.emitPayloadChange();
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