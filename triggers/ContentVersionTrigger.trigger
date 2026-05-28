trigger ContentVersionTrigger on ContentVersion (after insert) {
    new ContentVersionTH().run();
}