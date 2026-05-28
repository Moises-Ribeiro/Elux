trigger VisitChecklistTemplateTrigger on VisitChecklistTemplate__c (before update) {

    new VisitChecklistTemplateTH().run();

}