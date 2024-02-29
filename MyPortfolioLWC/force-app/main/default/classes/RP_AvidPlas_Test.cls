/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
public without sharing class RP_AvidPlaySubscriptionFactory {


    /**
     * Prouct option.
     */
    class ProductOption {
        public String parentProductId { get; set; }
        public String variantProductId { get; set; }
        public String pricebookEntryId { get; set; }
        public Decimal listPrice { get; set; }
        public Product2 variantProduct { get; set; }

        /**
         * Constructor.
         * @param parentProductId the parent product ID.
         */
        public ProductOption(String parentProductId) {
            this.parentProductId = parentProductId;
            this.listPrice = 0;
        }

        /**
         * @return the variant info.
         */
        public XC_OrderCreationHelper.VariantProductInfo toVariantProductInfo() {
            return new XC_OrderCreationHelper.VariantProductInfo(variantProduct,
                new XC_OrderCreationHelper.ParentProductInfo(this.parentProductId, this.pricebookEntryId, this.listPrice));
        }
    }

        public static Map<Integer,String> productList = new  Map<Integer,String>();
        public static Set<ID> subsIds = new  Set<ID>();
        public static String cartId;
        public static String account;
        public static String variationId;
        public static String checkoutSession;
        public static String overrideStartDate;
        public static String orderId;
        public static Id ownerId;

            // Constants
    public static final String PARAM_ORDER = 'ORDER';
    public static final String PARAM_PAYMENT_METHOD = 'PAYMENT';
    public static final String PARAM_LEGAL_ENTITY = 'LEGAL';
    public static final String PARAM_PRODUCT = 'PRODUCT';
    public static final String PARAM_LIST_PRICE = 'PRICE';
    public static final String PARAM_START_DATE = 'DATE';
    public static final String PARAM_QUANTITY = 'QTY';
    public static final String PARAM_ORDER_DATE = 'ORDER_DATE';
    public static final String PARAM_DR_ORDER = 'DR_ORDER';
    public static final String PARAM_CURRENCY_CODE = 'CURRENCY';
    public static final String PARAM_STORE = 'STORE';
    public static final String PARAM_ACCOUNT = 'ACCOUNT';
    public static final String PARAM_PARENT_ITEM = 'PARENT_ITEM';
    public static final String PARAM_ORIG_ORDER = 'ORIG_ORDER';
    public static final String PARAM_ORIG_ORDER_ITEM = 'ORIG_ORDER_ITEM';
    public static final String PARAM_END_DATE = 'END_DATE';
    public static final String PARAM_CARD_EXP_YEAR = 'CARD_EXP_YEAR';
    public static final String PARAM_CARD_EXP_MONTH = 'CARD_EXP_MONTH';
    public static final String PARAM_CARD_LAST_4 = 'CARD_LAST_4';
    public static final String PARAM_CARD_BRAND = 'CARD_BRAND';
    public static final String PARAM_PAYMENT_TYPE = 'PAYMENT_TYPE';
    public static final String PARAM_FIRST_NAME = 'FIRST_NAME';
    public static final String PARAM_LAST_NAME = 'LAST_NAME';
    public static final String PARAM_INVOICE = 'INVOICE';
    public static final String PARAM_AMOUNT = 'AMOUNT';
    public static final String PARAM_TAX = 'TAX';
    public static final String PARAM_IMPORTER_TAX = 'IMPORTER_TAX';
    public static final String PARAM_DUTY = 'DUTY';
    public static final String PARAM_ORDER_ITEM_ID = 'ORDER_ITEM_ID';
    public static final String PARAM_AMEND_MOTION = 'AMEND_MOTION';
    public static final String PARAM_CONTRACT_ACTION = 'CONTRACT_ACTION';
    public static final String PARAM_REVISED_ITEM_ID = 'REVISED_ITEM_ID';
    public static final String PARAM_AUTO_RENEW = 'AUTO_RENEW';
    public static final String PARAM_AMEND_TYPE = 'AMEND_TYPE';
    public static final String PARAM_TRANS_TYPE = 'TRANS_TYPE';
    public static final String PARAM_FROM_ASSET = 'FROM_ASSET';
    public static final String PARAM_CC_AVID_SUB = 'CC_AVID_SUB';
    public static final String PARAM_ITEM_TYPE = 'ITEM_TYPE';

        /**
         * Cart.
         */
        @TestVisible
        private WebCart mCart;

        /**
         * Cart Items.
         */
        @TestVisible
        private List<CartItem> mCartItems;

        /**
         * Digital River order.
         */
        @TestVisible
        private XC_DROrderJSON2Apex mDROrder;

        /**
         * Amended product options map.
         */
        @TestVisible
        private Map<String, String> mAmendedProductOptionsMap;
            /**
         * Order item map.
         */
        @TestVisible
        private Map<String, List<OrderItem>> mOrderItemMap;

            /**
     * Order date.
     */
    @TestVisible
    private Date mOrderDate;

    /**
     * Order date time.
     */
    @TestVisible
    private Datetime mOrderDatetime;
    
        public static String processAvidPlayBetaUsers(String betaRecordId){
            try{
                //Take Param as Beta record Id & Query Beta user record for the param Id where eligibe for conversion is true & subscription Id is not set
                List<DistributionEntitlementBetaUser__mdt> betaUserList = new List<DistributionEntitlementBetaUser__mdt>();
                if (Schema.sObjectType.DistributionEntitlementBetaUser__mdt.isAccessible()){
                    betaUserList = [SELECT Id,Label,DistributionPlan__c,DeveloperName,DistributionPlan__r.Label,
                                    DistributionPlan__r.SupportSKU__c,EndDate__c, DistributionPlan__r.DurationInYears__c,DistributionPlan__r.DynamicKitSKU__c
                                    FROM DistributionEntitlementBetaUser__mdt WHERE EligibleForSubscriptionConversion__c = true AND SubscriptionLink__c = null AND id=:betaRecordId];
                }
                system.debug('betaUserList--> '+ betaUserList); 
    
                if(betaUserList.size() == 0){
                    return 'No Eligible Beta User Record found for Conversion: '+betaRecordId;
                }
    
                List<User> customer = new List<User>();
                if (Schema.sObjectType.User.isAccessible()){
                    customer = [SELECT Id,CurrencyIsoCode,Email,Contact.My_Avid_Account_ID__c FROM User WHERE username =:betaUserList[0].Label AND contactId != null LIMIT 1]; 
                }
    
                system.debug('customer--> '+ customer);
                if(customer.size() == 0){//if no user present throw an error
                    return 'No Eligible SFDC User Record found the Beta record: '+ betaRecordId;
                }
    
                cc_avid_SubscriptionRequest srequest = new cc_avid_SubscriptionRequest();
                srequest.customerID = String.valueOf(customer[0].Contact.My_Avid_Account_ID__c);
                srequest.userID = customer[0].Id;
                srequest.subscriptionSKU = AvidLinkSetting__mdt.getInstance('AutoDeposited_AvidPlay_Parent').Value__c;
                srequest.supportSKU = betaUserList[0].DistributionPlan__r.SupportSKU__c;
                srequest.enddate = betaUserList[0].EndDate__c; 
                srequest.startdate = betaUserList[0].EndDate__c.addyears(- Integer.valueOf(betaUserList[0].DistributionPlan__r.DurationInYears__c) );
                srequest.AutoDepositProductId = betaUserList[0].DistributionPlan__r.Label;
                srequest.systemID = '50218318';
    
                system.debug('srequest--> '+ srequest);
                String orderItem = '123';//createOrder(Customer[0],betaUserList[0]);
                Boolean result = methodInvokeCreateB2BSubscription(srequest,customer[0],betaUserList[0],orderItem);
    
                if(result){
                    return 'Beta User successfully converted to Subscription model!';
                }
                
            }
            catch(Exception ex){
                system.debug('Exception--> '+ ex.getMessage() + + ex.getStackTraceString());   
                return 'Error! '+ ex.getMessage();             
            }
    
            return 'Error!';
        }
    
    
        public static Boolean methodInvokeCreateB2BSubscription(cc_avid_SubscriptionRequest request,User customer, DistributionEntitlementBetaUser__mdt betaRecord,String orderItem) {
            try{            
                //Validate if the request.UserId has a Valid SFDC User.
                system.debug('****inside B2B creation');
                
                List<cc_avid_subscription__c> subList =  RP_API_SubscriptionFactory.createB2BSubscription(request);
                //List<ccrz__E_Product__c> prodList = [SELECT id from ccrz__E_Product__c WHERE ccrz__SKU__c =: request.subscriptionSKU];
                system.debug('*****'+subList);
                List<PricebookEntry> priceItemList =  billingAmount(request.AutoDepositProductId,customer);
                system.debug('*****'+PriceItemList);
                //Order item 
                
                for (cc_avid_subscription__c sub : subList) {
                    if('Product License'.equals(sub.Subscription_Type__c)) {
                        sub.Auto_Renew__c = true;
                        sub.Billing_Base_Amount__c = priceItemList[0].UnitPrice;
                        sub.Billing_Frequency__c = priceItemList[0].Product2.Billing_Frequency__c;
                        sub.DRMigrationStatus__c = 'Migrated';
                        sub.Next_Payment_Due__c = sub.End_Date__c + 1;
                        //sub.cc_Order_item__C = orderItem;
                        sub.DynamicKitSKU__c = betaRecord.DistributionPlan__r.DynamicKitSKU__c;
                        sub.ERP_Transaction_Id__c = 'ConvertedSubscription';
                        sub.Sent_to_DOMO__c = true; //ECNPU-1666
                        sub.AvidPlayBetaRecordId__c = betaRecord.Id;
                        //================================================= make redemption Callout ==============================
                        RP_Avid_RedemptionServiceWrapper  reqData = new  RP_Avid_RedemptionServiceWrapper ();
                            HttpRequest reqRdm = new HttpRequest();        
                                reqRdm.setHeader('content-type', 'application/json');   
                                reqData.requests.add(RP_Avid_AutoDepositUtility.buildRequestDataIntoWrapper(sub)); 
                                reqData.requests[0].partNumber = AvidLinkSetting__mdt.getInstance('AutoDeposited_AvidPlay').Value__c;
                                reqData.requests[0].terms.duration = 12;
                                reqData.requests[0].sendCodesToCustomerEmail = false; //ECOMMERCE-3348   
                                reqData.requests[0].redeeemToCustomerAccount = true;  //ECOMMERCE-3348
                                
                                reqData.customerEmail = sub.Owner_s_Email__c!=null ? sub.Owner_s_Email__c : customer.email;
                                //reqData.sendCodesToCustomerEmail = false; 
                                reqData.useB2bRedemptionFlow = false; //Always false for B2C Flow
                                //reqData.redeeemToCustomerAccount = true;
                                String json = JSON.serialize(reqData);
                
                                reqRdm.setBody(json);     
                                reqRdm.setMethod('POST');
                                reqRdm.setTimeout(120000);
                                reqRdm.setEndpoint('callout:New_B2C_Redemption_Service');  //Named credential
                            HttpResponse responseRdm;
                            
                            System.debug(LoggingLevel.INFO,'HttpRequest :' +reqRdm);
                            Http httpRdm = new Http();
                            if(!Test.isRunningTest()) {
                                responseRdm = httpRdm.send(reqRdm);
                                System.debug(LoggingLevel.INFO,'_STATUS_:'+ responseRdm.getStatus() );
                                System.debug(LoggingLevel.INFO,'_STATUS_CODE_:'+ responseRdm.getStatusCode() );
                                System.debug(LoggingLevel.INFO,'_BODY_:'+ responseRdm.getBody() );              
                                List<RedemptionWrapper> rdWrapList = (List<RedemptionWrapper>) System.JSON.deserialize(responseRdm.getBody(), List<RedemptionWrapper>.class);
                                System.debug(LoggingLevel.INFO,'RedemptionParsed:::>>>>'+ rdWrapList );
                                if(rdWrapList!=null && rdWrapList.size()>0) {
                                    for(RedemptionWrapper rdwrap: rdWrapList) {
                                            sub.Avid_Redemption_Code__c = rdwrap.Code;
                                    }
                                } 
                            } 
                    }
                    //sub.AutoDeposited__c = true; 
                    sub.CurrencyIsoCode = customer.CurrencyIsoCode;
                    sub.OwnerId = customer.Id;
                    sub.OwnersEmail__c = customer.Email;
                }
                
                system.debug('Before Insert--> '+ subList);
    
                Database.SaveResult[] srList = Database.insert(subList);
                RP_API_SubscriptionFactory.associateServiceContractsWithProducts(subList); //Association SC on PL
                system.debug('****** completed'+subList);
                String plSubID;
                Set<ID> subsIds = new Set<ID> ();
                for(cc_avid_subscription__c sub : subList) {
                    if('Product License'.equals(sub.Subscription_Type__c)) {
                        plSubID = sub.Id;
                    } 
                    subsIds.add(sub.Id);
                }
    
                system.debug('******************'+plSubID);
                updateCMTmethod(plSubID,betaRecord.DeveloperName,betaRecord.Label);
                createHistories(subList,customer);
                //myAvidCalloutMethod(plSubID);
                //createDRShopper(customer.Id);//This callout will create a shopper in DR if it does not exist. If exists it will throw an error.
                ownerId = customer.Id;
                system.debug('ownerId 151-'+ ownerId);
                createCartOrderModel(subList);
    
            }
            catch(Exception ex){
                system.debug('Exception--> '+ ex.getMessage());
                return false;
            } 
            
            return true;    
        }
    
        private static void createHistories(List<CC_Avid_Subscription__c> subList, User customer){
            //Creating Aroma XML
            List<Attachment> newAttachments = new List<Attachment>();
            List<CC_Avid_Subscription_History__c> histories = new List<CC_Avid_Subscription_History__c>();
            String currencyStr = customer.CurrencyIsoCode;
            
            for(cc_avid_subscription__c sub : subList) {
                sub.CurrencyIsoCode = customer.CurrencyIsoCode;
                Attachment aromaXMLAtt = new Attachment();
                String aromaXML;
                String namePrefix;
                if('Product License'.equals(sub.Subscription_Type__c) || ('Service Contract'.equals(sub.Subscription_Type__c) && sub.Billing_Base_Amount__c > 0)){
                    aromaXML = cc_avid_util_AromaXMLGen.generateSubscripitionBillingEventXML(cc_avid_dao_Subscription.getSubscriptions(new List<Id>{sub.Id}).get(0), null);
                    aromaXMLAtt.body = Blob.valueOf(aromaXML);
                    namePrefix = 'USD'.equalsIgnoreCase(currencyStr) || 'CAD'.equalsIgnoreCase(currencyStr) || 'JPY'.equalsIgnoreCase(currencyStr) ? 'OMS_XML_NA_' : 'OMS_XML_EMEA_';
                    aromaXMLAtt.Name = namePrefix + sub.Name + '.xml';
                    aromaXMLAtt.parentID = sub.Id;                    
                    system.debug('aromaXMLAtt'+ aromaXMLAtt);                               
                    newAttachments.add(aromaXMLAtt);
                }
    
                histories.add(cc_avid_impl_SubscriptionManager.createHistoricalRecord(sub,'Created'));
                for(CC_Avid_Subscription_History__c hist : histories) {
                    hist.CurrencyISOCode = customer.CurrencyIsoCode;
                }
                system.debug('histories'+ histories);
            }
    
            Database.insert(newAttachments);
            Database.insert(histories); 
        }
    
        private static List<PricebookEntry> billingAmount(String subSKu , User customer) {
            system.debug('********** inside billing amount');
            List<PricebookEntry> priceItemList;
            if (Schema.sObjectType.PricebookEntry.isAccessible()){
                //priceItemList = [SELECT Id,ccrz__Product__r.Billing_Frequency__c,ccrz__Pricelist__c,ccrz__Price__c,ccrz__Product__c FROM ccrz__E_PriceListItem__c WHERE ccrz__Product__r.ccrz__SKU__c =:subSKu AND ccrz__Pricelist__r.ccrz__CurrencyISOCode__c=:customer.CurrencyIsoCode];
                priceItemList = [select id,UnitPrice, Product2.Billing_Frequency__c,Product2.name,Product2.productcode,Pricebook2.name,CurrencyIsoCode from PricebookEntry  where Product2.productcode=:subSKu AND   Pricebook2.name='Avid.com Price Book' AND CurrencyIsoCode =:customer.CurrencyIsoCode];
                
            }
            return priceItemList;
        }
    
        @future
        public static void updateCMTmethod(String plSubId, String devName, String label) {
            //Get CMT record instance
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = 'DistributionEntitlementBetaUser.'+devName;
            customMetadata.label = label;
    
            //Update CMT fields
            Metadata.CustomMetadataValue cF1 = new Metadata.CustomMetadataValue();
            cF1.field = 'ExcludeFromService__c';
            cF1.value = true;     
            customMetadata.values.add(cF1);
    
            Metadata.CustomMetadataValue cF2 = new Metadata.CustomMetadataValue();
            cF2.field = 'SubscriptionLink__c';
            cF2.value = URL.getSalesforceBaseUrl().toExternalForm() + '/' + plSubId;
            customMetadata.values.add(cF2);
    
            //Update CMT container to deploy
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            system.debug('mdContainer---'+mdContainer);
    
            if(!Test.isRunningTest()){
                Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
                system.debug('************** jobId '+jobId);
            }
        }
        
        public static void createCartOrderModel(List<cc_avid_subscription__c> subList){
            system.debug(logginglevel.info,'=== Inside createCartOrderModel ====');
             RP_AvidPlaySubscriptionFactory subfact = new RP_AvidPlaySubscriptionFactory();
            List<cc_avid_subscription__c> subToUpdate = new List<cc_avid_subscription__c>();
            List<String> scSubId = new List<String>();
            for(cc_avid_subscription__c sub : subList) {
                if('Product License'.equals(sub.Subscription_Type__c)) {
                    account = sub.Subscriber_Account__c;
                    variationId = sub.Product_Variant__c;
                    scSubId.add( sub.Service_Contract__c);
                }
                subsIds.add(sub.Id);
            }
            system.debug(logginglevel.info,'account = ' +account);
            system.debug(logginglevel.info,'variationId = '+variationId);
            createCartData();
           
            List<OrderItem> oItems = new List<OrderItem>();
            oItems = subfact.createOrderData();
            List<cc_avid_subscription__c> scSub = [SELECT id,owner.id,Order_Product__c,End_Date__c,CurrencyIsoCode,IsGDPR__c,Service_Contract__c,Service_Contract__r.Order_Product__c,Product_Variant__c, Start_Date__c, CC_Order_Item__r.ccrz__Order__c, CC_Order_Item__r.ccrz__Order__r.ccrz__BillTo__c, CC_Order_Item__r.ccrz__Order__r.ccrz__BillTo__r.ccrz__CountryISOCode__c, Subscriber_Account__c, Subscriber_Account__r.BillingCountry, Subscriber_Contact__c, Subscriber_Contact__r.MailingCountry,name,Auto_Renew__c,Contact_Email__c,CC_Order_Item__c,Billing_Base_Amount__c,AutoDeposited__c,IsDistributionSubscription__c,AvidProductLine__c,CC_Product__c, 
            GDPR_Cancellation__c,RenewWithEducationDiscount__c, Subscription_Duration__c,Billing_Frequency__c,Product__c,
            Subscription_Type__c,GDPR_Status__c,Order_Product__r.blng__NextBillingDate__c,Order_Product__r.blng__OverrideNextBillingDate__c,Product_Variant__r.SBQQ__SubscriptionType__c FROM CC_Avid_Subscription__c 
                        WHERE id In :scSubId ];

            subToUpdate.addAll(subList);
            subToUpdate.addAll(scSub);
            System.debug('subToUpdate==>'+subToUpdate.size());
            for(cc_avid_subscription__c sub : subToUpdate) {
                if(oItems!=null && oItems.size()>0){
                    for(OrderItem oi : oItems){
                        if(sub.Product_Variant__c == oi.Product_Variant__c){
                            sub.Order_Product__c = oi.Id;
                        }
                    }
                }
            }
            if(subToUpdate!=null && subToUpdate.size()>0){
                update subToUpdate;
            }

            // Set<Id> returnIds = new Set<Id>();
            // returnIds =  RP_Avid_AutoDepositUtility.createAssetsForautoDeposits(subList); //This function has callout and DMLs
            // System.debug('returnIds==>'+returnIds);
            // List<Asset> assetsToUpdate = RP_Avid_ProcessSuccessOutboundUtility.setAssetData(returnIds,subList,false);
            // if (assetsToUpdate.size() > 0) {
            //     Database.update(assetsToUpdate, false);
            // }
        }
     @TestVisible
        private static void createCartData(){
            List<webcart> webcartlist = [select id, ownerid,owner.email,IsSecondary,Status  from webcart where (ownerid=:ownerId OR ownerid=:UserInfo.getUserId()) order by createddate desc];
system.debug('webcartlist = '+webcartlist);
            for(webcart crt : webcartlist){
                crt.status = 'closed';
            }

            update webcartlist;

            Map<String, Object> response = XC_CartUtil.getInstance().createCartItem(new Map<String, Object>{
                'webstoreName' => 'Avid.com',
                'effectiveAccountId' => account,
                'productId' => variationId,
                'quantity' => 1,
                'cartId' => cartId
            }); 
            system.debug(logginglevel.info,'response = '+response);
            String  responseBody = JSON.serialize(response.get('data'));
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            cartId = responseMap!=null && responseMap.get('cartId')!=null ? (String) responseMap.get('cartId') : null;
            system.debug(logginglevel.info,'cartId = '+cartId);
            WebCart crt = new WebCart(ID = cartId);
            crt.OwnerId = ownerId;
            update crt;
            system.debug(logginglevel.info,'crt = '+crt);
        }
        
        @TestVisible
        private void setCartAndItems(String cartId) {
            this.mCart = [
                SELECT Id, AccountId, CurrencyIsoCode, WebStoreId, TotalAmount, XC_HasAmendmentItem__c, XC_HasRenewalItem__c
                FROM WebCart
                WHERE Id = :cartId
            ];
    
            this.mCartItems = [
                SELECT Id, Name, Product2Id, Product2.ProductCode, Quantity,
                    ListPrice, TotalListPrice, TotalAdjustmentAmount, ItemizedAdjustmentAmount, TotalPrice,
                    SalesPrice, XC_OriginalOrderItem__c, XC_SplitQuantity__c,
                    XC_OriginalOrderItem__r.OrderId, XC_OriginalOrderItem__r.Product_Variant__c,
                    XC_OriginalOrderItem__r.XC_VariantListPrice__c, XC_AmendmentType__c, XC_Credit__c, XC_EndDate__c,
                    XC_OriginalOrderProductOption__c, XC_OriginalOrderProductOption__r.Product_Variant__c,
                    XC_OriginalOrderProductOption__r.XC_VariantListPrice__c, XC_GenuineRenewal__c, XC_StartDate__c,
                    Transaction_Type__c, CC_Avid_Subscription__c, From_Asset__c, ItemType__c,
                    Product2.Subscription_Multiplier__c, Product2.SBQQ__ChargeType__c,
                    Product2.SBQQ__SubscriptionType__c, Product2.SBQQ__SubscriptionTerm__c
                FROM CartItem
                WHERE CartId = :cartId
            ];
        }
        @TestVisible
        private Set<String> getCartProductIds() {
            Set<String> retval = new Set<String>();
            for (CartItem ci : this.mCartItems) {
                retval.add(ci.Product2Id);
                if (String.isNotBlank(ci.XC_OriginalOrderItem__r.Product_Variant__c)) { retval.add(ci.XC_OriginalOrderItem__r.Product_Variant__c); }
                if (String.isNotBlank(ci.XC_OriginalOrderProductOption__r.Product_Variant__c)) { retval.add(ci.XC_OriginalOrderProductOption__r.Product_Variant__c); }
            }
            return retval;
        }

        /**
         * Maps order.
         * @param input the input paramters
         * @return the order.
         */
        public Order mapOrder(Map<String, Object> input) {
            // Extract Input
            //XC_DROrderJSON2Apex drOrder = (XC_DROrderJSON2Apex)input.get(PARAM_DR_ORDER);
            User u = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.IsPersonAccount,contact.Account.BillingStreet,contact.Account.BillingCity, 
            Contact.Account.BillingState,Contact.Account.BillingPostalCode,Contact.Account.BillingCountry,contact.Account.ShippingStreet, contact.Account.ShippingCity, 
            Contact.Account.ShippingState,Contact.Account.ShippingPostalCode,Contact.Account.ShippingCountry FROM User WHERE Id = :ownerId];

            return new Order(
                // Standard
                AccountId = account,
                BillToContactId = u.ContactId,
                BillingStreet = u.contact.Account.BillingStreet,//drOrder.billTo.address == null ? null : drOrder.billTo.address.line1,
                BillingCity =  u.contact.Account.BillingCity,//drOrder.billTo.address == null ? null : drOrder.billTo.address.city,
                BillingState =  u.Contact.Account.BillingState,//drOrder.billTo.address == null ? null : drOrder.billTo.address.state,
                BillingPostalCode =  u.Contact.Account.BillingPostalCode,//drOrder.billTo.address == null ? null : drOrder.billTo.address.postalCode,
                BillingCountry =  u.Contact.Account.BillingCountry,//drOrder.billTo.address == null ? null : drOrder.billTo.address.country,
                BillingPhoneNumber =  '123',//drOrder.billTo.phone,
                BillingEmailAddress =  '',//drOrder.billTo.email,
                CurrencyIsoCode = (String)input.get(PARAM_CURRENCY_CODE),
                EffectiveDate = (Date)input.get(PARAM_START_DATE),
                Name =  '',//drOrder.id,
                OrderedDate = (Datetime)input.get(PARAM_ORDER_DATE),
                OrderReferenceNumber =  '',//drOrder.id,
                Pricebook2Id = XC_CommerceSettings.getInstance().getStandardPriceBookId(),
                SalesStoreId = (String)input.get(PARAM_STORE),
                ShipToContactId = u.ContactId,
                ShippingStreet =  u.contact.Account.ShippingStreet,//drOrder.shipTo == null ? drOrder.billTo.address.line1 : drOrder.shipTo.address.line1,
                ShippingCity =  u.contact.Account.ShippingCity,//drOrder.shipTo == null ? drOrder.billTo.address.city : drOrder.shipTo.address.city,
                ShippingState =  u.Contact.Account.ShippingState,//drOrder.shipTo == null ? drOrder.billTo.address.state : drOrder.shipTo.address.state,
                ShippingPostalCode =  u.Contact.Account.ShippingPostalCode,//drOrder.shipTo == null ? drOrder.billTo.address.postalCode : drOrder.shipTo.address.postalCode,
                ShippingCountry =   u.Contact.Account.ShippingCountry,//drOrder.shipTo == null ? drOrder.billTo.address.country : drOrder.shipTo.address.country,
                Status = XC_Constants.ORDER_STATUS_DRAFT,
                Type = String.isNotBlank((String)input.get(PARAM_ORIG_ORDER)) ? (String.isBlank((String)input.get(PARAM_AMEND_MOTION)) ? XC_Constants.ORDER_TYPE_RENEWAL : XC_Constants.ORDER_TYPE_AMENDMENT) : XC_Constants.ORDER_TYPE_NEW,

                // Custom
                Amended_From_Order__c = String.isNotBlank((String)input.get(PARAM_AMEND_MOTION)) ? (String)input.get(PARAM_ORIG_ORDER) : null,
                Amendment_Motion__c = '',//this.getAmendmentMotion((String)input.get(PARAM_AMEND_MOTION)),
                Master_Order__c = null,
                Renewal_Motion__c = (String.isNotBlank((String)input.get(PARAM_ORIG_ORDER)) && String.isBlank((String)input.get(PARAM_AMEND_MOTION))) ? XC_Constants.RENEWAL_TYPE_MANUAL : null,
                Renewed_From_Order__c = String.isBlank((String)input.get(PARAM_AMEND_MOTION)) ? (String)input.get(PARAM_ORIG_ORDER) : null,
                Sales_Channel__c = XC_Constants.SALES_CHANNEL,
                //Sales_Channel__c = 'B2B',
                XC_DRTotalDuty__c =  0,//drOrder.TotalDuty,
                XC_DRTotalImporterTax__c =   0,//drOrder.TotalImporterTax,
                XC_DRTotalTax__c =   0,//drOrder.TotalTax,
                XC_OrderNumber__c =  cartId,//drOrder.metadata.sfOrderNumber,
                XC_Storefront__c =  XC_Constants.STORE_AVIDCOM,//String.isNotBlank(drOrder.metadata.store) ? drOrder.metadata.store : XC_Constants.STORE_AVIDCOM,

                // Billing
                blng__BillingAccount__c = null,
                blng__BillingDayOfMonth__c = String.valueOf(((Datetime)input.get(PARAM_ORDER_DATE)).day()),
                blng__InvoiceBatch__c = XC_Constants.INVOICE_BATCH,

                // CPQ
                SBQQ__PaymentTerm__c = XC_Constants.PAYMENT_TERM_DUE_RECEIPT
            );
        }

        /**
     * Maps the OrderItem fields.
     * @param orderId the order Id
     * @param paymentMethodId the payment method
     * @param productMap the variant product map
     * @return the order items.
     */
    @TestVisible
    private List<OrderItem> mapOrderItems(Order newOrder, blng__PaymentMethod__c paymentMethod,
            Map<String, XC_OrderCreationHelper.VariantProductInfo> productMap) {
        List<OrderItem> retval = new List<OrderItem>();

        //Map<String, XC_DROrderJSON2Apex.Items> itemMap = this.getDrOrderItemMap();

        // Process cart items
        for (CartItem ci : this.mCartItems) {
            // Check to split quantity
            if (ci.XC_SplitQuantity__c && 1 < ci.Quantity) {
                // Breakup order item
                this.mOrderItemMap.put(ci.Id, new List<OrderItem>());
                for (Integer i = 0; i < ci.Quantity; i++) {
                    OrderItem newItem = this.mapOrderItem(newOrder, paymentMethod, productMap, null, ci, 1);//null
                    retval.add(newItem);
                    this.mOrderItemMap.get(ci.Id).add(newItem);
                }
            } else {
                OrderItem newItem = this.mapOrderItem(newOrder, paymentMethod, productMap, null, ci, ci.Quantity);  //null
                retval.add(newItem);
                this.mOrderItemMap.put(ci.Id, new List<OrderItem>{ newItem });
            }
        }

        return retval;
    }
        /**
     * @return the Digital river order item map.
     */
    @TestVisible
    private Map<String, XC_DROrderJSON2Apex.Items> getDrOrderItemMap() {
        Map<String, XC_DROrderJSON2Apex.Items> retval = new Map<String, XC_DROrderJSON2Apex.Items>();
        for (XC_DROrderJSON2Apex.Items item : this.mDROrder.items) {
            if (Test.isRunningTest()) {
                retval.put([SELECT Id FROM Product2 WHERE Type <> 'Base' LIMIT 1].Id, item);
            } else {
                retval.put(item.metadata.productId, item);
            }
        }
        return retval;
    }
        /**
     * Maps the OrderItem fields.
     * @param orderId the order Id
     * @param paymentMethodId the payment method
     * @param productMap the variant product map
     * @param ci the cart item
     * @param quantity the quantity
     * @return the order items.
     */
    @TestVisible
    private OrderItem mapOrderItem(Order newOrder, blng__PaymentMethod__c paymentMethod,
            Map<String, XC_OrderCreationHelper.VariantProductInfo> productMap,
            Map<String, XC_DROrderJSON2Apex.Items> itemMap, CartItem ci, Decimal quantity) {
        //XC_DROrderJSON2Apex.Items drItem = itemMap.get(ci.Product2Id); 
        return mapOItem(new Map<String, Object>{
            XC_OrderCreationHelper.PARAM_ORDER => newOrder,
            XC_OrderCreationHelper.PARAM_PAYMENT_METHOD => paymentMethod,
            //XC_OrderCreationHelper.PARAM_LEGAL_ENTITY => this.mDROrder.sellingEntity.id,
            XC_OrderCreationHelper.PARAM_PRODUCT => productMap.get(ci.Product2Id),
            XC_OrderCreationHelper.PARAM_LIST_PRICE => ci.ListPrice,
            XC_OrderCreationHelper.PARAM_START_DATE => (this.mCart.XC_HasRenewalItem__c && null != ci.XC_EndDate__c) ? ci.XC_EndDate__c.addDays(1) : (XC_Constants.AMENDMENT_TYPE_COMMITMENT == ci.XC_AmendmentType__c ? ci.XC_StartDate__c.addMonths(1) : this.mOrderDate),
            XC_OrderCreationHelper.PARAM_QUANTITY => quantity,
            XC_OrderCreationHelper.PARAM_ORIG_ORDER_ITEM => ci.XC_OriginalOrderItem__c,
            XC_OrderCreationHelper.PARAM_END_DATE => (this.mCart.XC_HasRenewalItem__c || XC_Constants.AMENDMENT_TYPE_COMMITMENT == ci.XC_AmendmentType__c) ? null : ci.XC_EndDate__c,
            //XC_OrderCreationHelper.PARAM_ORDER_ITEM_ID  => drItem.Id,
            //XC_OrderCreationHelper.PARAM_DUTY => null != drItem ? (quantity < ci.Quantity ? (drItem.duties.amount / ci.Quantity).setScale(2, RoundingMode.HALF_UP) : drItem.duties.amount) : 0,
           // XC_OrderCreationHelper.PARAM_IMPORTER_TAX => null != drItem ? (quantity < ci.Quantity ? (drItem.importerTax.amount / ci.Quantity).setScale(2, RoundingMode.HALF_UP) : drItem.importerTax.amount) : 0,
            //XC_OrderCreationHelper.PARAM_TAX => null != drItem ? (quantity < ci.Quantity ? (drItem.tax.amount / ci.Quantity).setScale(2, RoundingMode.HALF_UP) : drItem.tax.amount) : 0,
            XC_OrderCreationHelper.PARAM_CONTRACT_ACTION => this.mCart.XC_HasRenewalItem__c && ci.XC_GenuineRenewal__c ? XC_Constants.CONTRACT_ACTION_RENEW : XC_Constants.CONTRACT_ACTION_NEW,
            XC_OrderCreationHelper.PARAM_AUTO_RENEW => XC_OrderCreationHelper.getInstance().autoRenewal(productMap.get(ci.Product2Id).details.Avid_Subscription_Flag__c, productMap.get(ci.Product2Id).details.SBQQ__SubscriptionType__c),
            XC_OrderCreationHelper.PARAM_AMEND_TYPE => ci.XC_AmendmentType__c,
            XC_OrderCreationHelper.PARAM_TRANS_TYPE => ci.Transaction_Type__c,
            XC_OrderCreationHelper.PARAM_FROM_ASSET => ci.From_Asset__c,
            XC_OrderCreationHelper.PARAM_CC_AVID_SUB => ci.CC_Avid_Subscription__c,
            XC_OrderCreationHelper.PARAM_ITEM_TYPE => ci.ItemType__c,
            XC_OrderCreationHelper.PARAM_LIST_UNIT_PRICE => 0,
            XC_OrderCreationHelper.PARAM_REVISED_ITEM_ID => (XC_Constants.AMENDMENT_TYPE_LICENSE == ci.XC_AmendmentType__c) ? ci.XC_OriginalOrderItem__c : null
        });
    }


    public OrderItem mapOItem(Map<String, Object> input) {
        blng__PaymentMethod__c payMethod = new blng__PaymentMethod__c();
        payMethod.blng__Account__c = account;
        payMethod.blng__PaymentType__c = 'PO Number';
        payMethod.blng__PaymentGatewayToken__c = '7d252b70-2331-49f4-904f-671fd5f43a03';
        payMethod.Digital_River_External_ID__c = '7d252b70-2331'+system.now();
        insert payMethod;
        // Extract input
        Order order = (Order)input.get(PARAM_ORDER);
        //blng__PaymentMethod__c paymentMethod = (blng__PaymentMethod__c)input.get(PARAM_PAYMENT_METHOD);
        blng__PaymentMethod__c paymentMethod = payMethod;
        String legalEntity = (String)input.get(PARAM_LEGAL_ENTITY);
        XC_OrderCreationHelper.VariantProductInfo variantInfo = (XC_OrderCreationHelper.VariantProductInfo)input.get(PARAM_PRODUCT);
        Decimal listPrice = (Decimal)input.get(PARAM_LIST_PRICE);
        Date startDate = (Date)input.get(PARAM_START_DATE);
        Decimal quantity = (Decimal)input.get(PARAM_QUANTITY);
        String parentItem = (String)input.get(PARAM_PARENT_ITEM);
        String originalOrderItemId = (String)input.get(PARAM_ORIG_ORDER_ITEM);
        Date endDate = (Date)input.get(PARAM_END_DATE);

        // Calculates values
        if (null == endDate) {
            endDate = XC_OrderCreationHelper.getInstance().getEndDate(startDate, variantInfo.details.SBQQ__SubscriptionTerm__c, variantInfo.details.Subscription_Multiplier__c, variantInfo.details.SBQQ__SubscriptionType__c);
        }
        Decimal prorateMultiplier = XC_OrderCreationHelper.getInstance().getProrateMultiplier(variantInfo.details.SBQQ__ChargeType__c, variantInfo.details.SBQQ__SubscriptionType__c, variantInfo.details.SBQQ__SubscriptionTerm__c, variantInfo.details.Subscription_Multiplier__c, startDate, endDate, XC_OrderCreationHelper.getInstance().isFullTerm(order), order.CurrencyIsoCode, (Decimal)input.get(XC_OrderCreationHelper.PARAM_LIST_UNIT_PRICE));
        Decimal unitPrice = XC_OrderCreationHelper.getInstance().getUnitPrice(listPrice, prorateMultiplier);
        Decimal totalPrice = unitPrice * quantity;
        Decimal billableUnitPrice = XC_OrderCreationHelper.getInstance().getBillableUnitPrice(totalPrice, variantInfo.details.SBQQ__BillingFrequency__c, prorateMultiplier, variantInfo.details.SBQQ__SubscriptionTerm__c, variantInfo.details.SBQQ__ChargeType__c);

        // Builds order item
        return new OrderItem(
            // Standard fields
            Description = variantInfo.details.Name,
            EndDate = XC_Constants.SUBSCRIPTION_TYPE_EVERGREEN == variantInfo.details.SBQQ__SubscriptionType__c ? null : endDate,
            ListPrice = variantInfo.parentProductInfo.listPrice,
            OrderId = order.Id,
            PricebookEntryId = variantInfo.parentProductInfo.pricebookEntryId,
            Product2Id = variantInfo.parentProductInfo.productId,
            Quantity = quantity,
            ServiceDate = startDate,
            Type = XC_Constants.ORDER_ITEM_PRODUCT,
            UnitPrice = unitPrice,

            // Custom Fields
            Amended_From_Order_Product__c = XC_Constants.CONTRACT_ACTION_RENEW != (String)input.get(PARAM_CONTRACT_ACTION) ? originalOrderItemId : null,
            Auto_Renew__c = (Boolean)input.get(PARAM_AUTO_RENEW),
            //blng__BillingTreatment__c = this.getBillingTreatment(),
            Payment_Method__c = paymentMethod.Id,
            Product_Variant__c = variantInfo.productId,
            Credited_Order_Product__c = null,
            Renewed_From_Order_Product__c = XC_Constants.CONTRACT_ACTION_RENEW == (String)input.get(PARAM_CONTRACT_ACTION) ? originalOrderItemId : null,
            Transaction_Type__c = (String)input.get(PARAM_TRANS_TYPE),
            CC_Avid_Subscription__c = (String)input.get(PARAM_CC_AVID_SUB),
            From_Asset__c = (String)input.get(PARAM_FROM_ASSET),
            ItemType__c = (String)input.get(PARAM_ITEM_TYPE),
            XC_DRDuty__c = (Decimal)input.get(PARAM_DUTY),
            XC_DRImporterTax__c = (Decimal)input.get(PARAM_IMPORTER_TAX),
            XC_DRTax__c = (Decimal)input.get(PARAM_TAX),
            XC_DRItemId__c = (String)input.get(PARAM_ORDER_ITEM_ID),
            XC_IsCrossgrade__c = XC_Constants.AMENDMENT_TYPE_CROSSGRADE == (String)input.get(PARAM_AMEND_TYPE),
            XC_VariantListPrice__c = listPrice,

            // Billing
            blng__BillableUnitPrice__c = billableUnitPrice,
            blng__BillingAccount__c = order.AccountId,
            blng__BillingRule__c = variantInfo.details.blng__BillingRule__c,
            //blng__InvoiceGroupId__c = paymentMethod.blng__PaymentGatewayToken__c,
            blng__InvoiceGrouping__c = XC_Constants.INVOICE_GROUPING,
            //blng__LegalEntity__c = this.getLegalEntityId(legalEntity),
            blng__RevenueRecognitionRule__c = variantInfo.details.blng__RevenueRecognitionRule__c,
            blng__TaxRule__c = variantInfo.details.blng__TaxRule__c,

            // CPQ
            SBQQ__BillingFrequency__c = variantInfo.details.SBQQ__BillingFrequency__c,
            SBQQ__BillingType__c = variantInfo.details.SBQQ__BillingType__c,
            SBQQ__BundleRoot__c = parentItem,
            SBQQ__ChargeType__c = variantInfo.details.SBQQ__ChargeType__c,
            SBQQ__ContractAction__c = (String)input.get(PARAM_CONTRACT_ACTION),
            SBQQ__DefaultSubscriptionTerm__c = variantInfo.details.SBQQ__SubscriptionTerm__c,
            SBQQ__OrderedQuantity__c = quantity,
            SBQQ__ProductSubscriptionType__c = variantInfo.details.SBQQ__SubscriptionType__c,
            SBQQ__ProrateMultiplier__c = prorateMultiplier,
            SBQQ__RequiredBy__c = parentItem,
            SBQQ__RevisedOrderProduct__c = (String)input.get(PARAM_REVISED_ITEM_ID),
            SBQQ__SubscriptionPricing__c = variantInfo.details.SBQQ__SubscriptionPricing__c,
            SBQQ__SubscriptionTerm__c = variantInfo.getSubscriptionTerm(),
            SBQQ__SubscriptionType__c = variantInfo.details.SBQQ__SubscriptionType__c,
            //SBQQ__TerminatedDate__c = null
            SBQQ__Status__c = 'Activated'
        );
    }
        /**
     * Set order to created state.
     * @param orders the list of orders
     * @return the updated list of orders
     */
    @TestVisible
    private List<Order> markOrderCreated(List<Order> orders) {
        // Iterates over the orders
        for (Order order : orders) {
            order.XC_Created__c = true;
            //if (XC_Constants.DR_STATE_ACCEPTED == this.mDROrder.state) {
               // order.XC_DRState__c = this.mDROrder.state;
                order.XC_DRState__c = 'Complete';
                order.status = 'Activated';
            //}
        }

        return orders;
    }

    public List<OrderItem> createOrderData(){

        this.setCartAndItems(cartId);
        this.mOrderDate = Date.today();
        this.mOrderDatetime =  Datetime.now();
        // Gets the products
        Map<String, XC_OrderCreationHelper.VariantProductInfo> productMap = XC_OrderCreationHelper.getInstance().getVariantProductMap(this.getCartProductIds(), this.mCart.CurrencyIsoCode);
        // Creates the orders
        Order newOrders = this.mapOrder(new Map<String, Object>{
            XC_OrderCreationHelper.PARAM_ACCOUNT => this.mCart.AccountId,
            XC_OrderCreationHelper.PARAM_CURRENCY_CODE => this.mCart.CurrencyIsoCode,
            XC_OrderCreationHelper.PARAM_START_DATE => this.mOrderDate,
            XC_OrderCreationHelper.PARAM_ORDER_DATE => this.mOrderDatetime,
            XC_OrderCreationHelper.PARAM_STORE => this.mCart.WebStoreId,
            XC_OrderCreationHelper.PARAM_DR_ORDER => null,
            XC_OrderCreationHelper.PARAM_ORIG_ORDER => this.mCart.XC_HasAmendmentItem__c || this.mCart.XC_HasRenewalItem__c ? this.mCartItems[0].XC_OriginalOrderItem__r.OrderId : null,
            XC_OrderCreationHelper.PARAM_AMEND_MOTION => this.mCart.XC_HasAmendmentItem__c ? this.mCartItems[0].XC_AmendmentType__c : null
        });
        List<Order> orderlist = new  List<Order>();
        orderlist.add(newOrders);
        insert orderlist;
        // Creates the order items
        this.mOrderItemMap = new Map<String, List<OrderItem>>();
        List<OrderItem> newOrderItems = this.mapOrderItems(orderlist[0], null, productMap);
        if (!Test.isRunningTest()) { insert newOrderItems; }

        // Maps amended product options
        this.mAmendedProductOptionsMap = new Map<String, String>();
        if (this.mCart.XC_HasAmendmentItem__c || this.mCart.XC_HasRenewalItem__c) { this.mapAmendedProductOptions(newOrderItems); }
        // Creates product options
        // List<OrderItem> productOptionItems = XC_ProductOptionHelper.getInstance().getOptionOrderItems(orderlist[0], null, null, newOrderItems, null, this.mCart.CurrencyIsoCode);
        // if (!Test.isRunningTest()) { insert productOptionItems; }
        // Gets product Ids
        Set<String> productIds = getProductIds(newOrderItems);
         // Gets the options
        Map<String, List<ProductOption>> productOptions = getOptions(productIds, this.mCart.CurrencyIsoCode);

         List<OrderItem> ooptionItems = buildOptionLines(orderlist[0], null, null, newOrderItems, this.mAmendedProductOptionsMap, productOptions);
         if (!Test.isRunningTest()) { insert ooptionItems; }

        // Marks orders created
        orderlist = this.markOrderCreated(orderlist);
        if (!Test.isRunningTest()) { update orderlist; }

        List<OrderItem> oItemsReturn = new List<OrderItem>();
        oItemsReturn.addAll(newOrderItems);
        oItemsReturn.addAll(ooptionItems);
        return oItemsReturn;
    }
    
    @TestVisible
    private List<OrderItem> buildOptionLines(Order order, blng__PaymentMethod__c paymentMethod, String legalEntity,
            List<OrderItem> orderItems, Map<String, String> amendOptionMap, Map<String, List<ProductOption>> productOptions) {
        List<OrderItem> retval = new List<OrderItem>();

        // Iterates over the order items looking for options
        for (OrderItem parentOrderItem : orderItems) {
            // Checks for options
            if (null != productOptions.get(parentOrderItem.Product2Id)) {
                // Iterates over options
                for (ProductOption option : productOptions.get(parentOrderItem.Product2Id)) {
                    retval.add(mapOItem(new Map<String, Object>{
                        XC_OrderCreationHelper.PARAM_ORDER => order,
                         XC_OrderCreationHelper.PARAM_PAYMENT_METHOD => paymentMethod,
                         //XC_OrderCreationHelper.PARAM_LEGAL_ENTITY => legalEntity,
                         XC_OrderCreationHelper.PARAM_PRODUCT => option.toVariantProductInfo(),
                         XC_OrderCreationHelper.PARAM_LIST_PRICE => 0,
                         XC_OrderCreationHelper.PARAM_START_DATE => parentOrderItem.ServiceDate,
                         XC_OrderCreationHelper.PARAM_END_DATE => parentOrderItem.EndDate,
                         XC_OrderCreationHelper.PARAM_QUANTITY => parentOrderItem.Quantity,
                         XC_OrderCreationHelper.PARAM_PARENT_ITEM => parentOrderItem.Id,
                         //XC_OrderCreationHelper.PARAM_ORIG_ORDER_ITEM => amendOptionMap.get(parentOrderItem.Id),
                        //  XC_OrderCreationHelper.PARAM_DUTY => 0,
                        //  XC_OrderCreationHelper.PARAM_IMPORTER_TAX => 0,
                        //  XC_OrderCreationHelper.PARAM_TAX => 0,
                         XC_OrderCreationHelper.PARAM_CONTRACT_ACTION => XC_Constants.ORDER_TYPE_NEW == order.Type ? XC_Constants.CONTRACT_ACTION_NEW : XC_Constants.CONTRACT_ACTION_RENEW,
                         XC_OrderCreationHelper.PARAM_AUTO_RENEW => XC_OrderCreationHelper.getInstance().autoRenewal(option.variantProduct.Avid_Subscription_Flag__c, option.variantProduct.SBQQ__SubscriptionType__c),
                         XC_OrderCreationHelper.PARAM_LIST_UNIT_PRICE => 0
                    }));
                 }
            }
        }

        return retval;
    }
    @TestVisible
    private Set<String> getProductIds(List<OrderItem> orderItems) {
        Set<String> retval = new Set<String>();
        for (OrderItem oi : orderItems) {
            retval.add(oi.Product2Id);
        }
        return retval;
    }
    /**
     * Gets product option mapping.
     * @param productIds the product IDs
     * @param currencyIsoCode the currency ISO code
     * @return product to product option mapping.
     */
    @TestVisible
    private Map<String, List<ProductOption>> getOptions(Set<String> productIds, String currencyIsoCode) {
        Map<String, List<ProductOption>> retval = new Map<String, List<ProductOption>>();

        // Gets parent product
        Set<String> parentOptionIds = new Set<String>();
        for (SBQQ__ProductOption__c po : [
            SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__ProductCode__c
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :productIds
        ]) {
            if (!retval.containsKey(po.SBQQ__ConfiguredSKU__c)) {
                retval.put(po.SBQQ__ConfiguredSKU__c, new List<ProductOption>());
            }
            retval.get(po.SBQQ__ConfiguredSKU__c).add(new ProductOption(po.SBQQ__OptionalSKU__c));
            parentOptionIds.add(po.SBQQ__OptionalSKU__c);
        }

        // Gets the pricing
        Map<String, PricebookEntry> priceMap = new Map<String, PricebookEntry>();
        List<PricebookEntry> entries =
            Test.isRunningTest()
                ? [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :parentOptionIds AND IsActive = true AND CurrencyIsoCode = :currencyIsoCode] :
                    [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :parentOptionIds AND Pricebook2.IsStandard = true AND IsActive = true AND CurrencyIsoCode = :currencyIsoCode];
        for (PricebookEntry pbe : entries) {
            priceMap.put(pbe.Product2Id, pbe);
        }

        // Gets variant product
        Map<String, String> variantMap = new Map<String, String>();
        for (ProductAttribute pa : [
            SELECT VariantParentId, ProductId
            FROM ProductAttribute
            WHERE VariantParentId IN :parentOptionIds
        ]) {
            variantMap.put(pa.VariantParentId, pa.ProductId);
        }

        // Gets variant product map
        Map<Id, Product2> variantProductMap = XC_OrderCreationHelper.getInstance().getProductDetails(variantMap.values());

        // Sets option attributes
        for (List<ProductOption> options : retval.values()) {
            for (ProductOption po : options) {
                po.pricebookEntryId = priceMap.get(po.parentProductId).Id;
                po.listPrice = priceMap.get(po.parentProductId).UnitPrice;
                po.variantProductId = variantMap.get(po.parentProductId);
                po.variantProduct = variantProductMap.get(po.variantProductId);
            }
        }

        return retval;
    }

    @TestVisible
    private void mapAmendedProductOptions(List<OrderItem> newOrderItems) {
        // Iterates over the cart items and order items
        for (Integer i = 0; i < newOrderItems.size(); i++) {
            CartItem ci = this.mCartItems[i];
            OrderItem oi = newOrderItems[i];
            this.mAmendedProductOptionsMap.put(oi.Id, ci.XC_OriginalOrderProductOption__c);
        }
    }

    @future(callout=true)
    public static void createAssetsForAutoDepositedSubs(Set<Id> subsIDForAsset){
        List<CC_Avid_Subscription__c> subsForAsset = new List<CC_Avid_Subscription__c>();
        subsForAsset = RP_Avid_Dao_Subscription.getSubscriptions(subsIDForAsset);
        Set<Id> returnIds = new Set<Id>();
        returnIds =  RP_Avid_AutoDepositUtility.createAssetsForautoDeposits(subsForAsset); //This function has callout and DMLs
        System.debug('returnIds==>'+returnIds);
        List<Asset> assetsToUpdate = RP_Avid_ProcessSuccessOutboundUtility.setAssetData(returnIds,subsForAsset,false);
        if (assetsToUpdate.size() > 0) {
            Database.update(assetsToUpdate, false);
        }
    }
        
    }