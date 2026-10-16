/*
 * enumerateRangesInRange.m - regression test for
 * -[NSIndexSet enumerateRangesInRange:options:usingBlock:], which passed
 * each whole stored range that met the range asked for, instead of the
 * part of it within that range.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSIndexSet -enumerateRangesInRange:options:usingBlock:")
#if __has_feature(blocks)
    NSMutableIndexSet	*set;
    NSMutableString	*seen;
    void		(^record)(NSRange, BOOL*);

    set = [NSMutableIndexSet indexSetWithIndexesInRange: NSMakeRange(2, 5)];
    [set addIndexesInRange: NSMakeRange(10, 5)];
    [set addIndexesInRange: NSMakeRange(20, 5)];
    seen = [NSMutableString string];
    record = ^(NSRange r, BOOL *stop) {
      [seen appendFormat: @"{%lu, %lu} ",
	(unsigned long)r.location, (unsigned long)r.length];
    };

    [set enumerateRangesInRange: NSMakeRange(4, 18)
			options: 0
		     usingBlock: record];
    PASS_EQUAL(seen, @"{4, 3} {10, 5} {20, 2} ",
      "the ranges are clipped to the range asked for");

    [seen setString: @""];
    [set enumerateRangesInRange: NSMakeRange(4, 18)
			options: NSEnumerationReverse
		     usingBlock: record];
    PASS_EQUAL(seen, @"{20, 2} {10, 5} {4, 3} ",
      "the ranges are clipped in a reverse enumeration");

    [seen setString: @""];
    [set enumerateRangesInRange: NSMakeRange(11, 2)
			options: 0
		     usingBlock: record];
    PASS_EQUAL(seen, @"{11, 2} ", "a range inside one stored range");

    [seen setString: @""];
    [set enumerateRangesInRange: NSMakeRange(7, 3)
			options: 0
		     usingBlock: record];
    PASS_EQUAL(seen, @"", "a range between the stored ranges");

    [seen setString: @""];
    [set enumerateRangesInRange: NSMakeRange(0, 100)
			options: 0
		     usingBlock: record];
    PASS_EQUAL(seen, @"{2, 5} {10, 5} {20, 5} ",
      "a range covering the set passes the whole ranges");
#else
    SKIP("Blocks support unavailable")
#endif
  END_SET("NSIndexSet -enumerateRangesInRange:options:usingBlock:")

  [arp release];
  return 0;
}
