/*
 * reverseSearch.m - regression test for the NSArray passingTest: searches
 * with NSEnumerationReverse, which answered the position in the reverse
 * enumeration instead of the index in the receiver.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSArray reverse passingTest: searches")
#if __has_feature(blocks)
    NSArray		*a;
    NSMutableIndexSet	*expected;
    NSIndexSet		*found;
    NSUInteger		index;
    BOOL		(^isB)(id, NSUInteger, BOOL*);

    a = [NSArray arrayWithObjects:
      @"a", @"b", @"c", @"d", @"b", @"e", @"f", nil];
    isB = ^(id o, NSUInteger i, BOOL *stop) {
      return (BOOL)[o isEqual: @"b"];
    };

    index = [a indexOfObjectWithOptions: NSEnumerationReverse
			    passingTest: isB];
    PASS(index == 4,
      "-indexOfObjectWithOptions:passingTest: answers the last match");

    index = [a indexOfObjectWithOptions: NSEnumerationReverse
			    passingTest: ^(id o, NSUInteger i, BOOL *stop) {
      return (BOOL)(o == [a objectAtIndex: i] && [o isEqual: @"a"]);
    }];
    PASS(index == 0,
      "-indexOfObjectWithOptions:passingTest: passes the receiver's index");

    expected = [NSMutableIndexSet indexSetWithIndex: 1];
    [expected addIndex: 4];
    found = [a indexesOfObjectsWithOptions: NSEnumerationReverse
			       passingTest: isB];
    PASS_EQUAL(found, expected,
      "-indexesOfObjectsWithOptions:passingTest: answers the receiver's indexes");

    found = [a indexesOfObjectsAtIndexes:
      [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(2, 3)]
				 options: NSEnumerationReverse
			     passingTest: isB];
    PASS_EQUAL(found, [NSIndexSet indexSetWithIndex: 4],
      "-indexesOfObjectsAtIndexes:options:passingTest: answers the receiver's indexes");
#else
    SKIP("Blocks support unavailable")
#endif
  END_SET("NSArray reverse passingTest: searches")

  [arp release];
  return 0;
}
