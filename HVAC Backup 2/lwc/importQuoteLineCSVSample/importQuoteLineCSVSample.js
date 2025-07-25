import { LightningElement } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class ImportQuoteLineCSVSample extends LightningElement {
    headers = ['Product Code','Component Id','Quantity','Start Date','End Date','CP Downloading %','Standard Downloading Value','Revised CP %','Last Year Price for Asset','Standard Price for 1 year','List Unit Price','Discount(%)'];  // Sample headers

    connectedCallback() {
        this.generateCSV();  // Trigger the CSV download
    }

    generateCSV() {
        const csvContent = this.headers.join(',') + '\n';  // Create CSV content
        const element = 'data:application/csv,' + encodeURIComponent(csvContent);
        const downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'sampleFile.csv';  // Specify the file name
        document.body.appendChild(downloadElement);   // Add to DOM
        downloadElement.click();                      // Trigger download
        document.body.removeChild(downloadElement);   // Remove from DOM

        location.reload(); // This will navigate back to the previous page/context.
    }
}