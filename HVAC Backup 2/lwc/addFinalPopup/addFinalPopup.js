import { LightningElement } from 'lwc';
export default class AddFinalPopup extends LightningElement {
    closePopup() {
        // Dispatch an event to notify the parent component to close the popup
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }

    handleSave() {
        // Add logic here to handle saving data or any other action
        // For example, you can dispatch an event to notify the parent component about the save action
    }
}