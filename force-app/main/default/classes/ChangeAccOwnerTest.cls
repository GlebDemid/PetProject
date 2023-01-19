@isTest
private class ChangeAccOwnerTest {
    
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
            Region__c region = new Region__c(Name='Region №'+ k);
            uowTwo.registerNew(region);
            for (Integer n = 0; n < 4; n++){
                Country__c country = new Country__c(Name ='Country №'+ numberForCountry);
                numberForCountry++;
                uowTwo.registerNew(country, Country__c.Region__c, region);
                for (Integer m = 0; m < 10; m++) {
                    Account acc = new Account(Name='Account №'+ numberForAccount);
                    numberForAccount++;
                    uowTwo.registerNew(acc, Account.Country__c, country);
                    allAccounts.add(acc);
                }
            }
            fiveRegions.add(region);
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
    static void changeAccountOwnerTest() {
        List<Account> acc = new List<Account>();
        System.Test.startTest();
        acc = [SELECT id, Owner__c 
                FROM Account 
                WHERE Owner__c=null];
        //checking that accounts without owner have been inserted
        System.assertEquals(97, acc.size());
        ChangeAccOwner classInstant = new ChangeAccOwner();
        Id batchId = Database.executeBatch(classInstant);        
        System.Test.stopTest();
        acc = [SELECT id, Owner__c 
                FROM Account 
                WHERE Owner__c=null];
        //checking of the absence of accounts without an owner
        System.assertEquals(0, acc.size());
        Sales_Team_Assignment__c onlyOneSTA = [SELECT MD_to_Region__r.Name, MD_to_Sales_Team__r.Lead__c 
                FROM Sales_Team_Assignment__c 
                WHERE MD_to_Region__r.Name = 'Region №4'];
        Region__c regionWithOneSTA = onlyOneSTA.MD_to_Region__r;
        Account accWithOneSTA = [SELECT Owner__c, Country__r.Region__c 
                FROM Account 
                WHERE Country__r.Region__c = :regionWithOneSTA.Id
                LIMIT 1];
        //checking that account with one Sales Team Assignment has the correct owner
        System.assertEquals(onlyOneSTA.MD_to_Sales_Team__r.Lead__c, accWithOneSTA.Owner__c);
        List<Account> accWithPreOwner = [SELECT Owner__c 
                FROM Account 
                WHERE Owner__r.Name = 'Jon 90' 
                AND Owner__r.Last_Name__c ='Adams 1'];
        //checking for the correctness of the Sales Team lead selection, if there are several of them
        System.assertEquals(4, accWithPreOwner.size());
    }
}