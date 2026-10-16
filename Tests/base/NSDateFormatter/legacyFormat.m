/*
 * legacyFormat.m - regression test for -[NSDateFormatter stringFromDate:]
 * with the 10.0 behavior: a formatter made with
 * -initWithDateFormat:allowNaturalLanguage: has a strftime-style format
 * but formatted dates through ICU ("%Y-%m-%d" gave "%2001-%5-%3").
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSDateFormatter	*f;
  NSTimeZone		*tz;
  NSDate		*d;
  NSDate		*parsed = nil;

  tz = [NSTimeZone defaultTimeZone];
  d = [NSCalendarDate dateWithYear: 2001 month: 2 day: 3
			      hour: 4 minute: 5 second: 6 timeZone: tz];

  START_SET("10.0 behavior -stringFromDate:")
    f = AUTORELEASE([[NSDateFormatter alloc]
      initWithDateFormat: @"%Y-%m-%d" allowNaturalLanguage: NO]);
    PASS([f formatterBehavior] == NSDateFormatterBehavior10_0,
      "the formatter has the 10.0 behavior")
    PASS_EQUAL([f stringFromDate: d], @"2001-02-03",
      "-stringFromDate: uses the strftime-style format")
    PASS_EQUAL([f stringForObjectValue: d], @"2001-02-03",
      "-stringForObjectValue: uses the strftime-style format")
    PASS([f getObjectValue: &parsed forString: @"2001-02-03"
      errorDescription: NULL] && [[f stringFromDate: parsed]
      isEqual: @"2001-02-03"], "a formatted date reads back")
    f = AUTORELEASE([[NSDateFormatter alloc]
      initWithDateFormat: @"%H:%M:%S" allowNaturalLanguage: NO]);
    PASS_EQUAL([f stringFromDate: d], @"04:05:06",
      "time fields use the strftime-style format")
  END_SET("10.0 behavior -stringFromDate:")

  [arp release];
  return 0;
}
