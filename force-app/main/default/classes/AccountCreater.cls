public without sharing class AccountCreater {
    //create a number of Accounts and randomly connected them with all countries 
    public void aAccounts(Integer numbOfAcc) {
        List<Account> accs = new List<Account>();
        List<Country__c> allcountrys = [SELECT id, Name, ISO_Country_Code__c FROM Country__c];
        Integer numbOfCountrys = allcountrys.size();
        if (numbOfCountrys > numbOfAcc) {
            throw new IllegalArgumentException('Number of Accounts can\'t be lower than number of countries');
        }
        List<Integer> numbAccInCountries = nRandNumbInRange(numbOfCountrys, numbOfAcc);
        for (Integer i=0; i<numbOfCountrys; i++) {
            Country__c oneCountry = allcountrys[i];
            for (Integer j=0; j<numbAccInCountries[i]; j++) {
                Account newAccount = new Account();
                newAccount.Name = (oneCountry.Name + ' account №' + j);
                newAccount.BillingCountry = oneCountry.ISO_Country_Code__c;
                newAccount.Country__c = oneCountry.id;
                accs.add(newAccount);
            }
        }
        insert accs;
    }
    //create n random numbers with k summ
    static public List<Integer> nRandNumbInRange(Integer n, Integer k) {
        List<Integer> randNumbers = new List<Integer>();
        randNumbers.add(0);
        randNumbers.add(k);
        for (Integer i=1; i<n ; i++) {
            Integer randNumber = Integer.valueOf(Math.random()*k);
            randNumbers.add(randNumber);
        }
        randNumbers.sort();
        List<Integer> randValues = new List<Integer>();
        for (Integer j=0; j<n; j++) {
            Integer value = randNumbers[j+1] - randNumbers[j];
            randValues.add(value);
        }
        return randValues;
    }
}