trigger OrderTrigger on Order (before update) {
  OrderTriggerHandler handler = new OrderTriggerHandler(
      Trigger.old, 
      Trigger.new, 
      Trigger.oldMap, 
      Trigger.newMap
  );

  switch on Trigger.operationType{
    when BEFORE_UPDATE{
      handler.beforeUpdate();
    }
    // when AFTER_UPDATE{
    //   handler.afterUpdate();
    // }
  }
}