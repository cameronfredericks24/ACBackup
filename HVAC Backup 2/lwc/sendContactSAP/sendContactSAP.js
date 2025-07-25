import { LightningElement, track ,api,wire } from 'lwc';
import sendToSAP from '@salesforce/apex/SendContactDetails.sendContactQuickAction';


export default class sendContactSAP extends LightningElement {

    @api recordId; 
    @track mrSuccessMessage = 'Contact Details sent to SAP successfully';

        // Automatically call Apex method when the component is inserted into the DOM
        connectedCallback() {
            console.log('opp record id---'+ this.recordId);
            this.callSendToSAP();
        }
    
        // Call Apex method to send MR details to SAP
        callSendToSAP() {
    
            console.log('pr record id---'+ this.recordId);
            sendToSAP({ recordId: this.recordId })
       
        }






}