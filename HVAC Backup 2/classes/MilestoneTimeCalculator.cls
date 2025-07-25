global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {   
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        System.debug('calculateMilestoneTriggerTime called with caseId: ' + caseId + ' and milestoneTypeId: ' + milestoneTypeId);
        //axis bank working hours 8 hdfc 24
        //Default tat taking 10 days for all cases
        // Fetch Case details
        Case c;
        WorkOrder workOrder = null;
        try {
            c = [SELECT Account.Name,  Account.SLA_Classification__c, 
                 (SELECT Root_Cause_Technical_Issue__c FROM WorkOrders ORDER BY CreatedDate ASC LIMIT 1) 
                 FROM Case 
                 WHERE Id = :caseId];
            if (!c.WorkOrders.isEmpty()) {
                workOrder = c.WorkOrders[0];
                System.debug('WorkOrder fetched successfully: ' + workOrder);
                System.debug('WorkOrder fetched Root_Cause_Technical_Issue__c: ' + workOrder.Root_Cause_Technical_Issue__c);
            }
            System.debug('Case fetched successfully: ' + c);
        } catch (Exception e) {
            System.debug('Error fetching Case: ' + e.getMessage());
            return  14400; // Default value if Case fetch fails
        }
        
        // Fetch MilestoneType details
        MilestoneType mt;
        try {
            mt = [SELECT Name FROM MilestoneType WHERE Id = :milestoneTypeId];
            System.debug('MilestoneType fetched successfully: ' + mt);
        } catch (Exception e) {
            System.debug('Error fetching MilestoneType: ' + e.getMessage());
            return 14400; // Default value if MilestoneType fetch fails
        }
        System.debug('Account.Name fetched successfully: ' + c.Account.Name);
        // Default trigger time
        Integer triggerTime = 14400;
         String accName = c.Account.Name;
        //Axis Bank
        if(accName.equalsIgnoreCase('Axis Bank') || accName.equalsIgnoreCase('Axis Bank Limited')){
            System.debug('If Axis Bank: ' + c.Account.Name);
            if (workOrder != null && workOrder.Root_Cause_Technical_Issue__c != null && (c.Account.SLA_Classification__c == 'Metro' || c.Account.SLA_Classification__c == 'Non Metro' || c.Account.SLA_Classification__c == 'Rural' || c.Account.SLA_Classification__c == 'Semi urban' || c.Account.SLA_Classification__c == 'Urban')) {
                System.debug('If Axis Bank: ' + workOrder);
                switch on workOrder.Root_Cause_Technical_Issue__c {
                    //Minor Calls
                    when 'Failure of Electrical Components Like Capacitor, Relays, Contactor, MCB, Sensors',
                        'Filter Choke',
                        'HP / LP Tripping',
                        'Water Leakage' {
                            if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                triggerTime = 1440;
                            } else { 
                                triggerTime = 14400;
                            }
                        }
                    //Major Calls
                    when 'Refrigerant System Failure',
                        'Gas Leak / Top Up',
                        'Expansion Valve',
                        'Compressor Failure',
                        'Fan Motor',
                        'Controllers / Display / PCB' {
                            if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                triggerTime = 3360;
                                System.debug('If Axis Bank: ' + workOrder);
                            } else { 
                                triggerTime = 14400;
                            }
                        }
                    when else {
                        triggerTime = 14400; // Default value if no match found
                    }
                }
            }
        }
            //Axis Bank
            // Wipro GE Healthcare
            else  if ((accName.equalsIgnoreCase('Wipro GE Healthcare')  || accName.equalsIgnoreCase('Wipro GE Healthcare Private Limited')) && workOrder != null && workOrder.Root_Cause_Technical_Issue__c != null  ) {
                System.debug('If Wipro GE Healthcare : ' + c.Account.Name);
                if( c.Account.SLA_Classification__c == 'Class A'){
                    switch on workOrder.Root_Cause_Technical_Issue__c {
                        //Minor Calls
                        when 'Failure of Electrical Components Like Capacitor, Relays, Contactor, MCB, Sensors',
                            'Filter Choke',
                            'HP / LP Tripping',
                            'Water Leakage' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 1440;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        //Major Calls
                        when 'Refrigerant System Failure',
                            'Gas Leak / Top Up',
                            'Expansion Valve',
                            'Compressor Failure',
                            'Fan Motor',
                            'Controllers / Display / PCB' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 4320;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        when else {
                            triggerTime = 14400; // Default value if no match found
                        }
                    }
                }
                else if( c.Account.SLA_Classification__c == 'Class B')
                {
                    switch on workOrder.Root_Cause_Technical_Issue__c {
                        //Minor Calls
                        when 'Failure of Electrical Components Like Capacitor, Relays, Contactor, MCB, Sensors',
                            'Filter Choke',
                            'HP / LP Tripping',
                            'Water Leakage' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 2880;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        //Major Calls
                        when 'Refrigerant System Failure',
                            'Gas Leak / Top Up',
                            'Expansion Valve',
                            'Compressor Failure',
                            'Fan Motor',
                            'Controllers / Display / PCB' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 14400760;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        when else {
                            triggerTime = 14400; // Default value if no match found
                        }
                    }
                }
                else if( c.Account.SLA_Classification__c == 'Class C')
                {
                    switch on workOrder.Root_Cause_Technical_Issue__c {
                        //Minor Calls
                        when 'Failure of Electrical Components Like Capacitor, Relays, Contactor, MCB, Sensors',
                            'Filter Choke',
                            'HP / LP Tripping',
                            'Water Leakage' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 4320;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        //Major Calls
                        when 'Refrigerant System Failure',
                            'Gas Leak / Top Up',
                            'Expansion Valve',
                            'Compressor Failure',
                            'Fan Motor',
                            'Controllers / Display / PCB' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 7200;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        when else {
                            triggerTime = 14400; // Default value if no match found
                        }
                    }
                }
                else if( c.Account.SLA_Classification__c == 'J&K / Northeast')
                {
                    switch on workOrder.Root_Cause_Technical_Issue__c {
                        //Minor Calls
                        when 'Failure of Electrical Components Like Capacitor, Relays, Contactor, MCB, Sensors',
                            'Filter Choke',
                            'HP / LP Tripping',
                            'Water Leakage' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 7200;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        //Major Calls
                        when 'Refrigerant System Failure',
                            'Gas Leak / Top Up',
                            'Expansion Valve',
                            'Compressor Failure',
                            'Fan Motor',
                            'Controllers / Display / PCB' {
                                if (mt.Name != null && mt.Name.equals('Turn Around Time')) { 
                                    triggerTime = 10080;
                                } else { 
                                    triggerTime = 14400;
                                }
                            }
                        when else {
                            triggerTime = 14400; // Default value if no match found
                        }
                    }
                }
            }
            //Wipro GE Healthcare 
        
        //Rural : 8 Working Days
        //Non-Metro : 5 working day also for urban and semiurban
        //Metro : 2 working days
        //HDFC Bank
        else if(accName.equalsIgnoreCase('HDFC Bank') || accName.equalsIgnoreCase('HDFC Bank Limited')){
             System.debug('If HDFC Bank: ' + c.Account.Name);
              System.debug('If HDFC Bank: ' + c.Account.SLA_Classification__c);
            if(c.Account.SLA_Classification__c == 'Metro'){
                 System.debug('If HDFC Bank: ' + c.Account.Name);
                triggerTime = 2880;
            }
            else if(c.Account.SLA_Classification__c == 'Non Metro'){
                triggerTime = 7200;
            }
            else if(c.Account.SLA_Classification__c == 'Rural'){
                triggerTime = 11520;
            }
            else if(c.Account.SLA_Classification__c == 'Semi urban'){
                triggerTime = 7200;
            }
            else if(c.Account.SLA_Classification__c == 'Urban'){
                triggerTime = 7200;
            }
        } //HDFC Bank
        
        System.debug('Calculated Trigger Time: ' + triggerTime);
        return triggerTime;
    }
}