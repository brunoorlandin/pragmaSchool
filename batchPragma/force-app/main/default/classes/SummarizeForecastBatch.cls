global with sharing class SummarizeForecastBatch implements Database.Batchable<SObject>, Database.Stateful{
    global SummarizeForecastBatch() {}

    private AccountInfo accountInfo = null;

    global Database.QueryLocator start(Database.BatchableContext context){
        String query = 'SELECT Id FROM Account';
        System.debug('query => ' + query);
        
        return Database.getQueryLocator(query);                                                                                                
    }

    global void execute(Database.BatchableContext context, List<Account> scope){
        List<AggregateResult> aggregateResultByAccountList = [
            SELECT Account__c, SUM(Value__c) Value
            FROM Forecast__c
            WHERE Account__c IN: scope
            GROUP BY Account__c
        ];

        System.debug('Forecast por conta => ' + aggregateResultByAccountList);
        System.debug('Quantidade de forecasts por conta => ' + aggregateResultByAccountList.size());

        List<AggregateResult> aggregateResultByAccountProductList = [
            SELECT Account__c, Product__c, SUM(Value__c) Value
            FROM Forecast__c
            GROUP BY Account__c, Product__c
        ];

        System.debug('Forecast por conta e produto => ' + aggregateResultByAccountProductList);
        System.debug('Quantidade de forecasts por conta e produto => ' + aggregateResultByAccountProductList.size());

        List<ForecastSummary__c> forecastSummaryList = new List<ForecastSummary__c>();

        for(AggregateResult accountResult : aggregateResultByAccountList){
            Decimal totalValue = (Decimal)accountResult.get('Value');

            String accountId = (String)accountResult.get('Account__c');
            System.debug(accountId);
            
            forecastSummaryList.add(new ForecastSummary__c(
                Key__c = (String)accountResult.get('Account__c'),
                Account__c = (Id)accountResult.get('Account__c'),
                Value__c = totalValue
            ));

            if(this.accountInfo == null || totalValue > this.accountInfo.Value){
                this.accountInfo = new AccountInfo(
                    (String)accountResult.get('Account__c'),
                    totalValue
                );
            }
        }

        for(AggregateResult accountResult : aggregateResultByAccountProductList){
            String accountId = (String)accountResult.get('Account__c');
            System.debug(accountId);

            forecastSummaryList.add(new ForecastSummary__c(
                Key__c = (String)accountResult.get('Account__c') + ' ' + (String)accountResult.get('Product__c'),
                Account__c = (Id)accountResult.get('Account__c'),
                Product__c = (Id)accountResult.get('Product__c'),
                Value__c = (Decimal)accountResult.get('Value')
            ));
        }

        upsert forecastSummaryList Key__c;
    }

    global void finish(Database.BatchableContext context){
        Account account = [
            SELECT Id, Name
            FROM Account
            WHERE Id =: this.accountInfo.AccountId
        ];

        ForecastEmailNotification__c forecastEmailSettings = ForecastEmailNotification__c.getValues('ForecastAccountProduct');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> {forecastEmailSettings.ToAddress__c});
        mail.setSubject(forecastEmailSettings.Subject__c);

        String body = String.format(
            '{0}. Account {1} had a total forecast of {2}',
            new List<Object> {forecastEmailSettings.Body__c, account.Name, this.accountInfo.Value}
        );

        mail.setPlainTextBody(body);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
    }

    public class AccountInfo{
        public Id AccountId {get; set;}
        public Decimal Value {get; set;}

        public AccountInfo(Id accountId, Decimal value){
            this.AccountId = accountId;
            this.Value = value;
        }
    }
}