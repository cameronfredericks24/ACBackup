import { LightningElement,api, track,wire } from 'lwc';
import getAccount from '@salesforce/apex/CreateCaseFormController.getAccount';
import tagChannelPartner from '@salesforce/apex/CreateCaseFormController.tagChannelPartner';
import getRecordTypes from '@salesforce/apex/CreateCaseFormController.getRecordTypes';
import createRecords from '@salesforce/apex/CreateCaseFormController.createRecords';
import getAccountBasedOnNameAndPincode from '@salesforce/apex/CreateCaseFormController.getAccountBasedOnNameAndPincode';
import checkSSDUser from '@salesforce/apex/CreateCaseFormController.checkSSDUser';
import getIssueTypes from '@salesforce/apex/CreateCaseFormController.getIssueTypes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getRateCard from '@salesforce/apex/RateCardController.getRateCard';
import getProductSubFamily from '@salesforce/apex/CreateCaseFormController.getProductSubFamily';
import deleteCase from '@salesforce/apex/CaseDeleteController.deleteCase';
import fetchProductFamily from '@salesforce/apex/CreateCaseFormController.fetchProductFamily';
import fetchProducts from '@salesforce/apex/CreateCaseFormController.fetchProducts';
import getCommercialAccountSearch from '@salesforce/apex/CreateCaseFormController.getCommercialAccountSearch';
import Id from '@salesforce/user/Id';

export default class CreateCaseForm extends NavigationMixin(LightningElement) {
    ssduserId = Id;
    @api recordId;
    @api assetId;
    customerEmailAddress;
    customerPhoneNumber;
    serialNumber;
    showRecordTypeScreen = true;
    showEnterDetailsScreen = false;
    showCommCustomerScreen=false;
    showAccountScreen = false;
    showCaseScreen=false;
    serialNumberPresent=false;
    serialNumberNotPresent=false;
    showAssetScreen=false;
    accountFound=false;
    assetFound=false;
    subfamilySelected=false;
    @track account={};
    @track asset={};
    @track caseRecord={};
    @track contactRecord={};
    @track owner={}
    accountFoundMessage;
    assetFoundMessage;
    caseRecordTypeId;
    accountRecordTypeId;
    accountRecordType;
    commercialAccountRecordTypeId;
    recordTypeMap;
    isCommercial=false;
    disableButton = false;
    @track lstRecordTypes =[];
    quickAction=false;
    objectList=['Account','Case','Contact'];
    showCPScreen=false;
    showSpinner=false;
    @api contactData=[];
    selectedAddress=0;
    @track billingAddressheaderLabels= [{House_Flat__c:'House/Flat/Shop/Plot/Survey No',Sector__c: 'Sector',Locality__c:'Locality', Sub_Locality__c:'Sub Locality',Street:'Street',City:'City', PostalCode:'Postal Code', StateCode:'State', Country:'Country'}];
    @track shippingAddress=[];
    @api assetData=[];
    @track assetLabels=[{ AssetName:'Asset Name', SerialNumber:'Serial Number',Model:'Model', ProductSubFamily:'Product Sub Family', Asset_Obligation__c : 'Obligation', Status:'Asset Status', CP__c:'CP', SDE__C:'SDE'}];
    @track headerLabels = [
        { FirstName: 'FirstName', LastName: 'LastName',Phone:'Phone', Email: 'Email',OtherPhone: 'Secondary Phone No',Role__c: 'Role', GenderIdentity: 'GenderIdentity',Salutation: 'Salutation'}
    ];
    isNamo = false;
    existingAsset=false;
    businessContactRecordType;
    familyContactRecordType;
    contactRecordType;
    createServiceTicket=false;
    showServiceTicketButton=true;
    recordTypeName;
    resAccName ;
    resPincode;
    showNewaccountButton;
    showNext;
    @track accountColumns = [
        { label: 'Account Name', fieldName: 'Name', type: 'text',initialWidth:200, wrapText:true },
        { label: 'Active', fieldName: 'Is_Active__c', type: 'boolean',initialWidth: 160},
        { label: 'Pincode', fieldName: 'ShippingPostalCode', type: 'text', initialWidth: 160},
        { label: 'Address', fieldName: 'ShippingStreet', type: 'text',wrapText: true,initialWidth:500 },
        { label: 'Locality', fieldName: 'Shipping_Locality__c', type: 'text',wrapText: true,initialWidth: 160},
        { label: 'Sub Locality', fieldName: 'Shipping_Sublocality__c', type: 'text',wrapText: true,initialWidth: 160},
        { label: 'Sector', fieldName: 'Shipping_Sector__c', type: 'text',initialWidth: 160}
    ];
    accountdata=[];
    showDatatable=false;
    accountsearchlabel = 'Account Name';
    ssdUser = false;
    issueTypes=[];
    disableSegment = false;
    disableSubSegment=false;
    disableSolId = false;
    disableParentId = false;
    @track rateMatrixesWithSelection = [];
    assetUnderWarranty = false;
    showPrice=false;
    disableAccountName=false;
    disableSal=false;
    disableFirstName=false;
    disableLastName=false;
    disableMiddleName=false;
    disableSuffix=false;
    isVIP = false;
    accountChange = false;
    showCharges = false;
    emailAddress;
    branch;
    solId;
    accName;
    commContactName;
    commEmail;
    sendChargesClicked=false;
    customerId;


    //Product Family variables
    @track productOptions = [];
    @track products =[];
    selectedPincode;
    createNewAccountBoolean=false;

    
    


    connectedCallback() {
        //To check if component has been called from account 
        if(this.recordId!=null && this.recordId!=undefined){
            this.account.Id = this.recordId;
            this.showRecordTypeScreen = false;
            this.quickAction=true;
            this.handleCommAccount();
        } 
        this.caseRecord.Sub_Type_Source__c = 'Call From Customer';
         
        this.checkSSDUserMethod();
        this.getIssueTypesMethod();
        this.loadProductFamily();
        
    }
    
    renderedCallback() {

        if(this.recordId!=null && this.recordId!=undefined){
            const divElement = this.template.querySelector('.my-div');
            divElement.classList.remove('slds-box');
            divElement.classList.remove('box-shadow');
        }
    }

    //Filter to search the commercial recordtype accounts
    filter = {
        criteria: [
                {
                fieldPath: 'RecordTypeId',
                operator: 'eq',
                value: this.commercialAccountRecordTypeId
                }
            ]
    }

     //Filter to search the products from product sub family
     get productfilter(){
        return {
            criteria: [
                {
                    fieldPath: 'Product_Sub_Family__c',
                    operator: 'eq',
                    value: this.caseRecord.Product_Sub_Family_temp__c
                }
            ]
        }
    }

    matchingInfoProduct = {
        primaryField: { fieldPath: 'Name' },
        additionalFields: [{ fieldPath: 'ProductCode' }],
    };

    matchingInfoAccount = {
        primaryField: { fieldPath: 'Name' }
    };

    displayInfoAccount = {
        primaryField: 'Name',
        additionalFields: ['Namo_Branch_Formula__c'],
    };

    displayInfoProduct = {
        primaryField: 'Name',
        additionalFields: ['ProductCode'],
    };

    //Get the Record Type Info for Account, case and Contact
    @wire(getRecordTypes,{objectList:'$objectList'})
    getRecordTypes(result){
        if (result.error) {
            this.lstRecordTypes = [];
            this.recordTypeMap = new Map();
            console.log('Error', result.error);
            var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
        } else if (result.data) {
            for (let key in result.data) {
                if(key=='Contact'){
                    result.data[key].forEach(resultvar => { 
                        if(resultvar.DeveloperName=='Business_Contact'){
                            this.businessContactRecordType=resultvar.Id;
                        }else if(resultvar.DeveloperName=='Family_Contact'){
                            this.familyContactRecordType=resultvar.Id;
                            this.contactRecordType=this.familyContactRecordType;
                        }
                    });
                }
                if(key=='Case'){
                    result.data[key].forEach(resultvar => { 
                        if(resultvar.DeveloperName=='Customer_Request'){
                            this.caseRecordTypeId =resultvar.Id;
                        }
                    });
                }
                if(key=='Account'){
                    this.lstRecordTypes = [];
                    this.recordTypeMap = new Map();
                    result.data[key].forEach(resultvar => { 
                        if((resultvar.DeveloperName).includes('Customer')){
                            this.lstRecordTypes.push({ value: resultvar.Id, label:resultvar.Name});
                            this.recordTypeMap.set(resultvar.Id,resultvar.DeveloperName);
                        }

                        if((resultvar.DeveloperName).includes('Commercial')){
                            this.lstRecordTypes.push({ value: resultvar.Id+'-', label:'NAMO Customer'});
                            this.recordTypeMap.set(resultvar.Id+'-','NAMO Customer');
                        }
                    });
                }
            }          
        }
    }
  
    //Method to assign account record type Id based on user selection
    assignRecordType(event){
        this.accountRecordTypeId=(event.detail.value).replace('-','');
        this.accountRecordType =(this.recordTypeMap).get(this.accountRecordTypeId);
        this.recordTypeName = this.accountRecordType.replace('_',' ');
        debugger;
        if(this.accountRecordType == 'Commercial_Customer'){
            this.commercialAccountRecordTypeId = this.accountRecordTypeId;
            this.isCommercial=true;
            this.contactRecordType=this.businessContactRecordType;
        }


        if((this.recordTypeMap).get(event.detail.value)=='NAMO Customer'){
            this.matchingInfoAccount = {
                primaryField: { fieldPath: 'Name' },
                additionalFields: [{ fieldPath: 'Namo_Branch_Formula__c' }],
            };

            this.displayInfoAccount = {
                primaryField: 'Name',
                additionalFields: ['Namo_Branch_Formula__c'],
            };

            this.filter = {
                criteria: [
                        {
                            fieldPath: 'Group__c',
                            operator: 'eq',
                            value: 'NAMO'
                        },
                    ]
            }
            this.accountsearchlabel = 'Name / SOL ID / Branch ';
            this.isNamo=true;
        }else{
            this.isNamo=false;
            this.matchingInfoAccount = {
                primaryField: { fieldPath: 'Name' }
            };

            this.displayInfoAccount = {
                primaryField: 'Name',
                additionalFields: ['Namo_Branch_Formula__c'],
            };

            this.filter = {
                criteria: [
                        {
                        fieldPath: 'RecordTypeId',
                        operator: 'eq',
                        value: this.commercialAccountRecordTypeId
                        }
                    ]
            }

            this.accountsearchlabel = 'Account Name';
        }
        this.handleNext();
    }

    handleEmailChange(event){
        this.customerEmailAddress = event.target.value;
    }
    handlePhonChange(event){
        this.customerPhoneNumber = event.target.value;
    }
    handleAsset(){
        this.serialNumberPresent=true;
        this.serialNumberNotPresent=false;
        this.subfamilySelected=false;
        this.caseRecord.Product_Sub_Family_temp__c=null;
        this.caseRecord.ProductId=null;
    }

    handleAssetClose(){
        this.serialNumberNotPresent=false;
        this.subfamilySelected=false;
        this.caseRecord.Product_Sub_Family_temp__c=null;
        this.caseRecord.ProductId=null;
    }

    handleProduct(){
        this.serialNumberNotPresent=true;
        this.serialNumberPresent=false;
    }
    assignSerialNumber(event){
        this.serialNumber= event.target.value;
    }
    handleNext(){
        if(this.accountRecordTypeId!=null){
            if(this.accountRecordType=='Commercial_Customer'){
                this.showCommCustomerScreen=true;
            }else{
                this.showEnterDetailsScreen=true;
            }       
            this.showRecordTypeScreen=false; 
        }else{
            this.showToast('Please select the customer type.','Error');
        }
          
    }
    handleBack(){
        this.showEnterDetailsScreen=false;
        this.showCommCustomerScreen=false;
        this.showRecordTypeScreen=true;
    }

    //Method to validate user input
    handleSearch(){

       
        if (allValid) {
            this.showEnterDetailsScreen=false;
            this.getAccountJs();
        }
    }

    searchCommAccount(){
        debugger;
        if((this.resAccName!='' && this.resAccName!=null ) && (this.customerEmailAddress=='' || this.customerEmailAddress==null)){
            this.showToast('Please enter Contact Name and Email both to search the account.','Error');
            return;
        }
        if((this.customerEmailAddress!='' && this.customerEmailAddress!=null ) && (this.resAccName=='' || this.resAccName==null)){
            this.showToast('Please enter Contact Name and Email both to search the account.','Error');
            return;
        }
        if((this.account.Id == '' || this.account.Id==null) && ((this.customerEmailAddress=='' || this.customerEmailAddress==null) && (this.resAccName=='' || this.resAccName==null)) ){
            this.showToast('Please enter account name or contact name and email to search the account.','Error');
            return;
        }
        this.handleCommAccount();
    }

    handleCommAccount(){
        //this.showCommCustomerScreen=false;
        this.getAccountJs();
    }

    //method to get already existed account record 
    getAccountJs(){
        this.showSpinner=true;
        getAccount({recordTypeId:this.accountRecordTypeId, recordId:this.account.Id})
                       .then(result =>{
                        console.log('result',result);
                        if(result!=null && result.Id!=null){
                            debugger;
                            console.log('result',result);
                            this.showAccountScreen=true;
                            this.showSpinner=false;
                            this.account = result;
                            this.accountFound = true;

                            this.disableSegment = (this.account.Industry!=null) ? true :false;
                            this.disableSubSegment = (this.account.Sub_Segment__c!=null) ? true :false;
                            this.disableSolId = (this.account.SOL_Store_ID__c!=null) ? true :false;
                            this.disableParentId = (this.account.ParentId!=null) ? true :false;
                            this.disableAccountName = (this.account.Name!=null) ? true :false;
                            this.disableSal=(this.account.Salutation!=null) ? true :false;
                            //this.disableFirstName=(this.account.FirstName!=null) ? true :false;
                            //this.disableLastName=(this.account.LastName!=null) ? true :false;
                            //this.disableMiddleName=(this.account.MiddleName!=null) ? true :false;
                            this.disableSuffix=(this.account.Suffix!=null) ? true :false;

                            


                            if(result.Group__c == 'NAMO'){
                                this.isNamo=true;
                            }

                            if(result.Category__c == 'VIP'){
                                this.isVIP = true;
                            }else{
                                this.isVIP=false;
                            }

                            this.accountRecordTypeId = result.RecordTypeId;
                            this.accountRecordType = result.RecordType.DeveloperName;
                            this.recordTypeName = (result.RecordType.DeveloperName).replace('_',' ');

                            //debugger;

                            if(result.Assets!=null && result.Assets.length>0){
                                var i=0;
                                result.Assets.forEach(record => {
                                    i++;
                                    //debugger;
                                    var assetRecord = {};
                                    assetRecord['AssetName'] = record.Name;
                                    assetRecord['SerialNumber'] = record.SerialNumber;
                                    assetRecord['Model'] = (record.Product2Id!=null)? record.Product2.ProductCode : '';
                                    assetRecord['ProductSubFamily'] = (record.Product_Sub_Family__c != null && record.Product_Sub_Family__r.Name!=null) ? record.Product_Sub_Family__r.Name : null;
                                    var nicCharge =  (record.Product_Sub_Family__c != null && record.Product_Sub_Family__r.NIC_Installation_Charges__c!=null) ? record.Product_Sub_Family__r.NIC_Installation_Charges__c : null;
                                    if(nicCharge!=null && record.Asset_Obligation__c=='NIC' ){
                                        assetRecord['Asset_Obligation__c'] = record.Asset_Obligation__c + ', NIC Visiting Charge : '+nicCharge;
                                    }else{
                                        assetRecord['Asset_Obligation__c'] = record.Asset_Obligation__c;
                                    }
                                   
                                    assetRecord['CP__c'] = (record.CP__c!=null)?record.CP__r.Name : '';
                                    assetRecord['SDE__c'] = (record.SDE__c!=null) ? record.SDE__r.Name: '';
                                    assetRecord['Branch__c'] = (record.Branch__c) ? record.Branch__r.Name : '';
                                    assetRecord['Id'] = record.Id;
                                    assetRecord['SRNo'] = i;
                                    assetRecord['Status'] = record.Status;
                                    assetRecord['Division'] = (record.Serviceable_Division__c!=null && record.Serviceable_Division__r.Name!=null ) ? record.Serviceable_Division__r.Name : '';
                                    assetRecord['Product_Sub_Family__c'] = record.Product_Sub_Family__c;
                                    assetRecord['Product2Id'] = record.Product2Id;
                                    assetRecord['CreatedDate'] = record.CreatedDate;
                                    assetRecord['ParentId'] = record.ParentId;
                                    assetRecord['ProductFamilyCode'] = (record.Product_Family__c!=null) ? record.Product_Family__r.Code__c : '';
                                    assetRecord['ProductSubFamilyCode'] = (record.Product_Sub_Family__r!=null) ? record.Product_Sub_Family__r.Code__c : '';
                                    assetRecord['IsInstallable'] = (record.Product2Id!=null) ? record.Product2.Is_Installable__c : false;
                                    assetRecord['PostalCode'] = record.PostalCode;
                                    assetRecord['RecordType'] = record.RecordType.Name;

                                    if(i==1){
                                        assetRecord['selected']=false;
                                        if((this.ssdUser && record.CP__c !=null && record.CP__r.CP_User__c == this.ssduserId ) || !this.ssdUser){
                                            this.assetData = [assetRecord,...this.assetData];
                                        }
                        
                                    }else{
                                        assetRecord['selected']=false;
                                        if((this.ssdUser && record.CP__c !=null && record.CP__r.CP_User__c == this.ssduserId ) || !this.ssdUser){
                                            this.assetData = [...this.assetData, assetRecord];
                                        }
                                        
                                    }
                                   
                                    this.existingAsset=true;
                                });
                            }

                            var primarySelected = false;
                            var resContactAddedAlready = false;
                            debugger;
                            if(result.Contacts!=null && result.Contacts.length>0 ){
                                var i=0;
                                result.Contacts.forEach(record => {
                                    i++;
                                    var contactRecord = {};
                                    if( result.Phone!=undefined && result.Phone!=null && record.Phone == result.Phone){
                                        resContactAddedAlready=true;
                                    }
                                    console.log('resContactAddedAlready',resContactAddedAlready);
                                    contactRecord['FirstName'] = record.FirstName;
                                    contactRecord['LastName'] = record.LastName;
                                    contactRecord['Phone'] = record.Phone;
                                    contactRecord['Email'] = record.Email;
                                    contactRecord['OtherPhone'] = record.OtherPhone;
                                    contactRecord['Role__c'] = record.Role__c;
                                    contactRecord['Id'] = record.Id;
                                    contactRecord['Is_Primary__c'] = record.Is_Primary__c;
                                    contactRecord['SRNo'] = i;
                                    if(record.Is_Primary__c == true){
                                        contactRecord['selected'] = true;
                                        primarySelected=true;
                                        this.contactData = [contactRecord,...this.contactData];
                                    }else{
                                        contactRecord['selected'] = false;
                                        this.contactData = [...this.contactData, contactRecord];
                                    }                                       
                                });

                                if (!primarySelected && this.contactData.length > 0) {
                                    this.contactData[0].Is_Primary__c = true;
                                    this.contactData[0].selected = true;
                                }
                            }

                           
                            if(this.accountRecordType == 'Commercial_Customer'){
                                this.isCommercial=true;
                                this.contactRecordType = this.businessContactRecordType;
                                
                                    var addRecord = {};
                                    addRecord['House_Flat__c'] = result.Shipping_House_Flat_BlockNo__c;
                                    addRecord['Locality__c'] = result.Shipping_Locality__c;
                                    addRecord['Sub_Locality__c'] = result.Shipping_SubLocality__c;
                                    addRecord['Sector__c'] = (result.Shipping_Sector__c!=null) ? result.Shipping_Sector__c : null;
                                    addRecord['Street'] = result.ShippingStreet;
                                    addRecord['City'] = result.ShippingCity;
                                    addRecord['PostalCode'] = result.ShippingPostalCode;
                                    addRecord['StateCode'] = result.ShippingStateCode;
                                    addRecord['Country'] = result.ShippingCountry;
                                    addRecord['selected'] = true;
                                    addRecord['Selected__c'] = true;
                                    this.selectedPincode =  result.ShippingPostalCode; 
                                    addRecord['SRNo'] = i;
                                    this.shippingAddress = [...this.shippingAddress, addRecord];
                                

                            }else{
                                console.log('final contact res',resContactAddedAlready);
                                if(  result.Contacts!=null && result.Contacts.length==0 && resContactAddedAlready==false && result.Phone!=null && result.Phone!=undefined && result.Phone!=''){
                                    var contactRecord = {};
                                    contactRecord['FirstName'] = '-';
                                    contactRecord['LastName'] = '-';
                                    contactRecord['Phone'] = result.Phone;
                                    contactRecord['Email'] = result.Email__c;
                                    contactRecord['OtherPhone'] = result.Secondary_Phone_No__c;
                                    contactRecord['Role__c'] = '';
                                    if(primarySelected==false){
                                        contactRecord['selected'] = true;
                                        primarySelected=true;
                                    }else{
                                        contactRecord['selected'] = false;
                                    }
                                    
                                    contactRecord['SRNo'] = 1;
                                    contactRecord['NoContact'] = true;
                                    this.contactData = [contactRecord,...this.contactData];
                                }
                                

                                    //Add Shipping address for residential
                                    var addRecord = {};
                                    addRecord['House_Flat__c'] = result.Shipping_House_Flat_BlockNo__c;
                                    addRecord['Locality__c'] = result.Shipping_Locality__c;
                                    addRecord['Sub_Locality__c'] = result.Shipping_SubLocality__c;
                                    addRecord['Sector__c'] = result.Shipping_Sector__c;
                                    addRecord['Street'] = result.ShippingStreet;
                                    addRecord['City'] = result.ShippingCity;
                                    addRecord['PostalCode'] = result.ShippingPostalCode;
                                    addRecord['StateCode'] = result.ShippingStateCode;
                                    addRecord['Country'] = result.ShippingCountry;
                                    addRecord['selected'] = true;
                                    addRecord['Selected__c'] = true;
                                    this.selectedPincode =  result.ShippingPostalCode; 
                                    addRecord['SRNo'] = i;
                                    this.shippingAddress = [...this.shippingAddress, addRecord];
                                                             
                            }

                            if(this.quickAction==true){
                                this.showAccountScreen = true;
                                this.showCaseScreen=true;
                            }else{
                                this.showAccountScreen = true;
                            }

                            console.log('Here 1');
                            this.showEnterDetailsScreen = false;
                            console.log('Here 2');
                            this.accountFoundMessage = (this.quickAction) ? 'Update account details if required.': 'Existing customer account found. Please verify the details and click on next.';
                            console.log('Here 3');
                            this.showCommCustomerScreen=false;
                            console.log('Here 4');
                        }else if(result!=null && result.Id==null){
                            if(this.createNewAccountBoolean==true){
                                this.showSpinner=false;
                                this.createNew();
                            }else{
                                this.createNewAccountBoolean=false;
                                if(this.resAccName!='' && this.resAccName!=null && this.resPincode!='' && this.resPincode!=null){
                                    this.getAccountBasedOnPincode();
                                }else{
                                    this.showToast('No customer account found. Please try with other combinations or create new account.','Error');
                                    this.showNewaccountButton=true;
                                    this.showSpinner=false;
                                    this.accountFound = false;
                                }

                            }
                          
                        }
                        })
                       .catch(error =>{
                        console.log('Here 5',error);
                        this.showSpinner=false;
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
           });   
    }

    proceedWithCase(){  
        this.createServiceTicket=false;
        if(this.caseRecord.Id!=null){
            this.navigateToCase();
        }else{
            this.formSubmit();
        }
        

    }

    generateServiceTicket(){  
        this.createServiceTicket=true;
        if(this.caseRecord.Id!=null){
            this.tagChannelPartner();
        }else{
            this.formSubmit();
        }

    }

    formSubmit(){    
        debugger;
        var valid=true;
        var requiredFields='';
        var errorMessage = '';
        this.disableButton=true;

        //To check if all the mandatory fields are filled
        if(/*this.isCommercial==true && */this.account.Name==null){
            requiredFields+='Account Name'+', ';
            valid=false;
        }/*if(this.isCommercial==false && this.account.LastName==null){
            requiredFields+='Account Name'+', ';
            valid=false;
        }*/if(this.caseRecord.Type==null){
            requiredFields+='Case Type'+', ';
            valid=false;
        }if(this.caseRecord.Subject__c==null || this.caseRecord.Subject__c=='None' ){
            requiredFields+='Subject'+', ';
            valid=false;
        }if(this.serialNumberNotPresent==true && this.caseRecord.Product_Sub_Family_temp__c==null){
            requiredFields+='Product Sub Family'+', ';
            valid=false;
        }if(this.caseRecord.Sub_Type_Source__c==null || this.caseRecord.Sub_Type_Source__c=='' || this.caseRecord.Sub_Type_Source__c==undefined || this.caseRecord.Sub_Type_Source__c=='None' || this.caseRecord.Sub_Type_Source__c=='--None--'){
            requiredFields+='Sub Type Source'+', ';
            valid=false;
        }if(this.caseRecord.Description==null || this.caseRecord.Description=='' || this.caseRecord.Description==undefined){
            requiredFields+='Description'+', ';
            valid=false;
        }



        if(this.template.querySelector(".contactChild")!=null && this.template.querySelector(".contactChild")!=undefined){
            this.template.querySelector(".contactChild").getChildData();
        }
        
        this.template.querySelector(".addressChild").getChildData();
        if(this.existingAsset || this.serialNumberPresent){
            this.template.querySelector(".assetChild").getChildData();
        }

        if(this.contactData.length==0){
            requiredFields+='Contact Details'+', ';
            valid=false;
        }if(this.shippingAddress.length==0){
            requiredFields+='Shipping Address'+', ';
            valid=false;
        }

        debugger;
        var phoneRegex = /^[6-9]\d{9}$/;
        if(requiredFields!=''){
            valid=false;
            errorMessage ='Please add '+requiredFields.slice(0, -2)+' to create case.';
        }else if(this.caseRecord.Caller_Phone__c !=null && this.caseRecord.Caller_Phone__c!=undefined && this.caseRecord.Caller_Phone__c!='' &&  !(phoneRegex.test(this.caseRecord.Caller_Phone__c))){
            valid=false;
            errorMessage = 'Please enter a valid caller phone number.';
        }else if( this.caseRecord.Type!='Enquiry' && this.serialNumberNotPresent && this.caseRecord.Product_Sub_Family_temp__c==null){
            valid=false;
            errorMessage='Please include either assets or the model.';
        }else if(this.caseRecord.Type!='Enquiry' && this.serialNumberNotPresent==false){
            var assetSelected = false;
            this.assetData.forEach(asset => {
                console.log('asset selected validation',asset['selected']);
                if(asset['selected']==true){
                    assetSelected = true;
                }
            });

            if(assetSelected==false){
                valid=false;
                errorMessage='Please include either assets or the model.';
            }
        }

        if(valid){
            this.showSpinner=true;
            this.disableButton=true;
            var jsParameters ={};
            debugger;
            var contactList = [];
            var addressList = [];
            var assetRecordVar = {};
            var primaryContact = {};
            var selectedAddress={}
            this.contactData.forEach(contact => {
               
                console.log('contact selected',contact['selected']);
                const updatedRow = { ...contact };
                if(contact.selected==true){
                    primaryContact=contact;
                    updatedRow['Is_Primary__c'] = true;
                }else{
                    updatedRow['Is_Primary__c'] = false;
                }
                contactList.push(updatedRow);
            });

            debugger;
            this.shippingAddress.forEach(address => {
                console.log('address selected',address['selected']);
                const updatedRow = { ...address };
                if(address.selected==true){
                    selectedAddress=address;
                    updatedRow['Selected__c'] = true;
                }else{
                    updatedRow['Selected__c'] = false;
                }
                addressList.push(updatedRow);           
            });

            if( this.serialNumberNotPresent && this.caseRecord.Product_Sub_Family_temp__c!=null && this.caseRecord.Product_Sub_Family_temp__c!=undefined && this.caseRecord.Product_Sub_Family_temp__c!='' ){
               console.log('no asset selected');
            }else{
                this.assetData.forEach(asset => {
                    console.log('asset selected',asset['selected']);
                    if(asset['selected']==true){
                        delete asset.children;
                        delete asset.RecordType;
                        assetRecordVar=asset;
                        this.assetId = asset.Id;
                    }
                });
            }

            console.log('selectedAddress',selectedAddress);
            //console.log('shippingAddressList',shippingAddressList);
            jsParameters.contactList=contactList;
            jsParameters.shippingAddressList=addressList;
            jsParameters.caseRecord=this.caseRecord;
            jsParameters.isCommercial=this.isCommercial;
            jsParameters.assetRecord=assetRecordVar;
            
            jsParameters.primaryContact=primaryContact;
            jsParameters.selectedAddress=selectedAddress;
            jsParameters.division = assetRecordVar.Division;
            jsParameters.accountChange = this.accountChange;
            jsParameters.createServiceTicket = this.createServiceTicket;

            createRecords({accountRecord : this.account, caseParameters:JSON.stringify(jsParameters)})
                       .then(result =>{
                        debugger;
                        console.log('result',result); 
                       // var a = result.split(";");
                        if(result.hasError==false){
                            this.caseRecord.Id= result.caseRecord.Id;
                            this.account.Id=result.accountRecord.Id;
                            debugger;

                           
                            /*if(this.ssdUser==true){
                                console.log('ssd');
                                this.showToast('Successfully created the case and service ticket.','success');
                                this.navigateToRecord(result.serviceTicket.Id);
                                this.showSpinner = false;
                            }*/

                            if(this.caseRecord.Type=='Enquiry'){
                                this.showToast('Successfully created the case record.','success');                            
                            }else{
                                console.log('ssd 1');
                                this.showToast('Successfully created the case and service ticket.','success');
                            }

                            this.showSpinner=false;
                            this.disableButton=false; 

                            if(this.assetId!=null && this.assetId!=undefined && this.caseRecord.Type == 'Regular Service'){
                                this.showCPScreen=true;
                                this.showAccountScreen =false;
                            }else{
                                console.log('ssd 2');
                                if(this.ssdUser==true && this.caseRecord.Type!='Enquiry' && this.caseRecord.Type!='Stock Defective' ){
                                    console.log('ssd');
                                    this.showToast('Successfully created the case and service ticket.','success');
                                    this.navigateToRecord(result.serviceTicket.Id);
                                    this.showSpinner = false;
                                }else{
                                    this.navigateToCase();
                                }                               
                            }

                        }else{
                            const regex = /<a\s+(?:[^>]*?\s+)?href=(["'])(.*?)\1[^>]*?>(.*?)<\/a>/i;
                            const matches = (result.errorMessage).match(regex);
                            if(matches!=null){
                                const url = matches ? matches[2] : null;
                                const label = matches ? matches[3] : null;
                                const modifiedErrorMessage = (result.errorMessage).replace(regex, `{0}`);
                                this.showToastWithLink(modifiedErrorMessage, 'Error','sticky', url,label);
                            }else{
                                this.showToast(result.errorMessage, 'Error','sticky');
                            }                           
                            this.showSpinner=false;
                            this.disableButton=false;
                        }                    
                        })
                       .catch(error =>{
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showSpinner=false;
                        this.disableButton=false; 
                        this.showToast(errormsg, 'Error');
            }); 
        }else{

            this.showToast(errorMessage, 'Error');
            this.showSpinner=false;
            this.disableButton=false;
        }
    }

    showToast(message, type, mode) {
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
            mode: (mode==null || mode==undefined )?'dismissable' : mode
        });
        this.dispatchEvent(event);
    }

    showToastWithLink(message, type, mode, url,label) {
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
            mode: (mode==null || mode==undefined )?'dismissable' : mode,
            messageData:[
                {
                    url :url,
                    label : label
                }
            ]
        });
        this.dispatchEvent(event);
    }
   
    setCommercialAccount(event){    
       this.account.Id=event.detail.recordId;
       console.log(this.account.Id);
    }
    setCustomValidation(){
        let dateCmp = this.template.querySelector("lightning-record-picker");
        if(this.account.Id==null){
           
            dateCmp.setCustomValidity("Select an option or remove the entered text.If you don't find a account please click on next to create new account.");
        }else{
            dateCmp.setCustomValidity("");
        }
    }

    //to bind the account values
    assignAccountValues(event){
        debugger;
        let updatedAccount = Object.assign({}, this.account);
        updatedAccount[event.target.fieldName] = event.target.value;
        this.account = updatedAccount;
        this.accountChange=true;
        //this.account[event.target.fieldName] = event.target.value;
    }

    //to bind the case values
    assignCaseValues(event){
        debugger;
        this.caseRecord[event.target.fieldName] = event.target.value;
        if(event.target.fieldName=='Product_Sub_Family_temp__c'){
            this.subfamilySelected=true;
        }
        

        if(event.target.fieldName=='Sub_Type_Source__c' && event.target.value!=null){
            this.Source__c=event.target.value;
        }

        if(event.target.fieldName=='Subject__c'){
            this.caseRecord['Subject'] = event.target.value;
        }
        if(event.target.fieldName=='Type' && event.target.value == 'Enquiry'){
            this.showServiceTicketButton=false;
        }else if (event.target.fieldName=='Type' && event.target.value != 'Enquiry'){
            this.showServiceTicketButton=true;
        }
    }

    setProductOnCase(event){    
        this.caseRecord.ProductId=event.detail.recordId;
        console.log('productId',this.caseRecord.ProductId);
    }

    navigateToObjectHome() {
        // Navigate to the Case home page
        if(this.ssdUser || window.location.href.includes('channelpartnerportal')){
            window.location = `${window.location.origin}/channelpartnerportal/s/createcase`; 
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'home',
                },
            });
        }
       
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

    setChildData(event){
        debugger;
        console.log('called from child to pass data');
        console.log('data', event.detail);
        if(event.detail.objectName=='Contact'){
            this.contactData=event.detail.recordList;
            if(this.sendChargesClicked){
                this.sendChargesEmail();
            }
        }else if(event.detail.objectName=='Address'){
            this.shippingAddress=event.detail.recordList;
        }else if(event.detail.objectName=='Asset'){
            console.log(event.detail.recordList.length);
            console.log('y',event.detail.recordList);
            this.assetData=event.detail.recordList;
            //let assetPin = this.assetData.find(asset => asset.PostalCode === this.selectedPincode);
           /* if(assetPin==null || assetPin==undefined){
                this.assetData = [];
            }*/
        }
    }

    navigateToCase(){
        this.showSpinner=true;
        console.log('Navigate ');
        var result = this.caseRecord.Id;
        window.location = `${window.location.origin}/${result}`;
       /* this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseRecord.Id,
                actionName: 'view'
            }
        });*/
    }

    navigateToRecord(recordId){
        this.showSpinner=true;
        console.log('Navigate ssd ');
       // https://bluestarlimited--dev.sandbox.my.site.com/channelpartnerportal/s/workorder/0WOBi000002PDLtOAO
       //https://bluestarlimited--dev.sandbox.my.site.com/channelpartnerportal/s/
    
        window.location =  `${window.location.origin}/channelpartnerportal/s/detail/${recordId}`;
    }

    tagChannelPartner() {
        console.log('child method tag channel partner', this.recordId);
        this.showSpinner=true;
        this.disableButton = true;
        console.log('child method tag channel partner', this.recordId);
        debugger;
        tagChannelPartner({ recordId: this.caseRecord.Id})
            .then(result => {
                this.showSpinner=false;
                console.log('result channel partner', result);
                if (result == 'success') {
                    
                    if(this.ssdUser==true){
                        this.showToast('Successfully created the case and service ticket.','success');
                        this.navigateToCase();
                        this.showSpinner = false;
                    }else{
                        this.showToast('Successfully created the case and service ticket.','success');
                        if(this.caseRecord.Type=='Regular Service'){
                            this.showCPScreen=true;
                            this.showAccountScreen =false;
                            this.showSpinner = false;
                        }else{
                            this.navigateToCase();
                            this.showSpinner = false;
                        }
                        //this.showCPScreen=true;
                        this.showAccountScreen =false;
                        this.showSpinner = false;
                    }
                   
                   /* if(this.assetId!=null && this.assetId!=undefined && this.caseRecord.Type == 'Regular Service'){
                        this.showCPScreen=true;
                        this.showAccountScreen =false;
                    }else{
                        this.navigateToCase();
                    }*/
                    
                }else{
                    debugger;
                    this.showError=true;
                    this.errorMessage='Case couldn\'t be generated.The error is :  '+result;
                    this.deleteCaseJs(this.errorMessage);                  
                    this.disableButton = false;
                    this.showSpinner = false;
                }
            })
            .catch(error => {
                console.log('error',error);
                var errormsg = (typeof error.body.message === 'string') ? error.body.message : 'Error occured, Please Contact Admin.'
                console.log('Error', error.body.message);
                this.disableButton = false;
                this.showSpinner = false;
                this.deleteCaseJs(errormsg);
                //this.showToast(errormsg, 'Error');
            });
    }

    handleKeyDown(event) {
        if(event.code == 'Escape') {
          this.openModal = false;
          event.preventDefault();
          event.stopImmediatePropagation();
        }
    }

    handleResAccountNameChange (event){
        this.resAccName = event.target.value;
    }

    handlePincodeChange (event){
        this.resPincode = event.target.value;
    }

    handleResAccountSearch(){
        debugger;
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(!allValid){
            return;
        }

        if( (this.resAccName!='' && this.resAccName!=null && this.resAccName!=undefined) && (this.resPincode=='' || this.resPincode==undefined || this.resPincode==null)){
            this.showToast('Pincode is also required with name.','Error');
            return;

        }

        /*if(this.customerPhoneNumber!='' && this.customerPhoneNumber!= null){
            this.getAccountJs();
        }
        if(this.customerEmailAddress!='' && this.customerEmailAddress!= null){
            this.getAccountJs();
        }
        if(this.resAccName!='' && this.resAccName!=null && (this.resPincode=='' || this.resPincode == null)){
            this.showToast('Name and pincode both are required while searching with pincode.','Error',null);
            return;
        }
        if(this.resPincode!='' && this.resPincode!=null && (this.resAccName=='' || this.resAccName == null)){
            this.showToast('Name and pincode both are required while searching with pincode.','Error',null);
            return;
        }*/
        if((this.customerEmailAddress=='' || this.customerEmailAddress==null) && (this.customerPhoneNumber=='' || this.customerPhoneNumber==null) && (this.resAccName=='' || this.resAccName==null) && (this.customerId=='' || this.customerId==null)){
                this.showToast('Please enter any search term to find the account','Error');
                return;
        }else{
            this.getAccountBasedOnPincode();
        }

        /*if(this.resAccName!='' && this.resAccName!=null && this.resPincode!='' && this.resPincode!=null){
            this.getAccountBasedOnPincode();
        }*/
       
        this.showDatatable=false;
    }

    createNewAccountJs() {
        debugger;
        if(this.showEnterDetailsScreen){
            if(this.customerPhoneNumber=='' || this.customerPhoneNumber==null || this.customerPhoneNumber==undefined ){
                this.showToast('Please enter phone number.','Error');
                return;
            }
        }

        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {

            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(!allValid){
            return;
        }

        this.createNewAccountBoolean=true;
        if(this.accountRecordType == 'Commercial_Customer'){
            this.createNew();
        }else{
            this.createNew();
        }
      
    }

    createNew(){

        this.accountChange = true;
        this.account.Email__c = (this.customerEmailAddress != null) ? this.customerEmailAddress : '';
        this.account.Phone = (this.customerPhoneNumber) ? this.customerPhoneNumber : '';
        this.account.Name = (this.resAccName !=null) ? this.resAccName : '';
        this.account.RecordTypeId = this.accountRecordTypeId;
        this.caseRecord.Language_Preference__c = 'Hindi';
        if (this.accountRecordType == 'Commercial_Customer') {
            this.contactData = [];
        } else {
            var contactRecord = {};
            contactRecord['FirstName'] = '-';
            contactRecord['LastName'] = '-';
            contactRecord['Phone'] = this.account.Phone;
            contactRecord['Email'] = this.account.Email__c;
            contactRecord['OtherPhone'] = null;
            contactRecord['Role__c'] = '';
            contactRecord['selected'] = true;
            contactRecord['NoContact'] = true;
            contactRecord['SRNo'] = 1;
            this.contactData = [...this.contactData, contactRecord];
        }
        this.shippingAddress = [];
        this.showAccountScreen = true;
        this.showEnterDetailsScreen = false;
        this.showCommCustomerScreen = false;
        this.accountFoundMessage = 'Create a new account by filling the following details.';
    }

    getAccountBasedOnPincode(){
        this.showSpinner=true;
        getAccountBasedOnNameAndPincode({name:this.resAccName, pincode:this.resPincode, email : this.customerEmailAddress, phone : this.customerPhoneNumber,ssduser : this.ssdUser,customerId : this.customerId})
                       .then(result =>{
                        console.log('result',result);
                    
                        debugger;
                        var returnRecord = [];

                        if(result!=null && result.length>0){
                            if(this.ssdUser){
                                result.forEach(resultVar => {
                                    console.log('resultVar.OwnerId',resultVar.OwnerId);
                                    console.log('this.ssduserId',this.ssduserId);
                                    if(resultVar.OwnerId == this.ssduserId){
                                        console.log('resultVar',resultVar);
                                        returnRecord.push(resultVar);
                                    }else{
                                        if(resultVar.Assets!=null && resultVar.Assets.length>0){
                                            console.log('asset present');
                                            var assetPresent=false;
                                            resultVar.Assets.forEach(record => {
                                                if(record.CP__c!=null && record.CP__c!=undefined && record.CP__r.CP_User__c==this.ssduserId){
                                                    assetPresent=true;
                                                }
                                            });

                                           // var assetsServedByCP = (resultVar.Assets).filter(record => ((record.CP__c!=null && record.CP__r.Cp_User__c==this.ssduserId)));
                                           // console.log('assetsServedByCP',assetsServedByCP);
                                            if(assetPresent){
                                                returnRecord.push(resultVar);
                                            }                     
                                        }
                                    }
                                });
                            }else{
                                returnRecord = result;
                            }
                        }


                        if(returnRecord!=null && returnRecord.length>0){
                            this.accountdata = returnRecord.map(account => ({
                                ...account,
                                ShippingStreet: account.ShippingStreet + ', ' + account.ShippingCity + ', ' + account.ShippingState+', '+account.ShippingPostalCode // Format address
                            }));
                            this.showDatatable=true;
                        }

                        else if(result.length==0){
                            console.log('here');
                            this.showToast('No customer account found. Please try with other combinations or create new account.','Error',null);
                            console.log('here 1');
                            this.showNewaccountButton=true;
                            console.log('here 2');
                            this.showDatatable=false;
                            console.log('here');
                        }
                        this.showSpinner=false;
                        })
                       .catch(error =>{
                        this.showSpinner=false;
                        console.log('error',error);
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
           });   
    } 
    checkSSDUserMethod(){
        checkSSDUser()
                       .then(result =>{
                        console.log('result',result);
                        this.ssdUser = result;
                        })
                       .catch(error =>{
                        this.showSpinner=false;
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
           });   
    }    
    handleRowSelection (event) {
        var selectedRows=event.detail.selectedRows;
        console.log('selectedId = selectedRows[0].Id;',selectedRows);
        if(selectedRows.length>0){
            this.recordId = selectedRows[0].Id;
            this.showNext = true;
        }
        
        if(selectedRows.length>1)
        {
            var el = this.template.querySelector('lightning-datatable');
            selectedRows=el.selectedRows=el.selectedRows.slice(1);
            event.preventDefault();
            return;
        }
        if(selectedRows.length==0){
            this.showNext = false;
        }

        this.handleNextAccount();
    }
    handleNextAccount(){
        this.account.Id = this.recordId;
        this.showRecordTypeScreen = false;
        this.handleCommAccount();
    }
    getIssueTypesMethod(){
        getIssueTypes({objectName:'Case', fieldName:'Issue_Type__c'})
                       .then(result =>{
                        console.log('result',result);
                        result.forEach(resultVar => {
                            this.issueTypes.push({label:resultVar, value:resultVar});
                        });
                        //this.issueTypes = result;
                        })
                       .catch(error =>{
                        this.showSpinner=false;
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
           });   
    }
    handleSubjectChange(event){
        this.caseRecord['Subject'] = event.target.value;
    } 

    fetchPrice(){
        debugger;
        var familyCode;
        var subFamilyCode;

        if(this.existingAsset || this.serialNumberPresent){
            this.template.querySelector(".assetChild").getChildData();
        }
        debugger;
        if( this.serialNumberNotPresent && this.caseRecord.Product_Sub_Family_temp__c!=null && this.caseRecord.Product_Sub_Family_temp__c!=undefined && this.caseRecord.Product_Sub_Family_temp__c!='' ){
            console.log('no asset selected');
            getProductSubFamily({ recordId: this.caseRecord.Product_Sub_Family_temp__c })
                .then(result => {
                    debugger;
                    familyCode = (result.Parent_Product_Family__c!=null) ? result.Parent_Product_Family__r.Code__c : ';'
                    subFamilyCode = result.Code__c;
                    this.assetUnderWarranty = false;
                    this.fetchRateCard(familyCode,subFamilyCode);
                })
                .catch(error => {
                    console.error('Error fetching product family: ', error);
                });
         }else{
             this.assetData.forEach(asset => {
                 console.log('asset selected',asset['selected']);
                 if(asset['selected']==true){
                    familyCode = asset['ProductFamilyCode'];
                    subFamilyCode = asset['ProductSubFamilyCode'];
                    this.assetUnderWarranty = (asset['Asset_Obligation__c']).includes("NIC")? false : true;
                 }
             });
             this.fetchRateCard(familyCode,subFamilyCode);
        }

       

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
                this.showPrice=true;
            }else{
                this.showPrice=false;
                this.showToast('Unable to retrieve rates ','Error');
            }        
            //this.hasRateMatrix = this.rateMatrixesWithSelection.length > 0;
        })
        .catch(error => {
            console.error('Error fetching product family: ', error);
        });
       
    }

    deleteCaseJs(displayError){
        debugger;
        deleteCase({ recordId: this.caseRecord.Id })
        .then(result => {
            if(result=='success'){
                this.caseRecord.Id = null;
                if(this.ssdUser==true){
                    this.navigateToCase();
                }
                this.showSpinner = false;
                this.showToast(displayError, 'Error', 'Sticky');
                this.showSpinner = false;

            }else{
                this.showToast(result,'Error');
            }
        })
        .catch(error => {
            this.showSpinner = false;
            console.error('Some error has occured. Please contact admin. ', error);
        });   
    }

    sendCharges() {
        console.log('here');
    
        // Ensure getChildData() runs synchronously
        if (this.template.querySelector(".contactChild") != null) {
            this.sendChargesClicked = true;
            this.showSpinner = true;
            this.template.querySelector(".contactChild").getChildData(); // Assuming getChildData returns a Promise
        }
    
        
    }

    sendChargesEmail(){
        this.sendChargesClicked = false;
        this.showSpinner = false;
        console.log('contact length', this.contactData.length);
        let count = 0;
        this.contactData.forEach(contact => {
            count++;
            console.log('contact', contact);
            console.log('contact selected', contact.selected);
    
            if (contact.selected === true) {
                this.emailAddress = contact.Email;
                this.showCharges = true;
                if(this.emailAddress!=null && this.emailAddress!='' && this.emailAddress!=undefined){
                    console.log('contact selected', contact.selected);
                    this.template.querySelector(".sendCharge").emailAddress = this.emailAddress;
                    console.log('contact selected', contact.selected);
                    this.template.querySelector(".sendCharge").sendEmail();
                    console.log('contact selected', contact.selected);
                }             
            }
    
            if (count === this.contactData.length) {
                console.log('contact selected here');
                if (!this.emailAddress) {
                    this.showToast('Please enter a valid email address', 'Error');
                }
            }
        });
    
        if (this.contactData.length === 0) {
            console.log('contact selected here no email');
            if (!this.emailAddress) {
                this.showToast('Please enter a valid email address', 'Error');
            }
        }
       
    }
    

    loadProductFamily() {
        fetchProductFamily()
            .then(result => {
                console.log('product fa',result);
                const productSet = new Set(result); // Using Set to store unique product codes
                this.productOptions = Array.from(productSet).map(productCode => {
                    return { label: productCode.Name, value: productCode.Id };
                });
                console.log('this product',this.productOptions);
               
            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }

    loadProducts() {
        console.log(' this.caseRecord.Product_Sub_Family_temp__c', this.caseRecord.Product_Sub_Family_temp__c);
        fetchProducts({subFamilyId : this.caseRecord.Product_Sub_Family_temp__c})
            .then(result => {
                console.log('product fa',result);
                const productSet = new Set(result); // Using Set to store unique product codes
                this.products = Array.from(productSet).map(productCode => {
                    return { label: productCode.Name, value: productCode.Id };
                });
                console.log('this product',this.products);
                this.subfamilySelected=true;
                console.log('product',this.template.querySelector(".product"));
                if(this.template.querySelector(".product")!=null){
                    this.template.querySelector(".product").productOptionsParent = this.products;
                    this.template.querySelector(".product").setproductOption();
                }              
            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }

    getProductSubFamily(event){
        this.caseRecord.Product_Sub_Family_temp__c = event.detail;
       
        this.loadProducts();

        if(this.template.querySelector(".assetChild")!=null){
            this.template.querySelector(".assetChild").removeRadio();
        }
    }

    getProduct(event){
        this.caseRecord.ProductId = event.detail;
        //this.subfamilySelected=true;
        //this.loadProducts();
    }

    updateAsset(event){
        this.selectedPincode = event.detail;
        console.log('this.selectedPincode update asset',this.selectedPincode);
        if(this.template.querySelector(".assetChild")!=null){
            this.template.querySelector(".assetChild").selectedPincode= this.selectedPincode;
            this.template.querySelector(".assetChild").updateAssetsOnPincodeCange();
        }
       
    }

    handleBranchChange(event){
        this.branch = event.target.value;
    }

    handlesolIDChange(event){
        this.solId = event.target.value;
    }

    handleaccNameChange(event){
        console.log('name',this.accName);
        this.accName = event.target.value;
        console.log('name',this.accName);
    }


    getCommercialAccount(){
        this.showSpinner=true;
        console.log('here',((this.pincode!=null) && (this.accName==null || this.accName=='' ) &&  (this.branch==null || this.branch == '') && (this.solId==null || this.solId=='')));

        debugger;
        if((this.resPincode!=null && this.resPincode!='') && (this.accName==null || this.accName=='' ) &&  (this.branch==null || this.branch == '') && (this.solId==null || this.solId=='') ){
            this.showSpinner=false;;
            console.log('here');
            this.showToast('Please enter account name, branch or sol Id with pincode.','Error');
            return;
        }
        getCommercialAccountSearch({name:this.accName, pincode:this.resPincode, branch: this.branch, solId : this.solId, contactName:this.commContactName, email : this.commEmail,ssduser : this.ssdUser, customerId : this.customerId})
                       .then(result =>{
                        console.log('result',result);
                    
                       debugger;
                       var returnRecord = [];

                        if(result!=null && result.length>0){
                            if(this.ssdUser){

                                result.forEach(resultVar => {
                                    console.log('resultVar',resultVar.OwnerId);
                                    console.log('this.ssduserId',this.ssduserId);
                                    if(resultVar.OwnerId == this.ssduserId){
                                        console.log('resultVar',resultVar);
                                        returnRecord.push(resultVar);
                                    }else{
                                        if(resultVar.Assets!=null && resultVar.Assets.length>0){
                                            var assetPresent=false;
                                            resultVar.Assets.forEach(record => {
                                                //console.log('record.CP__r.Cp_User__c',record.CP__r.Cp_User__c);
                                                if(record.CP__c!=null && record.CP__c!=undefined && record.CP__r.CP_User__c==this.ssduserId){
                                                    assetPresent=true;
                                                }
                                            });

                                           // var assetsServedByCP = (resultVar.Assets).filter(record => ((record.CP__c!=null && record.CP__r.Cp_User__c==this.ssduserId)));
                                           // console.log('assetsServedByCP',assetsServedByCP);
                                            if(assetPresent==true){
                                                returnRecord.push(resultVar);
                                            }                      
                                        }
                                    }
                                });
                            }else{
                                returnRecord = result;
                            }
                        }

                        if(returnRecord!=null && returnRecord.length>0){

                            if(this.isNamo){

                           this.accountColumns = [
                                    { label: 'Account Name', fieldName: 'Name', type: 'text',initialWidth:200, wrapText: true },
                                    { label: 'Active', fieldName: 'Is_Active__c', type: 'boolean',initialWidth: 160},
                                    { label: 'Pincode', fieldName: 'ShippingPostalCode', type: 'text', initialWidth: 160},
                                    { label: 'Branch', fieldName: 'Namo_Branch__c', type: 'text',initialWidth:200 },
                                    { label: 'SOL ID', fieldName: 'SOL_Store_ID__c', type: 'text',initialWidth:200 },
                                    { label: 'Address', fieldName: 'ShippingStreet', type: 'text',wrapText: true,initialWidth:300 },
                                    { label: 'Locality', fieldName: 'Shipping_Locality__c', type: 'text',wrapText: true,initialWidth: 160},
                                    { label: 'Sub Locality', fieldName: 'Shipping_Sublocality__c', type: 'text',wrapText: true,initialWidth: 160},
                                    { label: 'Sector', fieldName: 'Shipping_Sector__c', type: 'text',initialWidth: 160}
                                   
                                ];
                            }

                            this.accountdata = returnRecord.map(account => ({
                                ...account,
                                ShippingStreet: ((account.ShippingStreet != null) ? (account.ShippingStreet + ', ') : '') + 
                                ((account.ShippingCity != null) ? (account.ShippingCity + ', ') : '') + 
                                ((account.ShippingState != null) ? (account.ShippingState + ', ') : '')
                            }));
                            this.showDatatable=true;
                        }
                        else if(result.length==0){
                            console.log('here');
                            this.showToast('No customer account found. Please try with other combinations or create new account.','Error',null);
                            console.log('here 1');
                            this.showNewaccountButton=true;
                            console.log('here 2');
                            this.showDatatable=false;
                            console.log('here');
                        }
                        this.showSpinner=false;
                        })
                       .catch(error =>{
                        this.showSpinner=false;
                        console.log('error',error);
                        var errormsg = (typeof error.body.message === 'string')? error.body.message : 'Error occured, Please Contact Admin.'
                        console.log('Error', error.body.message);
                        this.showToast(errormsg, 'Error');
           });   
    } 
    handlecontactNameChange(event){
        this.commContactName = event.target.value;
    }
    handleCommEmailChange(event){
        this.commEmail = event.target.value;
    }
    handleCustomerIdChange(event){
        this.customerId = event.target.value;
    }

    
}