import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getDetails from '@salesforce/apex/NavigateToRecordController.getDetails';

export default class NavigateToRecord extends LightningElement {
    
    @wire(CurrentPageReference)
    currentPageReference;

    @api recordId;

    connectedCallback() {
        getDetails({recId: this.currentPageReference.attributes.recordId})
            .then((result) => {
            window.location = window.location.origin+'/'+result.ProcessInstance.TargetObjectId;                
        });
    }

}