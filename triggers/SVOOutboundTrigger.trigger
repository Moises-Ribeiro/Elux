/* #01 Data: 01/08/2014 -  Criação da trigger - Rodrigo Francis da Silva
   #02 - Rodrigo Francis - 05/08/2014 - Inserção do Método SVOOutboundBO para OS da TOP Services 
   #03 - Rodrigo Francis - 24/09/2014 - Alteração do método para realizar no update e não do insert
   #04 - Rodrigo Francis - 24/09/2014 - Alteração do método para realizar no update e no insert
   #05 - Rodrigo Francis - 26/09/2014 - Alteração na trigger para executar apenas quando for diferente do ADM
   #06 - Rodrigo Francis - 01-10-2014 - Alteração na trigger exceção ADM
*/

trigger SVOOutboundTrigger on SVO_Outbound__c (before update, before insert) {  
          if (Userinfo.getProfileId() <> '00e80000000jSodAAE'){
                 SVOOutboundRegras.executaRegras(trigger.new,'Update');  
          }             
}