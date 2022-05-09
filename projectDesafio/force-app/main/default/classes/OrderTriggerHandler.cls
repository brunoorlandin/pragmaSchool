public with sharing class OrderTriggerHandler {
    List<Order> oldRecords {get; set;}
    List<Order> newRecords {get; set;}
    Map<Id, Order> oldMap {get; set;}
    Map<Id, Order> newMap {get; set;}

    public OrderTriggerHandler(List<Order> oldRecords, List<Order> newRecords, Map<Id, Order> oldMap, Map<Id, Order> newMap){
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeUpdate(){
        // OrderHelper.checkError(this.newRecords, this.oldRecords);
        // OrderHelper.checkErrorDraft(this.newRecords, this.oldRecords);
        // OrderHelper.getTotalAmount(this.newMap, this.oldMap, this.newRecords);
    }

    // public void afterUpdate(){
               
    // }
}