import { LightningElement, wire, api } from 'lwc';
import queryAMCLeads from '@salesforce/apex/AMCLeadController.queryAMCLeads';
const columns = [
    { label: 'Lead Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' }
];
export default class FetchAMCLeads extends LightningElement {
    columns = columns;
    @api recordId;
    leads;
    showTable = false;


    @wire(queryAMCLeads, { workOrderId: '$recordId' })
    wiredLeads({ error, data }) {
        if (data && data.length > 0) {
            this.showTable = true;
            this.leads = data;
        } else if (error) {
            console.error('Error fetching leads:', error);
        } 
    }
}