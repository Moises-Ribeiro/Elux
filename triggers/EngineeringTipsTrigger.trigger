trigger EngineeringTipsTrigger on EngineeringTips__c (before insert, before update, after insert, after update) {
    new EngineeringTriggerHandler().run();
}