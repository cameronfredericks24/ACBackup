import { LightningElement , wire, api} from 'lwc';
import getOpenWorkOrdersThisMonth from '@salesforce/apex/ShowUpcomingPMSController.getOpenWorkOrdersThisMonth';

const pageSize = 10;
const columns = [
    // { label: 'Asset ID', fieldName: 'AssetId', type: 'lookup' },
    { label: 'Asset Name', fieldName: 'AssetName', type: 'text' },
    { label: 'PMS Maintenance Date', fieldName: 'PMS_Maintenance_Date__c', type: 'date' },
    { label: 'PMS Reschedule Date', fieldName: 'PMS_Reschedule_Date__c', type: 'date' }
];


export default class ShowUpcomingPMS extends LightningElement {
    @api recordId;
    columns = columns;
    workOrders;
    pageNumber = 1;
    pageSize = 10;
    isUpcomingPMS=false;
    
    connectedCallback() {
    //    console.log('Data received:', this.recordId);
         getOpenWorkOrdersThisMonth({ recordId: this.recordId, pageNumber: this.pageNumber, pageSize: this.pageSize })
            .then(result => {
             console.log('Data received:', result);
            const flattenedData = result.map(item => ({
    AssetId: item.AssetId,
    AssetName: item.Asset ? item.Asset.Name : '', 
    PMS_Maintenance_Date__c: item.PMS_Maintenance_Date__c,
    PMS_Reschedule_Date__c: item.PMS_Reschedule_Date__c
}));
 this.workOrders = flattenedData;
 console.log('Data received:', this.workOrders);
           
            if(result.length >0){
                this.isUpcomingPMS=true;
            }
            else{
                 this.isUpcomingPMS=false;
            }              
            })
            .catch(error => {
                console.error('Error fetching work orders:', error);
            });
    }
    get disablePrevious() {
        return this.pageNumber === 1;
    }

    get disableNext() {
        return this.workOrders && this.workOrders.length <= pageSize;
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
        }
    }

    handleNext() {
        this.pageNumber++;
    }
     renderedCallback() {
    try {
        const styleElement = document.createElement('style');
        styleElement.innerText = `
        .scrollable-datatable .slds-scrollable_y{
            overflow: scroll;
        }
        .scrollable-datatable .slds-truncate{
           text-overflow: clip;
        }
        `;
        const head = document.head || document.getElementsByTagName('head')[0];
        head.appendChild(styleElement);
        }
        catch (error) {
        console.error('An error occurred:', error.message);
    }
     }
}