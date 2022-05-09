trigger AccountTrigger on Account (before insert, after insert) {

  AccountTriggerHandler handler = new AccountTriggerHandler(
    Trigger.old,
    Trigger.new,
    Trigger.oldMap,
    Trigger.newMap
  );

  switch on Trigger.operationType {
    when BEFORE_INSERT {
      handler.beforeInsert();
    }
    when AFTER_INSERT {
      handler.afterInsert();
    }
    when BEFORE_DELETE {
      handler.beforeDelete();
    }
  }
}