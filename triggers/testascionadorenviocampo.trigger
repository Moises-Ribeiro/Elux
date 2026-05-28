// Trigger inativada, já não foi mais usada
trigger testascionadorenviocampo on ADM__c (before insert, before update) {
	ADM__c objADM = new ADM__c ();
    objADM.testechange__c = trigger.new.get(0).testechange__c; 
}