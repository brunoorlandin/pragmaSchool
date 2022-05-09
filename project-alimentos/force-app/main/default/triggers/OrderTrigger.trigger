trigger OrderTrigger on Order (after update) {
  OrderTriggerHandler handler = new OrderTriggerHandler(
      Trigger.old, 
      Trigger.new, 
      Trigger.oldMap, 
      Trigger.newMap
  );

  switch on Trigger.operationType{
      when AFTER_UPDATE{
          handler.afterUpdate();
      }
  }
}