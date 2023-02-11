@isTest
private class CasesTest {
    @TestSetup
    private static void makeData(){
        List<Case> allNewCases = new List<Case>();
        List<String> allRecordType = new List<String>{CaseServise.SALES_RECORD_RT, CaseServise.SUPPORT_RECORD_RT};
        for (String oneRecordType : allRecordType) {
            List<Case> newCases = new List<Case> {
                new Case(
                    Origin='Phone',
                    Status='Closed',
                    RecordTypeId=oneRecordType),
                new Case(
                    Origin='Phone',
                    Status='Open',
                    RecordTypeId=oneRecordType),
                new Case(
                    Origin='Email',
                    Status='In progress',
                    RecordTypeId=oneRecordType),
                new Case(
                    Origin='Email',
                    Status='Support action',
                    RecordTypeId=oneRecordType),
                new Case(
                    Origin='Web',
                    Status='Sales action',
                    RecordTypeId=oneRecordType),
                new Case(
                    Origin='Web',
                    Status='Reopened',
                    RecordTypeId=oneRecordType)
            };
            allNewCases.addAll(newCases);
        }
        
        insert allNewCases;
    }
    @isTest
    private static void onBeforeUpdateAndInsertTest(){
        List<Case> allCases = [
                SELECT Id, Status, OwnerId
                FROM Case];
        List<Case> supportQueueCases = new List<Case> ();
        for (Case oneCase : allCases) {
            if (oneCase.OwnerId == CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Support_Queue').Id) {
                supportQueueCases.add(oneCase);
            }
        }
        List<Case> salesQueueCases = new List<Case> ();
        for (Case oneCase : allCases) {
            if (oneCase.OwnerId == CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Sales_Queue').Id) {
                salesQueueCases.add(oneCase);
            }
        }
        Assert.AreEqual(4, supportQueueCases.size(), '4 inserted cases must change owner on support queue');
        Assert.AreEqual(4, supportQueueCases.size(), '4 inserted cases must change owner on sales queue');    
        for (Case oneCase : allCases) {
            oneCase.Status='Support action';
        }

        System.Test.startTest();
            update allCases;
        List<Case> updatedCases = [SELECT Id, Status, OwnerId 
                FROM Case 
                WHERE OwnerId = :CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Support_Queue').Id];
        
        Assert.AreEqual(12, updatedCases.size(), '12 cases must change owner on support Queue after update');
        for (Case oneCase : updatedCases) {
            oneCase.Status='Sales action';
        }
        update updatedCases;
        System.Test.stopTest();
        updatedCases = [SELECT Id, Status, OwnerId 
                FROM Case 
                WHERE OwnerId = :CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Sales_Queue').Id];
        Assert.AreEqual(12, updatedCases.size(), '12 cases must change owner on sales Queue after update');
    }
}