trigger PriceMarginTrigger on PriceMargin__c (before insert) {

  PriceMarginTriggerHandler handler = new PriceMarginTriggerHandler(
      Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
  );

  switch on Trigger.operationType{
      when BEFORE_INSERT {
          handler.beforeInsert();
      }
  }

}