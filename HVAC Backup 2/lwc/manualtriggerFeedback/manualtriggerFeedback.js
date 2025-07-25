import { api, LightningElement, track } from 'lwc';
import sendSurveyLink from '@salesforce/apex/ManualFeedbackSendController.sendSurveyLink';

export default class ManualtriggerFeedback extends LightningElement {
    @track workOrderId = '';
    @api recordId;
    @track message = '';
    @track messageClass = 'slds-text-color_error';
    showSpinner = false;

    connectedCallback(){
        this.showSpinner = true;
        this.sendSurveyLinkMethod();
    }

    sendSurveyLinkMethod() {
        
        sendSurveyLink({ workOrderId: this.recordId })
            .then(result => {
               // this.surveyInvitations = result;
                this.message = result;
                this.messageClass = 'slds-text-color_success';
                this.showSpinner = false;
            })
            .catch(error => {
                this.message = 'Error sending Survey Invitations: ' + error.body.message;
                this.messageClass = 'slds-text-color_error';
                this.showSpinner = false;
            });
    }
}