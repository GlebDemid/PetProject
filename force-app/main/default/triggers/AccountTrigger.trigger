trigger AccountTrigger on Account (before update) {
    fflib_SobjectDomain.triggerHandler(Accounts.class);
}