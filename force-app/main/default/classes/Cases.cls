public with sharing class Cases extends fflib_SObjectDomain{
    
    public Cases(List<Account> sObjectList) {
        super(sObjectList);
    }

    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Cases(sObjectList);
        }
    }

    public override void onBeforeUpdate(map<id, SObject> existing) {
        changeCaseOwnerUpdate('Support');
        changeCaseOwnerUpdate('Sales');
    }

    public override void onBeforeInsert() {
        changeCaseOwnerInsert('Support');
        changeCaseOwnerInsert('Sales');
    }

    private void changeCaseOwnerInsert(String typeOfRecord) {
        
        List<String> developerNameQueue = new List<String>{'%'+typeOfRecord+'%', 'All_queue'}; 
        String soqlForQueue = 'SELECT Id, Name ' + 
                'FROM Group ' + 
                'WHERE Type=\'Queue\' '+
                'AND DeveloperName LIKE : developerNameQueue ' +
                'ORDER BY Name';
        
        List<Group> queueWithName = Database.query(soqlForQueue);
        Group allqueue = queueWithName.get(0);
        Group queueOfRecorType = queueWithName.get(1);

        for (Case oneCase: (List<Case>) records) {
            if (oneCase.Status == 'Open' && oneCase.Type == typeOfRecord && oneCase.OwnerId == allqueue.id) {
                oneCase.OwnerId = queueOfRecorType.Id;
            }
        }
    }

    private void changeCaseOwnerUpdate(String typeOfRecord) {
         
        String soqlForQueue = 'SELECT Id, Name ' + 
                'FROM Group ' + 
                'WHERE Type=\'Queue\' '+
                'AND DeveloperName LIKE \'%' + typeOfRecord + '%\' '+
                'Limit 1';
        
        Group queueOfRecorType = Database.query(soqlForQueue);        
        String statusValue = typeOfRecord + ' action';
        
        for (Case newValue : (List<Case>) records) {
            if (typeOfRecord=='Support') { 
                Case oldValue = (Case) Trigger.oldMap.get(newValue.id); 
                if (oldValue.Status == 'Closed' && newValue.Status == 'Reopened'){
                    newValue.OwnerId = queueOfRecorType.Id;
                }
            }            
            if (newValue.Status == statusValue) {
                newValue.OwnerId = queueOfRecorType.Id;
            }
        }
    }
}