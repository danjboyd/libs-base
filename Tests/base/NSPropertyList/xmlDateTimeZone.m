#import "ObjectTesting.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSPropertyList.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTimeZone.h>

/* 2026-11-03 20:04:06 UTC
 */
#define	WHEN	1793736246.0

static NSDate *
roundTrip(NSDate *date, NSPropertyListFormat format)
{
  NSDictionary	*plist;
  NSData	*data;

  plist = [NSDictionary dictionaryWithObject: date forKey: @"date"];
  data = [NSPropertyListSerialization dataWithPropertyList: plist
						    format: format
						   options: 0
						     error: NULL];
  plist = [NSPropertyListSerialization propertyListWithData: data
						    options: 0
						     format: NULL
						      error: NULL];
  return [plist objectForKey: @"date"];
}

static void
checkZone(NSString *name)
{
  NSDate	*date = [NSDate dateWithTimeIntervalSince1970: WHEN];
  NSDate	*once;
  NSDate	*twice;
  NSData	*xml;
  id		plist;
  NSString	*test;

  [NSTimeZone setDefaultTimeZone: [NSTimeZone timeZoneWithName: name]];

  once = roundTrip(date, NSPropertyListXMLFormat_v1_0);
  twice = roundTrip(once, NSPropertyListXMLFormat_v1_0);
  test = [NSString stringWithFormat: @"XML plist date survives a round trip in %@", name];
  PASS([once timeIntervalSince1970] == WHEN, "%s", [test UTF8String])
  test = [NSString stringWithFormat: @"XML plist date survives two round trips in %@", name];
  PASS([twice timeIntervalSince1970] == WHEN, "%s", [test UTF8String])

  xml = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    @"<plist version=\"1.0\"><date>2026-11-03T20:04:06Z</date></plist>"
    dataUsingEncoding: NSUTF8StringEncoding];
  plist = [NSPropertyListSerialization propertyListWithData: xml
						    options: 0
						     format: NULL
						      error: NULL];
  test = [NSString stringWithFormat: @"A date ending in Z is read as UTC in %@", name];
  PASS([plist isKindOfClass: [NSDate class]]
    && [plist timeIntervalSince1970] == WHEN, "%s", [test UTF8String])

  once = roundTrip(date, NSPropertyListBinaryFormat_v1_0);
  test = [NSString stringWithFormat: @"Binary plist date survives a round trip in %@", name];
  PASS([once timeIntervalSince1970] == WHEN, "%s", [test UTF8String])
}

int
main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  checkZone(@"UTC");
  checkZone(@"America/Chicago");
  checkZone(@"Asia/Tokyo");
  checkZone(@"Asia/Kolkata");
  [arp release];
  return 0;
}
