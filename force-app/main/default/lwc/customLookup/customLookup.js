import { api, LightningElement, track } from 'lwc';

export default class CustomLookup extends LightningElement {
    @api iconName = 'standard:account'; // pass value for icon 
    @api isDisabled; // pass to disable input field
    @api label; // pass to set label 
    @api preloadvalue; // pass to set value bu default
    @api isLoading = false; // pass to change search icon to spinner

    @api isRequired = false;
    @api isLabelHidden = false;
    @api searchTerm;
    @api isLabelHorizontal = false;


    @api searchPlaceholder = 'Select One';


    selectedName;
    @track records;
    isValueSelected=false;
    get isSelectedValue(){
        return this.selectedName?true:false;
    }
    @track blurTimeout;
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    @api searchOptions = []

    get formElementClass() {
        return this.isLabelHidden ? 'slds-form-element' : `slds-form-element ${(this.isLabelHorizontal) ? 'slds-form-element_horizontal' : ''}`;
    }
    get ifDisplayOptions() {
        return this.searchOptions.length > 0 ? true : false;
    }



    connectedCallback() {
        if (this.preloadvalue) {
            this.searchOptions.forEach(currentItem => {
                if (currentItem.value === this.preloadvalue) {
                    let selectedId = currentItem.value;
                    let selectedName = currentItem.label;
                    this.isValueSelected = this.isDisabled == true ? false : true;
                    this.selectedName = selectedName;
                    if (this.blurTimeout) {
                        clearTimeout(this.blurTimeout);
                    }
                    this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
                }
            });

        }
    }



    handleClick() {
        if (!this.isDisabled) {

            this.searchTerm = '';
            this.inputClass = 'slds-has-focus';
            this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        }
    }
    onBlur() {
        this.blurTimeout = setTimeout(() => { this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }, 300);
    }
    onSelect(event) {
        console.log('onSelect')
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;

        this.isValueSelected = true;
        this.selectedName = selectedName;
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';

        const valueonSelectedEvent = new CustomEvent('select', {
            detail: {
                value: selectedId,
                label: selectedName,
                data: this.searchOptions.find(i => i.value == selectedId)
            }
        });
        this.dispatchEvent(valueonSelectedEvent);


    }
    @api handleRemovePill() {
        this.isValueSelected = false;

        const removeSelectedSoldTo = new CustomEvent('select', {
            detail: {
                value: '',
                label: '',
                data: '',
            }
        });
        this.searchTerm = '';
        this.dispatchEvent(removeSelectedSoldTo);

    }
    onChange(event) {
        if(this.boxClass!='slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open'){
            this.boxClass='slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        }
        this.searchTerm = event.target.value;
        const removeSelectedSoldTo = new CustomEvent('search', {
            detail: {
                searchText: this.searchTerm
            }
        });
        this.dispatchEvent(removeSelectedSoldTo);

    }
}