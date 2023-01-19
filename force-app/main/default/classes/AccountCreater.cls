public without sharing class AccountCreater {
    
    public void create(Integer numbOfAcc) {
        List<Account> accs = new List<Account>();
        List<Country__c> allcountrys = [SELECT id, Name, ISO_Country_Code__c FROM Country__c];
        Integer numbOfCountrys = allcountrys.size();
        if (numbOfCountrys > numbOfAcc) {
            throw new IllegalArgumentException('Number of Accounts can\'t be lower than number of countries');
        }
        List<Integer> numbAccInCountries = createRandNumber(numbOfCountrys, numbOfAcc);
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
    
    private List<Integer> createRandNumber(Integer amount, Integer sum) {
        List<Integer> randNumbers = new List<Integer>();
        randNumbers.add(0);
        randNumbers.add(sum);
        for (Integer i=1; i<amount ; i++) {
            Integer randNumber = Integer.valueOf(Math.random()*sum);
            randNumbers.add(randNumber);
        }
        randNumbers.sort();
        List<Integer> randValues = new List<Integer>();
        for (Integer j=0; j<amount; j++) {
            Integer value = randNumbers[j+1] - randNumbers[j];
            randValues.add(value);
        }
        return randValues;
    }
}