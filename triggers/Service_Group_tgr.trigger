trigger Service_Group_tgr on Service_Group__c (before insert, before update) {
	
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		EspelhoTradutor_DSM ET = new EspelhoTradutor_DSM();
		ET.SyncFields('Service_Group__c', (list<Service_Group__c>)Trigger.old, (list<Service_Group__c>)Trigger.new, Trigger.isInsert, Trigger.isUpdate);
	}
}