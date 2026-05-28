trigger SendToRightExchangeTrigger on SendToRightExchange__e (after insert) {

    new SendToRightExchangeTH().run();

}