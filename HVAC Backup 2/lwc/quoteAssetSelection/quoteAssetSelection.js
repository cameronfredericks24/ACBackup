import { LightningElement, wire, track, api } from 'lwc';
import formQuoteLines from '@salesforce/apex/QuoteAddAssetController.formQuoteLines';

const columns = [
    { label: 'Asset Name', fieldName: 'AssetName' },
    { label: 'Capacity', fieldName: 'Capacity', type: 'number' },
    { label: 'Unit', fieldName: 'Unit' },
    { label: 'Quantity', fieldName: 'quantity', type: 'number' },
    {
        type: 'button-icon',
        typeAttributes: {
            iconName: 'utility:add',
            name: 'add',
            title: 'Add',
            variant: 'border-filled',
            alternativeText: 'Add',
        },
    },
];
export default class QuoteAssetSelection extends LightningElement {
     
        @api recordId;
        @track quoteLineWrappers = [];
        columns = columns;
        selectedRows = [];
    
        @wire(formQuoteLines, { quoteId: '$recordId' })
        wiredQuoteLines({ error, data }) {
            if (data) {
                this.quoteLineWrappers = data;
            } else if (error) {
                console.error(error);
            }
        }
    
        handleRowSelection(event) {
            this.selectedRows = event.detail.selectedRows;
        }
    
        processSelected() {
            processSelectedQuoteLines({ selectedQuoteLines: this.selectedRows })
                .then(() => {
                    // Handle success
                    console.log('Selected rows processed successfully');
                })
                .catch(error => {
                    // Handle error
                    console.error('Error processing selected rows: ', error);
                });
        }

}