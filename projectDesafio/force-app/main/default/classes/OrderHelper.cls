public with sharing class OrderHelper {
    public OrderHelper() {}

    public static void checkError(List<Order> newOrdersList, List<Order> oldOrdersList){
        for(Order oldOrder: oldOrdersList){
            Integer count = 0;
            Order newOrder = newOrdersList[count];
            if (oldOrder.Status == 'Draft'){
                
            }
            else if(oldOrder.Status == 'Activated' && newOrder.Status == 'Draft'){

            }
            else if(oldOrder.Status == 'Draft' && newOrder.Status == 'Activated'){
                
            }
            else if(oldOrder.Status == 'Activated' && newOrder.Status == 'Activated'){
                newOrder.addError(Label.OrderNotDraftError);
            }
        }
    }

    public static void checkErrorDraft(List<Order> newOrederRecordsList, List<Order> oldOrderRecordsList){
        for(Order order : newOrederRecordsList){
            Integer count = 0;

            Id oldItem = oldOrderRecordsList[count].AccountId;

            if(order.Status == 'Draft'){
                if (order.AccountId != oldItem){
                    order.addError(Label.OrderDraftAccount);
                }
            }

            count++;
        }
    }

    public static void getTotalAmount(
            Map<Id, Order> newOrderMap,
            Map<Id, Order> oldOrderMap,
            List<Order> newOrderList
        ){
            Map<Id, List<Decimal> > orderAmountMap = new Map<Id, List<Decimal> >();

            List<orderItem> orderItemList= [
                SELECT OrderId, Id, Quantity, 	Volume__c, Weight__c
                FROM OrderItem
            ];

            List<DistributionCenter__c> distributionCenterList = [
                SELECT Id, Name
                FROM DistributionCenter__c
            ];

            List<Freight__c> freightList = [
                SELECT Id, CEP__c, City__c, State__c, DistributionCenter__c, FreightByVolume__c, FreightByWeight__c, FreightBase__c
                FROM Freight__c
            ];

            List<Account> accountList = [
                SELECT Id, CEP__c, City__c
                FROM Account
            ];

            for(Order order: newOrderList){
                Decimal volumeAmount = 0;
                Decimal weightAmount = 0;
                Decimal quantityAmount = 0;

                List<Decimal> totalOrderAmount = new List<Decimal>();

                List<Freight__c> foundFreightList = new List<Freight__c>();

                for(OrderItem orderItem : orderItemList){
                    if(order.id == orderItem.OrderId){
                        volumeAmount += orderItem.Volume__c;
                        weightAmount += orderItem.Weight__c;
                        quantityAmount += orderItem.Quantity;
                    }
                }

                totalOrderAmount.add(volumeAmount);
                totalOrderAmount.add(weightAmount);
                totalOrderAmount.add(quantityAmount);

                orderAmountMap.put(order.Id, totalOrderAmount);

                Account account = [
                    SELECT Id, CEP__c, City__c, City__r.State__c
                    FROM Account
                    WHERE Id =: order.AccountId
                ];

                for(DistributionCenter__c dc : distributionCenterList){
                    System.debug('entrou for');
                    for(Freight__c freight : [
                        SELECT  Id, 
                                CEP__c, 
                                City__c, 
                                State__c, 
                                DistributionCenter__c, 
                                FreightByVolume__c, 
                                FreightByWeight__c, 
                                FreightBase__c
                        FROM    Freight__c
                        WHERE   DistributionCenter__c =: dc.Id
                    ]){
                        //for(Account account : accountList){
                            if(order.AccountId == account.Id){
                                if(freight.DistributionCenter__c == dc.Id){
                                    if(freight.CEP__c == account.CEP__c){
                                        foundFreightList.add(freight);
                                        System.debug(freight);
                                        System.debug('CEP freight: ' + freight.CEP__c);
                                        System.debug('CEP account: ' + account.CEP__c);
                                    }
                                    
                                    else if(freight.City__c == account.City__c){
                                        foundFreightList.add(freight);
                                        System.debug(freight);
                                        System.debug('City freight: ' + freight.City__c);
                                        System.debug('City account: ' + account.City__c);
                                    }

                                    else if(freight.State__c == account.City__r.State__c){
                                        foundFreightList.add(freight);
                                        System.debug(freight);
                                        System.debug('state freight: ' + freight.State__c);
                                        System.debug('state account: ' + account.City__r.State__c);
                                    }
                                }
                            }
                        //}                        
                    }
                }



                Map<Freight__c, Decimal> freightMap = new Map<Freight__c, Decimal>();

                for(Freight__c freight: foundFreightList){
                    List<Decimal> costs = new List<Decimal>();

                    Decimal volumeCost = volumeAmount * freight.FreightByVolume__c;
                    costs.add(volumeCost);
                    Decimal weightCost = weightAmount * freight.FreightByWeight__c;
                    costs.add(weightAmount);
                    Decimal quantityCost = quantityAmount * freight.FreightBase__c;
                    costs.add(quantityAmount);

                    costs.sort();

                    Decimal max = costs[costs.size() - 1];

                    freightMap.put(freight, max);
                }

                List<Decimal> minList = new List<Decimal>();

                for(Decimal value : freightMap.values()){
                    minList.add(value);
                }

                minList.sort();

                Decimal min = minList[0];

                Freight__c freight;

                for(Freight__c key : freightMap.keySet()){
                    if(freightMap.get(key) == min){
                        freight = key;
                    }
                }

                order.Freight__c = freight.Id;
                order.DistributionCenter__c = freight.DistributionCenter__c;
                order.TotalFreight__c = min;
            }
        }
}