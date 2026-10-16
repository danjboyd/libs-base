/*
 * countStyle.m - regression test for -[NSByteCountFormatter
 * stringFromByteCount:], which used 1024 bytes to the kilobyte whatever
 * the count style and rounded every fraction up to a whole number.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

static NSString *
fmt(long long n, NSByteCountFormatterCountStyle style)
{
  return [NSByteCountFormatter stringFromByteCount: n countStyle: style];
}

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSByteCountFormatter count styles")
    PASS_EQUAL(fmt(1000000, NSByteCountFormatterCountStyleDecimal), @"1 MB",
      "the decimal style has 1000 bytes to the kilobyte")
    PASS_EQUAL(fmt(1000000, NSByteCountFormatterCountStyleFile), @"1 MB",
      "the file style has 1000 bytes to the kilobyte")
    PASS_EQUAL(fmt(2500000, NSByteCountFormatterCountStyleDecimal), @"2.5 MB",
      "megabytes keep one fraction digit")
    PASS_EQUAL(fmt(2 * 1048576, NSByteCountFormatterCountStyleBinary),
      @"2 MB", "the binary style has 1024 bytes to the kilobyte")
    PASS_EQUAL(fmt(3 * 1048576 / 2, NSByteCountFormatterCountStyleMemory),
      @"1.5 MB", "the memory style has 1024 bytes to the kilobyte")
    PASS_EQUAL(fmt(1234567890, NSByteCountFormatterCountStyleDecimal),
      @"1.23 GB", "gigabytes keep two fraction digits, rounded")
    PASS_EQUAL(fmt(1400, NSByteCountFormatterCountStyleDecimal), @"1 KB",
      "kilobytes are rounded to the nearest whole number")
    PASS_EQUAL(fmt(512, NSByteCountFormatterCountStyleDecimal), @"512 bytes",
      "a count below a kilobyte is in bytes")
  END_SET("NSByteCountFormatter count styles")

  [arp release];
  return 0;
}
