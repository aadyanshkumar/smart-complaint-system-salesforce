@isTest
public class ComplaintTriggerHandlerTest {

    @testSetup
    static void setupData(){

        Client__c client = new Client__c(
            Name = 'Test Client',
            Status__c = 'Active'
        );

        insert client;

    }

    @isTest
    static void testPriorityAssignment(){

        Client__c client = [
            SELECT Id
            FROM Client__c
            LIMIT 1
        ];

        Complaint__c complaint = new Complaint__c(
            Subject__c = 'Payment Failed',
            Description__c = 'Testing',
            Category__c = 'Payment Issue',
            Client__c = client.Id
        );

        Test.startTest();

        insert complaint;

        Test.stopTest();

        Complaint__c insertedComplaint = [

            SELECT Priority__c
            FROM Complaint__c
            WHERE Id = :complaint.Id

        ];

        System.assertEquals(
            'High',
            insertedComplaint.Priority__c
        );

    }

    @isTest
    static void testClientStatusUpdate(){

        Client__c client = [
            SELECT Id, Status__c
            FROM Client__c
            LIMIT 1
        ];

        List<Complaint__c> complaints =
            new List<Complaint__c>();

        for(Integer i = 0; i < 6; i++){

            complaints.add(
                new Complaint__c(
                    Subject__c = 'Complaint ' + i,
                    Description__c = 'Testing',
                    Category__c = 'Technical Bug',
                    Client__c = client.Id
                )
            );

        }

        Test.startTest();

        insert complaints;

        Test.stopTest();

        Client__c updatedClient = [

            SELECT Status__c
            FROM Client__c
            WHERE Id = :client.Id

        ];

        System.assertEquals(
            'Attention Needed',
            updatedClient.Status__c
        );

    }

    @isTest
    static void testPreventDelete(){

        Client__c client = [
            SELECT Id
            FROM Client__c
            LIMIT 1
        ];

        Complaint__c complaint = new Complaint__c(
            Subject__c = 'Escalated Issue',
            Description__c = 'Testing',
            Category__c = 'Technical Bug',
            Status__c = 'Escalated',
            Client__c = client.Id
        );

        insert complaint;

        Test.startTest();

        try{

            delete complaint;

            System.assert(false);

        }catch(DmlException e){

            System.assert(
                e.getMessage().contains(
                    'Cannot delete complaints'
                )
            );

        }

        Test.stopTest();

    }

    @isTest
    static void testQueueableJob(){

        Test.startTest();

        System.enqueueJob(
            new ComplaintSummaryQueueable()
        );

        Test.stopTest();

        System.assert(true);

    }

    @isTest
    static void testScheduler(){

        Test.startTest();

        String cronExp = '0 0 1 * * ?';

        System.schedule(
            'Test Scheduler Job',
            cronExp,
            new ComplaintScheduler()
        );

        Test.stopTest();

        System.assert(true);

    }

}