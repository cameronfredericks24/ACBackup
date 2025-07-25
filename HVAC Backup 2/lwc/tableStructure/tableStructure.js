import { LightningElement, api, track } from 'lwc';
import getAsset from '@salesforce/apex/CreateCaseFormController.getAsset';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSectorBasedCity from '@salesforce/apex/CreateCaseFormController.getSectorBasedCity';
import getStateCodes from '@salesforce/apex/CreateCaseFormController.getStateCodes';
import getRateCard from '@salesforce/apex/RateCardController.getRateCard';

export default class TableStructure extends LightningElement {
    @api records = [];
    @track recordsList = [];
    @track originalAssetRecords = [];
    @api headerLabels = [];
    @api objectName;
    @api title;
    @api isCommercial;
    searchBySector=false;
    @track isModalOpen = false;
    @track formData = {};
    @track editIndex = null;
    createNew = false;
    editRecord = false;
    showAddress = false;
    showHeaders = true;
    isAsset = false;
    serialNumber;
    isContact = false;
    noDataFound=false;
    runOnce=false;
    classVar;
    showBillingRadio=false;
    resContact=false;
    showNewButton=true;
    disableFirstName = false;
    disableEmail = false;
    disableOtherPhone = false;
    disableRole = false;
    disablePhone = false;
    disableLastName = false;
    addAssetId;
    searchAsset=false;
    addAsset = false;
    showSearchAsset = false;
    initialized=false;
    @api accountId;
    serialList=new Map();
    @track headerObjectList=[];
    showAscending = false;
    showDescending = false;
    provinceOptions=[];

    @track placeSearch;
    @track placeAddresses = [];
    @track showResults = false;
    @track locationSelected = false;
    @track inputClass = 'field-container';
    @api searchPlaceholder = 'Search';
    @track placeArray = [];
    @api contactRecordType;
    @track rateMatrixesWithSelection = [];
    assetUnderWarranty = false;
    showPrice=false;
    showPagination = false;
    createNewContact =false;
    @api selectedPincode;
    showEditButton=true;


    //PaginationVariables
    pageSizeOptions = [20,30,50,100];
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number 
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page


    connectedCallback() {
        debugger;
        this.recordsList = this.records;
        
        console.log('records', JSON.stringify(this.recordsList));
        console.log('Here 6');
        //console.log(Object.keys(this.recordsList.data[0]));
        this.classVar = this.objectName+'RecordForm';
        this.headersList();
        if (this.recordsList.length == 0) {
            this.showHeaders = false;
            this.noDataFound=true;
        }
        if (this.objectName == 'Address') {
            this.showAddress = true;
            if(this.recordsList.length==0){
                this.showBillingRadio=true;
            }
            if(this.recordsList.length > 0){
                this.showNewButton = false;
                this.showEditButton = false;
            }
            this.getStates();
            console.log('Address',this.recordsList);

        }
        if (this.objectName == 'Asset') {
            this.isAsset = true;
            this.showAddress = false;
            this.showEditButton = false;
            if(this.recordsList.length>0){
                this.showSearchAsset=true;
                this.showPagination = true;
            }else{
                this.showPagination=false;
            }
            
            var parentRecords = this.recordsList.filter(record => ((record.RecordType=='Asset')));          
            console.log('parentRecords',parentRecords);

            if(parentRecords!=null && parentRecords.length>0){
                const updatedData = parentRecords.map((row, index) => {
                    const updatedRow = { ...row };
                    updatedRow['children'] = this.recordsList.filter(child => child.ParentId === updatedRow.Id);
                    updatedRow['showChild'] = false;

                    if((updatedRow['children']).length>0){
                        updatedRow['hasChild'] = true;
                    }else{
                        updatedRow['hasChild'] =false;
                    }

                    updatedRow['children'].forEach(child => {
                        // Access each child here
                        // For example:
                        if(child['IsInstallable'] == true || child['IsInstallable']=='true'){
                            updatedRow['SerialNumber'] = child['SerialNumber'];
                        }
                        console.log(child);
                    });

                    return updatedRow;
                });

                this.originalAssetRecords = updatedData;
                console.log('this.originalAssetRecords',this.originalAssetRecords);
                var filterdata = this.originalAssetRecords;
                if(this.selectedPincode!=null && this.selectedPincode!='' && this.selectedPincode!=undefined){
                    //filterdata = this.originalAssetRecords.filter(record => record.PostalCode==this.selectedPincode);
                }
                console.log('this.selectedPincode',this.selectedPincode);

                if(filterdata!=null && filterdata.length>0){
                    this.recordsList = filterdata;          
                    this.records = filterdata;                  
                    this.totalRecords = filterdata.length;
                    this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                    this.paginationHelper();
                }else{
                    this.showPagination=false;
                    this.showHeaders = false;
                    this.noDataFound=true;
                }
               
            }else{
                
                this.showPagination=false;
                this.showHeaders = false;
                this.noDataFound=true;
                this.recordsList = parentRecords;         
               /* this.records = parentRecords;
                this.originalAssetRecords = parentRecords;
                this.totalRecords = 0;
                this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                this.paginationHelper(); */        
            }

            console.log('this.recordsList',this.recordsList);
           
            
        }
        
        if (this.objectName == 'Contact') {
            this.isContact = true;
            if(this.accountId!=null && this.accountId!=undefined && this.recordsList.length>0 ){
               // this.showNewButton = false;
            }
            if(this.recordsList.length>0){
               // this.showNewButton = false;
            }
        }
        
    }

    renderedCallback() {
        debugger;
        if(!this.runOnce && this.objectName != 'Asset'){
            this.updateRadioAtFirstRow();
            this.runOnce=true;
            console.log('records', JSON.stringify(this.recordsList));
        }          
    }

    handleChange(event) {
        this.showResults=true;
        this.serialList = new Map();
        this.recordsList.forEach(asset => {
            if(asset.SerialNumber!=undefined){
                this.serialList.set( asset.SerialNumber , asset.SerialNumber );
            }
        });
        //this.placeSearch = event.target.value;
        //console.log(this.placeSearch);
       /* searchPlaces({ query: this.placeSearch })
            .then(result => {
                // console.log(result);
                this.placeAddresses = result;
                // console.log(this.placeAddresses);

                // Prepare a map with placeName as key and placeAddress as value
                let placeMap = {};
                this.placeAddresses.forEach(location => {
                    placeMap[location.placeName] = location.placeAddress;
                });

                // console.log(placeMap);

                // Convert the placeMap object into an array of objects
                this.placeArray = Object.keys(placeMap).map(key => ({ placeName: key, placeAddress: placeMap[key] }));

                console.log(this.placeArray);

                this.showResults = true;

            })
            .catch(error => {
                console.error('Error fetching place addresses', error);
            });*/
    }

    matchingInfoProduct = {
        primaryField: { fieldPath: 'Name' },
        additionalFields: [{ fieldPath: 'SerialNumber' }],
    };

    displayInfoProduct = {
        primaryField: 'Name',
        additionalFields: ['SerialNumber'],
    };

    get filter(){
        console.log('this.acctab',this.accountId);
        return {
            criteria: [
                {
                    fieldPath: 'AccountId',
                    operator: 'eq',
                    value: this.accountId
                }
            ]
        }
    }

    searchAssetMethod(event){    
        this.addAssetId=event.detail.recordId;
        console.log('productId',this.addAssetId);
    }

    get headersApi() {
        return this.headerLabels.length > 0 ? Object.keys(this.headerLabels[0]) : [];
    }

    headersList() {
        var headerVar = this.headerLabels.length > 0 ? Object.values(this.headerLabels[0]) : [];
        headerVar.forEach(header => {
            var ob = {};
            ob.header = header;
            if(ob.header == 'Asset Name'){
                ob.showSorting = true;
            }else{
                ob.showSorting = false;
            } 
            this.headerObjectList.push(ob);          
        });
        this.showDescending = true; 
    }

    get headers() {
        return this.headerLabels.length > 0 ? Object.values(this.headerLabels[0]) : [];
    }

    // Prepare the table data for rendering
    get tableData() {
        var headerLength = (this.headers).length;
        return this.recordsList.map(row => Object.values(row).slice(0, headerLength));
    }

    get childData() {
        var headerLength = (this.headers).length;
        return this.recordsList.map(row => Object.values(row));
    }

    get serialNumberOptions(){

        debugger;
        var serialList = new Map();
        this.recordsList.forEach(asset => {
            if(asset.SerialNumber!=undefined){
                serialList.set( asset.SerialNumber , asset.SerialNumber );
            }
        });
        return serialList;
    }

    handleSearchAsset() {
        //let listId = this.template.querySelector('datalist').id;
        this.template.querySelector("input").setAttribute("list", 'valueList'); 

        this.searchAsset = true;
        this.addAsset = false;
        this.handleOpenModal();

    }

    handleSearch(event){
        const searchKey = event.target.value.toLowerCase();
        console.log('****searchKey'+searchKey);
        this.searchMethod(searchKey);
    }

    searchMethod(searchKey){
        debugger;
        if (searchKey) {
            let searchRecords = [];
            for (let record of this.originalAssetRecords) {
                debugger;
                let valuesArray = Object.values(record);
                var recordAdded=false;
                for (let val of valuesArray) {
                    let strVal = String(val);
    
                    if (strVal && strVal.toLowerCase().includes(searchKey)) {
                        searchRecords.push(record);
                        recordAdded=true;
                        break;
                    }
                }

                if(recordAdded==false){
                    let childArray=[];
                    for (let child of record.children) {
                        childArray.push(Object.values(child));
                        console.log(childArray);
                    }

                    for (let childValue of childArray) {
                        let strChildVal = String(childValue);
        
                        if (strChildVal && strChildVal.toLowerCase().includes(searchKey)) {
                            searchRecords.push(record);
                            break;
                        }
                    }
                }
                
            }
            console.log('****Matched Products: ' + JSON.stringify(searchRecords));
            this.records = searchRecords;
        }else {
            this.records = this.originalAssetRecords;
        }

        //this.recordsList = [... this.recordsList];
        this.records = [... this.records];
        this.totalRecords = this.records.length;
        this.pageNumber = 1;
        this.paginationHelper();
    }

    @api updateAssetsOnPincodeCange(){
        debugger;
        var parentRecords=this.originalAssetRecords;
        console.log('this.selectedPincode update asset child',this.selectedPincode);
        console.log('this.recordsList',this.recordsList);
        if(this.selectedPincode!=null && this.selectedPincode!='' && this.selectedPincode!=undefined && this.originalAssetRecords!=null && this.originalAssetRecords.length>0){
            //parentRecords = this.originalAssetRecords.filter(record => record.PostalCode==this.selectedPincode);
        }

        //this.recordsList = [... this.recordsList];
        console.log('parentRecords',parentRecords);
        if(parentRecords!=null && parentRecords !=undefined && parentRecords.length>0){
            this.records = parentRecords;
            this.records = [... this.records];
            this.totalRecords = this.records.length;
            this.pageNumber = 1;
            this.pageSize = this.pageSizeOptions[0];
            this.runOnce=false;
            this.paginationHelper();
            this.showPagination=true;
            this.showHeaders = true;
            this.noDataFound=false;
        }else{
            this.recordList = parentRecords;
            //console.log('this.recordList',this.recordList);
            //console.log('this.recordList pag',this.recordList.length);
            this.showPagination=false;
            this.showHeaders = false;
            this.noDataFound=true;
        }
      
    }

    handleAddAsset() {
        this.addAsset = true;
        this.searchAsset = false;
        this.handleOpenModal();
        this.isModalOpen = true;
    }

    handleOpenModal() {
        debugger;
        if (this.objectName == 'Contact') {
            this.createNewContact=true;
        }else if(this.objectName == 'Address'){
            this.createNew = true;
        }

        this.editRecord = false;
        //this.isModalOpen = true;
        this.formData = {};
        this.headersApi.forEach(header => {
            this.formData[header] = '';
            if(header=='Role__c' && this.isCommercial==false){
                this.formData[header] = 'Family';
            }
        });
        console.log('formData',this.formData);
        this.editIndex = null;
        this.resContact=false;
        this.disableFirstName = false;
        this.disableEmail = false;
        this.disableOtherPhone = false;
        this.disableRole = false;
        this.disablePhone = false;
        this.disableLastName = false;
    }

    handleCloseModal() {
        this.isModalOpen = false;
        this.addAssetId = null;
        this.searchAsset=false;
        this.addAsset=false;
        this.createNew=false;
        this.createNewContact = false;
    }

    handleInputChange(event) {
        this.formData[event.target.fieldName] = event.target.value;
        console.log('event.target.fieldName-- '+ event.target.fieldName);
        console.log('event.target.value-- '+ event.target.value);

        console.log('this.formData-- '+ JSON.stringify(this.formData));
    }

    addressInputChange(event) {
        this.formData.Street = event.detail.street;
        this.formData.City = event.detail.city;
        this.formData.Country = event.detail.country;
        this.formData.PostalCode = event.detail.postalCode;
        this.formData.StateCode = event.detail.province;
    }

    handleAddContact() {
        debugger;
        this.validateInput();
    }
    handleExpansion(event){
        debugger;
        const indexVar = event.currentTarget.dataset.index;
        const updatedData = this.recordsList.map((row, index) => {
            debugger;
            console.log('index',index);
            if (index === parseInt(indexVar)) {
                const updatedRow = { ...row };
                console.log(updatedRow);
                updatedRow['showChild'] = !updatedRow['showChild'];
                return updatedRow;
            } else {
                const updatedRow = { ...row };
                return updatedRow;
            }
        });

        // Assign the updated back
        this.recordsList = updatedData;
    }

    handleEdit(event) {
        debugger;
        this.disableFirstName = false;
        this.disableEmail = false;
        this.disableOtherPhone = false;
        this.disableRole = false;
        this.disablePhone = false;
        this.disableLastName = false;
        this.formData = {};
        this.editRecord = true;
        this.createNew = false;
        this.createNewContact=false;
        const index = event.currentTarget.dataset.index;
        this.editIndex = parseInt(index, 10);
        const editedRow = this.recordsList[this.editIndex];
        this.headersApi.forEach(header => {
            this.formData[header] = editedRow[header];
            if(header == 'StateCode' && this.formData[header]!='' && this.formData[header]!=null && this.formData[header]!=undefined){
                console.log('here state');
                let foundObject = this.provinceOptions.find(option => option.value === (this.formData[header]).trim());
                console.log('foundObject',foundObject);
                this.formData.State = (foundObject!=null && foundObject!=undefined) ? foundObject.label : null;
            }
        });

        //Show phone details only if  the customer is residential customer and there is not other contact.
        if(this.objectName == 'Contact' && editedRow['NoContact']!=undefined && editedRow['NoContact']==true ){
            this.resContact=true;
        }else{
            this.resContact=false;
        }

        
        if(this.objectName == 'Contact' && editedRow['NoContact']!=undefined && editedRow['NoContact']==true ){
            this.disablePhone = true;
            if(editedRow['OtherPhone']!='' && editedRow['OtherPhone']!= undefined && editedRow['OtherPhone']!=null){
                this.disableOtherPhone =true;
            }
            if(editedRow['Email']!='' && editedRow['Email']!=undefined && editedRow['Email']!=null){
                this.disableEmail=true;
            }
        }

        if(this.objectName == 'Contact' && editedRow['Id']!='' && editedRow['Id']!=null && editedRow['Id']!=undefined && (editedRow['NoContact']==undefined || editedRow['NoContact']==null || editedRow['NoContact'] == '') ){
            this.disablePhone = true;
            if(editedRow['OtherPhone']!='' && editedRow['OtherPhone']!=undefined && editedRow['OtherPhone']!=null){
                this.disableOtherPhone =true;
            }
            if(editedRow['Email']!='' && editedRow['Email']!=undefined && editedRow['Email']!=null){
                this.disableEmail=true;
            }
            if(editedRow['Role__c']!='' && editedRow['Role__c']!=undefined && editedRow['Role__c']!=null ){
                this.disableRole=true;
            }
            if(editedRow['FirstName']!='' && editedRow['FirstName']!=undefined && editedRow['FirstName']!=null){
                this.disableFirstName=true;
            }
            if(editedRow['LastName']!='' && editedRow['LastName']!=undefined && editedRow['LastName']!=null){
                this.disableLastName = true;
            }
        }



        this.isModalOpen = true;
    }

    radioOnClick(event){
        console.log('inside on click');
        console.log(event.target.checked);

    }

    handleRadioChange(event) {
        debugger;
        //selectedRowId = event.target.name;
        var indexvar= event.target.id;

        console.log(' parseInt( this.selectedRowId.split('-')[0])', parseInt( (indexvar).split('-')[0]));
        const updatedData = this.recordsList.map((row, index) => {
            if (index === parseInt( (indexvar).split('-')[0])) {
                const updatedRow = { ...row };
                updatedRow['selected'] = true;
                if(this.objectName=='Address' &&  updatedRow['PostalCode']!=undefined){
                    this.selectedPincode = updatedRow['PostalCode'];
                    const selectEvent = new CustomEvent('submitpincode', {
                        detail: this.selectedPincode
                    });
                    console.log('event detail',selectEvent.detail);
                    // Fire the custom event
                    this.dispatchEvent(selectEvent);
                }

                return updatedRow;
            } else {
                const updatedRow = { ...row };
                updatedRow['selected'] = false;
                return updatedRow;
            }
        });

        // Assign the updated back
        this.recordsList = updatedData;
    }

    toggleSection(event) {
        let buttonid = event.currentTarget.dataset.buttonid;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section slds-is-close';
        }
    }

    findAsset() {
        getAsset({ serialNumber : this.serialNumber,recordId: this.addAssetId })
            .then(result => {
                console.log('result', result);
                if (result != null && result.Id != null) {
                    this.asset = result;
                    var assetRecord = {};
                    assetRecord['AssetName'] = result.Name;
                    assetRecord['SerialNumber'] = result.SerialNumber;
                    assetRecord['Model'] = (result.Product2 != null) ? result.Product2.ProductCode : null;
                    assetRecord['ProductSubFamily'] = (result.Product_Sub_Family__c != null && result.Product_Sub_Family__r.Name!=null) ? result.Product_Sub_Family__r.Name : null;
                    var nicCharge =  (result.Product_Sub_Family__c != null && result.Product_Sub_Family__r.NIC_Installation_Charges__c!=null) ? result.Product_Sub_Family__r.NIC_Installation_Charges__c : null;
                    if(nicCharge!=null && result.Asset_Obligation__c=='NIC'){
                        assetRecord['Asset_Obligation__c'] = result.Asset_Obligation__c + ', NIC Visiting Charge : '+nicCharge;
                    }else{
                        assetRecord['Asset_Obligation__c'] = result.Asset_Obligation__c;
                    }
                    assetRecord['CP__c'] = (result.CP__c!=null) ? result.CP__r.Name :'';
                    assetRecord['SDE__c'] = (result.SDE__c!=null) ? result.SDE__r.Name:'';
                    assetRecord['Branch__c'] = (result.Branch!=null) ? result.Branch__r.Name:'';
                    assetRecord['Id'] = result.Id;
                    assetRecord['SRNo'] = this.recordsList.length + 1;
                    assetRecord['Status'] = result.Status;
                    assetRecord['Division'] = (result.Serviceable_Division__c!=null && result.Serviceable_Division__r.Name!=null ) ? result.Serviceable_Division__r.Name : '';
                    assetRecord['Product_Sub_Family__c'] = result.Product_Sub_Family__c;
                    assetRecord['Product2Id'] = result.Product2Id;
                    assetRecord['ProductFamilyCode'] = (result.Product_Family__c!=null) ? result.Product_Family__r.Code__c : '';
                    assetRecord['ProductSubFamilyCode'] = (result.Product_Sub_Family__r!=null) ? result.Product_Sub_Family__r.Code__c : '';
                    assetRecord['IsInstallable'] = (result.Product2Id!=null) ? result.Product2.Is_Installable__c : false;


                    const updatedData = this.recordsList.filter(row => {
                        return row.Id !== result.Id; // Keep all rows except the one with the targetId
                    });
        
                    this.recordsList = updatedData;
                                    
                    this.recordsList = [assetRecord,...this.recordsList];
                    if(this.recordsList.length==1){
                        this.runOnce=false;
                    }else{
                        this.updateRadioAtFirstRow();
                    }   
                    this.updateSelectedAtFirstRow();
                    this.showHeaders = true;
                    this.isModalOpen = false;
                    this.noDataFound=false;
                    this.addAssetId = null;
                    if(this.searchAsset){
                        this.showToast('The asset is now located in the first row of the list ','Success');
                    }else{
                        this.showToast('The asset added to the list successfully.','Success');
                    }
                    this.searchAsset=false;
                    this.addAsset=false;
                   this.showPagination = true;
                    

                } else if (result != null && result.Id == null) {
                    this.asset = {};
                    this.isModalOpen = false;
                    this.showToast('No asset found for this serial number.','Error');
                }
            })
            .catch(error => {
                var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
                console.log('Error', error.body.message);
            });
    }

    assignSerialNumber(event) {
        this.serialNumber = event.target.value;
    }

    @api getChildData(){
        console.log('child method');
        console.log('this.recordsList get child',this.recordsList.length);
        const selectEvent = new CustomEvent('submitparent', {
            detail: {
                recordList: this.recordsList,
                objectName: this.objectName
            }
        });
        console.log('event detail',selectEvent.detail);
        // Fire the custom event
        this.dispatchEvent(selectEvent);

    }

    updateRadioAtFirstRow(){
        const radioButtons = this.template.querySelectorAll("." + this.objectName);
        //const radioButtons = parentDiv.querySelectorAll('input[type="radio"]');
        radioButtons.forEach(button => {
            debugger;
            var valueBeforeDash = (button.id).split("-")[0];
            console.log(button.id);
            console.log(button.name);
            if((valueBeforeDash).includes("0")){
                button.checked = true;
            }           
        });
    }

    @api
    removeRadio(){
        const radioButtons = this.template.querySelectorAll("." + this.objectName);
        //const radioButtons = parentDiv.querySelectorAll('input[type="radio"]');
        radioButtons.forEach(button => {
            debugger;
            console.log(button.id);
            console.log(button.name);
           
                button.checked = false;
                      
        });

        const updatedData = this.recordsList.map((row, index) => {
            const updatedRow = { ...row };
            updatedRow['selected'] = false;
            return updatedRow;
            
        });

        // Assign the updated back
        this.recordsList = updatedData;
    }

    updateSelectedAtFirstRow(){
        const updatedData = this.recordsList.map((row, index) => {
            if (index == 0) {
                const updatedRow = { ...row };
                updatedRow['selected'] = true;
                return updatedRow;
            } else {
                const updatedRow = { ...row };
                updatedRow['selected'] = false;
                return updatedRow;
            }
        });

        // Assign the updated back
        this.recordsList = updatedData;
    }

    validateInput(){
        var allValid=true;
        console.log('validateInput');
        debugger;
        var phoneRegexp = /^[6-9]\d{9}$/;
        if(this.objectName=='Contact'){
            if((this.formData.LastName=='' || this.formData.LastName==null) && this.isCommercial){
                allValid=false;
            } if((this.formData.Phone=='' || this.formData.Phone==null)){
                allValid=false;
            }
             if((this.formData.Email=='' || this.formData.Email==null) && this.isCommercial){
                allValid=false;
            }
            if(this.formData.GenderIdentity=='' || this.formData.Salutation==null){
                allValid=false;
            }


            if(allValid==false){
                this.showToast('Please complete required fields : LastName, Phone, Email, Gender Identity, Salutation.','Error');
            }
            if(this.formData.Phone!='' && this.formData.Phone!=null && phoneRegexp.test(this.formData.Phone)==false){
                allValid=false;
                this.showToast('Please enter phone number in correct format.','Error');
            }
            if(this.formData.OtherPhone!='' && this.formData.OtherPhone!=null && phoneRegexp.test(this.formData.OtherPhone)==false){
                allValid=false;
                this.showToast('Please enter phone number in correct format.','Error');
            }
            if(allValid){
                this.addRow();
            }
        }
        if(this.objectName=='Address'){
            if(this.formData.Street=='' || this.formData.Street==null || this.formData.City=='' || this.formData.City==null || this.formData.Country=='' || this.formData.Country==null || this.formData.StateCode=='' || this.formData.StateCode==null){
                this.showToast('Please complete the required fields.','Error');
            }else{
               this.findSectorBased();               
            }
        }     
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

    findSectorBased(){
        getSectorBasedCity({city:this.formData.City})
                       .then(result =>{
                        console.log('result',result);
                        this.searchBySector=false;
                        if(result!=null && result.Id!=null){
                            this.searchBySector=true;
                        }
                        debugger;
                        if(this.searchBySector==true && (this.formData.Sector__c == '' || this.formData.Sector__c == null)){
                            this.showToast('Please add shipping sector.','Error');
                        }else if (this.searchBySector==false && (this.formData.PostalCode==null || this.formData.PostalCode=='') ){
                            this.showToast('Please add shipping pincode.','Error');
                        }else{
                            this.addRow();
                        }
                        })
                       .catch(error =>{
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
        }); 
    }

    getStates(){
        getStateCodes()
                       .then(result =>{
                        console.log('result states',result);
                        result.forEach(resultVar => {
                            this.provinceOptions.push({label:resultVar.Label, value:resultVar.QualifiedApiName});
                        });
                        })
                       .catch(error =>{
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
        }); 
    }

    addRow(){
        debugger;
        if (this.editIndex === null) {
            const newRecord = {};
            this.headersApi.forEach(header => {
                console.log('header--',header);       

                if (header == 'SRNo') {
                    newRecord['SRNo'] = this.recordsList.length + 1;
                }else {
                    if (this.formData[header] != undefined) {
                        newRecord[header] = this.formData[header];
                    }
                    else {
                        newRecord[header] = '';
                    }

                }
            });
            //add the logic for select; 
            console.log('newRecord--',newRecord);       
            this.recordsList = [newRecord, ...this.recordsList];
            this.updateSelectedAtFirstRow();
            if(this.recordsList.length==1){
                this.runOnce=false;
            }else{
                this.updateRadioAtFirstRow();
            }
            if(this.objectName=='Address'){
                this.showNewButton=false;
            }        
        } else {
            const updatedData = this.recordsList.map((row, index) => {
                if (index === this.editIndex) {
                    const updatedRow = { ...row };
                    this.headersApi.forEach(header => {
                        updatedRow[header] = this.formData[header];
                    });
                    return updatedRow;
                } else {
                    return row;
                }
            });

            this.recordsList = updatedData;
        }
        this.showHeaders = true;
        this.noDataFound=false;
        if(this.objectName!='Address'){
            this.handleCloseModal();
        }
    }
    
    handleKeyDown(event) {
        if(event.code == 'Escape') {
          this.openModal = false;
          event.preventDefault();
          event.stopImmediatePropagation();
        }
    }

    handleDescending(){
        debugger;
        const updatedData = this.recordsList.map((row, index) => {
                return row;
        });

        this.showAscending = !this.showAscending;
        updatedData.sort(function(a, b){
            const assetNameA = a.AssetName.toUpperCase(); // Convert to uppercase for case-insensitive comparison
            const assetNameB = b.AssetName.toUpperCase();
        
            if (assetNameA < assetNameB) {
                return -1;
            }
            if (assetNameA > assetNameB) {
                return 1;
            }
            return 0;
        });
        this.recordsList = updatedData;
        this.updateRadioAtFirstRow();
        this.updateSelectedAtFirstRow();
    }

    handleAscending(){
        debugger;

        const updatedData = this.recordsList.map((row, index) => {
            return row;
        });
        this.showAscending = !this.showAscending;
        updatedData.sort(function(a, b){
            const assetNameA = a.AssetName.toUpperCase(); // Convert to uppercase for case-insensitive comparison
            const assetNameB = b.AssetName.toUpperCase();
        
            if (assetNameA > assetNameB) {
                return -1;
            }
            if (assetNameA < assetNameB) {
                return 1;
            }
            return 0;
        });
        this.recordsList = updatedData;
        this.updateRadioAtFirstRow();
        this.updateSelectedAtFirstRow();
    }


    //Pagination Method
    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    handleRecordsPerPage(event) {
        this.runOnce = false;
        this.pageSize = event.target.value;
        this.paginationHelper();
    }

    previousPage() {
        this.runOnce = false;
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        debugger;
        this.runOnce = false;
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.runOnce = false;
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.runOnce = false;
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    paginationHelper() {
        this.recordsList = [];
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

        this.recordsList = tempRecords;
        this.recordsList = [... this.recordsList];

        if(this.objectName!='Asset'){
            this.updateRadioAtFirstRow();
            this.updateSelectedAtFirstRow();
        }
        
        console.log('records', JSON.stringify(this.recordsList));
        console.log('run once', this.runOnce);
    }

    fetchPrice(){
        debugger;
        var familyCode;
        var subFamilyCode;

        
        this.recordsList.forEach(asset => {
            console.log('asset selected',asset['selected']);
            if(asset['selected']==true){
                familyCode = asset['ProductFamilyCode'];
                subFamilyCode = asset['ProductSubFamilyCode'];
                this.assetUnderWarranty = (asset['Asset_Obligation__c']).includes("NIC")? false : true;
            }
        });
        this.fetchRateCard(familyCode,subFamilyCode);

    }

    fetchRateCard(selectedProductFamilyCode,selectedProductSubFamilyCode){
        debugger;
        console.log('selectedProductFamilyCode',selectedProductFamilyCode);
        console.log('selectedProductSubFamilyCode',selectedProductSubFamilyCode);
        getRateCard({ familyCode: selectedProductFamilyCode, familySubCode: selectedProductSubFamilyCode })
        .then(result => {
            console.log('JSON.stringify(result)',JSON.stringify(result));
            this.rateMatrixesWithSelection = JSON.parse(JSON.stringify(result));     
            if(this.rateMatrixesWithSelection.length > 0){
                this.showPrice = true;
            }else{
                this.showPrice = false;
                this.showToast('Unable to retrieve rates ','Error');
            }
            //this.hasRateMatrix = this.rateMatrixesWithSelection.length > 0;
        })
        .catch(error => {
            console.error('Error fetching product family: ', error);
        });
       
    }

    handleAddressValues(event){
        console.log('in address');
        console.log(event.detail.flat);
        console.log('in address2');
        this.formData.House_Flat__c = event.detail.flat;
        //this.formData.Sector__c= ;
        //this.formData.Area__c = event.detail.area;
        this.formData.Locality__c = event.detail.locality;
        this.formData.Sub_Locality__c = event.detail.sublocality;
        this.formData.Street = event.detail.street;
        if(event.detail.sector!=null && event.detail.sector!=undefined ){
            this.formData.Sector__c = event.detail.sector;
        }else{
            this.formData.Sector__c = '';
        }
        

        this.formData.City = event.detail.city;
        this.formData.Country = event.detail.country;
        this.formData.PostalCode = event.detail.pincode;
        let foundObject = this.provinceOptions.find(option => option.label === (event.detail.state).trim());
        console.log('foundObject',foundObject);
        //console.log('foundObject',foundObject.value);
        this.formData.StateCode = (foundObject!=null && foundObject!=undefined) ? foundObject.value : null;
        this.addRow();
        this.handleCloseModal();

        this.selectedPincode =  this.formData.PostalCode;

        const selectEvent = new CustomEvent('submitpincode', {
            detail: this.selectedPincode
        });
        console.log('event detail',selectEvent.detail);
        // Fire the custom event
        this.dispatchEvent(selectEvent);

    }
   

}