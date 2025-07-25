import { LightningElement,api } from 'lwc';
export default class CallImageContainer extends LightningElement {


 @api recordId;

 connectedCallback() {
    console.log('recordId'+ this.recordId);
  }
}