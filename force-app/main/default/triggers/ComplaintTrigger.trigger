trigger ComplaintTrigger on Complaint__c (
        before insert,
        after insert,
        before delete,
        after update
        ){
    if(Trigger.isInsert && Trigger.isBefore){
        ComplaintTriggerHandler.assignPriority(Trigger.NEW);
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        ComplaintTriggerHandler.updateClientStatus(Trigger.NEW);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        ComplaintTriggerHandler.preventDelete(Trigger.Old);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        ComplaintTriggerHandler.handleEscalation(
            Trigger.new,
            Trigger.oldMap
        );
    }
}