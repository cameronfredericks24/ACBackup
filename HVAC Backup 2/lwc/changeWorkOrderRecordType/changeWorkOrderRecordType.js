import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getRecordTypeName from '@salesforce/apex/ChangeWorkOrderRecordTypeController.getRecordTypeName';
import toggleRecordType from '@salesforce/apex/ChangeWorkOrderRecordTypeController.toggleRecordType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = [
    'WorkOrder.RecordType.DeveloperName'
];

export default class ChangeWorkOrderRecordType extends LightningElement {
    @api recordId;
    currentRecordType;
    nextRecordType;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredWorkOrder({ error, data }) {
        if (data) {
            this.currentRecordType = getFieldValue(data, 'WorkOrder.RecordType.DeveloperName');
            this.nextRecordType = this.currentRecordType === 'Breakdown' ? 'Regular Service' : 'Breakdown';
        } else if (error) {
            this.showToast('Error', 'Error loading work order record', 'error');
        }
    }

    handleUpdate() {
        toggleRecordType({ workOrderId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Work Order record type updated successfully', 'success');
                // Refresh the record view to show updated record type
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}