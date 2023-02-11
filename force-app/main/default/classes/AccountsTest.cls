@isTest
private class AccountsTest {
    @TestSetup
    private static void makeData(){
        List<Country__C> cntrs = new List<Country__C>();
        Country__c polandCountry = new Country__c(
                Name='Poland',
                ISO_Country_Code__c='PL');
        cntrs.add(polandCountry);
        Country__c armeniaCountry = new Country__c(
                Name='Armenia',
                ISO_Country_Code__c='AR');
        cntrs.add(armeniaCountry);
        Country__c nigeriaCountry = new Country__c(
                Name='Nigeria',
                ISO_Country_Code__c='NG');
        cntrs.add(nigeriaCountry);
        Country__c slovakiaCountry = new Country__c(
                Name='Slovakia',
                ISO_Country_Code__c='SL');
        cntrs.add(slovakiaCountry);
        Country__c cyprusCountry = new Country__c(
                Name='Cypr',
                ISO_Country_Code__c='CP');
        cntrs.add(cyprusCountry);
        List<Account> accs = new List<Account>();
        for (Integer k = 0; k < 50; k++) {
            Account acc = new Account(Name='Test account '+k);
            accs.add(acc);
        }
        insert cntrs;
        insert accs;
    }


    @isTest
    private static void onBeforeUpdateTest() {        
        Account accUpdate = [SELECT BillingCountry FROM Account LIMIT 1];
        
        System.Test.startTest();
        accUpdate.BillingCountry='PL';
        update accUpdate;

        Country__c cntr = [SELECT Id FROM Country__c WHERE Name='Poland'];
        accUpdate = [SELECT Id, Name, Country__c FROM Account WHERE BillingCountry='PL'];
        
        
        Assert.areEqual(cntr.Id, accUpdate.Country__c, 
                'checking that account country was changed based on ISO code after update');
        
        accUpdate.BillingCountry='MN';
        update accUpdate;
        System.Test.stopTest();

        accUpdate = [SELECT Id, Name, Country__c FROM Account WHERE BillingCountry='MN'];
                
        Assert.areEqual(null, accUpdate.Country__c, 'check with incorect iso code');
    }

    @isTest
    private static void onBeforeInsertTest() {
        List<Account> accountsInsert = new List<Account>(); 
        for (Integer j = 0; j < 10 ; j++) {
            Account accInsert = new Account(Name='Argentina account '+j, 
                    BillingCountry='PL');
            accountsInsert.add(accInsert);
        }
        System.Test.startTest();
        insert accountsInsert;
        System.Test.stopTest();

        Country__c cntr = [SELECT Id FROM Country__c WHERE Name='Poland'];
        Account argentinaAcc = [SELECT Country__c FROM Account WHERE Name LIKE 'Argentina account 5'];
        
        Assert.areEqual(cntr.Id, argentinaAcc.Country__c, 
                'checking that account country was changed based on ISO code after insert');
    }
}