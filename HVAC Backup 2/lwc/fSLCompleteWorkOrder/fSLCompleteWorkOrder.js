import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import getWorkRecord from '@salesforce/apex/StartWorkController.getWorkRecord';



export default class FSLCompleteWorkOrder extends LightningElement {
    @api recordId; // Expose recordId property to be set from parent component or record page
    //showLocationoffStatus=true;
    //islocationavailable=false;
    showFileUpload = false
    showOTPForm = false; // Hide OTP validation form initially
    // @api islocationavailable;
    isBreakdown = false;
    showFailureForm = false;
    errorMessage;
    showErrorMessage = false;
    woStatus;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    workOrder;

    connectedCallback() {
        try {
            this.checkWorkOrderStatus();
            //this.handleNext();
            // this.handleChildSubmit()
            //  this.showOtpFormMethod();
        } catch (error) {
            console.log('error-->' + error.message);
        }
    }

    /*handleLocationService(event){
        this.islocationavailable=false;
        this.showFileUpload= true;
    }*/
    checkWorkOrderStatus() {
        getWorkRecord({ recordId: this.recordId })
            .then(result => {
                const status = result.Status;
                if (status == 'Completed' || status == 'Closed') {
                    this.errorMessage = 'Work Order is already Completed';
                    this.showErrorMessage = true;
                } else if (status != 'In Progress') {
                    this.errorMessage = 'Work is not started, click on Start Work';
                    this.showErrorMessage = true;
                } else if (status == 'In Progress') {
                    this.showErrorMessage = false;
                    //this.handleFileUploaded();
                    this.showOtpFormMethod();
                }


            });


    }
    handleNoLocationDetected() {
        this.islocationavailable = false;
        this.showFileUpload = false;
    }

    handleFileUploaded() {
        // This method is called when the file is uploaded successfully

        this.showFileUpload = true;

    }

    handleNext() {
        // This method is called when the 'Next' button is clicked
        // Switch to OTP validation form
        this.showFileUpload = false;
        this.showOTPForm = true;
    }
    showOtpFormMethod(event) {
        console.log('in parent' + JSON.stringify(event?.detail));
       this.showFileUpload = false;
        this.showFailureForm = false;
        this.showOTPForm = true;


    }

    handleOTPVerification(event) {
        console.log('detail - ', event.detail);
        console.log('detail - ', event.detail.otpSuccess);

        // Emit custom event on success
        const otpVerificationSuccessEvent = new CustomEvent('otpverificationsuccess', {
            detail: { success: true }
        });
        this.dispatchEvent(otpVerificationSuccessEvent);

    }


    showFailureFormMethod(event) {
        console.log('in parent' + JSON.stringify(event?.detail));
        // if(event?.detail?.Success){
        //if (this.workOrder.data && this.workOrder.data.fields.Work_Type_Name__c.value == 'Breakdown') {
        //  this.isBreakdown = true;
        //}
        //if(this.isBreakdown){
        this.showFileUpload = false;
        this.showFailureForm = true;
        // } else{
        // this.showFileUpload = false;
        //  this.showOTPForm = true;
        // }

        // }

    }

    handleBackClick(event) {
        // Emit custom event on back click
        const backClick = new CustomEvent('backclick', {});
        this.dispatchEvent(backClick);
    }


}