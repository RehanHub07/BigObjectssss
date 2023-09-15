import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ConfigurationNewArchiveSetup extends LightningModal  {


    onCancel(){
        this.close(false);
    }
}