trigger ContactTrigger on Contact (after delete) {
  ContactTriggerHandler handler = new ContactTriggerHandler(
    Trigger.old,
    Trigger.new,
    Trigger.oldMap,
    Trigger.newMap
  );

  switch on Trigger.operationType {
    when AFTER_DELETE {
      handler.afterDelete();
    }
  }
}