public with sharing class OrderHelper {
    public OrderHelper() {}

    public static List<OrderItem> checkRecalcItems(Map<id, Order> oldRecords,Map<id, Order> newRecords ){
        Set<Id> orderIds = new Set<Id>();

        for(Order order : newRecords.values()){
            Order oldRecord = oldRecords.get(order.Id);

            if(order.DistributionCenter__c != oldRecord.DistributionCenter__c){
                orderIds.add(order.Id);
            }
        }

        List<OrderItem> orderItemList = [
            SELECT Id, ListPrice, Product2Id, OrderId
            FROM OrderItem
            WHERE OrderId IN: orderIds
        ];

        List<OrderItem> updatedOrderItemList = OrderItemHelper.calcPrice(orderItemList);

        return updatedOrderItemList;
    }
}
