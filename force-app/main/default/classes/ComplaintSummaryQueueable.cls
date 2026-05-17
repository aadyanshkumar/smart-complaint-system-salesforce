public with sharing class ComplaintSummaryQueueable implements Queueable{
    public void execute(QueueableContext context){
        Integer totalComplaints = [
            SELECT COUNT()
            FROM Complaint__c
        ];

        Integer escalatedComplaints = [
            SELECT COUNT()
            FROM Complaint__c
            WHERE Status__c = 'Escalated'
        ];

        Integer resolvedComplaints = [
            SELECT COUNT()
            FROM Complaint__c
            WHERE Status__c = 'Resolved'
        ];

        System.debug('=========== Complaint Summary ===========');

        System.debug('Total Complaints: '+totalComplaints);
        System.debug('Total Escalted Complaints: '+escalatedComplaints);
        System.debug('Total Resolved Complaints: '+resolvedComplaints);
    }
}