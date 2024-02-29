import { LightningElement,api } from 'lwc';

export default class PortfolioUserDetails extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api resumeUrl


    downloadResume(){
        window.open(this.resumeUrl,"_blank")
    //"https://github.com/EnMohit/Mohit-Resume/raw/main/Mohit's%20Resume.pdf"
    }

}