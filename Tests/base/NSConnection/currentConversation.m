/*
 * currentConversation.m - +[NSConnection currentConversation] answers the
 * conversation of the request the thread is handling, identified by the
 * connection that delivered it, and nil outside a request.  It used to
 * answer nil always.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

static NSConnection	*serverConnection = nil;

@interface	ConversationServer : NSObject
- (int) conversation;
@end

@implementation	ConversationServer
/* 1 when the request is in the server connection's conversation, 0 when
 * there is no conversation, 2 for any other.
 */
- (int) conversation
{
  id	c = [NSConnection currentConversation];

  return (c == serverConnection) ? 1 : ((c == nil) ? 0 : 2);
}

- (void) serve: (NSArray*)ports
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  serverConnection = [[NSConnection alloc]
    initWithReceivePort: [ports objectAtIndex: 0]
	       sendPort: [ports objectAtIndex: 1]];
  [serverConnection setRootObject: self];
  [[NSRunLoop currentRunLoop]
    runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 10.0]];
  [arp release];
}
@end

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSConnection currentConversation")
    ConversationServer	*server = [[ConversationServer new] autorelease];
    NSPort		*serverPort = [NSPort port];
    NSPort		*clientPort = [NSPort port];
    NSConnection	*client;
    NSDate		*limit;
    id			proxy;

    PASS([NSConnection currentConversation] == nil,
      "there is no conversation outside a request")

    [NSThread detachNewThreadSelector: @selector(serve:)
			     toTarget: server
			   withObject: [NSArray arrayWithObjects:
			     serverPort, clientPort, nil]];
    limit = [NSDate dateWithTimeIntervalSinceNow: 5.0];
    while (serverConnection == nil && [limit timeIntervalSinceNow] > 0)
      {
	[NSThread sleepForTimeInterval: 0.01];
      }
    [NSThread sleepForTimeInterval: 0.2];

    client = [[NSConnection alloc] initWithReceivePort: clientPort
					      sendPort: serverPort];
    [client setRequestTimeout: 5.0];
    [client setReplyTimeout: 5.0];
    proxy = [client rootProxy];
    PASS([proxy conversation] == 1,
      "a request is handled in the conversation of its connection")
    PASS([NSConnection currentConversation] == nil,
      "the conversation ends with the request")

    [client invalidate];
    [client release];
  END_SET("NSConnection currentConversation")

  [arp release];
  return 0;
}
