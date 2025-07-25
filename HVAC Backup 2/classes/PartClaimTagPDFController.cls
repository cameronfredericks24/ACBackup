public with sharing class PartClaimTagPDFController {
    
    
    public Defective_Product_Item__c defProd{get; set;}
    public String partName {get; set;}
    public String partModel {get; set;}
    
    
    
    
    
    public PartClaimTagPDFController(ApexPages.StandardController controller) {
        this.defProd = (Defective_Product_Item__c)controller.getRecord();
        system.debug('def '+this.defProd );
        
        this.defProd =[select Id,Part_Request__r.Obligation__c,Part_Request__r.Ticket_Number__c,Defective_Category__c ,Part_Claim_Number_Text__c ,
                       Channel_Partner__r.Name,Part_Request__r.RMR_No__c,Branch__c, Product_Model__c,Product_Name_Text__c,Part_Request__r.WorkOrder.Defect__c,
                       Part_Request__r.Customer_Name__c,Part_Request__r.Customer_Code__c, Defective_Part_Serial_Number__c,CP_Code__c,
                       Defective_part_comments__c,PCT_Number__c,Part_Request__r.Delivery_Challan_Date__c,
                       Branch_name__c,Part_Request__r.Material_Code__c,Part_Request__r.Model_Number__c,Part_Request__r.Product__r.Name
                       From Defective_Product_Item__c where id=:defProd.id ];   
        if(this.defProd.Defective_Category__c =='RMR'){
            this.partName = this.defProd.Part_Request__r.Product__r.Name;
            this.partModel =this.defProd.Part_Request__r.Model_Number__c;
        }else{
           this.partName =this.defProd.Product_Name_Text__c;
            this.partModel =this.defProd.Product_Model__c;
        }
        
        
        
    }
    public PageReference generateAndAttachPDF() {
        
        PageReference pageRef;
        try {
            
            system.debug('attach1' + defProd.id);
            
            
            PageReference page = new PageReference('/apex/RMRChallan?id=' + defProd.id);
            page.getParameters().put('Id', defProd.id);
             Blob contentBlob;
            if(Test.isRunningTest()) {
                    contentBlob= Blob.valueOf('Generate Pdf');
                } else {
                   
                        contentBlob = pageRef.getContentAsPDF();
                       
                }
           
            ContentVersion cv = new ContentVersion();
            cv.VersionData = contentBlob;
            cv.Title = 'RMR Challan Pdf';
            cv.PathOnClient = 'RMRChallan.pdf' ;
            insert cv;                
            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'v';
            cdl.LinkedEntityId = defProd.Id;
            cdl.Visibility ='AllUsers';
            insert cdl;
            // Redirect to the same page or a success page
            pageRef = new PageReference('/channelpartnerportal/s/detail/' + defProd.Id);
            pageRef.setRedirect(true);
            
        } catch (VisualforceException e) {
            System.debug('VisualforceException: ' + e.getMessage());
            ApexPages.addMessages(e);
        } 
        return pageRef;
    }
    
   /* public PageReference save(){
        PageReference pdfPage = Page.RMRChallan;
        pdfPage.getParameters().put('Id', defProd.id);
        pdfPage.setRedirect(true);
        PageReference ret = null;
        
        try {
            Blob pdfBlob = Test.isRunningTest()
                ? Blob.valueOf('Test PDF Content')
                : pdfPage.getContentAsPDF();
            
            ContentVersion cv = new ContentVersion(
                Title = 'Quote ' + defProd.id,
                PathOnClient = 'Quote ' +defProd.id + '.pdf',
                VersionData = pdfBlob,
                FirstPublishLocationId = defProd.id
            );
            insert cv;
            System.debug('ContentVersion inserted: ' + cv);
            
            ret = new ApexPages.StandardController([SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id]).view();
        } catch (Exception e) {
            ApexPages.addMessages(e);
            System.debug('An exception occurred: ' + e.getMessage());
        }
        System.debug('Returning PageReference: ' + ret);
        return ret;
    }*/
    
}