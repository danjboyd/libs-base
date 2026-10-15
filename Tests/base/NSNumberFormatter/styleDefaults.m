#import <Foundation/Foundation.h>
#import "Testing.h"

#if	defined(GS_USE_ICU)
#define	NSLOCALE_SUPPORTED	GS_USE_ICU
#else
#define	NSLOCALE_SUPPORTED	1 /* Assume Apple support */
#endif

/* A number style brings its own numbers of fraction digits: none for
 * NSNumberFormatterNoStyle, up to three for NSNumberFormatterDecimalStyle
 * and two for NSNumberFormatterCurrencyStyle in en_US.  The default of
 * NSNumberFormatterNoStyle, with which a formatter starts, must not stay
 * when another style is set.
 */

static NSNumberFormatter *
formatter(NSString *localeIdentifier)
{
  NSNumberFormatter	*f = AUTORELEASE([NSNumberFormatter new]);

  [f setLocale: AUTORELEASE([[NSLocale alloc]
    initWithLocaleIdentifier: localeIdentifier])];
  return f;
}

static NSString *
format(NSNumberFormatter *f, double d)
{
  return [f stringFromNumber: [NSNumber numberWithDouble: d]];
}

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSNumberFormatter	*f;

  START_SET("NSNumberFormatter style defaults")
    if (!NSLOCALE_SUPPORTED)
      SKIP("NSLocale not supported\\nThe ICU library was not available when GNUstep-base was built")

    f = formatter(@"en_US");
    PASS_EQUAL(format(f, 1234567.5), @"1234568",
      "no style shows no fraction digits")
    PASS([f maximumFractionDigits] == 0,
      "no style has a maximum of 0 fraction digits")

    [f setNumberStyle: NSNumberFormatterDecimalStyle];
    PASS_EQUAL(format(f, 1234567.5), @"1,234,567.5",
      "decimal style formats 1234567.5 as 1,234,567.5")
    PASS_EQUAL(format(f, 1234.5678), @"1,234.568",
      "decimal style shows up to three fraction digits")
    PASS([f maximumFractionDigits] == 3,
      "decimal style has a maximum of 3 fraction digits")

    [f setNumberStyle: NSNumberFormatterNoStyle];
    PASS_EQUAL(format(f, 1234567.5), @"1234568",
      "setting no style again shows no fraction digits")

    f = formatter(@"en_US");
    PASS([f maximumFractionDigits] == 0, "reading the default ...")
    [f setNumberStyle: NSNumberFormatterDecimalStyle];
    PASS_EQUAL(format(f, 1234567.5), @"1,234,567.5",
      "... does not keep it when the style changes")

    f = formatter(@"en_US_POSIX");
    [f setNumberStyle: NSNumberFormatterDecimalStyle];
    PASS([format(f, 1234567.5) hasSuffix: @"567.5"],
      "decimal style shows the fraction in en_US_POSIX")

    f = formatter(@"en_US");
    [f setNumberStyle: NSNumberFormatterCurrencyStyle];
    PASS_EQUAL(format(f, 1234567.5), @"$1,234,567.50",
      "currency style shows two fraction digits")

    f = formatter(@"en_US");
    [f setNumberStyle: NSNumberFormatterPercentStyle];
    PASS_EQUAL(format(f, 0.25), @"25%", "percent style is unchanged")

    f = formatter(@"en_US");
    [f setNumberStyle: NSNumberFormatterDecimalStyle];
    [f setMaximumFractionDigits: 1];
    PASS_EQUAL(format(f, 1234.5678), @"1,234.6",
      "a maximum set after the style is used")
    PASS([f maximumFractionDigits] == 1,
      "a maximum set after the style is reported")
  END_SET("NSNumberFormatter style defaults")

  [arp release];
  return 0;
}
