import { LightningElement, api, wire , track} from 'lwc';

import saveProductLines from '@salesforce/apex/PlaceOrderComponentController.saveProductLines'
import saveMSLProductLines from '@salesforce/apex/PaginationController.saveMSLProductLines'
import getSDEUsers from'@salesforce/apex/PlaceOrderComponentController.getSDEUsers'

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
export default class ViewOrderSummary extends LightningElement {
    @api recId;
    @api recType;
    @api totalPrice; 
    @api combinedProducts = [];
    productIdDetails = {};
    pReq={};
    @track showSDE= false;
    
    productLineIds;
    loading =false;
    callParent=false;
    @track currentPageReference; 
    
    @track totalTax;
    @track totalAmount;
    @track ishandMSLBack=false ;
    @track isSubmitDisabled = false;
    @track isMSLSubmitDis = false;
    
    @api isIGSTChecked ; 

    @track branchId;
    @track sdeUserOptions = [];
    @track isFormVisible = true;
     @track isOrderSummaryVisible = false;
     @track isNextDisable= false;
     @track showErrorMessage = false;
    
    

    get loading(){
        return this.loading == true;
    }
    // Define columns dynamically
    get columns() {
        return [
            { label: 'Part Name', fieldName: 'itemName', type: 'text' },
            { label: 'Part Code', fieldName: 'itemCode', type: 'text' },
            { label: 'Quantity', fieldName: 'quantity', type: 'number' ,
            cellAttributes: {
                class: 'slds-align_absolute-center' // Center the button within the cell
            }},
            {
                label:'Price',fieldName:'itemPrice'
            },
            {
                label:'Tax',fieldName:'itemTax'
            }
            
        ];
    }
connectedCallback() {
        this.loading = true;
        console.log('this.recTyp',  this.recType);
        
        
        
        if(this.recType === 'MSL'){



            //this.handleMSLCalculations();
         }
         else{

        console.log('combinedProducts ' + JSON.stringify(this.combinedProducts));
          this.productIdDetails = JSON.stringify(this.combinedProducts);
              // Calculate total price and tax per line item
         this.totalPrice = this.combinedProducts.reduce((acc, item) => acc + parseFloat(item.itemPrice), 0);
         console.log('this.totalPrice:', this.totalPrice);
         this.totalPrice = parseFloat(this.totalPrice).toFixed(2);

           let totalTax = 0; // Initialize totalTax

                  this.combinedProducts = this.combinedProducts.map(item => {
    const itemPrice = parseFloat(item.itemPrice) || 0;
    const itemCGST = item.itemCGST || 0;
    const itemSGST = item.itemSGST || 0;
    const itemIGST = item.itemIGST || 0;

    let itemTax;

    // Calculate tax for each item based on isIGSTChecked
    if (this.isIGSTChecked) {
        itemTax = (itemIGST / 100) * itemPrice;
    } else {
        itemTax = ((itemCGST + itemSGST) / 100) * itemPrice;
    }
    console.log('itemTax', itemTax);
    
    //item.itemTax = parseFloat(itemTax.toFixed(2)); // Save individual item tax rounded to 2 decimals
    totalTax += itemTax; // Accumulate total tax
    console.log('totalTax',totalTax);
    return item;
});
console.log('totalTax2',totalTax);

this.totalTax = totalTax.toFixed(2); // Total tax rounded to 2 decimals
console.log('Total Tax:', this.totalTax);

// Calculate total amount (price + tax)
this.totalAmount = (parseFloat(this.totalPrice) + parseFloat(this.totalTax)).toFixed(2);
console.log('this.totalAmount:', this.totalAmount);

if (Array.isArray(this.combinedProducts) && this.combinedProducts.length > 0) {
    const productLineItems = this.combinedProducts.map(item => {
                  return {
                      productLineId: item.itemId,
                      productLineQuantity: item.quantity,
                      productLinePrice: item.itemPrice,
                      productLineTax: item.itemTax
               };
               });
                 console.log('productLineItems:', productLineItems);
                } else {
                  console.error('combinedProducts is either not an array or is empty');
                 }

            this.loading = false;
        }
        
    }


    handleMSLCalculations() {

       
   
    this.ishandMSLBack = true;
    this.totalPrice = 0;
this.totalTax = 0;
this.totalCGST = 0;
this.totalSGST = 0;
this.totalIGST = 0;


this.combinedProducts = this.combinedProducts.map(product => {
    let updatedProduct = { ...product };

    // Calculate item price based on quantity and price
    updatedProduct.itemPrice = updatedProduct.productLineQuantity * updatedProduct.productLinePrice;
    updatedProduct.itemName = updatedProduct.productLineName;
    updatedProduct.itemCode = updatedProduct.productLineCode;
    updatedProduct.quantity = updatedProduct.productLineQuantity;
    updatedProduct.originalPrice = updatedProduct.productLinePrice;

    // Calculate tax for each item individually based on CGST/SGST or IGST
    if (this.isIGSTChecked) {
        updatedProduct.itemTax = ((updatedProduct.itemIGST / 100) * updatedProduct.itemPrice) || 0;
        this.totalIGST += updatedProduct.itemIGST || 0;
    } else {
        updatedProduct.itemTax = (((updatedProduct.itemCGST + updatedProduct.itemSGST) / 100) * updatedProduct.itemPrice) || 0;
        this.totalCGST += updatedProduct.itemCGST || 0;
        this.totalSGST += updatedProduct.itemSGST || 0;
    }
    
    // Accumulate total price and total tax
    this.totalPrice += updatedProduct.itemPrice;
    this.totalTax += updatedProduct.itemTax;

// Round to 2 decimal places
this.totalPrice = parseFloat(this.totalPrice.toFixed(2));
this.totalTax = parseFloat(this.totalTax.toFixed(2));

    return updatedProduct;
});

// Calculate total amount
this.totalAmount = parseFloat((this.totalPrice + this.totalTax).toFixed(2));

    console.log('combinedProducts after', JSON.stringify(this.combinedProducts));
    console.log('this.hand',this.ishandMSLBack);
    this.loading = false;
}

   
    handleSubmit(){
        if(this.recType ==='MSL'){
            this.handleMSLSubmit();
        }else{
             console.log('this.branchId',this.branchId);
       console.log('this.branchId',this.deptId);
       console.log('this.branchId',this.sde);

    // Check if all required fields are filled
    if (this.branchId && this.deptId && this.sde) {
        // If all fields are filled, proceed to show the order summary
        this.isNextDisable = true;  // Disable the Next button
        this.isOrderSummaryVisible = true;  // Show order summary
        this.showErrorMessage = false;

         console.log('this.combinedProducts ',this.combinedProducts);
       this.isSubmitDisabled = true;
           //console.log('this.pls1 ', this.pls);
        const productLineItems = this.combinedProducts.map(item => ({
            productLineId: item.itemId,
            productLineQuantity: item.quantity,
            productLinePrice: item.itemPrice,
            productLineTax:item.itemTax
        }));
        console.log('productLineItems', productLineItems);
        saveProductLines({recId: this.recId, plLines: this.combinedProducts, 
                          totalAmount :this.totalAmount , isIGST :this.isIGSTChecked,
                          branch:this.branchId, dept:this.deptId, sde :this.sde})
        .then((result)=> {
        this.loading = false;
        window.location = '/channelpartnerportal/s/detail/'+result;
        const evt = new ShowToastEvent({
            title: 'Product Request and Lines Created',
                "message": "Record created! See it {0}!",
                "messageData": [
                {
                    url: '/'+result,
                    label: 'here'
                }
            ],
                variant: 'success',
            });
        this.dispatchEvent(evt);
    
    });
    } else {
        // If any field is not filled, show an error message
        this.showErrorMessage = true;  // Set error message flag to true
    }

        }

       
      
        
       
        
    }

    handleMSLSubmit() {
    console.log('this.branchId', this.branchId);
    console.log('this.deptId', this.deptId);
    console.log('this.sde', this.sde);

    if (this.branchId && this.deptId && this.sde) {
        this.isNextDisable = true;  // Disable the Next button
        this.isOrderSummaryVisible = true;  // Show order summary
        this.showErrorMessage = false;
        this.isMSLSubmitDis = true;

        

        console.log('plLines:', JSON.stringify(this.combinedProducts));

        saveMSLProductLines({ 
            recId: this.recId, 
            plLines: this.combinedProducts, 
            totalAmount: this.totalAmount, 
            isIGST: this.isIGSTChecked,
            branch: this.branchId, 
            dept: this.deptId, 
            sde: this.sde 
        })
        .then((result) => {
            this.loader = false;
            window.location = '/channelpartnerportal/s/detail/' + result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Product Request and Lines Created',
                    message: 'Record created! See it {0}!',
                    messageData: [{ url: '/' + result, label: 'here' }],
                    variant: 'success',
                })
            );
        })
        .catch((error) => {
            this.loader = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                })
            );
        });
    } else {
        this.showErrorMessage = true;  // Set error message flag to true if fields are missing
    }
}


    handBack(){
        this.dispatchEvent(new CustomEvent('back',{
             
        }));

    }
    handMSLBack(){
        console.log('handle back');
        this.dispatchEvent(new CustomEvent('back',{
             
        }));

    }


     handleBranchChange(event) {
        // Handle account change
        
        this.branchId = event.target.value;
        console.log('cpId -- '+ this.branchId);
        this.loadSDEUsers();

    }
    handleDepartmentChange(event) {
        
        this.deptId = event.target.value;
         console.log('this.deptId '+ this.deptId);
        this.loadSDEUsers();
    }
    
    
    loadSDEUsers() {

        console.log('cpId -- '+ this.branchId);
        console.log('this.deptId '+ this.deptId);
        if (this.branchId && this.deptId) {
            this.showSDE = true;

            getSDEUsers({ branch: this.branchId, department: this.deptId })
                .then(data => {
                    console.log('data',data);
                    this.sdeUserOptions = Object.entries(data).map(([id, name]) => ({
                    label: name,
                    value: id
                }));
                console.log('sdeUserOptions:', this.sdeUserOptions);
                console.log('com',this.combinedProducts);
                
                })
                .catch(error => {
                    console.error('Error fetching SDE Users:', error);
                });
        }
    }

    handleSDEChange(event) {
        this.sde = event.detail.value; // Store the selected ID
        console.log('this.sde',this.sde);
    }


    handleNextClick() {
       
    
    // Check if all required fields are filled
    if (this.branchId && this.deptId && this.sde) {
        // If all fields are filled, proceed to show the order summary
        this.isNextDisable = true;  // Disable the Next button
        console.log('this.isHandMSLBack', this.isHandMSLBack);
         console.log('this.isHandMSLBack', this.isHandMSLBack);
         console.log('this.rec',this.recType);
         if(this.recType ==='MSL'){
             this.handleMSLCalculations();
         }
       
       //this.handMSLBack =true;
        

        this.isOrderSummaryVisible = true;  // Show order summary
        this.showErrorMessage = false;
    } else {
        // If any field is not filled, show an error message
        this.showErrorMessage = true;  // Set error message flag to true
    }
    }
}