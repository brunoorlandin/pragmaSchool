public with sharing class SchedulerCloseOpportunityBatch implements Schedulable{
    public SchedulerCloseOpportunityBatch() {}

    public void execute(SchedulableContext context){
        CloseOpportunityBatch batch = new CloseOpportunityBatch();
        Database.executeBatch(batch);
    }
}
