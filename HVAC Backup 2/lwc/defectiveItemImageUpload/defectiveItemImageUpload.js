import { LightningElement, track, wire } from 'lwc';
import getDefectiveItemList from '@salesforce/apex/DefectiveLineItemsController.getDefectiveItemList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import checkImages from '@salesforce/apex/DefectiveLineItemsController.checkImages';

const columns = [
    { label: 'Name', fieldName: 'DefectiveName', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
    { label: 'Part Name', fieldName: 'Product_Name_Text__c' },
    { label: 'Part Code', fieldName: 'Product_Model__c' },
    { label: 'Part Claim Number', fieldName: 'ReverseGRN', type: 'url', typeAttributes: { label: { fieldName: 'Part_Claim_Number_Text__c' }, target: '_blank' } },
    { label: 'Created Date', fieldName: 'CreatedDate' }
   
];

export default class SelectedRowsPersistentPaginationLWC extends LightningElement {

    userId = Id;
    page = 1; //initialize 1st page
    items = []; //contains all the records.
    data = []; //data displayed in the table
    columns = columns; //holds column info.
    startingRecord = 1; //start record position per page
    endingRecord = 0; //end record position per page
    pageSize = 10; //default value we are assigning
    totalRecountCount = 0; //total record count received from all retrieved records
    totalPage = 0; //total number of pages needed to display all records
    @track selectedRows = [];
    @track selectedRowData = [];
    @track showFlow = false;
    @track showImageUpload = false;
    flowApiName = "GRN_for_Bulk_defective_Mismatched_Item";
    @track fileMap = {};
    @track filteredData = []; // Holds the filtered data to be displayed
    @track selectedRecordType = '';
    @track showTable = false;
    @track enablePartClaim = false;

    get recordTypeOptions() {
        return [
            { label: 'RMR', value: 'RMR' },
            { label: 'Sales Order', value: 'Sales Order' }
        ];
    }

    @wire(getDefectiveItemList)
    wiredAccounts({ error, data }) {
        if (data) {
            this.items = data.map(item => ({
                ...item,
                DefectiveName: '/channelpartnerportal/s/detail/' + item.Id,
                ReverseGRN: item.Reverse_GRN__c ? '/channelpartnerportal/s/detail/' + item.Reverse_GRN__c : '',
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
            this.showToast(this.error, 'Error', 'Error');
        }
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.target.value;
        this.showImageUpload = false;

        if (this.selectedRecordType) {
            this.showTable = true;
            this.filteredData = this.filterData(this.items); // Store filtered data
            this.totalRecountCount = this.filteredData.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.page = 1; // Reset to the first page on filter change
            this.displayRecordPerPage(this.page); // Display the first page of filtered data
            this.enablePartClaim = true;
        }

        console.log('Filtered Data:', this.filteredData);
        console.log('Current Page:', this.page);
        console.log('Total Pages:', this.totalPage);
    }

    filterData(data) {
        if (this.selectedRecordType) {
            return data.filter(item => item.Defective_Category__c === this.selectedRecordType);
        }
        return [];
    }

    displayRecordPerPage(page) {
        this.startingRecord = (page - 1) * this.pageSize;
        this.endingRecord = Math.min(page * this.pageSize, this.totalRecountCount);

        this.data = this.filteredData.slice(this.startingRecord, this.endingRecord); // Slice from filteredData
        this.startingRecord += 1; // Adjust for display

        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }

    previousHandler() {
        if (this.page > 1) {
            this.page -= 1;
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if (this.page < this.totalPage) {
            this.page += 1;
            this.displayRecordPerPage(this.page);
        }
    }

    handleRowSelection(event) {
        const updatedItemsSet = new Set(event.detail.selectedRows.map(row => row.Id));
        const selectedItemsSet = new Set(this.selectedRows);

        this.data.forEach(row => {
            if (updatedItemsSet.has(row.Id)) {
                selectedItemsSet.add(row.Id); // Add newly selected items
            } else {
                selectedItemsSet.delete(row.Id); // Remove deselected items
            }
        });

        this.selectedRows = [...selectedItemsSet];
        this.selectedRowData = this.items.filter(item => this.selectedRows.includes(item.Id));

        console.log('Selected Rows:', JSON.stringify(this.selectedRows));
        console.log('Selected Rows Data:', JSON.stringify(this.selectedRowData));
    }

    handlePartClaimClick() {
        if (this.selectedRows.length > 0) {
            if (this.selectedRecordType === 'Sales Order') {
                this.showImageUpload = true;
            } else {
                this.showFlow = true;
            }
        } else {
            this.showToast("Please select the Row", "Error", "Error");
        }
    }

    handleContinueToFlowClick() {
        checkImages({ selectedRowIds: this.selectedRows })
            .then(result => {
                const missingImages = Object.values(result)
                    .filter(details => !details.hasImage)
                    .map(details => details.name);

                if (missingImages.length > 0) {
                    this.showToast("Please upload images for the following items", "error", "Error");
                } else {
                    this.showFlow = true; // Proceed to call the flow
                }
            })
            .catch(error => {
                console.error('Error:', error);
                this.showToast(error.body?.message || 'An unexpected error occurred.', 'error', 'Error');
            });
    }

    get flowInputVariable() {
        return [
            {
                name: 'ids',
                type: 'String',
                value: this.selectedRows
            }
        ];
    }

    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleRowNavigation(event) {
        const rowId = event.target.dataset.id;
        console.log('Selected row ID:', rowId);
    }

    get isPreviousDisabled() {
        return this.page <= 1;
    }

    get isNextDisabled() {
        return this.page >= this.totalPage;
    }

    handleStatusChange(event) {
    // Check if the flow is finished
    if (event.detail.status === 'FINISHED') {
        // Reset the flow visibility
       window.location = '/channelpartnerportal/s/recordlist/GRN__c/Default?GRN__c-filterId=Defective_GRN';
    }
}
}