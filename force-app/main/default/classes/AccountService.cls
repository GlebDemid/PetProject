public with sharing class AccountService {
    public static final Map<String, Id> MAP_ISO_COUNTRY {
        get { 
            Map<String, Id> mutableMapISOCountry = new Map<String, Id>();
            for (Country__c oneCountry : [SELECT id, ISO_Country_Code__c FROM Country__c]) {
                mutableMapISOCountry.put(oneCountry.ISO_Country_Code__c, oneCountry.Id);
            }
            return mutableMapISOCountry;
        }
        private set;
    }
}