import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class FslFileUpload extends LightningElement {
    @api recordId; // Expose recordId property to be set from parent component or record page
    showFileUpload = false;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    workOrder;

    connectedCallback() {
        try {
            this.showFileUploadMethod();
           
        } catch (error) {
            console.log('error-->' + error.message);
        }
    }


    showFileUploadMethod() {
        console.log('in parent' + JSON.stringify(event?.detail));
        this.showFileUpload = true;
    }

    handleBackClick(event) {
        // Emit custom event on back click
        const backClick = new CustomEvent('backclick', {});
        this.dispatchEvent(backClick);
    }

    handleFileUploaded(){

        // Emit custom event on back click
        const backClick = new CustomEvent('backclick', {});
        this.dispatchEvent(backClick);

    }

    handleOnSumbit(event){
        
    }
}