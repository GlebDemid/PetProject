@isTest
private class AccountOwnerChangerTest {
    @TestSetup
    static void makeData(){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Region__c.SObjectType,
                Country__c.SObjectType,
                Account.SObjectType
            }
        );
        Sales_Team__c saleTM = new Sales_Team__c(Name='TestTeam');
        insert saleTM;
        Employee__c empl= new Employee__c(Name='Jon',
                                        Last_Name__c='Adams',
                                        Sales_Team__c=saleTM.Id);
        insert empl;
        saleTM.Lead__c=empl.id;
        update saleTM;
        Region__c region = new Region__c(Name='Africa');
        uow.registerNew(region, Region__c.Sales_Team__c, saleTM);
        Country__c country = new Country__c(Name='Nigeria');
        uow.registerNew(country, Country__c.Region__c, region);
        Account acc = new Account(Name='Testing');
        uow.registerNew(acc, Account.Country__c, country);
        uow.commitWork();
    }
    @isTest
    static void onLeadOwnersTest() {
        AccountOwnerChanger accOwnChng = new AccountOwnerChanger();
        Employee__c employee = [SELECT id FROM Employee__c WHERE Name='Jon' LIMIT 1];
        accOwnChng.onLeadOwners();
        Account acc = [SELECT id, Owner__c FROM Account WHERE Country__r.Name='Nigeria' LIMIT 1];
        System.assertEquals(employee.id, acc.Owner__c);
    }
    
    @isTest
    static void ChangeAccOwnerTest() {
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new ChangeAccOwner());
        Account acc = [SELECT id, Owner__c FROM Account WHERE Country__r.Name='Nigeria' LIMIT 1];
        System.assertEquals(null, acc.Owner__c);
        Test.stopTest();
        acc = [SELECT id, Owner__c FROM Account WHERE Country__r.Name='Nigeria' LIMIT 1];
        Employee__c employee = [SELECT id FROM Employee__c WHERE Name='Jon' LIMIT 1];
        System.assertEquals(employee.id, acc.Owner__c);
    }
}
