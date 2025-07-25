import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmailWithAttachment from '@salesforce/apex/SendChargesController.sendEmailWithAttachment';
//import sendSMSWithLink from '@salesforce/apex/SendChargesController.sendSMSWithLink';

export default class SendCharges extends LightningElement {

    attachmentName = 'RateCardTemplate'; // Static resource name of the attachment
    @api emailAddress; 
    //phoneNumber = '8769366077';

    showMessage = false;
    message = '';

    @api sendEmail() {
        console.log('here sendcharges',this.emailAddress)
        Promise.all([
            sendEmailWithAttachment({ attachmentName: this.attachmentName, emailAddress: this.emailAddress }),
            //sendSMSWithLink({ attachmentName: this.attachmentName, phoneNumber: this.phoneNumber })
        ])
            .then(result => {
                console.log('success',result);
                this.showMessage = true;
                this.message = 'Email sent successfully.';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email sent successfully.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.log('error',error);
                this.showMessage = true;
                this.message = 'Error sending email.';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error sending email. Please provide valid email address.',
                        variant: 'error'
                    })
                );
            });
    }
}