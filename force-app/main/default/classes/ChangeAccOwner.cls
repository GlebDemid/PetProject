public class ChangeAccOwner implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Country__r.Region__r.Id, Owner__r.Id' + 
        ' FROM Account' +
        ' WHERE Owner__c = null' +
        ' AND CreatedDate = TODAY';
        return Database.getQueryLocator(query);
    }


    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Id> regionsInScope = new List<Id>();         
        for (Account acc : scope) {
            regionsInScope.add(acc.Country__r.Region__r.Id);
        }

        List<Region__c> regionsWithSalesTeam = [
                SELECT id,
                (SELECT MD_to_Sales_Team__r.Lead__r.id 
                FROM Sales_Team_Assignments__r) 
                FROM Region__c
                WHERE id IN: regionsInScope];
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


    public void finish(Database.BatchableContext bc)  {

    }

    private Map<Account, Id> connectAccountsWithEmployees(List<Account> scope, List<Region__c> regionsWithSalesTeam) {
        Map<Account, Id> accWithSalesTeamOwners = new Map<Account, Id>();
        for (Account acc : scope) {
            for (Region__c region : regionsWithSalesTeam) {
                if (acc.Country__r.Region__c == region.Id) {
                    if (region.Sales_Team_Assignments__r.size() == 1 ) {
                        Id salesTeamLead = region.Sales_Team_Assignments__r.get(0).
                                MD_to_Sales_Team__r.Lead__r.Id;
                        accWithSalesTeamOwners.put(acc, 
                                salesTeamLead);
                    } else {
                        if (region.Sales_Team_Assignments__r.size()>1) {
                        Id openLead = chooseOpenToWorkLead(region.Sales_Team_Assignments__r);
                        accWithSalesTeamOwners.put(acc, 
                                openLead);
                        } 
                    }
                }
            }
        }
        return accWithSalesTeamOwners;
    }
    
    private Id chooseOpenToWorkLead(List<Sales_Team_Assignment__c> salesTeamAssigments) {
        List<Id> leads = new List<Id>();
        for (Sales_Team_Assignment__c salesAssigment : salesTeamAssigments) {
            leads.add(salesAssigment.MD_to_Sales_Team__r.Lead__r.Id);
        }
        List<AggregateResult> leadWithoutWork = [SELECT Owner__c Lead, COUNT(id)
                FROM Account
                WHERE Owner__C in: leads
                GROUP BY Owner__c
                ORDER BY COUNT(id) 
                Limit 1];       
        return (Id)leadWithoutWork[0].get('Lead');
    }
    
    
    public void execute(SchedulableContext ctx) {
        database.executebatch(new ChangeAccOwner());
    }
}