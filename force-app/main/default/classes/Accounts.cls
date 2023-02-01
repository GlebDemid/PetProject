public with sharing class Accounts extends fflib_SObjectDomain {
    public Accounts(List<Account> sObjectList) {
        super(sObjectList);
    }
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Accounts(sObjectList);
        }
    }

    public override void onBeforeUpdate(map<id, SObject> existing) {
        changingAccCountryBasedOnISO();        
    }

    public override void onBeforeInsert() {
        changingAccCountryBasedOnISO();
    }

    private void changingAccCountryBasedOnISO() {
        Map<String, Id> isoCountryMap = AccountService.MAP_ISO_COUNTRY;
        for (Account acc: (List<Account>) records) {
            acc.Country__c = isoCountryMap.get(acc.BillingCountry);
        }
    }
}