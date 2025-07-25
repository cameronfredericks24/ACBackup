import { LightningElement, track } from 'lwc';
import getAnnouncementMessages from '@salesforce/apex/AnnouncementMessageController.getAnnouncementMessages';

const PAGE_SIZE = 5; // Adjust this value as needed

export default class AnnouncementMessageDisplay extends LightningElement {
    @track announcementMessages;
    @track pageNumber = 1;

    connectedCallback() {
        this.fetchAnnouncementMessages();
    }

    fetchAnnouncementMessages() {
        getAnnouncementMessages({ pageSize: PAGE_SIZE, pageNumber: this.pageNumber })
            .then(result => {
                this.announcementMessages = result;
            })
            .catch(error => {
                console.error('Error fetching announcement messages:', error);
            });
    }

    handleNext() {
        this.pageNumber++;
        this.fetchAnnouncementMessages();
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.fetchAnnouncementMessages();
        }
    }
}