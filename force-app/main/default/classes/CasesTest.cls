@isTest
private class CasesTest {
    @TestSetup
    static void makeData(){
        List<Case> newCases = new List<Case> {
            new Case(
                Origin='Phone',
                Status='Closed'),
            new Case(
                Origin='Phone',
                Status='Open'),
            new Case(
                Origin='Email',
                Status='In progress'),
            new Case(
                Origin='Email',
                Status='Support action'),
            new Case(
                Origin='Web',
                Status='Sales action'),
            new Case(
                Origin='Web',
                Status='Reopened')
        };
        insert newCases;
    }
    @isTest
    static void onBeforeUpdateTest(){
        List<Case> allCases = [SELECT Id, Status, OwnerId 
                FROM Case];
        Group salesQueue = [SELECT id 
                FROM Group
                WHERE Type='Queue' 
                AND  Name = 'Sales Queue'
                LIMIT 1];
        Group supportQueue = [SELECT id 
                FROM Group
                WHERE Type='Queue' 
                AND  Name = 'Support Queue'
                LIMIT 1];
        
        
        for (Case oneCase : allCases) {
            oneCase.Status='Support action';
        }
        System.Test.startTest();
            update allCases;
        List<Case> UpdateCases = [SELECT Id, Status, OwnerId 
                FROM Case 
                WHERE OwnerId = :supportQueue.Id];
        
        Assert.AreEqual(allCases.size(), UpdateCases.size(), 'all cases must be with Support Queue');
        for (Case oneCase : UpdateCases) {
            oneCase.Status='Sales action';
        }
        update UpdateCases;
        System.Test.stopTest();
        UpdateCases = [SELECT Id, Status, OwnerId 
                FROM Case 
                WHERE OwnerId = :salesQueue.Id];
        Assert.AreEqual(allCases.size(), UpdateCases.size(), 'all cases must be with Sales Queue');
    }

    @isTest
    static void onBeforeInsertTest(){
        List<Case> newCases = new List<Case>();
        Group allQueue = [SELECT id 
                FROM Group
                WHERE Type='Queue' 
                AND  Name = 'All queue'
                LIMIT 1];
        Group supportQueue = [SELECT id 
                FROM Group
                WHERE Type='Queue' 
                AND  Name = 'Support Queue'
                LIMIT 1];
        
        for (Integer i = 0; i < 50; i++) {
            Case oneCase = new Case(
                    Origin='Email',
                    Status='Open',
                    Type='Support',
                    OwnerId=allQueue.Id);
            newCases.add(oneCase);
        }
        for (Integer i = 0; i < 50; i++) {
            Case oneCase = new Case(
                    Origin='Email',
                    Status='Support action',
                    OwnerId=allQueue.Id);
            newCases.add(oneCase);
        }
        System.Test.startTest();
        insert newCases;
        SYstem.Test.stopTest();
        List<Case> updateCases = [SELECT id 
                FROM Case
                WHERE OwnerId=:supportQueue.Id];
        Assert.AreEqual(50, updateCases.size(), 'Half of inserted cases must change owner');
    }
}