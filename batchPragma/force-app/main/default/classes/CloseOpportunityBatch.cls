global with sharing class CloseOpportunityBatch implements Database.Batchable<SObject> {
    global CloseOpportunityBatch() {}

    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('batch start');
        Datetime baseDate = System.today().addDays(-15);
        
        String query = 'SELECT Id FROM Opportunity WHERE StageName IN (\'Prospecting\',  \'Qualification\') AND CreatedDate <=: baseDate';
        System.debug('query => ' + query);
        
        return Database.getQueryLocator(query);                                                                                                
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        System.debug('batch execute');

        for(Opportunity opp : scope){
            System.debug('opp id => ' + opp.Id);
            opp.StageName = 'Closed Lost';
            opp.Description = Label.ClosedOpportunityDescription;
        }

        update scope;
    }

    global void finish(Database.BatchableContext bc){
        System.debug('batch finish');
    }
}