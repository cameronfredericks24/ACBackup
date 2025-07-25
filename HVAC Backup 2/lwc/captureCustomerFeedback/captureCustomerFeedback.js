/* eslint-disable no-undef */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFeedback from '@salesforce/apex/CustomerFeedbackController.saveFeedback';
import getTechnicianDetails from '@salesforce/apex/CustomerFeedbackController.getTechnicianDetails';
import { NavigationMixin } from 'lightning/navigation';
import LightningAlert from 'lightning/alert';




export default class CaptureCustomerFeedback extends NavigationMixin(LightningElement) {
    @api recordId;
    @track technicianRating;
    @track customerName;

    @api mainScreenVisibility;
    @api feedbackVisibility;

    @track showSpinner = false;
    @track technician;

    @track customerComments = '';

    @track isLessRating = false;
    imgSrc;

    connectedCallback() {

        this.fetchTechnician();
        // Add event listener for the popstate event
        window.addEventListener('popstate', this.handlePopState.bind(this));
    }

    fetchTechnician(){

        getTechnicianDetails()
        .then(result=>{

            console.log('result - ', result);
            this.technician = JSON.parse(result);



        })
        .catch(error=>{

            console.log('error - ', error);
        })


    }

    get technicianName() {
        return this.technician ? this.technician.Name : '';
    }

    get technicianCode() {
        return this.technician ? this.technician.Employee_Number__c : '';
    }

    // Handle the popstate event
    handlePopState(event) {
        const state = history.state;
        // Check if the state indicates a navigation to the parent component
        if (state && state.component === 'parent') {
            // Update component state accordingly
            this.mainScreenVisibility = true;
            this.captureFeedbackVisibility = false;
        }
    }

    handleRatingChange(event) {
        // this.technicianRating = event.target.checked ? event.target.value : null;

        this.technicianRating = event.target.value;
        console.log('technicianRating---', this.technicianRating);

        if(this.technicianRating < 3){
            this.isLessRating = true;
        }
        else{
            this.isLessRating = false;

        }
    }

    handleTextInput(event) {
        this.customerName = event.detail.inputText;
        console.log('customer name - ',event.detail.inputText);
        // Handle the input text received from the child component
        console.log('name:', this.customerName);

        //   LightningAlert.open({
        //         message: 'handleTextInput - ' + this.customerCode,
        //         theme: 'success', // a red theme intended for error states
        //         label: 'success!', // this is the header text
        //     });
    }

    customerCodeChangeHandler(event){

        this.customerCode = event.detail.customerCode;

            //  LightningAlert.open({
            //     message: 'customerCode - ' + this.customerCode,
            //     theme: 'success', // a red theme intended for error states
            //     label: 'success!', // this is the header text
            // });

        console.log('customer name - ',event.detail.customerCode);
        // Handle the input text received from the child component
        console.log('customerCode:', this.customerCode);

    }

    commentChangeHandler(event){

        this.customerComments = event.detail.value;

    }

    saveSignature() {
        const pad = this.template.querySelector("c-signature-pad");
        if (pad) {
            const dataURL = pad.getSignature();
            if (dataURL) {
                // At this point you can consume the signature, for example by saving
                // it to disk or uploading it to a Salesforce org/record.
                // Here we just preview it in an image tag.
                this.imgSrc = dataURL;
            }
        }
    }

    clearSignature() {
        const pad = this.template.querySelector("c-signature-pad");
        if (pad) {
            pad.clearSignature();
        }

        this.imgSrc = null;
        //this.customerCode ='';
    }

    handleSubmit() {
        this.showSpinner = true;
        const pad = this.template.querySelector("c-signature-pad");
        if (pad) {
            const dataURL = pad.getSignature();
            if (dataURL) {
                this.imgSrc = dataURL;
            }
        }
        if (!this.imgSrc) {
            this.showToast('Error', 'Please enter the signature', 'error');
            this.showSpinner = false;

            return;
        }
        if (!this.technicianRating) {
            this.showToast('Error', 'Please select a rating for the technician', 'error');
            this.showSpinner = false;

            return;
        }
        // if (!this.customerName) {
        //     this.showToast('Error', 'Please enter the customer name', 'error');
        //     this.showSpinner = true;

        //     return;
        // }

        saveFeedback({
            recordId: this.recordId,
            customerComments: this.customerComments,
            technicianRating: this.technicianRating,
            customerName: this.customerCode,
            base64Data: this.imgSrc.split(',')[1],
            fileName: 'Signature.png'
        })
            .then(result => {
                console.log('result:', result);
                this.showToast('Success', 'Feedback saved successfully', 'success');
                this.clearSignature();

                this.showSpinner = false;

                // Emit custom event on success
                const feedbackSubmittedEvent = new CustomEvent('feedbacksubmitted', {
                    detail: { success: true }
                });
                this.dispatchEvent(feedbackSubmittedEvent);

                console.log('feedbackSubmittedEvent:', JSON.stringify(feedbackSubmittedEvent));

            })
            .catch(error => {
                this.showSpinner = false;
                console.log('error -', error);

                this.showToast('Error', 'Error while saving feedback', 'error');
            });

        this.technicianRating = null;
        const starInputs = this.template.querySelectorAll('input[name="technician"]');
        starInputs.forEach(input => {
            input.checked = false;
        });
        console.log('technicianRating reset:', this.technicianRating);
    }

    backClickHandle(){
          // Emit custom event on back click
    const backClick = new CustomEvent('backclick', {});
    this.dispatchEvent(backClick);
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    onclickHandler(){

        url = "com.salesforce.fieldservice://v1/sObject/0WOBi000001uaq0OAA/Create_Service_Report";

        this[NavigationMixin.Navigate]({

            "type": "standard__webPage",
        
            "attributes": {
        
                "url": url 
            }
        
        });

    }
}