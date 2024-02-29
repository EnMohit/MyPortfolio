import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import PortfolioAssets from '@salesforce/resourceUrl/PortfolioAssets';

import SF_CERTIFI from '@salesforce/schema/Portfolio__c.SalesforceCertification__c';
import OTHER_CERTIFI from '@salesforce/schema/Portfolio__c.OtherCertifications__c';

export default class PortfolioCertifications extends LightningElement {

    certLogo = `${PortfolioAssets}/PortfolioAssets/cert_logo.png`
    SalesforceCertification=[];
    OtherCertifications=[];

    @api recordId;
    @wire(getRecord, {
        recordId:'$recordId',
        fields:[SF_CERTIFI,OTHER_CERTIFI]
    })certsHandler({data, error}){
        if(data){
            console.log("certsHandler data", JSON.stringify(data) )
            this.formatedEducation(data);
        }
        if(error){
            console.error(error);
        }
    }


    formatedEducation(data){
        const {SalesforceCertification__c,OtherCertifications__c}= data.fields
        this.SalesforceCertification = SalesforceCertification__c ? SalesforceCertification__c.value.split(';').map(item=>{
            return `Salesforce Certified ${item}`
        }):[]
        this.OtherCertifications = OtherCertifications__c ? OtherCertifications__c.value.split(','):[]
        
    }
}