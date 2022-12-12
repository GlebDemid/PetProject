public with sharing class AccountOwnerChanger {
    public void onLeadOwners() {
        List<Account> newAccs = [SELECT id, Country__r.Region__r.Sales_Team__r.Lead__c,Owner__c 
        FROM Account WHERE CreatedDate = TODAY AND Owner__c = null];
        for (Account newAcc : newAccs) {
            newAcc.Owner__c = newAcc.Country__r.Region__r.Sales_Team__r.Lead__c;
        }
        update newAccs;
    }
}
