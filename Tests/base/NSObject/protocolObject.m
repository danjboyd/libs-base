/* A protocol object answers -class and -description, as a Cocoa protocol
   does through NSObject.  With libobjc2, Protocol is a subclass of the
   method-less root class Object, so a protocol answered no messages.
   Messaging a protocol needs the libobjc2 fix that gives each protocol
   class its own metaclass; on a runtime without it the set is skipped. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>

@protocol GSTestProtocolObject
- (void) gsTestProtocolObject;
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];

  START_SET("Protocol object messages")

#ifdef __GNUSTEP_RUNTIME__
  {
    Class	protocolClass = objc_getClass("Protocol");
    Class	gsv1 = objc_getClass("ProtocolGSv1");
    Protocol	*p = @protocol(GSTestProtocolObject);
    NSString	*d;

    if (gsv1 != Nil
      && object_getClass((id)gsv1) == object_getClass((id)protocolClass))
      {
	SKIP("the runtime does not give each protocol class its own metaclass")
      }

    PASS([(id)p class] == object_getClass((id)p),
      "-class answers the protocol object's class");
    d = [(id)p description];
    PASS([d isKindOfClass: [NSString class]]
      && [d hasPrefix: @"<Protocol: "],
      "-description answers Cocoa's form, \"<Protocol: address>\"");
    PASS([(id)p retain] == (id)p && [(id)p autorelease] == (id)p,
      "-retain and -autorelease answer the protocol");
    [(id)p release];
    PASS([(id)p isEqual: (id)p]
      && ![(id)p isEqual: (id)@protocol(NSObject)]
      && [(id)p hash] == [(id)p hash],
      "a protocol is equal only to itself");
    PASS([[NSArray arrayWithObject: (id)p] containsObject: (id)p],
      "a protocol can be kept in an array");
  }
#else
  SKIP("Protocol has its own methods with this runtime")
#endif

  END_SET("Protocol object messages")

  [pool release];
  return 0;
}
