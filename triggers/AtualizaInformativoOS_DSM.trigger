/**
* Avanxo Colombia
* @author           Oscar angel href=<oangel@avanxo.com>
* @version 1.1
* Proyect:          Electrolux Brasil
* Description:      Trigger Class 
*
* Changes (Version)
* -------------------------------------
*           No.     Fecha           Autor                   Descripción
*           -----   ----------      --------------------    ---------------
* version   1.0     2015-01-13      Oscar Angel (OA)        Create Trigger
* version   1.1     2016-07-26      Rodrigo Lara            Fixed logical issue for update within a for
* version   1.2     2018-03-14      Gabriel Dias            Permitir alteração na OS somenete se o Status Electrolux for diferente de Bloqueada
CHG0124329 -- mar/2020 -- Renata Bicudo -- Adicionado um critério de entrada antes das funcionalidades

*************************************************************************************************************/
trigger AtualizaInformativoOS_DSM on Informativo_detalhe__c (before insert, after insert, before update, after update) {
    
    System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] ..START.. ');
    System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - '+
                 (trigger.isbefore? 'before ':'after ') + (trigger.isinsert? 'insert' : 'update'));
    if(trigger.isBefore){
        Id      InfoId;
        String  sOSNumber;
        String  sUser;
        String  sAN8;
        Boolean bPago;
        Boolean flagTemp; //flag que verificar se o registro ainda está como temporário
        
        //#02 - Inicio
        Date    dProcessa;
        //#02 - Fim
        
        Set<Id>     idsInformativo  = new Set<Id>();
        Set<Id>     idsOs           = new Set<Id>();
        Set<String> numeroOS        = new Set<String>(); 
        
        //Recupera valores do detalhe do informativo
        for (Informativo_detalhe__c info:trigger.new){
            sOSNumber   = info.Name;
            InfoId      = info.Informativo__c;
            flagTemp    = info.DSPA_tempIntegracao__c;
           
            if(flagTemp == true){    //adiciona na lista apenas os registros que não estão marcados como temporários.
              numeroOS.add(sOSNumber);
              idsInformativo.add(InfoId);             
            }
            info.DSPA_tempIntegracao__c = false;
            System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - info.DSPA_tempIntegracao__c : ' + info.DSPA_tempIntegracao__c);
            System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - sOSNumber : ' + sOSNumber);
            System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - InfoId : ' + InfoId);
            System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - dProcessa : ' + dProcessa);
        }
        
        System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - idsInformativo.size() : ' +idsInformativo.size());
        
        if(idsInformativo.size() == 0) // Lista vazia não executa os códigos abaixo.
          return ;
     
        List<Service_Order__c> listaOS = [Select Name,Id,Order_Status__c,Status_electrolux__c,Order_Type__c,Mensagem_OS_bloqueada__c,
                                                (Select id,Product__r.Name,Aprova_o__c,Peca_paga__c,Mensagem_OS_bloqueada__c From R00N70000001qVi7EAE__r where Bloqueado__c != true)
                                                   from Service_Order__c
                                                  where Name in :numeroOS];
                                                
        Map<String,Service_Order__c> mapaOS = new Map<String,Service_Order__c>();
        
        for(Service_Order__c serviceOrder :  listaOS){
            mapaOS.put(serviceOrder.Name, serviceOrder);
        }
                                                  
        Set<Id> serviceOrderIds = ListHelper.convertToSetIds(listaOS);
       
        List<Service_Order_Line__c> serviceOrderLines = [SELECT id, Mensagem_OS_bloqueada__c, Service_Order__c
                                            FROM Service_Order_Line__c 
                                            WHERE Bloqueado__c != true
                                            AND Service_Order__c in: serviceOrderIds];
        Map<Id, List<Service_Order_Line__c>> serviceOrderLinesByServiceOrderId = new Map<Id, List<Service_Order_Line__c>>();
        for(Service_Order_Line__c serviceOrderLine : serviceOrderLines ){
            List<Service_Order_Line__c> sOLines = serviceOrderLinesByServiceOrderId.get(serviceOrderLine.Service_Order__c);
            if(sOLines == null ){
                sOLines = new List<Service_Order_Line__c>();
            }
            sOLines.add(serviceOrderLine);
            serviceOrderLinesByServiceOrderId.put(serviceOrderLine.Service_Order__c,sOLines);
        }

        Map<Id,Informativo__c> mapaInfo = new Map<Id,Informativo__c>([Select Id,
                                                                             Pago__c,
                                                                             AN8__c,
                                                                             Data_do_Processamento__c
                                                                        from Informativo__c
                                                                       where Id in :idsInformativo]);
        List<Service_Order__c> osList = new List<Service_Order__c>();
        //Seleciona o informativo   
        List<Service_Order_Line__c> serviceOrderLinesToUpdate = new List<Service_Order_Line__c>();
        
        for(Informativo_detalhe__c infoDetalhe:trigger.new){
            try{
                bPago = mapaInfo.get(infoDetalhe.Informativo__c).Pago__c;
                sAN8  = String.valueOf(mapaInfo.get(infoDetalhe.Informativo__c).AN8__c);
                infoDetalhe.ID_Ordem_de_Servico_DSM__c = mapaOS.get(infoDetalhe.Name).Id;       
            } catch (Exception e){
                System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - Não foi possível identificar o informativo');
                System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - e.getMessage() : ' + e.getMessage());
            }
            
            //Atribui o Status dependendo da informação encontrada no informativo
            try {
                Id idOs = mapaOS.get(infoDetalhe.Name).Id;
                boolean aprovado=true;
               //OA:ajuste Service_Order__c os = new Service_Order__c(id=mapaOS.get(infoDetalhe.Name).Id);
                Service_Order__c os = mapaOS.get(infoDetalhe.Name);
                System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - os : ' + os);
                
                /* Gabriel Dias - 2018.03.14 - START - Permitir alteração na OS somenete se o Status Electrolux for diferente de Bloqueada */   
                    if (bPago == true){
                        if( os.Status_electrolux__c != 'Bloqueada'){
                            os.Status_electrolux__c = 'Paga';
                        }
                        os.Data_de_processamento__c = mapaInfo.get(infoDetalhe.Informativo__c).Data_do_Processamento__c; 
                        
                        System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - STATUS ALTERADO PARA PAGA');
                    }else{
                        if( os.Status_electrolux__c == 'Bloqueada'){
                            Integer dia =  mapaInfo.get(infoDetalhe.Informativo__c).Data_do_Processamento__c.day();
                        	Integer mes =  mapaInfo.get(infoDetalhe.Informativo__c).Data_do_Processamento__c.month();
                        	Integer ano =  mapaInfo.get(infoDetalhe.Informativo__c).Data_do_Processamento__c.year();
                            date myDate = date.newInstance(ano, mes, dia);
                           
                            List<Service_Order_Line__c> sOLines = serviceOrderLinesByServiceOrderId.get(os.Id);
                            if(sOLines != null){
                                for(Service_Order_Line__c SVO: sOLines){
                                    SVO.Mensagem_OS_bloqueada__c = system.label.ErroInformativoOSBloqueada + ' ' + myDate.format();
                                }
                                serviceOrderLinesToUpdate.addAll(sOLines);
                            }
                            os.Mensagem_OS_bloqueada__c = system.label.ErroInformativoOSBloqueada + ' ' + myDate.format();
                            os.Tipo_de_Analise__c = '';
                            os.Data_do_Pagamento__c=null;//OA: fica nula baseado no requerimento 23 planilha ocorrencias
                        }else{
                            os.Status_electrolux__c = 'Aguardando envio de nota fiscal';
                            os.Tipo_de_Analise__c = '';
                            os.Data_do_Pagamento__c=null;//OA: fica nula baseado no requerimento 23 planilha ocorrencias
                            os.Data_de_processamento__c = mapaInfo.get(infoDetalhe.Informativo__c).Data_do_Processamento__c; 
                        }
                        
                        System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - STATUS ALTERADO PARA Aguardando envio de nota fiscal');
                    }
                    
                    System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - Entra valida 1--->'+os.Order_Status__c+' - '+os.Status_electrolux__c+ ' - '+os.Order_Type__c);
                    //OA: atualiza data de contabilizacao baseado nos criterios do requerimento 23 planilha ocorrencias
                    //@juliana
                    if((os.Order_Status__c=='Encerrada' && os.Status_electrolux__c=='Aguardando contabilização'
                        && os.Order_Type__c=='Fora de Garantia com autorização') ||(os.Order_Status__c=='Encerrada' && os.Status_electrolux__c=='Aguardando contabilização'
                        && os.Data_do_Pagamento__c !=null )){
                        
                        //OA: confirma se os item da OS estão aprovados e a mão de obra não esta aprovada
                        for(Service_Order_Line__c itemOs:mapaOS.get(infoDetalhe.Name).R00N70000001qVi7EAE__r){
                            if(itemOs.Aprova_o__c && itemOs.Product__r.Name.contains('999007')){
                                System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - Entra valida 2'); 
                                aprovado=false;
                                break;//se é encontrado um item aprovado de mão de obra aprovada, o ciclo termina e fica false
                            }
                            if((!itemOs.Peca_paga__c || !itemOs.Aprova_o__c) && itemOs.Product__r.Name==infoDetalhe.Codigo_do_item__c){
                                System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - Entra valida 3');
                                aprovado=false;
                                break; //se o item tem Peca_paga__c = false ou Aprova_o__c = false é terminado o clico e fica false
                            } 
                        }
                        System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - Entra valida 4---->'+aprovado);
                        if(aprovado)
                            os.Data_do_Pagamento__c=infoDetalhe.CreatedDate.date();
                    }                
                    //--------------------------------------------------------------------------------------------------
                
                /* Gabriel Dias - 2018.03.14 - FINISH */
                //oa: 11-02-2017 osList.add(os);
                System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - SVO adicionada para update : ' + os.Id);
            } catch (Exception e){
                System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - e.getMessage() : ' + e.getMessage());
            }
        }
        if(!serviceOrderLinesToUpdate.isEmpty()){update serviceOrderLinesToUpdate;}
        
        if(!mapaOS.isEmpty()) {
             List<Database.SaveResult> resultSVO = Database.Update(mapaOS.values(), false);
             for(Integer i = 0; i < resultSVO.size(); i++) {
                if(!resultSVO.get(i).isSuccess()) {
                    Database.Error error = resultSVO.get(i).getErrors().get(0);
                    //System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - SVO não foi atualizada : ' 
                    //    + osList.get(i).Id
                    //    + ' - '
                    //    + error.getMessage());
                }
             }
        }
        else {
            System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] - Nenhuma OS encontrada para Update');
        }
    }
    
    /*if(trigger.isAfter){
        System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] >> ItemInformativoBO_DSM.atualizaQesSer(trigger.New)');
        ItemInformativoBO_DSM.getInstance().atualizaQesSer(trigger.New);
    }*/
    System.debug('__[trg AtualizaInformativoOS_DSM - Informativo_detalhe__c] ..END.. ');
}