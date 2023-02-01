public with sharing class ChangeAccountOwnerBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private List<Region__c> regionsWithSalesTeam = new List<Region__c>();
    private Map<String, Account_Allocation__c> mapRegionAllocation = new Map<String, Account_Allocation__c>();
    


    public void execute(SchedulableContext ctx) {
        database.executebatch(new ChangeAccountOwnerBatch());
    }



    public Database.QueryLocator start(Database.BatchableContext bc) {
        regionsWithSalesTeam = [
                SELECT id,
                Name,
                    (SELECT MD_to_Sales_Team__r.Lead__r.id 
                    FROM Sales_Team_Assignments__r) 
                FROM Region__c];
        createNewAccountAllocation();
        String query = 'SELECT Id, Country__r.Region__r.Id, Owner__r.Id' + 
        ' FROM Account' +
        ' WHERE Owner__c = null' +
        ' AND CreatedDate = TODAY';
        return Database.getQueryLocator(query);
    }



    private void createNewAccountAllocation(){        
        List<Account_allocation__c> allExistAccountAllocation =[SELECT Name, last_assignment_lead__c 
                FROM Account_allocation__c];
        Set<String> regionWithAllocation = new Set<String>();
        List<Account_allocation__c> allNewAccountAllocation = new List<Account_allocation__c>();
        
        if (allExistAccountAllocation!=null) {
            for (Account_allocation__c oneAccountAllocation : allExistAccountAllocation) {
                regionWithAllocation.add(oneAccountAllocation.Name);
                mapRegionAllocation.put(oneAccountAllocation.Name, oneAccountAllocation);            
            }
        }
        
        for (Region__c region : regionsWithSalesTeam) {            
            if (!regionWithAllocation.contains(region.Name)) {
                Account_allocation__c newAccountAllocation = new Account_allocation__c(
                    Name = region.Name);
                allNewAccountAllocation.add(newAccountAllocation);
                mapRegionAllocation.put(region.Name, newAccountAllocation);
            }
        }

        insert allNewAccountAllocation;        
    }


    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Map<Account, Id> accWithSalesTeamOwners = 
                connectAccountsWithEmployees(scope, regionsWithSalesTeam);
        List<Account> accounts = new List<Account>();
        if (accWithSalesTeamOwners != null) {
            for (Account account: accWithSalesTeamOwners.keyset()) {
                account.Owner__c = accWithSalesTeamOwners.get(account);
                accounts.add(account);
            }
        }
        update accounts;
    }



    private Map<Account, Id> connectAccountsWithEmployees(List<Account> scope, List<Region__c> regionsWithSalesTeam) {
        Map<Account, Id> accWithSalesTeamOwners = new Map<Account, Id>();
        System.debug(regionsWithSalesTeam);
        for (Region__c region : regionsWithSalesTeam) {
            System.debug(region.Sales_Team_Assignments__r.size());
        }
        for (Account acc : scope) {
            for (Region__c region : regionsWithSalesTeam) {
                if (acc.Country__r.Region__c == region.Id) {
                    Id salesTeamLead;
                    Account_allocation__c alocationWithCurrentRegion = mapRegionAllocation.get(region.Name);
                    
                    if (region.Sales_Team_Assignments__r.size() == 1 ) {
                        salesTeamLead = region.Sales_Team_Assignments__r.get(0).
                                MD_to_Sales_Team__r.Lead__r.Id;                        
                    } 
                    
                    if (region.Sales_Team_Assignments__r.size() > 1 ) {
                    salesTeamLead = chooseOpenToWorkLead(region.Sales_Team_Assignments__r, 
                            alocationWithCurrentRegion);
                    }
                    accWithSalesTeamOwners.put(acc, salesTeamLead);                    
                    alocationWithCurrentRegion.last_assignment_lead__c = salesTeamLead;                    
                }
            }
        }
        return accWithSalesTeamOwners;
    }
    


    private Id chooseOpenToWorkLead(List<Sales_Team_Assignment__c> salesTeamAssigments, Account_allocation__c alocationWithCurrentRegion) {
        List<Id> leads = new List<Id>();
        
        for (Sales_Team_Assignment__c salesAssigment : salesTeamAssigments) {
            leads.add(salesAssigment.MD_to_Sales_Team__r.Lead__r.Id);
        }

        leads.sort();
        Id lastLead = (Id)alocationWithCurrentRegion.last_assignment_lead__c;
        Integer indexEmployee = leads.indexOf(lastLead);
        
        if (lastLead == null || leads.size()-1 == indexEmployee) {
            return leads.get(0);
        }
        return leads.get(indexEmployee+1);
    }
    


    public void finish(Database.BatchableContext bc)  {
        List<Account_allocation__c> allAccountAllocation = mapRegionAllocation.values();
        update allAccountAllocation;
    }
}