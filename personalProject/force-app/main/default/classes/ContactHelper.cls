public with sharing class ContactHelper {
    public ContactHelper() {

    }

    public static List<Account> updateAccountInfo(List<Contact> contactList){
        Set<Id> accountIdSet = new Set<Id>();

        for(Contact contact : contactList){
            accountIdSet.add(contact.AccountId);
        }

        List<Account> accountList = [
            SELECT Id, UpdateContactInfo__c
            FROM Account
            WHERE Id IN: accountIdSet
            AND UpdateContactInfo__c <> true
        ];
        System.debug('accountList => ' + accountList);

        for(Account account: accountList){
            account.UpdateContactInfo__c = true;
        }

        return accountList;
    }
}