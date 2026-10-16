/*
 * components.m - regression test for
 * -[NSDateComponentsFormatter stringFromDateComponents:], which printed
 * every allowed unit (undefined ones as 9223372036854775807) and never
 * joined positional fields with colons.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool		*arp = [NSAutoreleasePool new];
  NSDateComponentsFormatter	*f;
  NSDateComponents		*c;

  c = AUTORELEASE([NSDateComponents new]);
  [c setHour: 1];
  [c setMinute: 5];

  START_SET("-stringFromDateComponents:")
    PASS_EQUAL([NSDateComponentsFormatter localizedStringFromDateComponents: c
      unitsStyle: NSDateComponentsFormatterUnitsStylePositional], @"1:05",
      "positional fields are joined with colons and undefined units left out")
    f = AUTORELEASE([NSDateComponentsFormatter new]);
    [f setUnitsStyle: NSDateComponentsFormatterUnitsStyleFull];
    PASS_EQUAL([f stringFromDateComponents: c], @"1 hour, 5 minutes",
      "the full style names each defined unit")
    [f setUnitsStyle: NSDateComponentsFormatterUnitsStyleAbbreviated];
    PASS_EQUAL([f stringFromDateComponents: c], @"1h 5m",
      "the abbreviated style uses unit letters")
    [c setSecond: 0];
    [f setUnitsStyle: NSDateComponentsFormatterUnitsStyleShort];
    PASS_EQUAL([f stringFromDateComponents: c], @"1 hr, 5 min",
      "the short style drops zero units by default")
    [f setUnitsStyle: NSDateComponentsFormatterUnitsStylePositional];
    PASS_EQUAL([f stringFromDateComponents: c], @"1:05:00",
      "positional fields keep trailing zeros")
    [f setZeroFormattingBehavior:
      NSDateComponentsFormatterZeroFormattingBehaviorPad];
    PASS_EQUAL([f stringFromDateComponents: c], @"01:05:00",
      "the pad behavior pads the first field")
    [f setZeroFormattingBehavior:
      NSDateComponentsFormatterZeroFormattingBehaviorDefault];
    [f setMaximumUnitCount: 1];
    [f setUnitsStyle: NSDateComponentsFormatterUnitsStyleFull];
    PASS_EQUAL([f stringFromDateComponents: c], @"1 hour",
      "maximumUnitCount limits the units shown")
  END_SET("-stringFromDateComponents:")

  [arp release];
  return 0;
}
