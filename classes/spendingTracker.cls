global class spendingTracker {
    
    @AuraEnabled
    global static Map<String, Decimal> spendingInformation() {
        Map<String, Decimal> spending = new Map<String, Decimal>();
        Id currentUser = UserInfo.getUserId();
        Date today = Date.today();
        Date sevenDaysAgo = Date.today().addDays(-7);
        Decimal todayAmount = 0;
        Decimal sevenDaysAmount = 0;
     	Decimal leftToSpend;
        List<Income_Spending__c> todaySpends = [SELECT Amount__c FROM Income_Spending__c WHERE CreatedById=:currentUser AND Spend_Date__c>=:today]; //Adding comment for test
        List<Income_Spending__c> sevenDaysSpends = [SELECT Amount__c FROM Income_Spending__c WHERE CreatedById=:currentUser AND Spend_Date__c>=:sevenDaysAgo];
        List<Targets__c> tList = [SELECT Target_Amount__c, Target_Date__c, CreatedDate FROM Targets__c WHERE OwnerId =:currentUser AND Target_Date__c >=:today ORDER BY Target_Date__c ASC NULLS LAST LIMIT 1];
       
        for(Income_Spending__c spend: todaySpends) {
            todayAmount+=spend.Amount__c;
        }
        spending.put('todayAmount', todayAmount);

        hellooo.sup();
        yo();
        
        for(Income_Spending__c sevenDaySpend : sevenDaysSpends) {
            sevenDaysAmount+=sevenDaySpend.Amount__c;
        }
        spending.put('sevenDaysAmount', sevenDaysAmount);
        
        if(tList.size()>0) {
            Targets__c t = tList[0];
            leftToSpend = t.Target_Amount__c;
            
            List<Income_Spending__c> spentSinceTargetInput = [SELECT Amount__c FROM Income_Spending__c WHERE CreatedById=:currentUser AND CreatedDate>=:t.CreatedDate];
        	
            for(Income_Spending__c spentSince : spentSinceTargetInput){
            	leftToSpend -= spentSince.Amount__c;
        	}
        
        
        List<String> targetDateBits = String.valueOf(Date.today()).split('-');
        Date targetDate = Date.newInstance(Integer.valueOf(targetDateBits[0]), Integer.valueOf(targetDateBits[1]), Integer.valueOf(targetDateBits[2]));
        Integer numberOfDaysLeftForTarget = targetDate.daysBetween(t.Target_Date__c);
        System.debug(numberOfDaysLeftForTarget);
        Decimal dailyAllowance = numberOfDaysLeftForTarget > 0 ? leftToSpend/numberOfDaysLeftForTarget: 0;
        
        spending.put('dailyAllowance', dailyAllowance);
        }
        else spending.put('dailyAllowance', 0);
        return spending;
            
    }
    
    @AuraEnabled
    global static void inputTarget(Decimal targetAmount, Integer dateLimit){
        Targets__c t = new Targets__c();
        t.Target_Amount__c = targetAmount;
        t.Target_Date__c = Date.today().addDays(dateLimit);
        insert t;
    }
    
    @AuraEnabled
    global static String inputSpend(String spendType, Decimal spendAmount) {
        String message = '';
        Income_Spending__c spend = new Income_Spending__c();
        spend.Amount__c = spendAmount;
        spend.Spend_date__c = Date.today();
        if(spendAmount > 200) message += 'Fy Faen Sigrid!';
        spend.Spending_Type__c = spendType;
        insert spend;
        return message;
    }

    private static void yo() {
        System.debug('yo');
    }

}