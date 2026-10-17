/*
 * ordinality.m - -[NSCalendar ordinalityOfUnit:inUnit:forDate:] answers
 * the position of the smaller unit that contains the date within the larger
 * unit, which was previously an unimplemented stub that always returned 0.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

#if	defined(GS_USE_ICU)
#define	NSCALENDAR_SUPPORTED	GS_USE_ICU
#else
#define	NSCALENDAR_SUPPORTED	1 /* Assume Apple support */
#endif

int main(void)
{
  START_SET("NSCalendar ordinalityOfUnit:inUnit:forDate:")
    NSCalendar		*cal;
    NSDateComponents	*c;
    NSDate		*d;

    if (NSCALENDAR_SUPPORTED == 0)
      {
        SKIP("NSCalendar not supported (no ICU)")
      }

    cal = [[NSCalendar alloc]
      initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    [cal setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];
    [cal setFirstWeekday: 1];
    [cal setMinimumDaysInFirstWeek: 1];

    c = [[NSDateComponents new] autorelease];
    [c setYear: 2015];
    [c setMonth: 2];
    [c setDay: 18];
    [c setHour: 12];
    [c setMinute: 30];
    [c setSecond: 45];
    d = [cal dateFromComponents: c];	// a Wednesday

    PASS([cal ordinalityOfUnit: NSCalendarUnitDay
                        inUnit: NSCalendarUnitMonth forDate: d] == 18,
      "the day of the month")
    PASS([cal ordinalityOfUnit: NSCalendarUnitDay
                        inUnit: NSCalendarUnitYear forDate: d] == 49,
      "the day of the year")
    PASS([cal ordinalityOfUnit: NSCalendarUnitWeekday
                        inUnit: NSCalendarUnitWeekOfMonth forDate: d] == 4,
      "the day of the week counts from the first weekday")
    PASS([cal ordinalityOfUnit: NSCalendarUnitMonth
                        inUnit: NSCalendarUnitYear forDate: d] == 2,
      "the month of the year")
    PASS([cal ordinalityOfUnit: NSCalendarUnitHour
                        inUnit: NSCalendarUnitDay forDate: d] == 13,
      "the hour of the day counts from one")
    PASS([cal ordinalityOfUnit: NSCalendarUnitMinute
                        inUnit: NSCalendarUnitHour forDate: d] == 31,
      "the minute of the hour counts from one")
    PASS([cal ordinalityOfUnit: NSCalendarUnitSecond
                        inUnit: NSCalendarUnitMinute forDate: d] == 46,
      "the second of the minute counts from one")
    PASS([cal ordinalityOfUnit: NSCalendarUnitHour
                        inUnit: NSCalendarUnitYear forDate: d] == 1165,
      "the hour of the year")
    PASS([cal ordinalityOfUnit: NSCalendarUnitWeekOfMonth
                        inUnit: NSCalendarUnitMonth forDate: d] == 3,
      "the week of the month")
    PASS([cal ordinalityOfUnit: NSCalendarUnitWeekOfYear
                        inUnit: NSCalendarUnitYear forDate: d] == 8,
      "the week of the year counts a partial first week")
    PASS([cal ordinalityOfUnit: NSCalendarUnitYear
                        inUnit: NSCalendarUnitMonth forDate: d] == NSNotFound,
      "a larger unit within a smaller one is not found")

    RELEASE(cal);
  END_SET("NSCalendar ordinalityOfUnit:inUnit:forDate:")
  return 0;
}
