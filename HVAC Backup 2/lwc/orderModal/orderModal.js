import { LightningElement, api } from 'lwc';

export default class OrderModal extends LightningElement {
    @api isModalOpen = false;

    handleSelection(event) {
        const selectedOption = event.target.value;
        this.closeModal();
        // Dispatch a custom event with the selected value
        this.dispatchEvent(new CustomEvent('selection', {
            detail: selectedOption
        }));
    }

    closeModal() {
        this.isModalOpen = false;
    }

    get options() {
        return [
            { label: 'MSL', value: 'msl' },
            { label: 'Sales Order', value: 'sales_order' }
        ];
    }
}