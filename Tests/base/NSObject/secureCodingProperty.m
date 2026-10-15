/* NSSecureCoding declares supportsSecureCoding as a class property, as
   Cocoa does, so Swift imports it as a static property that a Swift class
   adopting the protocol implements with a static var.  It was a class
   method, which Swift imports as a static function.  An Objective-C class
   still implements it as the class method +supportsSecureCoding. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface SecureThing : NSObject <NSSecureCoding>
@end

@implementation SecureThing
+ (BOOL) supportsSecureCoding
{
  return YES;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
}
- (id) initWithCoder: (NSCoder *)coder
{
  return [self init];
}
@end

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSSecureCoding class property")

#if __has_feature(objc_class_property)
  PASS(protocol_getProperty(@protocol(NSSecureCoding),
    "supportsSecureCoding", YES, NO) != NULL,
    "NSSecureCoding declares supportsSecureCoding as a class property");
#endif
  PASS([SecureThing supportsSecureCoding] == YES,
    "a class implements the property with a class method");
  PASS([SecureThing conformsToProtocol: @protocol(NSSecureCoding)],
    "the class conforms to NSSecureCoding");
  PASS([NSString supportsSecureCoding] == YES,
    "a Foundation class answers YES");

  END_SET("NSSecureCoding class property")

  [arp release];
  return 0;
}
