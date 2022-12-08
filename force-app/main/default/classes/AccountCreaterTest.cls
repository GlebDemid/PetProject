@isTest
private class AccountCreaterTest {
    @isTest
    static void nRandNumbInRangeTest() {
        Set<Integer> allValues = new Set<Integer>();
        //check summ of all values and that all values unique
        List<Integer> randomNumbers = AccountCreater.nRandNumbInRange(5, 200);
        Integer summ = 0;
        for (Integer numb : randomNumbers) {
            summ += numb;
            allValues.add(numb);
        }
        System.assertEquals(200, summ);
        System.assertEquals(5, allValues.size());
    }
    
    @isTest
    static void aAccountsTest() {
        List<Country__c> countrys = new List<Country__c>();
        for (Integer i = 0; i<5 ; i++) {
            Country__c newCountry = new Country__c(Name='Test'+i,
                                                    ISO_Country_Code__c='T'+i);
            countrys.add(newCountry); 
        }
        AccountCreater ac = new AccountCreater();
        Test.startTest();
            insert countrys;
            ac.aAccounts(20);
        Test.stopTest();
        List<Account> allNewAccounts = [SELECT Id FROM Account]; 
        System.assertEquals(20, allNewAccounts.size());
    }
}
