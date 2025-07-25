import { LightningElement, track } from 'lwc';
import searchSDEUsers from '@salesforce/apex/RecordTransferController.searchSDEUsers';

export default class RecordTransferChild extends LightningElement {
    @track searchKey = '';
    @track users = [];
    @track showDropdown = false;

    selectedUserId;
    selectedUserName;

    // Handles input typing
    handleInput(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length > 1) {
            this.fetchUsers();
        } else {
            this.users = [];
            this.showDropdown = false;
        }
    }

    // Shows dropdown if results exist
    handleFocus() {
        if (this.searchKey && this.users.length > 0) {
            this.showDropdown = true;
        }
    }

    // Clears selected user and search
    clearSearch() {
        this.searchKey = '';
        this.users = [];
        this.showDropdown = false;
        this.selectedUserId = null;
        this.selectedUserName = null;

        // Inform parent component that selection is cleared
        const clearEvent = new CustomEvent('userselect', {
            detail: {
                userId: null,
                userName: null
            }
        });
        this.dispatchEvent(clearEvent);
    }

    // Fetch matching users from Apex
    fetchUsers() {
        searchSDEUsers({ searchKey: this.searchKey })
            .then((result) => {
                this.users = result.map(user => ({
                    Id: user.Id,
                    Name: user.Name,
                    Code: user.Employee_Code__c // Assuming Apex returns this
                }));
                this.showDropdown = true;
            })
            .catch((error) => {
                console.error('Error fetching users', error);
            });
    }

    // When a user is selected from the list
    handleUserSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedName = event.currentTarget.dataset.name;
        const selectedCode = event.currentTarget.dataset.code;

        this.selectedUserId = selectedId;
        this.selectedUserName = `${selectedName}`;
        this.searchKey = '';
        this.showDropdown = false;

        
        const customEvent = new CustomEvent('userselect', {
            detail: {
                userId: this.selectedUserId,
                userName: this.selectedUserName
            }
        });
        this.dispatchEvent(customEvent);
    }
}