public with sharing class OrderItemTriggerHandler {
    List<OrderItem> oldRecords {get; set;}
    List<OrderItem> newRecords {get; set;}
    Map<Id, OrderItem> oldMap {get; set;}
    Map<Id, OrderItem> newMap {get; set;}

    public OrderItemTriggerHandler(List<OrderItem> oldRecords, List<OrderItem> newRecords, Map<Id, OrderItem> oldMap, Map<Id, OrderItem> newMap){
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    // public void beforeUpdate(){
    //     List<Order> orderList =  OrderItemHelper.getTotalAmount(this.newMap, this.oldMap, this.newRecords, this.oldRecords);
    //     update orderList;
    // }

    // public void beforeInsert(){
    //     List<Order> orderList = OrderItemHelper.getTotalAmount(this.newMap, this.oldMap, this.newRecords, this.oldRecords);
    //     update orderList;
    // }

    public void afterInsert(){
        List<Order> orderList = OrderItemHelper.getTotalAmount(this.newMap, this.oldMap, this.newRecords, this.oldRecords);
        update orderList;
    }

    public void afterUpdate(){
        List<Order> orderList =  OrderItemHelper.getTotalAmount(this.newMap, this.oldMap, this.newRecords, this.oldRecords);
        update orderList;
    }

    // public void beforeDelete(){
    //     List<Order> orderList = OrderItemHelper.getTotalAmount(this.newMap, this.oldMap, this.newRecords, this.oldRecords);
    //     update orderList;
    // }

    // public void afterUpdate(){
               
    // }
}