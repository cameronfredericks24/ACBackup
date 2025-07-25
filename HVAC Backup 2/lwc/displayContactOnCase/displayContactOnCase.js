import { LightningElement,track,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getContactDetails from '@salesforce/apex/AssetRegistrationController.getContactDetails';


import CONTACT_ID_FIELD from '@salesforce/schema/Case.ContactId';


export default class DisplayContactOnCase extends LightningElement {

      @api recordId; // This is the Case Id

    @track contactData = {
        Name: "",
        Title: "",
        Email: "",
        Phone: ""

    };


   @wire(getContactDetails, { caseId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            this.contactData = {
                Name: data.Account.Name,
                Title: data.Title,
                Email: data.Email,
                Phone: data.Phone
            };

            console.log()
        } else if (error) {
            console.error('Error fetching contact details:', error);
        }
    }

}