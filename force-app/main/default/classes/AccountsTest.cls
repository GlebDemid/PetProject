@isTest
public class AccountsTest {
    @TestSetup
    static void makeData(){
        List<Country__C> cntrs = new List<Country__C>();
        for (Integer i = 0; i < 5; i++) {
            Country__c cntr = new Country__c(Name='Poland '+i,
                    ISO_Country_Code__c='PL '+i);
            cntrs.add(cntr);
        }
        List<Account> accs = new List<Account>();
        for (Integer k = 0; k < 50; k++) {
            Account acc = new Account(Name='Poland account '+k);
            accs.add(acc);
        }
        insert cntrs;
        insert accs;
    }


    @isTest
    static public void onBeforeUpdateTest() {        
        Account accUpdate = [SELECT BillingCountry FROM Account LIMIT 1];
        
        System.Test.startTest();
        accUpdate.BillingCountry='PL 1';
        update accUpdate;

        Country__c cntr = [SELECT Id FROM Country__c WHERE Name='Poland 1'];
        accUpdate = [SELECT Id, Name, Country__c FROM Account WHERE BillingCountry='PL 1'];
        
        //checking that account country was changed based on ISO code after update
        System.assertEquals(cntr.Id, accUpdate.Country__c);
        
        accUpdate.BillingCountry='MN';
        update accUpdate;
        System.Test.stopTest();

        accUpdate = [SELECT Id, Name, Country__c FROM Account WHERE BillingCountry='MN'];
        
        //check with incorect iso code
        System.assertEquals(null, accUpdate.Country__c);
    }

    @isTest
    static public void onBeforeInsertTest() {
        List<Account> accountsInsert = new List<Account>(); 
        for (Integer j = 0; j < 10 ; j++) {
            Account accInsert = new Account(Name='Argentina account '+j, 
                    BillingCountry='PL 2');
            accountsInsert.add(accInsert);
        }
        System.Test.startTest();
        insert accountsInsert;
        System.Test.stopTest();

        Country__c cntr = [SELECT Id FROM Country__c WHERE Name='Poland 2'];
        Account argentinaAcc = [SELECT Country__c FROM Account WHERE Name LIKE 'Argentina account 5'];
        
        //checking that account country was changed based on ISO code after insert
        System.assertEquals(cntr.Id, argentinaAcc.Country__c);
    }

}