import { LightningElement, wire } from 'lwc';
import AccountRecord from '@salesforce/apex/AccountRecord';
export default class RecordUIComponent extends LightningElement {

    data;
    error;
    AccountRecord(data,error){
        if(data){
            this.data = data;
            this.error = undefined;
        }
        if(error){
            this.data = undefined;
            this.error = error
        }

    }
}