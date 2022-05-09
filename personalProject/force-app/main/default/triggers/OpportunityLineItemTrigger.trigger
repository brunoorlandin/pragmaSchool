trigger OpportunityLineItemTrigger on OpportunityLineItem (before update, after update) {
  OpportunityLineItemTriggerHandler handler = new OpportunityLineItemTriggerHandler(
    Trigger.old,
    Trigger.new,
    Trigger.oldMap,
    Trigger.newMap
  );

  switch on Trigger.operationType {
    when BEFORE_UPDATE {
      handler.beforeUpdate();
    }
    when AFTER_UPDATE {
      handler.afterUpdate();
    }
  }
}