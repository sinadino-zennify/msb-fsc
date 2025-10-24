import { LightningElement, track, api } from 'lwc';

export default class ComponentPlaceholder extends LightningElement {
    @api recordId;
    @track componentName = 'Component Placeholder';

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('back'));
    }
}
