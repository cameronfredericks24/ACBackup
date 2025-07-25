import { LightningElement, track, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WorkOrderOwnerChange extends LightningElement {
    @track workOrderId;
    @track newOwnerId;
    @track error;

    @api recordId;

    connectedCallback() {
        // Set the default value for workOrderId to the current record's Id
        this.workOrderId = this.recordId;
    }

    handleWorkOrderIdChange(event) {
        this.workOrderId = event.target.value;
    }

    handleNewOwnerIdChange(event) {
        this.newOwnerId = event.target.value;
    }

    changeOwner() {
        const fields = {};
        fields['Id'] = this.workOrderId;
        fields['OwnerId'] = this.newOwnerId;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Owner changed successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.error = error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error changing owner',
                        message: this.error,
                        variant: 'error'
                    })
                );
            });
    }
}