public with sharing class ContactList {

    @AuraEnabled
    public static List<Contact> getContactList(Id accId, String searchKey){
        if(searchKey!= Null && searchKey!=''){
            String key = '%'+searchKey+'%';
            List<Contact> conList = [Select Id, Name , Phone, AccountId FROM Contact WHERE AccountId= :accID AND Name LIKE :key ];
            if(!conList.isEmpty()){
                system.debug('CONTACT SEARCH LIST :'+ conList);
                return conList;
            }
            return NULL;
        }else {
            List<Contact> conList = [Select Id, Name , Phone, AccountId FROM Contact WHERE AccountId =: accID];
            if(!conList.isEmpty()){
                return conlist;
            }
            return Null;
        }
    }


}