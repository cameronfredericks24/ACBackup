import { LightningElement } from 'lwc';
export default class FslActionCmp extends LightningElement {
    disableStart = true;
    disableReject = false;
    disableCancel = true;
    // Define your action button handlers here
    handleStart(event) {
        // Handle action 1
    }

    handleReject(event) {
        // Handle action 2
    }

    handleCancel(event) {
        // Handle action 3
    }
}