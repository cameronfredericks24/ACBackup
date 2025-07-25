import { LightningElement , track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getListOfProductLineItems from '@salesforce/apex/CreateGRNController.getListOfProductLineItems';
import { NavigationMixin } from 'lightning/navigation';
import createGRN from '@salesforce/apex/CreateGRNController.createGRN';
    

export default class GRNReceived extends LightningElement {
    
    @api recordId;

    disabledInput = true;
    @track data = [];
    @api generateError = false;
    @track records = [];
    
    @track sampleData = [];
    @api isLoading = false;
    @api isModalOpen = false;
    @track productName = '';
    @track showImageUpload = false;
    @track noSAP =false;

    errorMessage = '';
    showErrorMessage = false;
    showChallanReceiveForm = false;
    grnCreated =false;
    challan;
    isValidChallan;
    isMR = false;
    @track status ='';
    @track otherStatus = false;

    @track notApplicable = false;
    @track noMR = false;
    isMobileDevice = false;

     flowApiName = "Defective_RMR_Image_upload";
    checkMobileDevice() {
        const userAgent = navigator.userAgent;
        const mobileDeviceRegex = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
        return mobileDeviceRegex.test(userAgent);
    }

    //to check if it is on mobile-----------------------------------------------

    connectedCallback() {
        this.isMobileDevice = this.checkMobileDevice();

        console.log(this.isMobileDevice);

        this.isLoading = true;
       // loadStyle(this, modal);
        console.log('this.recordId c',this.recordId);
    setTimeout(() => {
       
        console.log('this.recordId f',this.recordId);
        this.loadProductTransfers();
    }, 5);
        

    }

    loadProductTransfers(){
        console.log('recordId' ,this.recordId);
         getListOfProductLineItems({ Id: this.recordId })
         .then(result => {
           
            let itemNeeded =false;
              

                console.log('result'+result);
                console.log('result :', JSON.stringify(result));
                const res =result;
                console.log('Data '+ res.GRNNeeded);
                if(res.GRNNeeded == true){
                    itemNeeded =true;
                } 
                console.log('Data '+ itemNeeded);
              if(itemNeeded ==true){
                if(res.recType != 'MR'){
                    this.data = res.productItemsList.map(item => ({
                
                   
                        id: item.Id,
                        name: item.Product2.Name,
                        prod:item.Product2Id,
                        //status: item.Status,
                        quantityRequested :item.Quantity_Remaining__c,
                        quantitySent: item.Qty_Sent__c,
                        quantityRecieved:  0,
                        quantityDamaged: 0,
                        quantityMismatched: 0,
                        type:'SO/MSL',
                       
                       
                        //quantityMissing:  0,
                        //SourceLocationId: item.SourceLocationId,
                        //DestinationLocationId: item.DestinationLocationId
                    }));
                }else{
                      this.isMR=true;
                    //const productReqRMRItems = Array.isArray(res.productReqRMRItem) ? res.productReqRMRItem : [res.productReqRMRItem];
                    this.data =res.productReqRMRItem.map(item=>({
                        id:item.Id,
                        name: item.Product__r.Name,
                        prod:item.Product__c,
                        code:item.Material_Code__c,
                        quantityRequested :item.Quantity__c,
                        quantityRecieved:  0,
                        quantityDamaged: 0,
                        quantityMismatched: 0,
                        type:'MR',
                        error:false
                        
                        //quantityMissing:  0
                    }))
                    console.log('this.data '+ this.data);
                }
                
                
              }else{
                    console.log('this.noSAP'+ this.noSAP);

                if(result.GRNStatus == 'Received'){
                   this.grnCreated = true;
                }
                else if(result.GRNStatus =='Customer'){
                     this.notApplicable= true;
                }
                else if(result.GRNStatus =='noMR'){
                     this.noMR= true;
                }
               
                else if(result.GRNStatus == 'Draft' || result.GRNStatus=='Rejected'){
                    this.otherStatus= true;
                }
            console.log(' this.noSAP'+ this.noSAP);
              }
            console.log(' this.noSAP'+ this.noSAP);    
             
            
         })
            
         }


         handleQuantityRecievedChange(event) {
            const { id } = event.target.dataset;
            console.log('****event.target.dataset' + JSON.stringify(event.target.dataset));
            const updatedData = this.data.map((item) => {
                if (item.id === id) {
                    return { ...item, quantityRecieved: parseFloat(event.target.value) };
                }
                return item;
            });
            console.log('****updatedData' + JSON.stringify(updatedData));
            this.data = updatedData;
        }
        handleQuantityMismatchedChange(event) {
            const { id } = event.target.dataset;
            const updatedData = this.data.map((item) => {
                if (item.id === id) {
                    return { ...item, quantityMismatched: parseFloat(event.target.value) };
                }
                return item;
            });
            this.data = updatedData;
        }
        handleQuantityDamagedChange(event) {
            const { id } = event.target.dataset;
            const updatedData = this.data.map((item) => {
                if (item.id === id) {
                    return { ...item, quantityDamaged: parseFloat(event.target.value) };
                }
                return item;
            });
            this.data = updatedData;
        }
        handleQuantityMissingChange(event) {
            const { id } = event.target.dataset;
            const updatedData = this.data.map((item) => {
                if (item.id === id) {
                    return { ...item, quantityMissing: parseFloat(event.target.value) };
                }
                return item;
            });
            this.data = updatedData;
        }
    
        handleSubmit(event) {

            this.isLoading = true;
            this.generateError = false;
            console.log('****generateError' + this.generateError);
            console.log('****data' + JSON.stringify(this.data));
            let hasError = false;
            console.log('isMR '+ this.isMR);
            
            this.data.forEach(input => {
                
                console.log('****input' + JSON.stringify(input));
                if (parseInt(input.quantityRecieved) < 0 || parseInt(input.quantityMismatched) < 0 || parseInt(input.quantityDamaged) < 0 ) {
                    console.log('Inside check');
                     

                    this.generateError = true;
                    hasError = true;
                }
                const sumOfProducts = parseInt(input.quantityRecieved) + parseInt(input.quantityMismatched) + parseInt(input.quantityDamaged) ;
                /*if(input.quantitySent == (parseInt(input.quantityRecieved) + parseInt(input.quantityMismatched) +parseInt(input.quantityDamaged) +parseInt(input.quantityMissing) )){
                    this.generateError = false;
                    console.log('****sumoOfProd>>'+input.name+' :'+sumOfProducts);
                }else{
                    this.generateError = true;
                    this.productName = input.name;
                    hasError = true;
                    console.log('****sumoOfProd>>'+this.productName+' :'+sumOfProducts);
                    console.log('****productName>>'+this.productName);
                    return;
    
                    //break;
                }*/
                console.log('input.quantitySent '+ parseInt(input.quantitySent));
                console.log('input.quantityreq '+ parseInt(input.quantityRequested));

                let qtySent = parseInt(input.quantityRequested);
                console.log('qtySent '+ qtySent);
               /* if(!this.isMR){
                    qtySent = parseInt(input.quantitySent);
                }*/
               
                if (qtySent < sumOfProducts) {
                     
                    this.generateError = true;
                    this.productName = input.name;
                    hasError = true;
                    console.log('****sumoOfProd>>' + this.productName + ' :' + sumOfProducts);
                    console.log('****productName>>' + this.productName);
                    return;
                }
               
    
            })
    
            console.log('****generateError' + this.generateError);
    
            if (!hasError) {
                this.generateError = false;

            }
            if (this.generateError == false) {
                console.log('****inside update');
                const inputJson = JSON.stringify(this.data);
                console.log('this.record '+ this.recordId );
                createGRN({ prId:this.recordId , inputData: this.data })
                .then(result => {
                    console.log('****result**' + result);
                    //result = JSON.stringify(result);
                    console.log('****result99' + JSON.stringify(result));
                    console.log('type',typeof(result.mrGrn));
                    this.isLoading = false;
                    
                    if (result.mrGrn === false && result.grnId != null) {
                        
                        window.location ='/channelpartnerportal/s/detail/'+result.grnId;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'GRN is Created Successfully',
                                variant: 'success',
                            }),
                        );

                      


                    }
                    else if(result.defExist == true){
                        //window.location ='/channelpartnerportal/s/detail/'+this.recordId;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Defective Item created successfully please proceed with part claim tag',
                                variant: 'success',
                            }),
                        );
                       
                          this.showImageUpload = true;
                        
                        

                       // window.location ='/channelpartnerportal/s/detail/'+this.recordId;
                    } else if(result.mrGrn === true  && result.grnId != null &&  result.defExist == false){
                         window.location ='/channelpartnerportal/s/detail/'+result.grnId;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'GRN is Created Successfully',
                                variant: 'success',
                            }),
                        );
                    }
                    else {
                          window.location ='/channelpartnerportal/s/detail/'+this.recordId;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'An internal error has occurred. please contact your administrator.',
                                variant: 'error',
                            }),
                        );
                    }

                })
                .catch(err => {
                    console.log({ err });
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An internal error has occurred. please contact your administrator. Error :- ' + err,
                            variant: 'error',
                        }),
                    );
                });
               
            } else {
    
                this.isLoading = false;
    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please check the Quantity entered for ' + this.productName,
                        variant: 'error',
                    }),
                );
            }
    
        }
        get flowInputVariable() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

     handleFlowStatusChange(event) {
        const status = event.detail.status;
        console.log('Flow status:', status);
        
        if (status === 'FINISHED') {
            this.showImageUpload = false; // Hide the flow
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Flow completed successfully.',
                    variant: 'success'
                })
            );
            
           window.location ='/channelpartnerportal/s/detail/'+this.recordId;
        } 
    }
    
    }