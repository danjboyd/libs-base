/* An NS_OPTIONS type is a set of flags: its constants combine with | into
   values of the type, which keeps the size of its integer type.  The macro
   gives the type the flag_enum and open enum_extensibility attributes, as
   Cocoa's does, so that Swift imports it as an OptionSet. */
#import "Testing.h"
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, GSTestOptions)
{
  GSTestOptionNone = 0,
  GSTestOptionFirst = 1 << 0,
  GSTestOptionSecond = 1 << 1
};

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  GSTestOptions		options = GSTestOptionFirst | GSTestOptionSecond;
  NSEnumerationOptions	enumeration
    = NSEnumerationConcurrent | NSEnumerationReverse;

  START_SET("NS_OPTIONS")

  PASS(sizeof(GSTestOptions) == sizeof(NSUInteger)
    && sizeof(NSEnumerationOptions) == sizeof(NSUInteger),
    "an NS_OPTIONS type has the size of its integer type");
  PASS(options == 3 && (options & GSTestOptionSecond),
    "NS_OPTIONS constants combine into a value of the type");
  PASS(enumeration == (1 << 0 | 1 << 1),
    "NSEnumerationOptions constants combine as before");

  END_SET("NS_OPTIONS")

  [arp release];
  return 0;
}
