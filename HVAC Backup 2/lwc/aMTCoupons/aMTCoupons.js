import { LightningElement, api,  wire,track } from 'lwc';
import checkOpportunity from '@salesforce/apex/AMTCouponControllerClass.checkOpportunity';
import checkNewOpportunity from '@salesforce/apex/AMTCouponControllerClass.checkNewOpportunity';
import updateQuoteStatus from '@salesforce/apex/AMTCouponControllerClass.updateQuoteStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateIsOfflineField from '@salesforce/apex/AMTCouponControllerClass.updateIsOfflineField';
import savePODetails from '@salesforce/apex/AMTCouponControllerClass.savePODetails';
import rejectOpp from '@salesforce/apex/AMTCouponControllerClass.rejectOpp';
import tagFilesToAsset from '@salesforce/apex/AMTCouponControllerClass.tagFilesToAsset';

export default class YourComponent extends LightningElement {
    @api recordId; // ID of the service ticket (provided by Quick Action)
    @track isOnlineDisabled =false;
    @track isOfflineDisabled = false;
    @track isDisabled = false;
    @api uploadedFiles;

    isOpportunityExist = false; // Boolean flag to handle message display
    @track showSuccess = false;
    @track showPODetails = false;
    @track showRejectDetails = false;
    @track showPicklist = false;
    @track picklistValue; 
    @track disabledSave = false;
    @track savePO = false;
    @track showupload =false;

    @track poNumber = '';
    @track poTotalValue = '';
    @track poStartDate = '';
    @track poEndDate = '';
    @track poDate='';
    @track poReceiptDate='';
    @track showAccRej =false;
    @track showSMS = false;
    @track showRejectMsg= false;
    @track oppLost = false;
    @track hideRejectInput = false;
    isFileUploaded
    @track saveFile= false;

    
    
    @track oppId ;

    
    connectedCallback() {
        // Call the Apex method to check if an opportunity exists for the asset
        this.checkOpportunityForAsset();
    }

    // Define picklist options
    
    
    get picklistOptions() {
        return [
            { label: 'Technical', value: 'Technical' },
            { label: 'Brand Preference', value: 'Brand Preference' },
            { label: 'TurnKey', value: 'TurnKey' },
            { label: 'Product Quality', value: 'Product Quality' },
            { label: 'Delivery Schedule', value: 'Delivery Schedule' },
            { label: 'Taken By CAD', value: 'Taken By CAD' },
            { label: 'Customer Relationship', value: 'Customer Relationship' },
            { label: 'Future Potential', value: 'Future Potential' },
            { label: 'Lost to OEM', value: 'Lost to OEM' },
            { label: 'Lost to Local Party', value: 'Lost to Local Party' },
            { label: 'Extended WTY Given by Dealer (DLR)', value: 'Extended WTY Given by Dealer (DLR)' },
            { label: 'Extended WTY Given by CAD', value: 'Extended WTY Given by CAD' }
        ];
    }

    get lostToOptions() {
        return [
            { label: 'Lost to OEM', value: 'Lost to OEM' },
            { label: 'Lost to Local Party', value: 'Lost to Local Party' }
        ];
    }
    

    checkOpportunityForAsset() {
        checkOpportunity({ serviceTicketId: this.recordId })
            .then(result => {
                console.log('result1' +result);
                if(result!=null){
                  this.isOpportunityExist = true;
                }
                
                //this.oppId = result;

            })
            .catch(error => {

                this.showNotification('Error', error.body.message, 'error');
            });
    }

    handleOnline() {
       //this.isOlineDisabled = true;
       console.log('online');
       this.isOfflineDisabled  = true;
       updateIsOfflineField({ serviceTicketId: this.recordId, type:'online' })
            .then(() => {
                
                this.showSuccess = true;
                this.showSMS = true;
                //this.showNotification('Success', 'Service ticket marked as Offline', 'success');
            })
            .catch(error => {
                this.showNotification('Error', error.body.message, 'error');
            });

       
       
    }



    handleOffline() {
        
        this.isOfflineDisabled = true;
        //this.showNotification('Success', 'You clicked Offline!', 'success');
        updateIsOfflineField({ serviceTicketId: this.recordId,type:'offline' })
            .then(() => {
                
                this.showSuccess = true;
                this.showAccRej = true;
                //this.showNotification('Success', 'Service ticket marked as Offline', 'success');
            })
            .catch(error => {
                this.showNotification('Error', error.body.message, 'error');
            });
    }

    checkNewOpportunityForAsset(status) {
        checkNewOpportunity({ serviceTicketId: this.recordId })
            .then(result => {
                console.log('result2' +result);
                console.log('status',status);
                if(result!=null){
                 
                this.oppId = result;
                if(status =='Accepted'){
                    console.log('status2',status);
                    this.updateQuoteAcceptedStatus('Accepted');
                }else{
                    console.log('status3',status);
                    this.updateQuoteRejectStatus('Rejected');
                }
                //this.updateQuoteAcceptedStatus();
                //this.showPODetails = true;
                }
                console.log('this.oppId',this.oppId);
               console.log('this.showPOdetails',this.showPODetails);

            })
            .catch(error => {

                this.showNotification('Error', error.body.message, 'error');
            });
    }
    
    handleBack(){
        this.showPODetails = false;
        this.isDisabled= false;
        this.showAccRej=true;
        this.showSuccess= true;
    }


 handleFileUploaded() {
        // Handle general file upload
        console.log('File uploaded');
        const fileUploaded = new CustomEvent('fileuploaded', {});
        this.dispatchEvent(fileUploaded);


    }
    updateQuoteAcceptedStatus(sts) {
        console.log('sts',sts);
        updateQuoteStatus({ oppId: this.oppId, status :sts})
            .then(result => {
                console.log('result3' +result);
                if(result == true){
                 
               
                 this.showPODetails = true;
                 this.showAccRej = false;
                }
                console.log('this.oppId',this.oppId);
               console.log('this.showPOdetails',this.showPODetails);

            })
            .catch(error => {

                this.showNotification('Error', error.body.message, 'error');
            });
    }

handleFileUpload(event) {
     // Alert for initial upload message
    const uploadedFiles = event.detail.files;
    if (uploadedFiles && uploadedFiles.length > 0) {
        
        const docIds = [];
        uploadedFiles.forEach(file => {
            
            docIds.push(file.documentId);
            
        });
         
        this.tagFilesToLogicalUnit(docIds);
    } else {
       
    }
}

// Method to call Apex to tag files
tagFilesToLogicalUnit(docIds) {
  
    tagFilesToAsset({
        documentIds: docIds,
        oppId: this.oppId
    })
    .then(() => {
      
        this.saveFile = true;
        
        
    })
    .catch((error) => {
        
         this.showNotification('Error', 'Error tagging files to asset:', 'error');
    });
}

   
    
    handleReject(){
        
        console.log('this.showRejectDetails');
        console.log('this.showRejectDetails',this.showRejectDetails);
        this.checkNewOpportunityForAsset('Rejected');
        //this.updateQuoteRejectStatus();
        //this.showRejectDetails= true;
        console.log('this.showRejectDetails',this.showRejectDetails);
        this.isDisabled = true;
        //this.showAccRej = false;
    }

    handleAccept(){
        this.isDisabled = true;
        

        console.log('this.showRejectDetails');



        this.checkNewOpportunityForAsset('Accepted');
        console.log('this.showPOdetails');
       
        
    }
    handleInputChange(event) {
        const field = event.target.dataset.id;
        const value = event.target.value;

        switch (field) {
            case 'poNumber':
            this.poNumber = value;
            break;
            case 'poTotalValue':
            this.poTotalValue = value;
            break;
        case 'poStartDate':
            this.poStartDate = value;
            break;
        case 'poEndDate':
            this.poEndDate = value;
            break;
        case 'poDate':
            this.poDate = value;
            break;
        case 'poReceiptDate':
            this.poReceiptDate = value;
            break;
        case 'documentRequired':
            this.documentRequired = event.detail.value; // This should capture the selected options from the checkbox group
            break;
        default:
            break;
    }
}


    handleSave() {
       this.disabledSave = true;
         console.log('this.poNumber',this.poNumber);
         console.log('this.poTotalValue',this.poTotalValue);
         console.log('this.poStartDate',this.poStartDate);
         console.log('this.poNumber',this.poEndDate );
         console.log('this.poNumber',this.oppId);
         this.updateOpp();

         
      
    }



updateOpp() {
        savePODetails({ oppId: this.oppId, poValue: this.poTotalValue, poNumber:this.poNumber ,poStartDate:this.poStartDate ,poEndDate:this.poEndDate ,poDate:this.poDate,poReceiptDate:this.poReceiptDate})
            .then(result => {
                console.log('result3' +result);
                if(result == true){
                 this.showNotification('Success', 'PO details updated successfully!', 'success');
                 this.savePO = true;
                
                }
                console.log('this.oppId',this.oppId);
               console.log('this.showPOdetails',this.showPODetails);

            })
            .catch(error => {

                this.showNotification('Error', error.body.message, 'error');
            });
    }

   handlePicklistChange(event) {
        this.picklistValue = event.detail.value;
    }

    handleLostToChange(event) {
        this.lostToValue = event.detail.value;
    }

    
   

    handleLostToChange(event) {
        this.lostToValue = event.detail.value;
    }

    handleRejectSave() {
        
        this.handleRejectSaveOpp();
        
    }

    handleRejectSaveOpp() {

        //this.checkNewOppForAsset();
        rejectOpp({ oppId: this.oppId,lostReason :this.picklistValue, lostToValue :this.lostToValue})
            .then(result => {
                console.log('result3' +result);
                if(result == true){
                 
               
                this.disabledSave= true;
                this.oppLost= true;
                this.showRejectMsg = false;
                this.hideRejectInput = false;
                }
                console.log('this.oppId',this.oppId);
               console.log('this.showPOdetails',this.showPODetails);

            })
            .catch(error => {

                this.showNotification('Error', error.body.message, 'error');
            });
    }

    updateQuoteRejectStatus() {
        updateQuoteStatus({ oppId: this.oppId ,status :'Rejected'})
            .then(result => {
                console.log('result3' +result);
                if(result == true){
                 
                this.showAccRej = false;
                this.showRejectMsg= true;
                this.showRejectDetails = true;
                this.hideRejectInput = true;
                }
                console.log('this.oppId',this.oppId);
               console.log('this.showPOdetails',this.showPODetails);

            })
            .catch(error => {

                this.showNotification('Error', error.body.message, 'error');
            });
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(evt);
    }
}