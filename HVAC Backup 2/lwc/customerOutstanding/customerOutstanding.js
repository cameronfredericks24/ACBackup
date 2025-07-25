import { LightningElement, track, api } from 'lwc';
import getCustomerOutstandingByOpportunity from '@salesforce/apex/CustomerOutstandingService.getCustomerOutstandingByOpportunity';
import updateOutstandingAmount from '@salesforce/apex/CustomerOutstandingService.updateOutstandingAmount';

export default class CustomerOutstanding extends LightningElement {
    @api recordId; // Automatically set to the Opportunity's ID
    @track outstandingData = []; // Data to show in the table
    @track totalOutstandingSum = 0; // Sum of Outstanding
    @track dataNotFound = false; // Flag to indicate if data is found

    columns = [
        { label: 'Customer ID', fieldName: 'customerId' },
        { label: 'Usage', fieldName: 'usage' },
        { label: 'Billing Doc', fieldName: 'billingDoc' },
        { label: 'Aging', fieldName: 'aging', type: 'number' },
        { label: 'Assignment No', fieldName: 'assignmentNo' },
        { label: 'Document No', fieldName: 'documentNo' },
        { label: 'Document Date', fieldName: 'documentDate' },
        { label: 'Baseline Date', fieldName: 'baselineDate' },
        { label: 'Total Outstanding', fieldName: 'totalOS', type: 'currency' }
    ];

    // Fetch the data and update account on component load
    connectedCallback() {
        this.fetchDataAndUpdateAccount();
    }

    fetchDataAndUpdateAccount() {
        getCustomerOutstandingByOpportunity({ accountId: this.recordId })
            .then(result => {
                console.log("Data fetched:", result); // Log the data structure
                if (result.outstandingData && result.outstandingData.length > 0) {
                    this.outstandingData = result.outstandingData;
                    this.totalOutstandingSum = result.totalOutstandingSum;
                    this.dataNotFound = false;

                    // Automatically update the Outstanding Amount on the Account
                    return updateOutstandingAmount({ accountId: this.recordId, outstandingAmount: this.totalOutstandingSum });
                } else {
                    this.outstandingData = [];
                    this.totalOutstandingSum = 0;
                    this.dataNotFound = true;
                }
            })
            .catch(error => {
                console.error("Error:", error);
                this.dataNotFound = true;
            });
    }
}