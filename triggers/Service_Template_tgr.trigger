trigger Service_Template_tgr on Service_Template__c (before insert, before update) {
	
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		EspelhoTradutor_DSM ET = new EspelhoTradutor_DSM();
		ET.SyncFields('Service_Template__c', (list<Service_Template__c>)Trigger.old, (list<Service_Template__c>)Trigger.new, Trigger.isInsert, Trigger.isUpdate);
	}
}