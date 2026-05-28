/********************************************************************************************************
* Trigger que atualiza o proprietario do informativo.                                                   *
*                                                                                                       *
* #01   Flavio Candian          18/02/2010          Criação da trigger                                  *
/*******************************************************************************************************/

/***************************************************************************************************************************
* Avanxo Brasil
* Author:           Joseph Ceron  href=<jceron@avanxo.com>
* Project:          Electrolux
* Description:      o
*
* Changes (Versions)
* -------------------------------------
*           No.     Date            Author                   Description
*           -----   ----------      --------------------    ---------------
* @version  2        30/11/2016     Joseph Ceron            Clase criada     
* @version  3        07/12/2017     Bruno Soares            Adicionado condicional para acionamento da trigger - Line 43 

CHG0124329 -- mar/2020 -- Renata Bicudo -- Adicionado debug para depuração futura

***************************************************************************************************************************/

trigger AtualizaInformativoCabecalho on Informativo__c (before insert, before update, after update) {

    Set<String> an8 = new Set<String>();
    List<Informativo__c> listInfos = new List<Informativo__c>();
    System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] ..START..');
    for(Informativo__c info: Trigger.new){
        
        an8.add(info.AN8_Fornecedor__c);
        System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] - info.AN8_Fornecedor__c : ' + info.AN8_Fornecedor__c);
    }
    List<User> listaUsusarios = [Select Id,AN8_Fornecedor__c
                                   from User
                                  where AN8_Fornecedor__c in :an8];
    System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] - Quantidade registros na lista = '+listaUsusarios.size());
    Map<String,User> mapaUser = new Map<String,User>();
    
    //Cria o mapa usando como chave o AN8 
    for(Integer i=0;i<listaUsusarios.size();i++){
        mapaUser.put(listaUsusarios.get(i).AN8_Fornecedor__c,listaUsusarios.get(i));    
    }
    //Atualiza o proprietario do informativo
    for(Informativo__c info: Trigger.new){
        if(trigger.isBefore){
        try{
            String sAn8 = info.AN8_Fornecedor__c;
            System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] - AN8 : ' + sAn8);
            info.OwnerId = mapaUser.get(sAn8).Id; 

        }catch(Exception e){
            System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] - Não foi possivel atribuir o proprietário no informativo');
            System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] - e.getMessage() : ' + e.getMessage());
        }  
       }
    }
    

    // Joseph Ceron Chamado a clase de informativo 20122016
    if(trigger.isInsert){
    
    }
    else if(trigger.isUpdate && trigger.isAfter)
    {
        System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] - Ingreso Trigger pago');
        DSAP_Informativo_cls.InfoProcess(trigger.new,trigger.oldMap);
        
    }else if(trigger.isUpdate && trigger.isBefore){
        DSAP_Informativo_cls.DatadeProcessamento(trigger.new,trigger.oldMap);
    }
    System.debug('__[cls AtualizaInformativoCabecalho - Informativo__c] ..END..');

}