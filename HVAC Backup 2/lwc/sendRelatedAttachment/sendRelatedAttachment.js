import { LightningElement, wire, track } from 'lwc';
import getRelatedFiles from '@salesforce/apex/AccountFileEmailService.getRelatedFiles';
import sendFileEmails from '@salesforce/apex/AccountFileEmailService.sendFileEmails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api } from 'lwc';

export default class sendRelatedAttachment extends LightningElement {
    @track files = [];
    @track selectedFiles = [];
    @track selectAll = false;
    @api recordId;

    connectedCallback() {
        console.log(this.recordId);
        this.fetchFiles();
    }

    fetchFiles() {
        getRelatedFiles({ accountId: this.recordId })
            .then(data => {
                this.files = data;
            })
            .catch(error => {
                this.files = [];
                console.error('Error fetching files:', error);
            });
    }

    handleFileSelection(event) {
        const fileId = event.target.value;
        if (event.target.checked) {
            this.selectedFiles.push(fileId);
        } else {
            this.selectedFiles = this.selectedFiles.filter(id => id !== fileId);
        }
    }

    toggleSelectAll(event) {
        this.selectAll = event.target.checked;
        this.selectedFiles = this.selectAll ? this.files.map(file => file.Id) : [];
    }

    sendEmail() {
        sendFileEmails({ accountId:this.recordId, fileIds: this.selectedFiles })
            .then(() => {
                this.showToast('Success', 'Emails sent successfully!', 'success');
                this.selectedFiles = [];
                this.selectAll = false;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to send emails.', 'error');
                console.error('Error sending emails:', error);
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(evt);
    }
}