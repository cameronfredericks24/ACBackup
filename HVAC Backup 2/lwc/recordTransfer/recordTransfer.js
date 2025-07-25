import { LightningElement, track, wire } from 'lwc';
import callRecordTransferQueueable from '@salesforce/apex/RecordTransferController.callRecordTransferQueueable';
import fetchAsset from '@salesforce/apex/RecordTransferController.fetchAsset';
import getTotalAssetCount from '@salesforce/apex/RecordTransferController.getTotalAssetCount';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class RecordTransfer extends LightningElement {

    @track masterAssetList = [];
    @track assetList = [];
    @track selectedRows = [];
    @track selectedRowsIds = [];
    @track selectedRowsMap = new Map();
    @track currentPageData = new Map();
    @track cp;
    @track sde;
    @track branch;
    @track department;
    @track isLoading = false;
    // @track cpSearchTerm;
    // @track isCpCodeSearchEnabled;
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' }
        , { label: 'Account', fieldName: 'Account_Name', type: 'text' }
        , { label: 'Obligation', fieldName: 'Asset_Obligation__c', type: 'text' }
        , { label: 'Component Id', fieldName: 'Component_Id__c', type: 'text' }
        , { label: 'SDE', fieldName: 'SDE_Name', type: 'text' }
        , { label: 'Branch', fieldName: 'Branch_Name', type: 'text' }
        , { label: 'Division', fieldName: 'Division_Name__c', type: 'text' }
        , { label: 'CP', fieldName: 'CP_Name', type: 'text' }
        , { label: 'Department', fieldName: 'Department_Name', type: 'text' }
        , { label: 'Pincode', fieldName: 'Pincode', type: 'text' }
    ];

    transferValue = '';
    selectedSobject = 'Asset';
    showTransferSelection=true
    showTransfer=false;
    showCp = false;
    fromId;
    toId;
    fieldName = '';
    showJobStatus=false;
    showSobject=true;
    showSde=false;
    showBranch=false;
    showDivision=false;
    showDepartment=false;
    showAccount=false;
    displayMsg = '';
    objectApiName = 'Account'; 
    cpRecordTypeId;
    filters = {
        cp: null,
        department: null,
        sde: null,
        branch: null,
        account: null,
        division: null,
        obligation: null,
        pincode: null,
        component: null
    };

    productsPerPage = 500; // Rows per page
    @track currentPage = 1; // Current page
    @track totalPages = 1;
    @track totalAssetCount = 0;
    @track selectedRecordsCount = 0;

    @track currentlySelectedData =[];

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            console.log(data);
            Object.keys(data.recordTypeInfos).forEach(key => {
                const recordTypeInfo = data.recordTypeInfos[key];
                // Example: Search for record type by developer name
                console.log('Record Type ID:', recordTypeInfo);
                if (recordTypeInfo && recordTypeInfo.name === 'Channel Partner') {
                    this.cpRecordTypeId = recordTypeInfo.recordTypeId;
                    console.log('Record Type ID:', this.recordTypeId);
                }
            });

        } else if (error) {
            console.error('Error fetching object info:');
        }
    }

    get options() {
        return [
            { label: 'Asset Transfer', value: 'Asset' }
            /*{ label: 'Account Transfer', value: 'Account' },*/
        ];
    }

   // Filter to search the products from product sub family
    //  get sdefilter(){
    //     return {
    //         criteria: [
    //             {
    //                 fieldPath: 'Profile_Assigned__c',
    //                 operator: 'eq',
    //                 value: 'BSL SDE'
    //             }
    //         ]
    //     }
    // }

    get sdefilter() {
    return {
        criteria: [
            {
                fieldPath: 'Profile_Assigned__c',
                operator: 'in',
                value: ['BSL SDE', 'BSL SME', 'BSL SDH', 'BSL AM', 'BSL SMH']
            },
            {
                fieldPath: 'IsActive',
                operator: 'eq',
                value: true
            }
        ]
    };
}



    // Computed filter based on search term and other criteria
    get cpfilter() {
        let criteria = [
            {
                fieldPath: 'RecordTypeId',
                operator: 'eq',
                value: this.cpRecordTypeId
            }
        ];

        return { criteria };
    }

    displayInfo = {
       additionalFields: ['CP_Code__c']
   }

    matchingInfo = {
       primaryField: { fieldPath: 'CP_Code__c' },
       additionalFields: [ { fieldPath: 'CP_Code__c' } ]
   }


    get accfilter(){
        return {
            criteria: [
                {
                    fieldPath: 'RecordTypeId',
                    operator: 'ne',
                    value: this.cpRecordTypeId
                }
            ]
        }
    }

    get transferOptions() {
        if(this.selectedSobject=='Asset'){
            return [
                { label: 'CP', value: 'CP' },
                { label: 'SDE', value: 'SDE' },
                { label: 'Service Division', value: 'Service Division' },
                { label: 'Customer Account', value: 'Customer Account' },
                { label: 'Department', value: 'Department' },
                { label: 'Branch', value: 'Branch' },

            ];
        }else{
            return [
                { label: 'CP', value: 'CP' },
                { label: 'SDE', value: 'SDE' },
                { label: 'Branch', value: 'Branch' }
            ];
        }
       
    }
    
    //need to get it dynamically
    get divisionOption() {
        return [
            { label: 'CPSD', value: 'CPSD' },
            { label: 'CRBG', value: 'CRBG' },
            { label: 'CPAG', value: 'CPAG' },
        ];
    }

    handleRecordChange(event) {
        this.selectedSobject = event.detail.value;    
    }

    handleTransferChange(event) {
        this.transferValue = event.detail.value;
        if(this.transferValue=='CP'){
            this.showCp=true;
            this.showSde=false;
            this.showBranch=false;
            this.showDivision=false;
            this.showDepartment=false;
            this.showAccount=false;
        }else if(this.transferValue=='SDE'){
            this.showSde=true;
            this.showCp=false;
            this.showBranch=false;
            this.showDivision=false;
            this.showDepartment=false;
            this.showAccount=false;
        }else if(this.transferValue=='Branch'){
            this.showSde=false;
            this.showCp=false;
            this.showBranch=true;
            this.showDivision=false;
            this.showDepartment=false;
            this.showAccount=false;
        }else if(this.transferValue=='Service Division'){
            this.showSde=false;
            this.showCp=false;
            this.showBranch=false;
            this.showDivision=true;
            this.showDepartment=false;
            this.showAccount=false;
        }else if(this.transferValue=='Department'){
            this.showSde=false;
            this.showCp=false;
            this.showBranch=false;
            this.showDivision=false;
            this.showDepartment=true;
            this.showAccount=false;
        }else if(this.transferValue=='Customer Account'){
            this.showSde=false;
            this.showCp=false;
            this.showBranch=false;
            this.showDivision=false;
            this.showDepartment=false;
            this.showAccount=true;
        }
    }


    setFrom(event){    
        if(event.detail!=null && event.detail.recordId!=null){
            this.fromId=event.detail.recordId;
        }else{
            this.fromId=event.detail.value;
        }      
        console.log(this.fromId);
    }

    
//today - 09-04-2024
    @track selectedId;
    @track selectedName;

    handleUserSelected(event) {

    console.log('im inside handleUserSelected')

    const selectedId = event.detail.userId;
    const selectedName = event.detail.userName;
    console.log('Received in Parent - ID:', selectedId, 'Name:', selectedName);

    this.fromId = selectedId;

    console.log('this.fromId', this.fromId);

}

//end

    setTo(event){    
        if(event.detail!=null && event.detail.recordId!=null){
            this.toId=event.detail.recordId;
        }else{
            this.toId=event.detail.value;
        }

        console.log(this.toId);
    }


    handleTransfer(){
        console.log('handle transfer');
        if(this.selectedSobject == 'Account'){
            if(this.transferValue=='CP'){
                this.fieldName='CP__c';
            }else if(this.transferValue=='SDE'){
                this.fieldName='SDE__c';
            }else if(this.transferValue=='Branch'){
                this.fieldName='Branch__c';
            }
        }else if(this.selectedSobject == 'Asset'){
            if(this.transferValue=='CP'){
                this.fieldName='CP__c';
            }else if(this.transferValue=='SDE'){
                this.fieldName='SDE__c';
            }else if(this.transferValue=='Branch'){
                this.fieldName='Branch__c';
            }else if(this.transferValue=='Service Division'){
                this.fieldName='Serviceable_Division__c';
            }else if(this.transferValue=='Department'){
                this.fieldName='Service_Department_L__c'; //need to add
            }else if(this.transferValue=='Customer Account'){
                this.fieldName='AccountId'; //need to add
            }
        }

        if(this.fromId==null || this.toId==null){
            console.log('im inside handleTransfer Method');
            this.showToast('Please select the From and To values.','Error')
        } 
        else if(this.transferValue==='Branch' && (this.cp==null || this.sde==null)) {
            console.log(this.CP);
        
            this.showToast('Please select mandate fields.','Error')
        }
        // if(this.transferValue=='SDE' && (this.department==null || this.branch==null)) {
        //     this.showToast('Please select mandate fields.','Error')
        // }
        else{
            this.showTransferSelection=false;
            console.log(this.showCp);
        }
        
    }

    handleBack() {
        this.assetList = [];
        this.masterAssetList = [];
        this.showTransferSelection=true;
        this.fromId=null;
        this.toId=null;
        this.fieldName='';  
        this.currentPage=1;
        this.totalPages=1;
        this.selectedRows = [];
        this.selectedRowsMap = new Map();
        this.selectedRowsIds = [];
        this.filters = {
            cp: null,
            department: null,
            sde: null,
            branch: null,
            account: null,
            division: null,
            obligation: null
        };
        this.selectedRecordsCount =0;
    }

    handleNext(){
        console.log('handle transfer');
        this.showTransfer=true; 
        this.showSobject=false;
    }

    handleTransferRecord() {
        if(this.selectedRows==null){
            console.log('selected recotrds - ' + JSON.stringify(this.selectedRows));
            this.showToast('Please select the record to transfer.','Error')
        }else{
            this.callRecordTransfer();
            console.log('transfeerring');
        }
        
    }

    
    handleFilterChange(event) {
        try {
            // Safely access event.target
            if (!event.target) {
                console.error('No event target found');
                return;
            }
    
            const filterName = event.target.name; // Get the filter name
            const selectedValue = event.target.value; // Get the value entered
    
            if (!filterName) {
                console.warn('Filter name is missing from the input element.');
                return;
            }
    
            // Update the filters object
            this.filters[filterName] = selectedValue;
            console.log('Updated Filters:', JSON.stringify(this.filters));
        } catch (error) {
            console.error('Error in handleFilterChange:', error);
        }
    }
    
    
    handleFilter() {
        this.fetchTotalAssetsCount();
        this.fetchAssets();
    }
    
   
    handleRowSelection(event) {

        try{
            console.log('Row selection triggered -' + JSON.stringify(event.detail.config.value));

            var currentPageSelectedRows = event.detail.selectedRows;
            console.log('currentPageSelectedRows 1 -' + JSON.stringify(currentPageSelectedRows));


            if (!this.selectedRowsMap) {
                this.selectedRowsMap = new Map(); // Initialize a Map if not already initialized
            }

            const eventType = event.detail.config.action;
            console.log('eventType- ', eventType);

            if(eventType ==='rowDeselect') {

                console.log('deselected row -- '+event.detail.config.value);
                const deselectedId = event.detail.config.value;
                this.selectedRowsMap.delete(deselectedId);

            } else if (eventType === 'deselectAllRows') {
                console.log('Deselecting all rows on the current page');

                this.assetList.forEach(row => {
                    this.selectedRowsMap.delete(row.Id);
                });
                console.log('removed all rows on the current page');

            } else if(eventType ==='selectAllRows'){
                this.currentlySelectedData = [];
                console.log('selectAllRows' + event.detail.selectedRows.length);
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.currentlySelectedData.push(event.detail.selectedRows[i]);

                }

                currentPageSelectedRows.forEach(row => {
                    console.log('rowId - '+ row.Id +' - ' + this.selectedRowsMap.has(row.Id));
                    if (row.Id && !this.selectedRowsMap.has(row.Id)) {
                        this.selectedRowsMap.set(row.Id, row);
                    }
                });

            }
       
            else {
                currentPageSelectedRows.forEach(row => {
                    console.log('rowId - '+ row.Id +' - ' + this.selectedRowsMap.has(row.Id));
                    if (row.Id && !this.selectedRowsMap.has(row.Id)) {
                        this.selectedRowsMap.set(row.Id, row);
                    }
                });
            } 
        
            console.log(' selectedRowsMapValues - '+ JSON.stringify( Array.from(this.selectedRowsMap.values())));
            console.log('selectedRowsMapKeys - '+ JSON.stringify(Array.from(this.selectedRowsMap.keys())));


    
                // Convert map to a list of selected rows
                this.selectedRows = Array.from(this.selectedRowsMap.values());
                this.selectedRowsIds = Array.from(this.selectedRowsMap.keys());
                this.selectedRecordsCount = this.selectedRows.length;
            
                console.log('Selected Rows:', JSON.stringify(this.selectedRows));
                console.log('Selected Rows IDs:', JSON.stringify(this.selectedRowsIds));

              }
        catch(error){
            console.log('error-- '+ error.message);
            console.log('error-- '+ error);
        }
    }
    
    fetchAssets() {
        this.isLoading = true; 
        if(this.selectedSobject = 'Asset') {
            fetchAsset({ pageSize:this.productsPerPage, pageNumber:this.currentPage, sObjectType:this.selectedSobject, fieldName:this.fieldName, fromId:this.fromId, filters: this.filters })
            .then(result => {
                console.log('fetch asset');
                this.masterAssetList = result.map(asset => {
                    const isSelected = this.selectedRowsIds.includes(asset.Id);
                    return {
                        ...asset,
                        SDE_Name: asset.SDE__r?.Name || '', // Safe navigation operator to avoid null errors
                        Branch_Name: asset.Branch__r?.Name || '',
                        Department_Name: asset.Service_Department_L__r?.Name || '',
                        Division_Name: asset.Division_Name__c || '',
                        CP_Name: asset.CP__r?.Name || '',
                        Account_Name: asset.Account?.Name || '' ,
                        Pincode: asset.Account?.ShippingPostalCode || '' ,
                        is_Selected: isSelected          
                    };
                });
                this.assetList = [...this.masterAssetList];
                console.log('Initial asset list fetched: ',  JSON.stringify(this.assetList));
                this.updateSelectedRows();
            })
            .catch(error => {
                console.error('Error fetching assets: ', error);
            })
            .finally(() => {
                this.isLoading = false; // Hide the loading spinner after fetch completes
            });
        
    }}

    updateSelectedRows() {
        // Ensure that selected rows are reflected in the datatable
        const selectedRowIds = this.selectedRowsIds;
        const rows = this.assetList;
    
        // Find the selected rows based on the selectedIds
        const selectedRows = rows.filter(row => selectedRowIds.includes(row.Id));
    
        // Set the selected rows in the table
        this.selectedRows = selectedRows;
        this.selectedRowsIds = selectedRows.map(row => row.Id);
    }
    
    

    callRecordTransfer(){
        callRecordTransferQueueable({sObjectType:this.selectedSobject,fieldName:this.fieldName ,fromId:this.fromId, toId:this.toId, selectedRecords: this.selectedRows, cp: this.cp, sde: this.sde, branch: this.branch, department: this.department })
                       .then(result =>{
                        console.log('result',result);
                        if(result === 'success'){
                            this.showToast('Records are being processed. Results will be sent to your email after the process is completed.','Success')
                            this.displayMsg = 'Records are being processed. Results will be sent to your email after the process is completed.';
                        }else{
                            this.showToast('Some assets are under AMC, only CBO has the authority to transfer them from this '+this.transferValue+'.','Error');
                            this.displayMsg = 'Some assets are under AMC, only CBO has the authority to transfer them from this '+this.transferValue+'.';
                        }
                        this.showJobStatus=true;
                        this.showTransfer=false;
                        this.showCp=false;
                        this.showSde=false;
                        this.showBranch=false;
                        this.showDivision=false;
                        this.showDepartment=false;
                        this.showAccount=false;
                        this.showTransferSelection=true;
                        })
                       .catch(error =>{
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
        }); 
    }

    showToast(message, type) {
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1; // Increment the page number
            this.fetchAssets(); // Fetch products for the new page
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1; // Decrement the page number
            this.fetchAssets(); // Fetch products for the new page
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }

    fetchTotalAssetsCount() {
        getTotalAssetCount({ sObjectType:this.selectedSobject,fieldName:this.fieldName,fromId:this.fromId,filters:this.filters })
            .then(result => {
                this.totalAssetCount = result;
                this.totalPages = Math.ceil(this.totalAssetCount / this.productsPerPage);
            })
            .catch(error => {
                this.showToast('Error fetching total product count.', 'error');
                console.error('Error fetching total product count:', error);
            });

    }

    handleMandateFieldChange(event) {
        console.log('recordPickerId - '+ event.target.dataset.id);
        const recordPickerId = event.target.dataset.id;

        
        if (recordPickerId === 'cpRecordPicker') {
            console.log('CP selected:', event.detail.recordId);
            this.cp = event.detail.recordId;

        } else if (recordPickerId === 'sdeRecordPicker') {
            console.log('SDE selected:', event.detail.recordId);
            this.sde = event.detail.recordId;
        }
    }
}