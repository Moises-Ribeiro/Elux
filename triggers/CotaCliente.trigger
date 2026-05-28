trigger CotaCliente on CotaCliente__c (before insert, before update, after insert, after update){

    if( Trigger.isBefore ){
        
        if( Trigger.isInsert ){
        	CotaClienteBO.getInstance().preencherCodigo( Trigger.new , null );
    	}
        else if( Trigger.isUpdate ){
      		CotaClienteBO.getInstance().preencherCodigo( Trigger.new , Trigger.oldMap );
    	}
    }
    else if( Trigger.isAfter ){
        if( Trigger.isInsert ){
        
    	}
        else if( Trigger.isUpdate ){
        
    	}
    }
}