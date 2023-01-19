trigger AccountTrigger on Account (before update, before Insert) {
    fflib_SobjectDomain.triggerHandler(Accounts.class);
}