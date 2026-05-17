public with sharing class ComplaintAsyncService {
    // send mail to manager when complaint status become Escalated
    @future
    public static void sendEscalationEmail(List<Id> complaintIds){
        List<Complaint__c> complaints = [
            SELECT Id,
                Subject__c,
                Status__c
            FROM Complaint__c
                WHERE Id IN: complaintIds   
        ];

        //Send emails 
        List<Messaging.SingleEmailMessage> emails = 
            new List<Messaging.SingleEmailMessage>();

        for(Complaint__c comp: complaints){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(
                new List<String>{'manager@test.com'}
            );

            mail.setSubject(
                'Complaint Escalated: ' + comp.Subject__c
            );

            mail.setPlainTextBody(
                'Complaint has been escalated.\n\n' +
                'Subject: ' + comp.Subject__c
            );
            emails.add(mail);
        }    
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}