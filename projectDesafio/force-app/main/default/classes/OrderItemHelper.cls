public with sharing class OrderItemHelper {
    public OrderItemHelper() {}

    public static List<Order> getTotalAmount(
            Map<Id, OrderItem> newOrderMap,
            Map<Id, OrderItem> oldOrderMap,
            List<OrderItem> newOrderItemList,
            List<OrderItem> oldOrderItemList
        ){
            Id orderId = newOrderItemList[0].OrderId;

            System.debug(orderId);

            List<Order> orderList2 = [
                SELECT Id, AccountId ,Freight__c, DistributionCenter__c, TotalFreight__c
                FROM Order
                WHERE Id =: orderId
            ];

            System.debug(orderList2);
            
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

            List<Order> orderList = [
                SELECT Id, AccountId ,Freight__c, DistributionCenter__c, TotalFreight__c
                FROM Order
            ];

            for(Order order: orderList){
                Decimal volumeAmount = 0;
                Decimal weightAmount = 0;
                Decimal quantityAmount = 0;

                List<Decimal> totalOrderAmount = new List<Decimal>();

                List<Freight__c> foundFreightList = new List<Freight__c>();
                
                for(OrderItem orderItem : orderItemList){
                    if(orderItem.OrderId == order.Id){
                        volumeAmount += orderItem.Volume__c;
                        weightAmount += orderItem.Weight__c;
                        quantityAmount += orderItem.Quantity;
                    }
                }
                
                // for(OrderItem orderItem : newOrderItemList){
                //     if(orderItem.OrderId == order.Id){
                //         volumeAmount += orderItem.Volume__c;
                //         weightAmount += orderItem.Weight__c;
                //         quantityAmount += orderItem.Quantity;
                //     }
                // }

                System.debug('Volume: ' + volumeAmount);
                System.debug('Peso: ' + weightAmount);
                System.debug('Quantidade: ' + quantityAmount);

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
                    List<Freight__c> foundFreightCEPList = new List<Freight__c>();
                    List<Freight__c> foundFreightCityList = new List<Freight__c>();
                    List<Freight__c> foundFreightStateList = new List<Freight__c>();

                    System.debug('entrou for');
                    for(Freight__c freight : freightList){
                        if(freight.DistributionCenter__c == dc.Id){
                        //for(Account account : accountList){
                            if(order.AccountId == account.Id){
                                if(freight.DistributionCenter__c == dc.Id){
                                    if(freight.CEP__c == account.CEP__c){
                                        foundFreightCEPList.add(freight);
                                        // System.debug(freight);
                                        // System.debug('CEP freight: ' + freight.CEP__c);
                                        // System.debug('CEP account: ' + account.CEP__c);
                                    }
                                    
                                    else if(freight.City__c == account.City__c){
                                        foundFreightCityList.add(freight);
                                        // System.debug(freight);
                                        // System.debug('City freight: ' + freight.City__c);
                                        // System.debug('City account: ' + account.City__c);
                                    }

                                    else if(freight.State__c == account.City__r.State__c){
                                        foundFreightStateList.add(freight);
                                        // System.debug(freight);
                                        // System.debug('state freight: ' + freight.State__c);
                                        // System.debug('state account: ' + account.City__r.State__c);
                                    }
                                }
                            }
                        }
                        //}                        
                    }

                    Boolean state = false;

                    if(foundFreightCEPList.size() > 0){
                        state = true;
                        System.debug(state);
                        System.debug(foundFreightCEPList);
                        for(Freight__c freight : foundFreightCEPList){
                            foundFreightList.add(freight);
                        }
                    }
                    else if(foundFreightCityList.size() > 0 && state == false){
                        state = true;
                        System.debug(state);
                        System.debug(foundFreightCityList);
                        for(Freight__c freight : foundFreightCityList){
                            foundFreightList.add(freight);
                        }
                    }
                    else if(foundFreightStateList.size() > 0 && state == false){
                        System.debug(state);
                        System.debug(foundFreightStateList);
                        for(Freight__c freight : foundFreightStateList){
                            foundFreightList.add(freight);
                        }
                    }

                    System.debug('Lista de fretes para o pedido: ' + foundFreightList);
                }

                Map<Freight__c, Decimal> freightMap = new Map<Freight__c, Decimal>();

                for(Freight__c freight: foundFreightList){
                    List<Decimal> costs = new List<Decimal>();

                    Decimal volumeCost = volumeAmount * freight.FreightByVolume__c;
                    costs.add(volumeCost);
                    Decimal weightCost = weightAmount * freight.FreightByWeight__c;
                    costs.add(weightCost);
                    Decimal quantityCost = quantityAmount * freight.FreightBase__c;
                    costs.add(quantityCost);

                    costs.sort();

                    Decimal max = costs[costs.size() - 1];

                    System.debug('Frete: ' + freight);
                    System.debug('Maior valor: ' + max);
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

            return orderList;
        }
}