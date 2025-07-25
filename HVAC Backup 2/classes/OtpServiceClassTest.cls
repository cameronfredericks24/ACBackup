/*
@Author : Anshika Jain
@CreatedDate : 2nd feb 2024
@Description : To get otp to verify updates
*/
@isTest
public class OtpServiceClassTest {

    @isTest
    static void testGenerateOtp() {
        // Call the generateOtp method from OtpServiceClass
        Test.startTest(); 
        List<String> otpList = OtpServiceClass.generateOtp();
        Test.stopTest();

        // Ensure that the returned list has only one element
        System.assertEquals(1, otpList.size(), 'The OTP list should contain only one element.');

        // Extract the generated OTP from the list
        String generatedOtp = otpList[0];

        // Ensure that the generated OTP is a four-digit number
        System.assert(generatedOtp.length() == 4, 'The generated OTP should be a four-digit number.');

        // Ensure that the generated OTP is a numeric value
        System.assert(Integer.valueOf(generatedOtp) != null, 'The generated OTP should be a numeric value.');
    }
}