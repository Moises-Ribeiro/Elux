/**
 * @author ercarval - topi/brq
 */
@isTest
public class AbstractEventPublisherTest {

    @isTest
    public static void shouldPublishAccountOutboundEvent () {
        
        Account account = AccountFixtureFactory.newWithFakeId ('One');
        
        AbstractEventPublisher publisher = new AccountOutboundEventPublisherMock ();

        List<EventQueue> events = publisher.publish(new List<Account> {account});

        Assert.areEqual(1, events.size());

        EventQueue event = events.get(0);

        Assert.areEqual( account.Id , event.getObjectId());
        Assert.areEqual( 'SYNC_ACCOUNT_OUTBOUND' , event.getEventName());
        Assert.isNotNull( event.getEventId() );

    }

    public class AccountOutboundEventPublisherMock extends AbstractEventPublisher {

        override
        public EventQueue buildEvent( SObject record ) {

            Account account = (Account) record;

            return new EventBuilder().createOutboundEventFor('SYNC_ACCOUNT_OUTBOUND')
                                .forObjectId(account.Id)
                                .buildEvent();
        }

    }

}