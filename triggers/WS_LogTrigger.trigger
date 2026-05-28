/**
 * File Name : WS_LogTrigger.trigger
 *
 * @author Wipro Technologies
 * @since 02/06/2016
 * @version 1.0
 *
 * Project : Electrolux Brasil
 * Description : Trigger for the object Service_Order__c
 *
 * Change Control
 * -------------------------------------
 * Version   Date          Author                         Description
 * -------   ----------    --------------------           ---------------
 * 1.0       02/06/2016    Rodrigo Lara                   Trigger created
 *
 */
trigger WS_LogTrigger on WS_Log__c (after insert, after update, before insert, before update) {
    // Instantiate the handler for this trigger
    WS_LogTriggerHandler handler = new WS_LogTriggerHandler(Trigger.isExecuting, Trigger.size);
    // After Insert
    if(Trigger.isAfter && Trigger.isInsert) {
        System.debug('[WS_LogTrigger] Handling After Insert');
        handler.handleAfterInsert(Trigger.new);
    }
    // After Update
    else if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('[WS_LogTrigger] Handling After Update');
        handler.handleAfterUpdate(Trigger.new);
    }
    // Before Insert
    else if(Trigger.isBefore && Trigger.isInsert) {
        System.debug('[WS_LogTrigger] Handling Before Insert');
        handler.handleBeforeInsert(Trigger.new);
    }
    // Before Update
    else if(Trigger.isBefore && Trigger.isUpdate) {
        System.debug('[WS_LogTrigger] Handling Before Update');
        handler.handleBeforeUpdate(Trigger.new);
    }
}