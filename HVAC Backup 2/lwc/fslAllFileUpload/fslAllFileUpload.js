import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class FslFileUpload extends LightningElement {
    @api recordId; // Expose recordId property to be set from parent component or record page
    @api isCommissioning;
    showFileUpload = false;

        @track isFileUploaded = false;
    @track uploadedFileNames = [];

    @track isInvoiceFile = true;

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

    handleFileUploaded() {
        // Handle general file upload
        console.log('File uploaded');
        const fileUploaded = new CustomEvent('fileuploaded', {});
        this.dispatchEvent(fileUploaded);


    }

    handleFilesChange(event) {
        const files = event.target.files;
        if (files.length > 0) {
            const selectedFile = files[0];
            console.log('Selected file:', selectedFile);

            // Add your file handling logic here
            // e.g., file validation, upload process, etc.

            // Example: Trigger a custom event after file selection
            const fileUploadedEvent = new CustomEvent('fileuploaded', {
                detail: { fileName: selectedFile.name }
            });
            this.dispatchEvent(fileUploadedEvent);
        }
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        //let uploadedFileNames = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            //this.uploadedFileNames.push(uploadedFiles[i].name);
            this.uploadedFileNames.push({
                name: uploadedFiles[i].name,
                id: uploadedFiles[i].documentId
            });
            this.isFileUploaded = true;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message:
                    uploadedFiles.length +
                    " Files uploaded Successfully: " +
                    this.uploadedFileNames,
                variant: "success"
            })
        );
        console.log("uploadedFileNames -- " + this.uploadedFileNames);
        console.log("isFileUploaded -- " + this.isFileUploaded);
    }
}