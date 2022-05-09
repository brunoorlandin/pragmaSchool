global with sharing class SummarizeOrderAmountBatch implements Database.Batchable<SObject>, Database.Stateful{
    global SummarizeOrderAmountBatch() {}

    private AccountInfo accountInfo = null;

    global Database.QueryLocator start(Database.BatchableContext context){
        String query = 'SELECT Id FROM Account';
        System.debug('query => ' + query);
        
        return Database.getQueryLocator(query);                                                                                                
    }

    global void execute(Database.BatchableContext context, List<Account> scope){     
        List<AggregateResult> aggregateOrderResultByAccountList = [
            SELECT Order.AccountId AccountId, Order.Status, SUM(TotalPrice) Value
            FROM OrderItem
            WHERE Order.Status = 'Closed'
            GROUP BY Order.AccountId, Order.Status
        ];

        System.debug('Forecast por pedido por conta=> ' + aggregateOrderResultByAccountList);
        System.debug('Quantidade de por pedido por conta => ' + aggregateOrderResultByAccountList.size());

        List<AggregateResult> aggregateOrderResultByAccountProductList = [
            SELECT Order.AccountId AccountId, Order.Status, Product2Id, SUM(TotalPrice) Value
            FROM OrderItem
            WHERE Order.Status = 'Closed'
            GROUP BY Order.AccountId, Order.Status, Product2Id
        ];

        System.debug('Forecast por pedido por produto e conta=> ' + aggregateOrderResultByAccountProductList);
        System.debug('Quantidade de pedidos por produto e conta => ' + aggregateOrderResultByAccountProductList.size());

        List<ForecastSummary__c> forecastSummaryList = new List<ForecastSummary__c>();

        for(AggregateResult accountOrderResult : aggregateOrderResultByAccountList){
            Decimal totalValue = (Decimal)accountOrderResult.get('Value');

            forecastSummaryList.add(new ForecastSummary__c(
                Key__c = (String)accountOrderResult.get('AccountId'),
                Account__c = (Id)accountOrderResult.get('AccountId'),
                RealizedValue__c = totalValue
            ));

            if(this.accountInfo == null || totalValue > this.accountInfo.Value){
                this.accountInfo = new AccountInfo(
                    (String)accountOrderResult.get('AccountId'),
                    totalValue
                );
            }
        }

        for(AggregateResult accountOrderProductResult : aggregateOrderResultByAccountProductList){
            forecastSummaryList.add(new ForecastSummary__c(
                Key__c = (String)accountOrderProductResult.get('AccountId') + ' ' + (String)accountOrderProductResult.get('Product2Id'),
                Account__c = (Id)accountOrderProductResult.get('AccountId'),
                Product__c = (Id)accountOrderProductResult.get('Product2Id'),
                RealizedValue__c = (Decimal)accountOrderProductResult.get('Value')
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