import { LightningElement, api, track} from 'lwc';
 export default class CustomRelatedLists extends LightningElement{
    @track isOptionTile = false;
    @track isOptionBasicList = false;
    @track isOptionEnhancedList = false;
    @track isOptionDefault = false;

    // This getter will be invoked when the "Name" property is set
    @api
    get Name() {
        return this._Name;
    }
    set Name(value) {
        this._Name = value;
        console.log('vallee' + this._Name)
        // Determine which template to show based on the property value
        this.isOptionTile = value === 'Tile';
        this.isOptionBasicList = value === 'Basic List';
        this.isOptionEnhancedList = value === 'Enhanced List';
        this.isOptionDefault = value === 'Default';
    }
    
    
}