import { LightningElement, track ,api,wire} from 'lwc';
import sendToSAP from '@salesforce/apex/SendMRDetailsSAPAPI.sendToSAPQuickAction';
import { CurrentPageReference } from 'lightning/navigation';


export default class SendMRDetailsQuickAction extends LightningElement {
    @api recordId; 
    @track mrSuccessMessage = 'MR Details sent to SAP successfully';

    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.recordId = currentPageReference.state.recordId;
    //     }
    // }

    // Automatically call Apex method when the component is inserted into the DOM
    connectedCallback() {


        console.log('pr record id---'+ this.recordId);


        this.callSendToSAP();


   
    }

    // Call Apex method to send MR details to SAP
    callSendToSAP() {

        console.log('pr record id---'+ this.recordId);
        sendToSAP({ partRequestId: this.recordId })
            // .then(() => {
            //     this.showToastMessage('Success', 'MR Details sent to SAP successfully.', 'success');
            // })
            // .catch((error) => {
            //     this.showToastMessage('Error', 'Failed to send MR details to SAP. ' + error.body.message, 'error');
            // });
    }


}