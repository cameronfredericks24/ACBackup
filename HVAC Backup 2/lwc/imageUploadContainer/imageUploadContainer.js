import { LightningElement, api } from 'lwc';
export default class ImageUploadContainer extends LightningElement {
    
    @api
    recordId;

    @api isInvoiceFile;

    

    handleNextButton(){
        
       const event = new CustomEvent('fileuploaded');
             this.dispatchEvent(event);
    }

    handleFileUploaded(){

        const fileUploded = new CustomEvent('fileuploaded');
        this.dispatchEvent(fileUploded);

    }

}