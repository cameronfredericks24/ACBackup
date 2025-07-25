.slds-modal__container {
    width: 90% !important;
    max-width: 90% !important;
    height: 90% !important;
    max-height: 90% !important;
}

this.dispatchEvent(successEvent);
this.dispatchEvent(new CloseActionScreenEvent());

const filterChangeEvent = new CustomEvent('filterchange',});

this.dispatchEvent(new CustomEvent('success'));

new CustomEvent('filterchange', {
            detail: { filters },

<c:productTransferCmpNew recordId="{!v.recordId}" />

  <c:categoryFilter onfilterchange="{!c.handleFilterChange}"/>
  
  
  ({
    handleFilterChange: function(component, event) {
        var filters = event.getParam('filters');
        component.set('v.message', filters.length > 0 ? 'Your selection: ' + filters.join() : 'No selection');
    },
});