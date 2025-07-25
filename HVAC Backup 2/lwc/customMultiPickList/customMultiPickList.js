import { LightningElement, api, track } from 'lwc';

export default class CustomMultiPickList extends LightningElement {
    @api placeholder = '';
    @api label;
    @api required;
    @api showpills;
    @api options = [];
    
    @track selectedValues = [];
    @track showDD = false;
    @track isSelectAll = false;
    @track init = false;

    connectedCallback() {
        this.setOptions(this.options);
        console.log('op', this.options);
    }

    renderedCallback() {
        if (!this.init) {
            this.template.querySelector('.cmpl-input').addEventListener('click', (event) => {
                this.showDD = !this.showDD;
                event.stopPropagation();
            });
            this.template.addEventListener('click', (event) => {
                event.stopPropagation();
            });
            document.addEventListener('click', () => {
                this.showDD = false;
            });
            this.init = true;
        }
    }

    handleChange(event) {
        Console.log('Entered GComponent')
        this.selectedValues = event.target.value;
        this.dispatchSelectedValues();
    }

    onSearch(event) {
        this.options.forEach(option => {
            option.show = option.label.toLowerCase().startsWith(event.target.value.toLowerCase());
        });
        let filteredOptions = this.options.filter((element) => element.show);
        this.showDD = filteredOptions.length > 0;
    }

    onSelect(event) {
        console.log('onSelect');
        if (event.target.value === 'SelectAll') {
            this.options.forEach(option => option.checked = event.target.checked);
        } else {
            this.options.find(option => option.label === event.target.value).checked = event.target.checked;
        }

        // Emit the selected values after updating the options
        this.dispatchSelectedValues();

        this.postSelect();
    }

    onRemove(event) {
        this.options.find(option => option.label === event.detail.name).checked = false;
        this.postSelect();
        this.dispatchSelectedValues();  // Emit updated selected values when removed
    }

    postSelect() {
        let count = this.options.filter((element) => element.checked).length;
        this.placeholder = count > 0 ? `${count} Item(s) Selected` : '';
        this.isSelectAll = (count === this.options.length);
        
        if (this.showpills) {
            let interval = setInterval(() => {
                if (count > 1) {
                    let pillView = this.template.querySelector('[role="listbox"]');
                    let pillHeight = this.template.querySelectorAll('[role="pill"]')[0].getBoundingClientRect().height;
                    let moreButton = this.template.querySelector('[role="more"]');
                    if (pillView.getBoundingClientRect().height > pillHeight + 10) {
                        moreButton.classList.remove('slds-hide');
                    } else {
                        moreButton.classList.add('slds-hide');
                    }
                }
                clearInterval(interval);
            }, 200);
        }

        if (this.required) {
            if (count === 0) {
                this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
            } else {
                this.template.querySelector('.cmpl-input').setCustomValidity('');
            }
            this.template.querySelector('.cmpl-input').reportValidity();
        }
    }

    dispatchSelectedValues() {
        // Gather the selected values (parts)
        const selectedValues = this.options
            .filter(option => option.checked)
            .map(option => option.label);
        console.log('dispatchSelectedValues'+JSON.stringify(selectedValues));
        // Dispatch the event with selected values
        this.dispatchEvent(new CustomEvent('selected', {
            detail: { value: selectedValues }
        }));
    }

    get showPillView() {
        let count = this.options ? this.options.filter((element) => element.checked).length : 0;
        return this.showpills && count > 0;
    }

    showMore() {
        this.template.querySelector('.slds-listbox_selection-group').classList.add('slds-listbox_expanded');
        this.template.querySelector('[role="more"]').classList.add('slds-hide');
        this.template.querySelector('[role="less"]').classList.remove('slds-hide');
    }

    showLess() {
        this.template.querySelector('.slds-listbox_selection-group').classList.remove('slds-listbox_expanded');
        this.template.querySelector('[role="less"]').classList.add('slds-hide');
        this.template.querySelector('[role="more"]').classList.remove('slds-hide');
    }

    @api
    getSelectedList() {
        return this.options.filter((element) => element.checked).map((element) => element.label).join(';');
    }

    @api
    setSelectedList(selected) {
        selected?.split(';').forEach(name => {
            let option = this.options.find(option => option.label === name);
            if (option) option.checked = true;
        });
        this.postSelect();
    }

    @api
    setOptions(opts) {
        this.options = opts.map(opt => ({ label: opt.label, value: opt.value, show: true, checked: false }));
    }

    @api
    isValid() {
        if (this.required) {
            let count = this.options ? this.options.filter((element) => element.checked).length : 0;
            if (count === 0) {
                this.template.querySelector('.cmpl-input').setCustomValidity('Please select item(s)');
                this.template.querySelector('.cmpl-input').reportValidity();
                return false;
            }
        }
        return true;
    }
}