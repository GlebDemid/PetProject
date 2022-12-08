
@isTest
public class AccountsTest {
    @isTest
    static public void onBeforeUpdateTest() {
        Country__c cntr = new Country__c(Name='TestCountry',
                                        ISO_Country_Code__c='TC');
        Account acc = new Account(Name='TestAccount');
        insert cntr;
        insert acc;
        acc.BillingCountry='TC';
        update acc;
        acc = [SELECT Id, Name, Country__c FROM Account WHERE Name='TestAccount'];
        cntr = [SELECT Id FROM Country__c WHERE Name='TestCountry'];
        System.assertEquals(cntr.Id, acc.Country__c);
        //check with incorect iso code
        acc.BillingCountry='MN';
        update acc;
        acc = [SELECT Id, Name, Country__c FROM Account WHERE Name='TestAccount'];
        System.assertEquals(null, acc.Country__c);
    }
}
