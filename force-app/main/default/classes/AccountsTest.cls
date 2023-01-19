@isTest
public class AccountsTest {
    @TestSetup
    static void makeData(){
        Country__c cntr = new Country__c(Name='Poland',
                                        ISO_Country_Code__c='PL');
        Account acc = new Account(Name='Poland account');
        insert cntr;
        insert acc;
    }


    @isTest
    static public void onBeforeUpdateTest() {
        Account accUpdate = [SELECT BillingCountry FROM Account LIMIT 1];
        
        System.Test.startTest();
        accUpdate.BillingCountry='PL';
        update accUpdate;

        Country__c cntr = [SELECT Id FROM Country__c WHERE Name='Poland'];
        accUpdate = [SELECT Id, Name, Country__c FROM Account WHERE Name='Poland account'];
        
        //checking that account country was changed based on ISO code after update
        System.assertEquals(cntr.Id, accUpdate.Country__c);
        
        accUpdate.BillingCountry='MN';
        update accUpdate;
        System.Test.stopTest();

        accUpdate = [SELECT Id, Name, Country__c FROM Account WHERE Name='Poland account'];
        
        //check with incorect iso code
        System.assertEquals(null, accUpdate.Country__c);
    }

    @isTest
    static public void onBeforeInsertTest() {
        Account accInsert = new Account(Name='Argentina account', 
                BillingCountry='PL');
        System.Test.startTest();
        insert accInsert;
        System.Test.stopTest();

        Country__c cntr = [SELECT Id FROM Country__c WHERE Name='Poland'];
        accInsert = [SELECT Country__c FROM Account WHERE Name='Argentina account'];
        
        //checking that account country was changed based on ISO code after insert
        System.assertEquals(cntr.Id, accInsert.Country__c);
    }

}