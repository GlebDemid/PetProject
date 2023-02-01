@isTest
private class AccountServiceTest {
    @TestSetup
    static void makeData(){
        List<Country__C> cntrs = new List<Country__C> {
                new Country__c(
                        Name='Poland',
                        ISO_Country_Code__c='PL'),       
                new Country__c(
                        Name='Armenia',
                        ISO_Country_Code__c='AR'),        
                new Country__c(
                        Name='Nigeria',
                        ISO_Country_Code__c='NG'),        
                new Country__c(
                        Name='Slovakia',
                        ISO_Country_Code__c='SL'),        
                new Country__c(
                        Name='Cypr',
                        ISO_Country_Code__c='CP')
        };
        Database.insert(cntrs);
    }

    @isTest
    static private void mapIsoCountryTest() {
        Map<String, Id> mutableMapISOCountry = new Map<String, Id>();
        for (Country__c oneCountry : [SELECT id, ISO_Country_Code__c FROM Country__c]) {
            mutableMapISOCountry.put(oneCountry.ISO_Country_Code__c, oneCountry.Id);
        }
        Assert.areEqual(mutableMapISOCountry, AccountService.MAP_ISO_COUNTRY, 
                'map is have to be full of test data');
    }
}