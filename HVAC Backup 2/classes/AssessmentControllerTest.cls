@isTest
public class AssessmentControllerTest {
    @isTest
    static void testAssessmentSubmission() {
        // Disable the Contact trigger
        ContactTriggerHandler.TriggerDisabled = true; 
        
        TestDataFactory.disableTriggers();   
        
        try {
            // Step 1: Set up test data
            
            // Create a test contact with L1 assessment sent and skills
            Contact testContact = new Contact(
                LastName = 'Test User',
                AssessmentSubmitted__c = false,
                L1_Assessment_Sent__c = true,
                L2_Assessment_Sent__c = false,
                Skills__c = 'Breakdown;Installation',
                Division__c ='CPSD;CPAG/CRBG'
            );
            insert testContact;
            
            // Create test questions (common and skill-specific)
            Assessment_Questions__c commonQuestion = new Assessment_Questions__c(
                Question_Text__c = 'Common Question?',
                Answer_Option_1__c = 'Answer A',
                Answer_Option_2__c = 'Answer B',
                Answer_Option_3__c = 'Answer C',
                Answer_Option_4__c = 'Answer D',
                Correct_Answer__c = 'Answer B',
                Question_Skill_Type__c = 'CPSD'
            );
            insert commonQuestion;
            
            Assessment_Questions__c skillQuestion = new Assessment_Questions__c(
                Question_Text__c = 'Skill-Based Question?',
                Answer_Option_1__c = 'Option 1',
                Answer_Option_2__c = 'Option 2',
                Answer_Option_3__c = 'Option 3',
                Answer_Option_4__c = 'Option 4',
                Correct_Answer__c = 'Option 3',
                Question_Skill_Type__c = 'Breakdown'
            );
            insert skillQuestion;
            
            // Step 2: Use a single startTest and stopTest block
            Test.startTest();
            
            // Create the controller instance within the test context
            ApexPages.currentPage().getParameters().put('ContactId', testContact.Id);
            AssessmentController controller = new AssessmentController();
            
            // Verify that the controller initialized the questions correctly
            System.assert(!controller.questions.isEmpty(), 'Questions should be loaded');
            System.assertEquals(1, controller.questions.size(), 'Only common questions should be loaded');
            
            // Step 3: Simulate submitting answers
            controller.selectedAnswers.put(commonQuestion.Id, 'Answer B'); // Correct answer for common question
            controller.selectedAnswers.put(skillQuestion.Id, 'Option 3');  // This won't be processed since L2 not sent
            
            // Call the submitAnswers method
            controller.submitAnswers();
            
            Test.stopTest();
            
            // Verify that the contact has been updated correctly
            Contact updatedContact = [SELECT AssessmentSubmitted__c, Correctly_Answered__c, Wrongly_Answered__c,
                                      Questions_Skipped__c, Assessment_Status__c
                                      FROM Contact WHERE Id = :testContact.Id];
            
            System.assert(updatedContact.AssessmentSubmitted__c, 'AssessmentSubmitted__c should be true');
            System.assertEquals(1, updatedContact.Correctly_Answered__c, 'Correctly_Answered__c should be 1');
            System.assertEquals(0, updatedContact.Wrongly_Answered__c, 'Wrongly_Answered__c should be 0');
            System.assertEquals(0, updatedContact.Questions_Skipped__c, 'Questions_Skipped__c should be 0');
            System.assertEquals('L1 Passed', updatedContact.Assessment_Status__c, 'Assessment_Status__c should be L1 Passed');
        } finally {
            // Re-enable the trigger after the test completes
            ContactTriggerHandler.TriggerDisabled = false;
        }
    }
    
   @isTest
static void testAssessmentAlreadySubmitted() {
    TestDataFactory.disableTriggers();   
        
    Contact testContact = new Contact(
        LastName = 'Test User 2',
        AssessmentSubmitted__c = true,
        L1_Assessment_Sent__c = true,
        L2_Assessment_Sent__c = false,
        Skills__c = 'Installation',
        Division__c ='CPSD;CPAG/CRBG'
    );
    insert testContact;

    Test.startTest();
    ApexPages.currentPage().getParameters().put('ContactId', testContact.Id);
    AssessmentController controller = new AssessmentController();
    Test.stopTest();

    System.assert(controller.alreadySubmitted, 'alreadySubmitted should be true');
}

    @isTest
    static void testMissingContactId() {
        // Disable the Contact trigger
        ContactTriggerHandler.TriggerDisabled = true;
        
        try {
            // Test scenario where ContactId is missing
            Test.startTest();
            AssessmentController controller = new AssessmentController();
            Test.stopTest();
            
            // Verify that an error message was added
            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Error message should be present for missing ContactId');
        } finally {
            // Re-enable the trigger after the test completes
            ContactTriggerHandler.TriggerDisabled = false;
        }
    }
    
    @isTest
    static void testL2AssessmentSubmission() {
        // Disable the Contact trigger
        ContactTriggerHandler.TriggerDisabled = true;
        
        try {
            // Create a test contact with L2 assessment sent
            Contact testContact = new Contact(
                LastName = 'Test User 3',
                AssessmentSubmitted__c = false, // Set to false to allow the assessment to proceed
                L1_Assessment_Sent__c = true,
                L2_Assessment_Sent__c = true,
                L2_Assessment_Submitted__c = false,
                Skills__c = 'Breakdown;Regular Service',
                Division__c='CPSD;CPAG/CRBG'
            );
            insert testContact;
            
            System.debug('Contact inserted: ' + testContact);
            
            // Create test L2 questions
            Assessment_Questions__c l2Question = new Assessment_Questions__c(
                Question_Text__c = 'L2 Question?',
                Answer_Option_1__c = 'Answer 1',
                Answer_Option_2__c = 'Answer 2',
                Answer_Option_3__c = 'Answer 3',
                Answer_Option_4__c = 'Answer 4',
                Correct_Answer__c = 'Answer 2',
                Question_Skill_Type__c = 'Breakdown'
            );
            insert l2Question;
            
            System.debug('L2 question inserted: ' + l2Question);
            
            // Use a single startTest and stopTest block
            Test.startTest();
            
            // Set up the controller for the L2 test
            ApexPages.currentPage().getParameters().put('ContactId', testContact.Id);
            AssessmentController controller = new AssessmentController();
            
            // Debug the loaded questions
            System.debug('Loaded questions: ' + controller.questions);
            
            // Verify L2 questions loaded
            System.assert(!controller.questions.isEmpty(), 'L2 questions should be loaded');
            System.assertEquals(1, controller.questions.size(), 'Only skill-based questions should be loaded');
            
            // Simulate submitting L2 answers
            controller.selectedAnswers.put(l2Question.Id, 'Answer 2'); // Correct L2 answer
            
            // Submit answers
            controller.submitAnswers();
            
            Test.stopTest();
            
            // Verify L2 assessment status update
            Contact updatedContact = [SELECT L2_Correct_Answers__c, L2_Wrong_Answers__c, L2_Skipped_Answers__c, Assessment_Status__c
                                      FROM Contact WHERE Id = :testContact.Id];
            
            System.assertEquals(1, updatedContact.L2_Correct_Answers__c, 'L2_Correct_Answers__c should be 1');
            System.assertEquals(0, updatedContact.L2_Wrong_Answers__c, 'L2_Wrong_Answers__c should be 0');
            System.assertEquals(0, updatedContact.L2_Skipped_Answers__c, 'L2_Skipped_Answers__c should be 0');
            System.assertEquals('L1 and L2 Passed', updatedContact.Assessment_Status__c, 'Assessment_Status__c should be L1 and L2 Passed');
        } finally {
            // Re-enable the trigger after the test completes
            ContactTriggerHandler.TriggerDisabled = false;
        }
    }
   
    
    
}