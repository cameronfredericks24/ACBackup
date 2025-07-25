import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class FslCaptureSDA extends LightningElement {
    @api recordId; // Expose recordId property to be set from parent component or record page
    showFailureForm = false;
    
 

    connectedCallback() {
        try {
            this.showFailureFormMethod();
           
        } catch (error) {
            console.log('error-->' + error.message);
        }
    }


    showFailureFormMethod() {
        console.log('in parent' + JSON.stringify(event?.detail));
        this.showFailureForm = true;
    }

    backEventHandler(){

               // Emit custom event on back click
               const backClick = new CustomEvent('backclick', {});
               this.dispatchEvent(backClick);

    }


    handleOnDraft(event){

        const draftsda = new CustomEvent('draftsda', {});
        this.dispatchEvent(draftsda);

        
    }


    handleOnSumbit(event){

        const submitSDA = new CustomEvent('submitsda', {});
        this.dispatchEvent(submitSDA);

        
    }
}