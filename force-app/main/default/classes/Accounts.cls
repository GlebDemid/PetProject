public class Accounts extends fflib_SObjectDomain {
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
        List<String> isoCodes = new List<String>();
        List<Account> changedAccs = new List<Account>();

        if (Trigger.isUpdate) {
            for(Account newAcc: (List<Account>) records){
                Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);
                if (oldAcc.BillingCountry != newAcc.BillingCountry) {
                    String isoCode = newAcc.BillingCountry;
                    changedAccs.add(newAcc);
                    isoCodes.add(isoCode);
                } 
            }
        }   

        if (Trigger.isInsert) {
            for(Account newAcc: (List<Account>) records){
                String isoCode = newAcc.BillingCountry;
                isoCodes.add(isoCode);
            }
            changedAccs = (List<Account>) records;
        }
        

        List<Country__c> countrys = [SELECT id, ISO_Country_Code__c 
                FROM Country__C 
                WHERE ISO_Country_Code__c IN :isoCodes];
        
        Map<String, Country__c> ISOAndItCountry = new Map<String,Country__c>();
        for (Country__c country : countrys) {
            ISOAndItCountry.put(country.ISO_Country_Code__c, country);
        }

        
        List<Account> accsWithCountry = new List<Account>();
        for (Account acc: changedAccs) {
            if (ISOAndItCountry.containsKey(acc.BillingCountry)) {
                acc.Country__c = ISOAndItCountry.get(acc.BillingCountry).Id;
                accsWithCountry.add(acc);
            } else {
                acc.Country__c = null;
            }
        }
    }
}