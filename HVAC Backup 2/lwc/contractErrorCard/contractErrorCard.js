import { LightningElement, track, api, wire } from 'lwc';
import getApiLogData from '@salesforce/apex/ApiLogController.getApiLogData';

export default class ContractErrorCard extends LightningElement {
  @track errors = [];
  @api recordId; 

  @wire(getApiLogData, { recordId: '$recordId' })
  wiredApiLog({ error, data }) {
    if (data) {
      try {
        const parsedData = JSON.parse(data);
        if (parsedData.ERROR) {
          this.errors = parsedData.ERROR.split(';');
        }
      } catch (e) {
        console.error('Error parsing JSON:', e);
      }
    } else if (error) {
      console.error('Error fetching API Log data:', error);
    }
  }
}