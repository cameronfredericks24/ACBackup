import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPublicImageUrl from '@salesforce/apex/ContentDistributionController.getPublicImageUrl';
import deleteFile from '@salesforce/apex/ContentDistributionController.deleteFile';


export default class ImageUploadforDefectiveItems extends LightningElement {
   @api rowId;
   @track files = [];
   @api uploadedImages = [];
   @api partName;
   @track showPartName = false;


   connectedCallback() {
       if (this.partName) {
           this.showPartName = true;
       }
   }


   handleUploadFinished(event) {
       const uploadedFiles = event.detail.files;


       if (uploadedFiles.length === 0) {
           this.showToast('Error', 'Please upload at least one file.', 'error');
           return;
       }


       this.files = [...this.files, ...uploadedFiles];


       // Fetch public URLs for each uploaded file
       uploadedFiles.forEach(file => {
           this.fetchPublicImageUrl(file.documentId);
       });


       this.dispatchEvent(
           new ShowToastEvent({
               title: 'Success',
               message: `${uploadedFiles.length} file(s) uploaded successfully.`,
               variant: 'success'
           })
       );


       // Dispatch the upload finished event with the files and rowId
       this.dispatchEvent(new CustomEvent('uploadfinished', {
           detail: {
               rowId: this.rowId,
               files: uploadedFiles
           }
       }));
   }


   fetchPublicImageUrl(documentId) {
       getPublicImageUrl({ contentVersionId: documentId })
           .then(url => {
               if (url) {
                   this.updateFileUrl(documentId, url);
               } else {
                   this.showToast('Error', 'Public URL not found for the uploaded file.', 'error');
               }
           })
           .catch(error => {
               this.showToast('Error', error.body.message, 'error');
           });
   }


 updateFileUrl(documentId, url) {
       this.files = this.files.map(file => {
           if (file.documentId === documentId) {
               return { ...file, url };
           }
           return file;
       });
   }


   handleFileDelete(event) {
       const fileId = event.target.dataset.id;


       deleteFile({ contentDocumentId: fileId })
           .then(() => {
               this.files = this.files.filter(file => file.documentId !== fileId);
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Success',
                       message: 'File deleted successfully',
                       variant: 'success'
                   })
               );
           })
           .catch(error => {
               this.showToast('Error', error.body.message, 'error');
           });
   }


   get hasFiles() {
       return this.files.length > 0;
   }


   get filePreviews() {
       return this.files.map(file => ({
           id: file.documentId,
           name: file.name,
           url: file.url,
           partName: this.partName
       }));
   }


   showToast(title, message, variant) {
       const event = new ShowToastEvent({
           title: title,
           message: message,
           variant: variant,
       });
       this.dispatchEvent(event);
   }
}