@isTest
private class ChangeAccountOwnerBatchTest {
    
    @TestSetup
    static void makeData(){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Sales_Team__c.SObjectType,
                Employee__c.SObjectType
            }
        );
        fflib_SObjectUnitOfWork uowTwo = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Region__c.SObjectType,
                Account_allocation__c.SObjectType,
                Country__c.SObjectType,
                Account.SObjectType,
                Sales_Team_Assignment__c.SObjectType,
                Sales_Team__c.SObjectType
            }
        );

        
        List<Region__c> fiveRegions = new List<Region__c>();
        List<Account> allAccounts = new List<Account>();
        Integer numberForAccount = 0;
        Integer numberForCountry = 0;


        for (Integer k = 0 ; k < 5; k++) {
            Region__c region = new Region__c(Name='Region '+ k);
            uowTwo.registerNew(region);
            fiveRegions.add(region);
            Account_allocation__c accAlocation = new Account_allocation__c(
                Name = region.Name);
            if (k!=4) {
                uowTwo.registerNew(accAlocation);
            }
            
            for (Integer n = 0; n < 4; n++){
                Country__c country = new Country__c(Name ='Country №'+ numberForCountry,
                        ISO_Country_Code__c='ISO'+numberForCountry);
                numberForCountry++;
                uowTwo.registerNew(country, Country__c.Region__c, region);
                
                for (Integer m = 0; m < 10; m++) {
                    Account acc = new Account(Name='Account №'+ numberForAccount,
                            BillingCountry=country.ISO_Country_Code__c);
                    numberForAccount++;
                    uowTwo.registerNew(acc, Account.Country__c, country);
                    allAccounts.add(acc);
                }
            }            
        }


        Region__c regionWithOneSalesTeamAsigm = fiveRegions.remove(4);
        List<Sales_Team__c> allSalesTeams = new List<Sales_Team__c>();
        List<Employee__c> allLeads = new List<Employee__c>();
        

        Integer countOfRegion = 0;
        for (Integer i = 0; i < 100; i++) {
            Sales_Team__c saleTM = new Sales_Team__c(Name='SalesTeam №' + i);
            uow.registerNew(saleTM);
            allSalesTeams.add(saleTM);
            for (Integer j=0; j < 3; j++) {
                Employee__c empl= new Employee__c(Name='Jon '+ i,
                        Last_Name__c='Adams '+ j);
                uow.registerNew(empl, Employee__c.Sales_Team__c, saleTM);
                if (j==1){
                    allLeads.add(empl);
                }
            }
            Sales_Team_Assignment__c salesTeamAssigment = new Sales_Team_Assignment__c();
            uowTwo.registerNew(salesTeamAssigment, 
                    Sales_Team_Assignment__c.MD_to_Region__c, fiveRegions.get(countOfRegion));
            uowTwo.registerRelationship(salesTeamAssigment, 
                    Sales_Team_Assignment__c.MD_to_Sales_Team__c, saleTM);
            if (countOfRegion < 3) {
                countOfRegion++;
            } else{
                countOfRegion=0;
            }
            if (math.mod(i, 2)==0) {
                Sales_Team_Assignment__c evenSalesTeamAssigment = new Sales_Team_Assignment__c();
                uowTwo.registerNew(evenSalesTeamAssigment, 
                    Sales_Team_Assignment__c.MD_to_Region__c, fiveRegions.get(countOfRegion));
                 uowTwo.registerRelationship(evenSalesTeamAssigment, 
                    Sales_Team_Assignment__c.MD_to_Sales_Team__c, saleTM);
            }
            if (i==0) {
                Sales_Team_Assignment__c onlyOneSTA = new Sales_Team_Assignment__c();
                uowTwo.registerNew(onlyOneSTA, 
                    Sales_Team_Assignment__c.MD_to_Region__c, regionWithOneSalesTeamAsigm);
                 uowTwo.registerRelationship(onlyOneSTA, 
                    Sales_Team_Assignment__c.MD_to_Sales_Team__c, saleTM);
            }
        }

        uow.commitWork();
        
        for (Integer x=0; x < allSalesTeams.size(); x++) {
            uowTwo.registerDirty(allSalesTeams.get(x), Sales_Team__c.Lead__c, allLeads.get(x));
            uowTwo.registerRelationship(allAccounts.get(x), Account.Owner__c, allLeads.get(x));
            if (x == 90) {
                for (Integer p=0; p < 3; p++){
                    uowTwo.registerRelationship(allAccounts.get(100+p), Account.Owner__c, allLeads.get(x));
                }
            }
        }

        uowTwo.commitWork(); 
    }
    
    @isTest
    static private void changeAccountOwnerTest() {
        List<Account> acc = new List<Account>();
        acc = [SELECT id, Owner__c
                FROM Account 
                WHERE Owner__c=null
                ];
        Account_allocation__c allocation = [
                SELECT Name, last_assignment_lead__c 
                FROM Account_allocation__c 
                WHERE Name = 'Region 2'];
        
        
        System.Assert.AreEqual(97, acc.size(), 
                'checking that accounts without owner have been inserted');
        
        System.Test.startTest();
        ChangeAccountOwnerBatch classInstant = new ChangeAccountOwnerBatch();
        Id batchId = Database.executeBatch(classInstant);        
        System.Test.stopTest();
        
        acc = [SELECT id, Owner__c 
                FROM Account 
                WHERE Owner__c=null];
        
        System.Assert.AreEqual(0, acc.size(),
                'checking of the absence of accounts without an owner');

        Sales_Team_Assignment__c onlyOneSTA = [SELECT MD_to_Region__r.Name, MD_to_Sales_Team__r.Lead__c 
                FROM Sales_Team_Assignment__c 
                WHERE MD_to_Region__r.Name = 'Region 4'];
        Region__c regionWithOneSTA = onlyOneSTA.MD_to_Region__r;
        Account accWithOneSTA = [SELECT Owner__c, Country__r.Region__c 
                FROM Account 
                WHERE Country__r.Region__c = :regionWithOneSTA.Id
                LIMIT 1];
        
        System.Assert.AreEqual(onlyOneSTA.MD_to_Sales_Team__r.Lead__c, accWithOneSTA.Owner__c,
                'checking that account with one Sales Team Assignment has the correct owner');
        
        List<Account> accWithPreOwner = [SELECT Owner__c 
                FROM Account 
                WHERE Owner__r.Name = 'Jon 90' 
                AND Owner__r.Last_Name__c ='Adams 1'];
        
        System.Assert.AreEqual(4, accWithPreOwner.size(), 
                'checking for the correctness of the Sales Team lead selection, if there are several of them');

        Account_allocation__c allocation2 = [
                SELECT Name, last_assignment_lead__c 
                FROM Account_allocation__c 
                WHERE Name = 'Region 2'];
        
        System.Assert.AreNotEqual(allocation.last_assignment_lead__c, allocation2.last_assignment_lead__c, 
                'last assignment lead in account allocation must change after butch');
    }
}