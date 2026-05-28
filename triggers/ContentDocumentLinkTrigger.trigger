/**
 * @author Daniel Affeldt - BRQ
 */
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    new ContentDocumentLinkTH().run();
}