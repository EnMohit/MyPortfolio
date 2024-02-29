import { LightningElement, wire, api } from 'lwc';
import PortfolioAssets from '@salesforce/resourceUrl/PortfolioAssets';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import FULLNAME from '@salesforce/schema/Portfolio__c.Full_Name__c';
import DESIGNATION from '@salesforce/schema/Portfolio__c.Designation__c';
import COMPANY_LOCATION from '@salesforce/schema/Portfolio__c.Company_Location__c';
import COMPANY_NAME from '@salesforce/schema/Portfolio__c.Company_Name__c';

export default class PortfolioBanner extends LightningElement {
    @api recordId //= 'a005j00000P41JvAAJ';
    
    @api linkedinUrl //= 'https://linkedin.com/in/mohit-tanwar-6347a2226';
    @api githubUrl // = 'https://github.com/EnMohit';
    @api trailheadUrl// = 'https://www.salesforce.com/trailblazer/mtanwar10';


    userPic = `${PortfolioAssets}/PortfolioAssets/userPic.jpeg`;
    linkedin = `${PortfolioAssets}/PortfolioAssets/Social/linkedin.svg`;
    github = `${PortfolioAssets}/PortfolioAssets/Social/github.svg`;
    trailhead = `${PortfolioAssets}/PortfolioAssets/Social/trailhead1.svg`;

    @wire(getRecord, {recordId:'$recordId', fields:[FULLNAME,COMPANY_LOCATION,COMPANY_NAME,DESIGNATION]})
    portfolioData
    // portfolioHandler({result, error}){
    //     console.log('i am here');
    //     if(result){
    //         console.log("record Data", JSON.stringify(result));
    //     }
    //     if(error){
    //         console.error("error", error);
    //     }
    // }

    get fullName (){
        return getFieldValue(this.portfolioData.data, FULLNAME)
    }
    get designation (){
        return getFieldValue(this.portfolioData.data, DESIGNATION)
    }
    get companyLocation (){
        return getFieldValue(this.portfolioData.data, COMPANY_LOCATION)
    }
    get companyName (){
        return getFieldValue(this.portfolioData.data, COMPANY_NAME)
    }
}