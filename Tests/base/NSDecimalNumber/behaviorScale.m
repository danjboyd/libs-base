/*
 * behaviorScale.m - regression test for the NSDecimalNumber
 * -decimalNumberBy...:withBehavior: methods, which used the behavior's
 * rounding mode but never rounded the result to the behavior's scale.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

static NSDecimalNumber *
dn(NSString *s)
{
  return [NSDecimalNumber decimalNumberWithString: s];
}

int main(void)
{
  NSAutoreleasePool		*arp = [NSAutoreleasePool new];
  NSDecimalNumberHandler	*two;
  NSDecimalNumberHandler	*down;
  NSDecimalNumber		*r;

  two = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:
    NSRoundPlain scale: 2 raiseOnExactness: NO raiseOnOverflow: NO
    raiseOnUnderflow: NO raiseOnDivideByZero: NO];
  down = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:
    NSRoundDown scale: 0 raiseOnExactness: NO raiseOnOverflow: NO
    raiseOnUnderflow: NO raiseOnDivideByZero: NO];

  START_SET("-decimalNumberBy...:withBehavior: scale")
    r = [dn(@"1") decimalNumberByDividingBy: dn(@"8") withBehavior: two];
    PASS_EQUAL([r stringValue], @"0.13", "dividing rounds to the scale")
    r = [dn(@"1.005") decimalNumberByAdding: dn(@"0.001") withBehavior: two];
    PASS_EQUAL([r stringValue], @"1.01", "adding rounds to the scale")
    r = [dn(@"1.006") decimalNumberBySubtracting: dn(@"0.002")
				    withBehavior: two];
    PASS_EQUAL([r stringValue], @"1", "subtracting rounds to the scale")
    r = [dn(@"1.25") decimalNumberByMultiplyingBy: dn(@"1.5")
				     withBehavior: down];
    PASS_EQUAL([r stringValue], @"1",
      "multiplying rounds to the scale with the rounding mode")
    r = [dn(@"1.2345") decimalNumberByMultiplyingByPowerOf10: 1
					       withBehavior: two];
    PASS_EQUAL([r stringValue], @"12.35",
      "multiplying by a power of ten rounds to the scale")
    r = [dn(@"1.5") decimalNumberByRaisingToPower: 3 withBehavior: down];
    PASS_EQUAL([r stringValue], @"3", "raising to a power rounds to the scale")
    r = [dn(@"1") decimalNumberByDividingBy: dn(@"8")];
    PASS_EQUAL([r stringValue], @"0.125",
      "the default behavior does not round")
    PASS([[NSDecimalNumberHandler defaultDecimalNumberHandler] scale]
      == NSDecimalNoScale, "the default behavior has no scale")
  END_SET("-decimalNumberBy...:withBehavior: scale")

  [arp release];
  return 0;
}
