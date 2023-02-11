public  with sharing class CaseServise {
    public static final List<String> CASE_QUEUE_DEVELOPER_NAME = new List<String>{'Support_Queue', 'Sales_Queue', 'All_queue'};
    public static final String SALES_RECORD_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_record').getRecordTypeId();
    public static final String SUPPORT_RECORD_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_record').getRecordTypeId();
    public static final Map<String, Group> DEVELOPER_NAME_CASE_QUEUE_MAP {
        get{
            if (DEVELOPER_NAME_CASE_QUEUE_MAP==null) {
                Map<String, Group> mutableMap = new  Map<String, Group>();
                for (Group oneQueue : [SELECT Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :CASE_QUEUE_DEVELOPER_NAME]) {
                    mutableMap.put(oneQueue.DeveloperName, oneQueue);
                }
                return mutableMap;
            }
            else {
                return DEVELOPER_NAME_CASE_QUEUE_MAP;
            } 
        }
        private set;
    }
}