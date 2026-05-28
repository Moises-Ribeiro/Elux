trigger InformativoMPTDetalhe_DeletaItensSaldoMPT_DSM on InformativoMPTdetalhe__c (after insert) {
    
    Set<String> idExterno = new Set<String>();
    for(InformativoMPTdetalhe__c f: trigger.new){
        String idEx = f.AN8_Formula__c+f.Codigo_item_formula__c+f.Nota_Fiscal__c;
        idExterno.add(idEx);
    }
    DeletaItensSaldoMPT_DSM.deletaSaldoMpt(idExterno);
}