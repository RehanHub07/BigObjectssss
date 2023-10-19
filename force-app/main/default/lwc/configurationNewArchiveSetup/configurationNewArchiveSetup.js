import { api, wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import getAllObjects from '@salesforce/apex/ConfigurationHomeController.getAllObjects';
import createArchiveConfig from '@salesforce/apex/ConfigurationHomeController.createArchiveConfig'
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConfigurationNewArchiveSetup extends LightningModal {

    isLoading = false;


    @track options = {
        allParentObjectsList: [],
        parentObjectOptionsList: [],
        get isParentObjectLoading() {
            return this.allParentObjectsList.length == 0;
        },
        get isChildObjectLoading() {
            return this.allChildObjectsList.length == 0;
        },
        allChildObjectsList: [],
        childObjectList: [],
        allChildObjectFields: [],
        fieldColumns: [
            { label: 'Field Name', fieldName: 'label', sortable: true },
            { label: 'API Name', fieldName: 'apiName', sortable: true },
            { label: 'Data Type', fieldName: 'type', sortable: true },
            { label: 'Indexed', fieldName: 'indexed', type: 'boolean' }
        ],
        selectedFieldsColumns: [
            { label: 'API Name', fieldName: 'apiName', sortable: true },
        ]
    }

    @track configs = {
        parentObjectApiName: '',
        childObjectApiName: '',
        childObjectRelatedFieldName: '',
        childObjectFieldsList: [],
        get isStep1NextDisabled() {
            if (!this.parentObjectApiName || !this.childObjectApiName || !this.childObjectRelatedFieldName) {
                return true;
            }

            return false;
        },
        get fieldsSelectedCount() {
            return this.childObjectFieldsList.length;
        }
    }


    @track currentStep = '1';
    get isStep1() {
        return this.currentStep === '1';
    }
    get isStep2() {
        return this.currentStep === '2';
    }
    get isStep3() {
        return this.currentStep === '3';
    }

    @wire(getObjectInfo, { objectApiName: '$configs.parentObjectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            console.log(data);
            this.options.allChildObjectsList = data?.childRelationships.map(i => {
                return {
                    label: i.relationshipName,
                    value: i.childObjectApiName,
                    description: i.fieldName
                }
            });
            this.options.childObjectList = this.options.allChildObjectsList;
        }
        else {
            console.error(error)
        }

    }

    @wire(getObjectInfo, { objectApiName: '$configs.childObjectApiName' })
    wiredChildObjectInfo({ error, data }) {
        if (data) {
            console.log(data);
            this.options.allChildObjectFields = Object.values(data?.fields)?.map(i => {
                return {
                    label: i.label,
                    apiName: i.apiName,
                    type: i.dataType,
                    indexed: i.apiName == this.configs.childObjectRelatedFieldName || i.apiName == 'Id',

                }
            });
            this.configs.childObjectFieldsList.push('Id');
            this.configs.childObjectFieldsList.push(this.configs.childObjectRelatedFieldName);

        }
        else {
            console.error(error)
        }

    }


    @wire(getAllObjects)
    wiredObjectResult({ error, data }) {
        if (data) {
            this.options.allParentObjectsList = Object.keys(data).map(apiName => {
                return {
                    label: apiName,
                    value: data[apiName]
                }
            });
            this.options.parentObjectOptionsList = this.options.allParentObjectsList;

        } else {
            console.error(error)
        }
    }

    onParentObjectSearch(event) {
        if (!event.detail.searchText) {
            this.options.parentObjectOptionsList = this.options.allParentObjectsList;
            return;
        }
        this.options.parentObjectOptionsList = this.options.allParentObjectsList.filter(i => i.label.toUpperCase().includes(event.detail.searchText.toUpperCase()));
    }
    onParentObjectSelect(event) {
        this.configs.parentObjectApiName = event.detail.data.value;
        console.log(this.configs.parentObjectApiName);
    }

    onChildObjectSearch(event) {
        if (!event.detail.searchText) {
            this.options.childObjectList = this.options.allChildObjectsList;
            return;
        }
        this.options.childObjectList = this.options.allChildObjectsList.filter(i => i.label.toUpperCase().includes(event.detail.searchText.toUpperCase()));
    }
    onChildObjectSelect(event) {
        let selectedValue = event.detail.data;
        this.configs.childObjectApiName = selectedValue?.value;
        this.configs.childObjectRelatedFieldName = selectedValue?.description;
        console.log(this.configs);
    }

    getSelectedFields(event) {
        const selectedRows = event.detail.selectedRows;
        this.configs.childObjectFieldsList = selectedRows.map(f => f.apiName);
        if (!this.configs.childObjectFieldsList.find(i => i == 'Id')) {
            this.configs.childObjectFieldsList.push('Id');
        }
        if (!this.configs.childObjectFieldsList.find(i => i == this.configs.childObjectRelatedFieldName)) {
            this.configs.childObjectFieldsList.push(this.configs.childObjectRelatedFieldName);
        }

    }

    /*Footers */
    goToStep1() {
        this.currentStep = '1';
    }
    goToStep2() {
        this.currentStep = '2';
    }
    goToStep3() {
        this.currentStep = '3';
    }

    onCancel() {
        this.close(false);
    }

    createConfigRecord() {



        this.isLoading = true;
        let request = {
            parentObjectApiName: this.configs.parentObjectApiName,
            childObjectApiName: this.configs.childObjectApiName,
            childObjectRelatedFieldName: this.configs.childObjectRelatedFieldName,
            childObjectFields: this.configs.childObjectFieldsList

        }

        createArchiveConfig(request)
            .then(() => {
                //this.showToast('Success','Config Record is created','success');
             })
            .catch(error => {
                console.error(error)
                //this.showToast('Error','Contact System Admin','error');
            })
            .finally(() => {
                this.isLoading = false
                this.onCancel();
            });
    }

    //utill
    showToast(title, msg, varient) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: varient
        });
        this.dispatchEvent(event);
    }
}