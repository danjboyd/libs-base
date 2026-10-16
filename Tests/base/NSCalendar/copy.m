/*
 * copy.m - regression test for -[NSCalendar copyWithZone:], which
 * answered the receiver itself for the default zone (a calendar is
 * mutable) and dropped the first weekday and minimum days in the first
 * week for other zones.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSCalendar		*cal;
  NSCalendar		*copy;
  NSTimeZone		*tz;

  START_SET("-[NSCalendar copyWithZone:]")
    cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    tz = [NSTimeZone timeZoneWithName: @"Europe/Paris"];
    [cal setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US"]];
    [cal setTimeZone: tz];
    [cal setFirstWeekday: 3];
    [cal setMinimumDaysInFirstWeek: 4];

    copy = [cal copy];
    PASS(copy != cal, "-copy answers a new calendar")
    PASS_EQUAL([copy calendarIdentifier], NSGregorianCalendar,
      "the copy has the calendar identifier")
    PASS_EQUAL([copy timeZone], tz, "the copy has the time zone")
    PASS([copy firstWeekday] == 3, "the copy has the first weekday")
    PASS([copy minimumDaysInFirstWeek] == 4,
      "the copy has the minimum days in the first week")
    [copy setFirstWeekday: 1];
    PASS([cal firstWeekday] == 3,
      "changing the copy leaves the original alone")
    [copy release];

    copy = [cal copyWithZone: NSCreateZone(1024, 1024, YES)];
    PASS([copy firstWeekday] == 3 && [copy minimumDaysInFirstWeek] == 4,
      "a copy in another zone has the week settings")
    [copy release];
    [cal release];
  END_SET("-[NSCalendar copyWithZone:]")

  [arp release];
  return 0;
}
