public with sharing class OpportunityLineItemTriggerHandler {
    List<OpportunityLineItem> oldRecords {get; set;} // Trigger.old
    List<OpportunityLineItem> newRecords {get; set;} // Trigger.new
    Map<Id, OpportunityLineItem> oldMap {get; set;} // Trigger.oldMap
    Map<Id, OpportunityLineItem> newMap {get; set;} // Trigger.newMap

    public OpportunityLineItemTriggerHandler(
        List<OpportunityLineItem> oldRecords, 
        List<OpportunityLineItem> newRecords,
        Map<Id, OpportunityLineItem> oldMap,
        Map<Id, OpportunityLineItem> newMap) {
            this.oldRecords = oldRecords;
            this.newRecords = newRecords;
            this.oldMap = oldMap;
            this.newMap = newMap;
    }

    public void beforeUpdate(){
        OpportunityLineItemHelper.checkChangeQuantity(this.oldMap, this.newMap);
    }

    public void afterUpdate(){
        List<Opportunity> opportunityList = OpportunityLineItemHelper.checkItemChange(this.oldMap, this.newMap);
        update opportunityList;
    }
}
