public with sharing class ChangeAccountOwnerBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private Map<Id, Region__c> regionsWithSalesTeam;
    private Map<String, Account_Allocation__c> mapRegionAllocation = new Map<String, Account_Allocation__c>();
    


    public void execute(SchedulableContext ctx) {
        database.executebatch(new ChangeAccountOwnerBatch());
    }



    public Database.QueryLocator start(Database.BatchableContext bc) {
        regionsWithSalesTeam = new Map<Id, Region__c> ([
                SELECT id, Name,
                    (SELECT MD_to_Sales_Team__r.Lead__r.id 
                    FROM Sales_Team_Assignments__r
                    ORDER BY MD_to_Sales_Team__r.Lead__r.id) 
                FROM Region__c]);
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
        
        if (allExistAccountAllocation!=null) {
            for (Account_allocation__c oneAccountAllocation : allExistAccountAllocation) {
                regionWithAllocation.add(oneAccountAllocation.Name);
                mapRegionAllocation.put(oneAccountAllocation.Name, oneAccountAllocation);            
            }
        }
        
        for (Region__c oneRegion : regionsWithSalesTeam.values()) {            
            if (!regionWithAllocation.contains(oneRegion.Name)) {
                Account_allocation__c newAccountAllocation = new Account_allocation__c(
                    Name = oneRegion.Name);
                mapRegionAllocation.put(oneRegion.Name, newAccountAllocation);
            }
        }
    }


    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        for (Account acc : scope) {           
            Region__c oneRegion = regionsWithSalesTeam.get(acc.Country__r.Region__r.Id);
            Id salesTeamLeadId;
            Account_allocation__c alocationWithCurrentRegion = mapRegionAllocation.get(oneRegion.Name);                    
            if (oneRegion.Sales_Team_Assignments__r.size() == 1 ) {
                salesTeamLeadId = oneRegion.Sales_Team_Assignments__r.get(0).
                        MD_to_Sales_Team__r.Lead__r.Id;
                acc.Owner__c = salesTeamLeadId;
            }                    
            if (oneRegion.Sales_Team_Assignments__r.size() > 1 ) {
            salesTeamLeadId = chooseOpenToWorkLead(oneRegion.Sales_Team_Assignments__r, 
                    alocationWithCurrentRegion);
            acc.Owner__c = salesTeamLeadId;                   
            alocationWithCurrentRegion.last_assignment_lead__c = salesTeamLeadId;
            }
        }
        update scope;
    }

    private Id chooseOpenToWorkLead(List<Sales_Team_Assignment__c> salesTeamAssigments, Account_allocation__c alocationWithCurrentRegion) {
        List<Id> allLeads = new List<Id>();        
        for (Sales_Team_Assignment__c salesAssigment : salesTeamAssigments) {
            allLeads.add(salesAssigment.MD_to_Sales_Team__r.Lead__r.Id);            
        }
        Id lastLeadId = (Id)alocationWithCurrentRegion.last_assignment_lead__c;
        Integer indexEmployee = allLeads.indexOf(lastLeadId);        
        if (lastLeadId == null || allLeads.size()-1 == indexEmployee) {
            return allLeads.get(0);
        }
        return allLeads.get(indexEmployee+1);
    }
    


    public void finish(Database.BatchableContext bc)  {
        List<Account_allocation__c> allAccountAllocation = mapRegionAllocation.values();
        upsert allAccountAllocation;
    }
}