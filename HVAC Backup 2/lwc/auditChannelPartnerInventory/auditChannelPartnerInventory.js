import { LightningElement, track,api } from 'lwc';
import getProductItems from '@salesforce/apex/AuditChannelPartnerInventoryController.getProductItems';
import submitForApproval from '@salesforce/apex/AuditChannelPartnerInventoryController.submitForApproval';
import checkAudit from '@salesforce/apex/AuditChannelPartnerInventoryController.checkAudit';
import Id from '@salesforce/user/Id';

export default class AuditChannelPartnerInventory extends LightningElement {
    @track initialRecords = [];
    @track originalRecords = [];
    @track error = '';
    @api userId = Id;
    //searchTerm = '';
    @api showSpinner;
    @api showForm;
    @api showError;
    pageSizeOptions = [5, 10, 25, 50, 75, 100];
    @track records = [];
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
    @track recordsToDisplay = [];
    @track columns = [];
    draftValues=[];
    showSuccess;
    successMsg;
    @api recordId;
    @track locationOptions=[];


    @track searchTerm = '';

    connectedCallback() {
        this.showForm = false;
        this.showSpinner = true;
        this.showError = false;
        this.locationOptions=[];
        //this.getUserId();
        setTimeout(() =>
            this.template.querySelector('[name="defaultPageSize"]').selectedIndex = 1
        );

        this.columns = [
            { label: 'Product Name', fieldName: 'productName', type: 'text' },
            { label: 'Product Code', fieldName: 'productCode', type: 'text' },  
            { label: 'Quantity On Hand', fieldName: 'quantityOnHand', type: 'number',initialWidth: 100,editable: true,}
        ];

        this.checkAuditMethod();
        this.draftValues=[];
    }

    
    handleSave(event){
        debugger;
        const recordInputs = event.detail.draftValues;
        // Logic to save the updated values
        // For demonstration purposes, simply log the updated records to the console
        console.log('Updated Records', recordInputs);

        // Update the data with the saved values
        this.recordsToDisplay = this.recordsToDisplay.map(row => {
            debugger;
            const editedRow = recordInputs.find(input => { console.log(input); return input.Id === row.Id});
            console.log('edit',editedRow);
            if (editedRow) {
                return { ...row, ...editedRow };
            }
            return row;
        });

        this.initialRecords = this.initialRecords.map(row => {
            debugger;
            const editedRow = recordInputs.find(input => { console.log(input); return input.Id === row.Id});
            console.log('edit',editedRow);
            if (editedRow) {
                return { ...row, ...editedRow };
            }
            return row;
        });

        //console.log('details',event.detail.draftValues);
        this.draftValues=[];

    }

    getProductItemsMethod() {
        console.log('****userId'+this.userId);
        getProductItems({ userId: this.userId })
            .then(result => {
                console.log('ProductItems : '+result);  
                
                var resultWrapperList = [];
                const locationSet = new Set();
                this.locationOptions=[];
                for(var i=0;i<result.length;i++){
                    var resultWrapper = {};
                    resultWrapper.productName = result[i].Product2.Name;
                    resultWrapper.productCode = result[i].Product2.ProductCode;
                    resultWrapper.quantityOnHand = 0;
                    resultWrapper.Id = result[i].Id;
                    resultWrapper.locationName = result[i].Location.Name;
                    resultWrapperList.push(resultWrapper);
                    locationSet.add(result[i].Location.Name);
                }

                debugger;

                console.log('locationSet',locationSet);

                const myIterator = locationSet.values();
                this.locationOptions.push({ value: 'None', label:'None'});
                for (const entry of myIterator) {
                    console.log('lo',this.locationOptions);
                    this.locationOptions.push({ value: entry, label:entry});
                }

                console.log('lo',this.locationOptions);

                this.initialRecords = resultWrapperList;
                this.records = resultWrapperList;
                this.totalRecords = this.records.length;
                this.pageSize = this.pageSizeOptions[1]; //set pageSize with default value as first option
                this.paginationHelper();
                this.error = '';
                this.showForm = true;
                this.showSpinner = false;
            })
            .catch(error => {                
                console.error('****error'+JSON.stringify(error.message) );
                this.error = 'Error occurred while fetching product items.\n'+JSON.stringify(error.message)+'\n';
                this.showError = true;
                this.showForm = true;
                this.showSpinner = false;
            });
    }

    checkAuditMethod() {
        console.log('****userId'+this.userId);
        checkAudit({ userId: this.userId })
            .then(result => {
                console.log('ProductItems : '+result);  
                if(result){
                    this.getProductItemsMethod();
                }else{
                    this.error = 'Audit is not required.';
                    this.showError = true;
                    this.showForm = false;
                    this.showSpinner = false; 
                }
            })
            .catch(error => {                
                console.error('****error'+JSON.stringify(error.message) );
                this.error = 'Error occurred while fetching product items.\n'+JSON.stringify(error.message)+'\n';
                this.showError = true;
                this.showForm = true;
                this.showSpinner = false;
            });
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    paginationHelper() {
        this.recordsToDisplay = [];
        let tempRecords = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }

        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            tempRecords.push(this.records[i]);
            //this.recordsToDisplay.push(this.records[i]);
        }
        this.recordsToDisplay = tempRecords;
        this.recordsToDisplay = [... this.recordsToDisplay];
        this.showForm = true;
        this.showSpinner = false;
        console.log(JSON.stringify(this.recordsToDisplay)+'<--recordsToDisplay');
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    /*handleSearch() {
        this.filterProductItems();
    }

    filterProductItems() {
        searchProductItems({ items: this.productItems, searchTerm: this.searchTerm })
            .then(result => {
                console.log('Search ProductItems : '+result);
                this.filteredProductItems = result;
                 //set pageSize with default value as first option
                //this.paginationHelper();
                this.error = '';
            })
            .catch(error => {
                console.error('****error'+JSON.stringify(error) );
                this.error = 'Error occurred while searching product items.';
                this.filteredProductItems = [];
            });
    }*/

    handleSearch(event) {
        this.showSpinner =true;

        const searchKey = event.target.value.toLowerCase();
        console.log('****searchKey'+searchKey);
        this.searchMethod(searchKey);
        
    }

    searchMethod(searchKey){
        debugger;
        if (searchKey) {
            let searchRecords = [];
            for (let record of this.initialRecords) {
                let valuesArray = Object.values(record);
                for (let val of valuesArray) {
                    let strVal = String(val);
    
                    if (strVal && strVal.toLowerCase().includes(searchKey)) {
                        searchRecords.push(record);
                        break;
                    }
                }
            }
            console.log('****Matched Products: ' + JSON.stringify(searchRecords));
            this.records = searchRecords;
        }else {
            this.records = this.initialRecords;
        }
        this.records = [... this.records];
        this.totalRecords = this.records.length;
        this.pageNumber = 1;
        this.paginationHelper();
        this.showSpinner = false;

    }

    submitforApprovalMethod(){
        this.showSpinner=true;
            console.log('****userId'+this.userId);
            submitForApproval({ resultWrapperString: JSON.stringify(this.initialRecords), userId: this.userId })
                .then(result => {
                    debugger;
                    if(result.includes('failed')){
                        this.error = 'Error occurred while fetching product items.\n';
                        this.showError = true;
                        this.showForm = false;
                        this.showSpinner = false;
                    }else{
                        this.successMsg = result;
                        this.showSuccess = true;
                        this.showForm = false;
                        this.showSpinner = false;
                    }
                })
                .catch(error => {                
                    console.error('****error'+JSON.stringify(error.message) );
                    this.error = 'Error occurred while fetching product items.\n'+JSON.stringify(error.message)+'\n';
                    this.showError = true;
                    this.showForm = false;
                    this.showSpinner = false;
                });

    }

    handleChange(event){
        var searchKey = event.detail.value.toLowerCase();
        if(searchKey=='none'){
            searchKey=undefined;
        }
        this.searchMethod(searchKey);
    }

}