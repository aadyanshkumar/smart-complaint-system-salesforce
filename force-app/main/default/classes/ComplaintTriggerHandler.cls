public with sharing class ComplaintTriggerHandler {

    public static void updateClientStatus(List<Complaint__c> compList){
        Set<Id> clientIds = new Set<Id>();

        for(Complaint__c comp: compList){
            if(comp.Client__c !=null){
                clientIds.add(comp.Client__c);
            }
        }
        if(clientIds.isEmpty()){
            return;
        }
        List<AggregateResult> results =  [
            SELECT Client__c clientId,
                    COUNT(Id) totalComplaint
                    FROM Complaint__c
                    WHERE Client__c IN: clientIds
                    GROUP BY Client__c
        ];

        List<Client__c> clientToUpdate = new List<Client__c>();

        for(AggregateResult ar: results){
            Id clientId = (Id) ar.get('clientId');
            Integer total = (Integer) ar.get('totalComplaint');
            if(total > 5){
                clientToUpdate.add(
                    new Client__c(
                        Id = clientId,
                        Status__c = 'Attention Needed'
                    )
                );
            }
        }

        if(!clientToUpdate.isEmpty()){
            update clientToUpdate;
        }

    }


    public static void assignPriority(List<Complaint__c> newComp){
        for(Complaint__c comp: newComp){
            if(comp.Category__c == 'Payment Issue'){
                comp.Priority__c = 'High';
            }
            else if(comp.Category__c == 'Login Issue'){
                comp.Priority__c = 'Medium';
            }
            else if(comp.Category__c == 'Technical Bug'){
                comp.Priority__c = 'Critical';
            }
           
        }
    }

    public static void preventDelete(List<Complaint__c> compList){
        for(Complaint__c comp: compList){
            if(comp.Status__c == 'In Progress' || comp.Status__c == 'Escalated'){
                //prevent delete
                comp.addError('Cannot delete complaints that are In '+comp.Status__c);
            }
        }
    }

    public static void handleEscalation(
            List<Complaint__c> newList,
            Map<Id,Complaint__c> oldMap 
        ){
            List<Id> escalatedComplaintIds = new List<Id>();
            
            for(Complaint__c comp: newList){

                Complaint__c oldComp = oldMap.get(comp.Id);

                if(comp.Status__c == 'Escalated' && oldComp.Status__c != 'Escalated'){
                    escalatedComplaintIds.add(comp.Id);
                }
            }
            
            if(!escalatedComplaintIds.isEmpty()){
                ComplaintAsyncService.sendEscalationEmail(escalatedComplaintIds);
            }
        }
}