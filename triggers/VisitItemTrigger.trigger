trigger VisitItemTrigger on VisitItem__c (after update) {

    new VisitITemTH().run();

}