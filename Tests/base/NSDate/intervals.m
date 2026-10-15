#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArchiver.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#include <float.h>
#include <math.h>
#include <string.h>

/* A date keeps its interval exactly, whatever its magnitude.
 * Where dates are small objects (tagged pointers) only part of the
 * double's exponent is stored, so this checks values on both sides of
 * the range that fits, and the reference date itself (zero).
 */

static BOOL
same(NSTimeInterval a, NSTimeInterval b)
{
  return memcmp(&a, &b, sizeof(a)) == 0 ? YES : NO;
}

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSTimeInterval	values[] = {
    0.0,
    -0.0,
    1e-30,
    -1e-30,
    DBL_MIN / 4,			/* subnormal */
    ldexp(1.0, -144),			/* smallest compressible magnitude */
    nextafter(ldexp(1.0, -144), 0.0),
    0.001,
    -1.5,
    -978307200.0,			/* 1970 */
    1e9,
    63113990400.0,			/* distantFuture */
    -63113817600.0,			/* distantPast */
    nextafter(ldexp(1.0, 112), 0.0),	/* largest compressible magnitude */
    ldexp(1.0, 112),
    1e20,
    -1e300,
    DBL_MAX
  };
  unsigned	count = sizeof(values) / sizeof(*values);
  unsigned	i;

  for (i = 0; i < count; i++)
    {
      NSTimeInterval	t = values[i];
      NSDate		*d1 = [NSDate dateWithTimeIntervalSinceReferenceDate: t];
      NSDate		*d2;
      NSDate		*d3;
      NSData		*data;

      PASS(same([d1 timeIntervalSinceReferenceDate], t),
	"+dateWithTimeIntervalSinceReferenceDate: %g keeps the interval", t)

      d2 = AUTORELEASE([[NSDate alloc] initWithTimeIntervalSinceReferenceDate: t]);
      PASS(same([d2 timeIntervalSinceReferenceDate], t),
	"-initWithTimeIntervalSinceReferenceDate: %g keeps the interval", t)
      PASS([d1 isEqual: d2] && [d1 hash] == [d2 hash]
	&& [d1 compare: d2] == NSOrderedSame,
	"two dates at %g are equal and have equal hashes", t)

      data = [NSKeyedArchiver archivedDataWithRootObject: d1];
      d3 = [NSKeyedUnarchiver unarchiveObjectWithData: data];
      PASS(same([d3 timeIntervalSinceReferenceDate], t),
	"a keyed archive of a date at %g keeps the interval", t)
      data = [NSArchiver archivedDataWithRootObject: d1];
      d3 = [NSUnarchiver unarchiveObjectWithData: data];
      PASS(same([d3 timeIntervalSinceReferenceDate], t),
	"an archive of a date at %g keeps the interval", t)

      d3 = [d1 dateByAddingTimeInterval: 0.0];
      PASS([d3 isEqual: d1], "adding zero to a date at %g gives an equal date", t)
    }

  /* Dates made from dates of another representation must be equal to,
   * and hash like, dates made directly.
   */
  {
    NSDate	*zero = [NSDate dateWithTimeIntervalSinceReferenceDate: 0.0];
    NSDate	*hundred = [NSDate dateWithTimeIntervalSinceReferenceDate: 100.0];
    NSDate	*tiny = [NSDate dateWithTimeIntervalSinceReferenceDate: 1e-300];
    NSDate	*derived = [zero dateByAddingTimeInterval: 100.0];
    NSDate	*back = [hundred dateByAddingTimeInterval: -100.0];
    NSDate	*fromTiny = [tiny dateByAddingTimeInterval: 100.0];
    NSSet	*set;
    NSDictionary	*dict;

    PASS(same([derived timeIntervalSinceReferenceDate], 100.0)
      && [derived isEqual: hundred] && [hundred isEqual: derived]
      && [derived hash] == [hundred hash],
      "the date at 0 plus 100 is equal to and hashes like the date at 100")
    PASS(same([fromTiny timeIntervalSinceReferenceDate], 100.0)
      && [fromTiny isEqual: hundred] && [fromTiny hash] == [hundred hash],
      "the date at 1e-300 plus 100 is equal to and hashes like"
      " the date at 100")
    PASS(same([back timeIntervalSinceReferenceDate], 0.0)
      && [back isEqual: zero] && [back hash] == [zero hash],
      "the date at 100 minus 100 is equal to and hashes like the date at 0")
    PASS([[[derived class] dateWithTimeIntervalSinceReferenceDate: 5.0]
      isEqual: [NSDate dateWithTimeIntervalSinceReferenceDate: 5.0]]
      && [[[derived class] dateWithTimeIntervalSinceReferenceDate: 5.0] hash]
      == [[NSDate dateWithTimeIntervalSinceReferenceDate: 5.0] hash],
      "a date made through the class of another date is equal and hashes alike")

    set = [NSSet setWithObjects: hundred, zero, nil];
    PASS([set member: derived] != nil && [set member: back] != nil
      && [set containsObject: fromTiny],
      "NSSet finds dates however they were made")
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
      @"hundred", derived, @"zero", back, nil];
    PASS_EQUAL([dict objectForKey: hundred], @"hundred",
      "NSDictionary finds the date at 100 under a derived key")
    PASS_EQUAL([dict objectForKey: zero], @"zero",
      "NSDictionary finds the date at 0 under a derived key")
  }

  PASS([[NSDate dateWithTimeIntervalSinceReferenceDate: 0.0]
    timeIntervalSince1970] == 978307200.0,
    "the reference date is 978307200 seconds after 1970")
  PASS([[NSDate dateWithTimeIntervalSince1970: 978307200.0]
    timeIntervalSinceReferenceDate] == 0.0,
    "978307200 seconds after 1970 is the reference date")
  PASS([[NSDate dateWithTimeIntervalSinceReferenceDate: 0.0]
    isEqual: [NSDate dateWithTimeIntervalSinceReferenceDate: -0.0]],
    "dates at 0 and -0 are equal")
  PASS([[NSDate dateWithTimeIntervalSinceReferenceDate: 0.0]
    compare: [NSDate dateWithTimeIntervalSinceReferenceDate: 1.0]]
    == NSOrderedAscending
    && [[NSDate dateWithTimeIntervalSinceReferenceDate: 1e20]
    compare: [NSDate dateWithTimeIntervalSinceReferenceDate: 1.0]]
    == NSOrderedDescending,
    "dates at 0, 1 and 1e20 are ordered")
  PASS([[NSDate dateWithTimeIntervalSinceReferenceDate: 1.0]
    timeIntervalSinceDate: [NSDate dateWithTimeIntervalSinceReferenceDate: 0.0]]
    == 1.0,
    "the interval between dates at 1 and 0 is 1")

  [arp release];
  return 0;
}
