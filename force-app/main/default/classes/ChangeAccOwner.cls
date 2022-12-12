public class ChangeAccOwner implements Schedulable{
    public void execute(SchedulableContext ctx) {
        AccountOwnerChanger accOwnChn = new AccountOwnerChanger();
        accOwnChn.onLeadOwners();
    }
}
