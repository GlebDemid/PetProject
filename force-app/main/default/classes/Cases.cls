public with sharing class Cases extends fflib_SObjectDomain{
    
    public Cases(List<Account> sObjectList) {
        super(sObjectList);
    }

    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Cases(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        for (Case oneCase : (List<Case>) records) {
            supportTypeRecord(oneCase);
            salesTypeRecord(oneCase);
        }
    }

    public override void onBeforeUpdate(map<id, SObject> existing) {        
        for (Case oneCase : (List<Case>) records) {
            supportTypeRecord(oneCase);
            salesTypeRecord(oneCase);
        }
    }

    private void supportTypeRecord(Case oneCase) {
        if (oneCase.recordTypeID == CaseServise.SUPPORT_RECORD_RT) {
            if (oneCase.Status == 'Sales action'){
                oneCase.OwnerId = CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Sales_Queue').Id;
            } else {
                if (oneCase.Status == 'Support action' || oneCase.Status == 'Reopened' || oneCase.Status == 'Open') {
                    oneCase.OwnerId = CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Support_Queue').Id;
                }
            }
        }
    }

    private void salesTypeRecord(Case oneCase) {
        if (oneCase.recordTypeID == CaseServise.SALES_RECORD_RT) {
            if (oneCase.Status == 'Support action'){
                oneCase.OwnerId = CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Support_Queue').Id;
            } else {
                if (oneCase.Status == 'Sales action' || oneCase.Status == 'Reopened' || oneCase.Status == 'Open') {
                    oneCase.OwnerId = CaseServise.DEVELOPER_NAME_CASE_QUEUE_MAP.get('Sales_Queue').Id;
                }
            }
        }
    }
}