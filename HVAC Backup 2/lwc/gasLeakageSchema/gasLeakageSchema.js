import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateWorkOrder from '@salesforce/apex/GasLeakageSchemaController.updateWorkOrder'; // Apex method to update WorkOrder fields

export default class GasLeakageSchema extends LightningElement {
    @track partType = '';
    @track showSelection = true;
    @track showIDUData = false;
    @track showODUData = false;
    @track selectedIDU = [];
    @track selectedODU = [];
    @track isSaving = false; // To handle save button state
    @track isUpdating = false;
    @track showMessage = false;
    @track saveMessage = '';  
    @api recordId; // Assuming recordId is the WorkOrder Id
    spinner = false;

    options = [
        { label: 'IDU', value: 'IDU' },
        { label: 'ODU', value: 'ODU' },
        { label: 'Both', value: 'Both' }
    ];

    // Sample part data for IDU and ODU parts
    iduParts = [
        { value: 1, label: 'EV-FL', show: true, checked: false },
        { value: 2, label: 'EV-SLB', show: true, checked: false },
        { value: 3, label: 'EV-PIPE', show: true, checked: false },
        { value: 4, label: 'EV-U', show: true, checked: false },
        { value: 5, label: 'Ev-TS', show: true, checked: false },
        { value: 6, label: 'EV-H', show: true, checked: false },
        { value: 7, label: 'Ev-IL', show: true, checked: false },
        { value: 8, label: 'EV-U Br', show: true, checked: false },
        { value: 9, label: 'EV-D', show: true, checked: false },
        { value: 10, label: 'EV-HP', show: true, checked: false }
    ];

    oduParts = [
        { value: 1, label: 'CD-STUB', show: true, checked: false },
        { value: 2, label: 'CD-H', show: true, checked: false },
        { value: 3, label: 'CD-TS', show: true, checked: false },
        { value: 4, label: 'CD-US', show: true, checked: false },
        { value: 5, label: 'CD-LSJ', show: true, checked: false },
        { value: 6, label: 'CD-FL', show: true, checked: false },
        { value: 7, label: 'CD-AV', show: true, checked: false },
        { value: 8, label: 'CD-DIS', show: true, checked: false },
        { value: 9, label: 'CD-COMP', show: true, checked: false },
        { value: 10, label: 'CD-Su B', show: true, checked: false },
        { value: 11, label: 'CD-THERM', show: true, checked: false },
        { value: 12, label: 'CD-DB', show: true, checked: false },
        { value: 13, label: 'CD-U Br', show: true, checked: false },
        { value: 14, label: 'CD-ACC', show: true, checked: false },
        { value: 15, label: 'CD-HP', show: true, checked: false },
        { value: 16, label: 'CD-TS', show: true, checked: false },
        { value: 17, label: 'CD-IL', show: true, checked: false }
    ];

    connectedCallback() {
        console.log('Component initialized with recordId:', this.recordId);
    }

    handleSelectionChange(event) {
    this.partType = event.target.value;
    console.log('Part type selected:', this.partType);
    
    // Update visibility based on part type selection
    if (this.partType === 'IDU') {
        this.showIDUData = true;
        this.showODUData = false;
    } else if (this.partType === 'ODU') {
        this.showIDUData = false;
        this.showODUData = true;
    } else if (this.partType === 'Both') {
        this.showIDUData = true;
        this.showODUData = false;
    } else {
        this.showIDUData = false;
        this.showODUData = false;
    }
}

    handleBack() {
        console.log('Back button clicked.');
        if (this.partType === 'Both' && this.showODUData) {
            console.log('Navigating back to IDU data from ODU data.');
            this.showODUData = false;
            this.showIDUData = true;
        } else {
            console.log('Navigating back to part selection.');
            this.showIDUData = false;
            this.showODUData = false;
            this.showSelection = true;
        }
    }

    handleNext() {
        console.log('Next button clicked.');
        if (this.partType === 'Both' && this.showIDUData) {
            console.log('Hiding IDU data and showing ODU data.');
            this.showIDUData = false;
            this.showODUData = true;
        }
    }

    handleIDUSelect(event) {
        console.log('handleIDUSelect', JSON.stringify(event.detail.value));
        this.selectedIDU = event.detail.value;
        console.log('IDU parts selected:', JSON.stringify(this.selectedIDU));
    }

    handleODUSelect(event) {
        console.log('handleODUSelect', JSON.stringify(event.detail.value));
        this.selectedODU = event.detail.value;
        console.log('ODU parts selected:', JSON.stringify(this.selectedODU));
    }

    handleSave() {
        console.log('Saving selected parts for Work Order:', this.recordId);
        console.log('Selected IDU parts:', JSON.stringify(this.selectedIDU));
        console.log('Selected ODU parts:', JSON.stringify(this.selectedODU));

        this.spinner = true;
        // Check if any parts are selected
        if (this.selectedIDU.length === 0 && this.selectedODU.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No parts selected for IDU or ODU',
                    variant: 'error'
                })
            );
            return;
        }

        // Prepare the payload to update the Work Order fields
        const fields = {
            Id: this.recordId,
            IDU_Gas_Leakage_Parts__c: this.selectedIDU.join(';'),
            ODU_Gas_Leakage_Parts__c: this.selectedODU.join(';')
        };

        console.log('Fields to update:', fields);

        // Start spinner and disable the Save button
        this.isSaving = true;

        // Call Apex method to update the Work Order
        updateWorkOrder({ fields })
            .then(() => {
                console.log('Work Order updated successfully.');
                this.spinner = false;
                // Show success message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Work Order updated successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error('Error updating Work Order:', JSON.stringify(error));
                // Show error message
                this.spinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                // Stop spinner and enable the Save button
                this.isSaving = false;
                this.spinner = false;
            });
    }

    get showNextButton() {
        return this.partType === 'Both' && this.showIDUData;
    }

    get cardTitle() {
        if (this.showIDUData) {
            return 'IDU Data';
        } else if (this.showODUData) {
            return 'ODU Data';
        } else {
            return 'Part Selection';
        }
    }
}