import { LightningElement,track } from 'lwc';

export default class ConfigurationHomeContainer extends LightningElement {
 

    @track visibilityController={
        tabSelected:'archive',
        get isBigObjectSelected(){
            return this.tabSelected=='bigObject';
        },
        get isArchiveSelected(){
            return this.tabSelected=='archive';
        }
    }

    handleTabSelect(event){
        this.visibilityController.tabSelected = event.detail.name;
         

    }
}