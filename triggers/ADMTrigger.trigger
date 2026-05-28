trigger ADMTrigger on ADM__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
    new ADMTriggerHandler().run();
}
    
/* Alterado conforme o novo padrão proposto 
(ou seja, uma trigger única responsável por disparar todos os gatilhos)
*/
/**
 * File Name : ADMTrigger.trigger
 *
 * @author Wipro Technologies
 * @since 16/05/2016
 * @version 1.0
 *
 * Project : Electrolux Brasil
 * Description : Trigger for the object ADM__c
 *
 * Change Control
 * -------------------------------------
 * Version   Date          Author                         Description
 * -------   ----------    --------------------           ---------------
 * 1.0       16/05/2016    Guilherme Nichetti             Trigger created
 */
/* 
trigger ADMTrigger on ADM__c (after update, before update) {
    
    // Instantiate the handler for this trigger
    ADMTriggerHandler handler = new ADMTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    
    
    
    // After Update
    if(Trigger.isAfter && Trigger.isUpdate) {
        handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
*/