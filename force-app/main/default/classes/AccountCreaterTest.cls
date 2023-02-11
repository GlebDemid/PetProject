@isTest
private class AccountCreaterTest {
    @TestSetup
    static private void makeData(){
        List<Country__c> countrys = new List<Country__c>();
        List<String> countryNames = new List<String>{'Brasilia', 'Armenia', 'Germany', 'Pakistan', 'Nigeria'};
        List<String> countryISO = new List<String>{'BR', 'AR', 'GM', 'PS', 'NI'};
        for (Integer i = 0; i<5 ; i++) {
            Country__c newCountry = new Country__c(Name = countryNames[i],
                    ISO_Country_Code__c = countryISO[i]);
            countrys.add(newCountry); 
        }
        insert countrys;
    }

    @isTest
    static private void createTest() {
        
        AccountCreater accCreate = new AccountCreater();
        System.Test.startTest();
            try{
                accCreate.create(4);
            } catch (IllegalArgumentException error) {
                /*check negative result: if an error is thrown when the number of accounts 
                is less than the number of countries*/
                System.assertEquals('Number of Accounts can\'t be lower than number of countries', 
                        error.getMessage());
            }
            accCreate.create(20);
        System.Test.stopTest();
        List<Account> allNewAccounts = [
                SELECT Id
                FROM Account]; 
        //checking that all required accounts have been created
        System.assertEquals(20, allNewAccounts.size());
    }
}