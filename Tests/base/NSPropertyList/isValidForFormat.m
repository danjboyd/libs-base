#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSPropertyList.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  Class			s = [NSPropertyListSerialization class];
  NSDictionary		*dict;
  NSNumber		*num = [NSNumber numberWithInt: 42];
  NSDate		*date = [NSDate date];

  START_SET("NSPropertyListSerialization propertyList:isValidForFormat:")

  dict = [NSDictionary dictionaryWithObject:
    [NSArray arrayWithObjects: @"a", @"b", nil] forKey: @"key"];

  PASS([s propertyList: dict isValidForFormat: NSPropertyListXMLFormat_v1_0],
    "a dictionary of string arrays is valid XML")
  PASS([s propertyList: dict isValidForFormat: NSPropertyListOpenStepFormat],
    "a dictionary of string arrays is valid OpenStep")
  PASS([s propertyList: dict
    isValidForFormat: NSPropertyListBinaryFormat_v1_0],
    "a dictionary of string arrays is valid binary")

  PASS([s propertyList: num isValidForFormat: NSPropertyListXMLFormat_v1_0],
    "a number is valid XML")
  PASS([s propertyList: date isValidForFormat: NSPropertyListXMLFormat_v1_0],
    "a date is valid XML")
  PASS([s propertyList: num isValidForFormat: NSPropertyListGNUstepFormat],
    "a number is valid in the GNUstep format")
  PASS(NO == [s propertyList: num isValidForFormat: NSPropertyListOpenStepFormat],
    "a number is not valid OpenStep")

  dict = [NSDictionary dictionaryWithObject: num forKey: @"key"];
  PASS([s propertyList: dict isValidForFormat: NSPropertyListXMLFormat_v1_0],
    "a dictionary holding a number is valid XML")
  PASS(NO == [s propertyList: dict isValidForFormat: NSPropertyListOpenStepFormat],
    "a dictionary holding a number is not valid OpenStep")

  dict = [NSDictionary dictionaryWithObject: [NSNull null] forKey: @"key"];
  PASS(NO == [s propertyList: dict isValidForFormat: NSPropertyListXMLFormat_v1_0],
    "a dictionary holding a null is not valid XML")

  END_SET("NSPropertyListSerialization propertyList:isValidForFormat:")

  [arp release];
  return 0;
}
