/*
 * replacementString.m - regression test for
 * -[NSRegularExpression replacementStringForResult:inString:offset:template:],
 * which matched the expression again against the text at the result's range,
 * instead of expanding the template from the result's own ranges, and
 * ignored the offset.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

static NSString *
replace(NSRegularExpression *re, NSTextCheckingResult *result,
  NSString *string, NSInteger offset, NSString *template)
{
  return [re replacementStringForResult: result
			       inString: string
				 offset: offset
			       template: template];
}

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSRegularExpression -replacementStringForResult:...")
#if !(__APPLE__ || GS_USE_ICU)
    SKIP("NSRegularExpression not built, please install libicu")
#else
    NSRegularExpression		*re;
    NSTextCheckingResult	*result;
    NSString			*string;
    NSRange			ranges[3];

    re = [NSRegularExpression regularExpressionWithPattern: @"(\\w+) (\\w+)"
						   options: 0
						     error: NULL];
    string = @"hello world";
    result = [re firstMatchInString: string
			    options: 0
			      range: NSMakeRange(0, [string length])];
    PASS_EQUAL(replace(re, result, string, 0, @"<$2 $1> $0"),
      @"<world hello> hello world", "a template for a match");
    PASS_EQUAL(replace(re, result, @"> hello world", 2, @"$2 $1"),
      @"world hello", "the offset moves the result's ranges");
    PASS_EQUAL(replace(re, result, string, 0, @"\\$1 \\\\ $10"),
      @"$1 \\ hello0", "escapes, and digits beyond the groups are literal");
    PASS(replace(re, result, string, 0, @"$3") == nil,
      "a group the result does not have answers nil");

    re = [NSRegularExpression regularExpressionWithPattern: @"(\\d+)-(\\d+)"
						   options: 0
						     error: NULL];
    string = @"10-20";
    ranges[0] = NSMakeRange(0, 5);
    ranges[1] = NSMakeRange(3, 2);
    ranges[2] = NSMakeRange(0, 2);
    result = [NSTextCheckingResult
      regularExpressionCheckingResultWithRanges: ranges
					  count: 3
			      regularExpression: re];
    PASS_EQUAL(replace(re, result, string, 0, @"$1/$2"), @"20/10",
      "a result made from ranges expands its own ranges");

    re = [NSRegularExpression regularExpressionWithPattern: @"(a)|(b)"
						   options: 0
						     error: NULL];
    result = [re firstMatchInString: @"b"
			    options: 0
			      range: NSMakeRange(0, 1)];
    PASS_EQUAL(replace(re, result, @"b", 0, @"[$1][$2]"), @"[][b]",
      "a group which did not take part expands to nothing");
#endif
  END_SET("NSRegularExpression -replacementStringForResult:...")

  [arp release];
  return 0;
}
