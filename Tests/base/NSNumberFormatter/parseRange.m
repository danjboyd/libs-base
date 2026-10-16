/*
 * parseRange.m - regression test for
 * -[NSNumberFormatter getObjectValue:forString:range:error:], whose
 * NSDecimalNumber branch (the one used by default) was compiled out, so
 * the method answered NO with generatesDecimalNumbers set.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSNumberFormatter	*f;
  NSRange		r;
  id			v;
  BOOL			ok;

  f = AUTORELEASE([NSNumberFormatter new]);
  [f setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
  [f setNumberStyle: NSNumberFormatterDecimalStyle];

  START_SET("-getObjectValue:forString:range:error:")
    [f setGeneratesDecimalNumbers: YES];
    v = nil;
    r = NSMakeRange(0, 7);
    ok = [f getObjectValue: &v forString: @"1,234.5" range: &r error: NULL];
    PASS(ok, "a decimal number parses")
    PASS([v isKindOfClass: [NSDecimalNumber class]],
      "with generatesDecimalNumbers the value is an NSDecimalNumber")
    PASS_EQUAL([v description], @"1234.5", "the decimal value is exact")
    PASS(r.location == 0 && r.length == 7, "the range is the parsed text")

    v = nil;
    r = NSMakeRange(2, 4);
    ok = [f getObjectValue: &v forString: @"x 42 y" range: &r error: NULL];
    PASS(ok && [[v description] isEqual: @"42"],
      "parsing starts at the range's location")
    PASS(r.location == 2 && r.length == 2,
      "the range is narrowed to the number")

    v = @"unset";
    r = NSMakeRange(0, 3);
    ok = [f getObjectValue: &v forString: @"abc" range: &r error: NULL];
    PASS(ok == NO && v == nil, "text that is not a number fails")

    [f setGeneratesDecimalNumbers: NO];
    v = nil;
    r = NSMakeRange(0, 7);
    ok = [f getObjectValue: &v forString: @"1,234.5" range: &r error: NULL];
    PASS(ok && [v doubleValue] == 1234.5
      && [v isKindOfClass: [NSDecimalNumber class]] == NO,
      "without generatesDecimalNumbers the value is an NSNumber")
  END_SET("-getObjectValue:forString:range:error:")

  [arp release];
  return 0;
}
