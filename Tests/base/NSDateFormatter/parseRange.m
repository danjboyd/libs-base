#import "ObjectTesting.h"
#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSDate.h"
#import "Foundation/NSDateFormatter.h"
#import "Foundation/NSError.h"
#import "Foundation/FoundationErrors.h"
#import "Foundation/NSString.h"
#import "Foundation/NSTimeZone.h"

/* -getObjectValue:forString:range:error: parses the date in a range of the
 * string and answers the range it used.  It used to answer NO for any
 * string.
 */
int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSDateFormatter	*formatter;
  NSString		*string = @"on 2001-01-01 at noon";
  NSRange		range;
  id			parsed = nil;
  NSError		*error = nil;
  BOOL			ok;

  formatter = [[NSDateFormatter alloc] init];
  [formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
  [formatter setDateFormat: @"yyyy-MM-dd"];
  [formatter setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];

  range = NSMakeRange(3, 18);
  ok = [formatter getObjectValue: &parsed
                       forString: string
                           range: &range
                           error: &error];
  PASS(ok, "a date at the start of the range is parsed")
  PASS_EQUAL(parsed, [NSDate dateWithTimeIntervalSinceReferenceDate: 0.0],
    "the parsed date is the one in the range")
  PASS(range.location == 3 && range.length == 10,
    "the range is set to the characters parsed")

  ok = [formatter getObjectValue: &parsed
                       forString: @"2001-01-01"
                           range: NULL
                           error: NULL];
  PASS(ok, "without a range the whole string is parsed")

  parsed = nil;
  range = NSMakeRange(0, 2);
  ok = [formatter getObjectValue: &parsed
                       forString: string
                           range: &range
                           error: &error];
  PASS(ok == NO && parsed == nil, "a range without a date is not parsed")
  PASS([[error domain] isEqualToString: NSCocoaErrorDomain]
    && [error code] == NSFormattingError,
    "the error is a formatting error")

  RELEASE(formatter);
  [arp release];
  return 0;
}
