/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-03-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class AccountFileEmailServiceTest {
  
      @testSetup
      static void setupTestData() {
        Trigger_Setting__c allTrigger = new Trigger_Setting__c();
        allTrigger.Name = 'AllTriggers';
        allTrigger.isActive__c = true;
        insert allTrigger;
        Trigger_Setting__c accTrigger = new Trigger_Setting__c();
        accTrigger.Name = 'AccountTrigger';
        accTrigger.isActive__c = true;
        insert accTrigger;
        Trigger_Setting__c conTrigger = new Trigger_Setting__c();
        conTrigger.Name = 'ContactTrigger';
        conTrigger.isActive__c = true;
        insert conTrigger; 
        Trigger_Setting__c conDocTrigger = new Trigger_Setting__c();
        conDocTrigger.Name = 'ContentDocumentLinkTrigger';
        conDocTrigger.isActive__c = true;
        insert conDocTrigger;
        Account testAccount = new Account(Name = 'Test Account');
        testAccount.RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT;
        insert testAccount;
        Attachment testAttachment = new Attachment(
          ParentId = testAccount.Id,
          Name = 'Test Attachment',
          Body = Blob.valueOf('Test Attachment Content')
        );
        insert testAttachment;
          
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion;
          ContentVersion contentVersion2 = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.pdf',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion2;
          ContentVersion contentVersion3 = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.doc',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion3;
          ContentVersion contentVersion4 = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.xls',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion4;
          ContentVersion contentVersion5 = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.txt',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion5;
          ContentVersion contentVersion6 = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.png',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion6;
          ContentVersion contentVersion7 = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.csv',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion7;
          ContentVersion contentVersion8 = new ContentVersion(
                    Title          = 'a picture',
					PathOnClient   = 'Pic.abc',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion8;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = testAccount.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
          
      }
    
    @isTest
    static void buildEmailBodyTest(){
        AccountFileEmailService.buildEmailBody();
    }
    
    @isTest
    static void sendAccountFilesEmailTest(){
        AccountFileEmailService.EmailRequest emailReq = new AccountFileEmailService.EmailRequest();
        emailReq.emailSent = false;
        emailReq.accountId = [Select Id from Account limit 1].Id;
        emailReq.recipientEmail = 'test@kk.com';
        List<AccountFileEmailService.EmailRequest> emailReqList = new List<AccountFileEmailService.EmailRequest>();
        emailReqList.add(emailReq);
        AccountFileEmailService.sendAccountFilesEmail(emailReqList);
    }
    
    @isTest
    static void sendFileEmails(){
        Account acc = [Select Id from Account limit 1];
        List<Id> idList = new List<Id>();
        List<ContentVersion> contentVersionList = [
                    SELECT Id,VersionData, Title, PathOnClient, FileExtension
                    FROM ContentVersion ];
        for(ContentVersion cv : contentVersionList){
            idList.add(cv.Id);
        }
        
        AccountFileEmailService.sendFileEmails(acc.Id, idList);
    }
    
    @isTest
    static void getRelatedFiles(){
        Account acc = [Select Id from Account limit 1];
        
        AccountFileEmailService.getRelatedFiles(acc.Id);
    }

}