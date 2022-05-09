trigger OrderItemTrigger on OrderItem (before insert) {

    
  OrderItemTriggerHandler handler = new OrderItemTriggerHandler(
      Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
  );

  switch on Trigger.operationType{
      when BEFORE_INSERT{
          handler.beforeInsert();
      }
  }

}