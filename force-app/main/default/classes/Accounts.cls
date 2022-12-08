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
        List<String> isoCodes = new List<String>();
        List<Account> changedAccs = new List<Account>();
        List<Account> accsWithCountry = new List<Account>();
        for(Account newAcc: (List<Account>) records){
            Account oldAcc = (Account)Trigger.oldMap.get(newAcc.Id);
            if (oldAcc.BillingCountry != newAcc.BillingCountry) {
                String isoCode = newAcc.BillingCountry;
                changedAccs.add(newAcc);
                isoCodes.add(isoCode);
            } 
        }

        List<Country__c> countrys = [SELECT id, ISO_Country_Code__c FROM Country__C WHERE ISO_Country_Code__c IN :isoCodes];
        
        for (Account acc: changedAccs) {
            for (Country__c country : countrys) {
                if (acc.BillingCountry == country.ISO_Country_Code__c) {
                    acc.Country__c = country.Id;
                    accsWithCountry.add(acc);
                }
            }
        }

        for (Account acc: changedAccs) {
            if (!accsWithCountry.contains(acc)) {
                acc.Country__c = null;
            }
        }
        
    }
    
}