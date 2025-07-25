@isTest
public class DateUtilsTest {
    @isTest
    static void testCalculateDemoDateAndTotalAmount() {
        // Test data
        Decimal calculatedValue = 100.0;
        Date proposedFrom = Date.today();

        // Test cases for different billing frequencies
        List<String> billingFrequencies = new List<String>{
            'Yearly', 'Bi-Monthly', 'Quarterly', 'Four Monthly', 'Half Yearly', 'Invalid'
        };

        for (String billingFrequency : billingFrequencies) {
            // Call the method
            Map<String, Object> result = DateUtils.calculateDemoDateAndTotalAmount(
                billingFrequency, 
                proposedFrom, 
                calculatedValue
            );

        }
        
        NumberTOWordConversion objNum = new NumberTOWordConversion();
        objNum.getNumberTOWordConversion(1.0);
        objNum.getNumberTOWordConversion(1.11110);
        objNum.getNumberTOWordConversion(19);
        objNum.getNumberTOWordConversion(199);
        objNum.getNumberTOWordConversion(1999);
        objNum.getNumberTOWordConversion(19999);
        objNum.getNumberTOWordConversion(111110);
        objNum.getNumberTOWordConversion(9991110.1222);
        objNum.getNumberTOWordConversion(999911110);
        objNum.getNumberTOWordConversion(9991110.1222);
        objNum.getNumberTOWordConversion(999911110.1222);
    }

    // Mocked calcDayDiff method for testing purposes
    public static Integer calcDayDiff(Date startDate, Date endDate) {
        return endDate.daysBetween(startDate);
    }
    
}