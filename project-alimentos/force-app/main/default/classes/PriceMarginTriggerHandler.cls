public with sharing class PriceMarginTriggerHandler {

    List<PriceMargin__c> oldRecords {get; set;}
    List<PriceMargin__c> newRecords {get; set;}
    Map<Id, PriceMargin__c> oldMap {get; set;}
    Map<Id, PriceMargin__c> newMap {get; set;}


    public PriceMarginTriggerHandler(List<PriceMargin__c> oldRecords, List<PriceMargin__c> newRecords, Map<Id, PriceMargin__c> oldMap, Map<Id, PriceMargin__c> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        PriceMarginHelper.validateMarginCategory(this.newRecords);
        PriceMarginHelper.calcScore(this.newRecords);
    }
}
