trigger CaseTrigger on Case (before update, before Insert) {
    fflib_SobjectDomain.triggerHandler(Cases.class);
}