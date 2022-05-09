public with sharing class AccountTriggerHandler {

    List<Account> oldRecords {get; set;} // Trigger.old
    List<Account> newRecords {get; set;} // Trigger.new
    Map<Id, Account> oldMap {get; set;} // Trigger.oldMap
    Map<Id, Account> newMap {get; set;} // Trigger.newMap

    public AccountTriggerHandler(
        List<Account> oldRecords, 
        List<Account> newRecords,
        Map<Id, Account> oldMap,
        Map<Id, Account> newMap) {
            this.oldRecords = oldRecords;
            this.newRecords = newRecords;
            this.oldMap = oldMap;
            this.newMap = newMap;
    }

    //BEFORE_INSERT
    public void beforeInsert(){
        AccountHelper.fillAccountDescription(this.newRecords);
    }

    //AFTER_INSERT
    public void afterInsert(){
        List<Contact> contactList = AccountHelper.createContacts(this.newRecords);
        insert contactList;
    }

    //BEFORE_DELETE
    public void beforeDelete(){
        AccountHelper.checkAccountTypeToBlock(this.oldRecords);
    }
}