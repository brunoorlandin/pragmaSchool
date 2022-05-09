public with sharing class ContactTriggerHandler {
    List<Contact> oldRecords {get; set;} // Trigger.old
    List<Contact> newRecords {get; set;} // Trigger.new
    Map<Id, Contact> oldMap {get; set;} // Trigger.oldMap
    Map<Id, Contact> newMap {get; set;} // Trigger.newMap

    public ContactTriggerHandler(
        List<Contact> oldRecords, 
        List<Contact> newRecords,
        Map<Id, Contact> oldMap,
        Map<Id, Contact> newMap) {
            this.oldRecords = oldRecords;
            this.newRecords = newRecords;
            this.oldMap = oldMap;
            this.newMap = newMap;
    }

    public void afterDelete(){
        List<Account> accountList = ContactHelper.updateAccountInfo(this.oldRecords);
        update accountList;
    }
}
