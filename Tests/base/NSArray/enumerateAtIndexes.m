/*
 * enumerateAtIndexes.m - regression test for
 * -enumerateObjectsAtIndexes:options:usingBlock: of NSArray and
 * NSOrderedSet, which passed the block the index of each object in the
 * objects at the indexes instead of its index in the receiver.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("-enumerateObjectsAtIndexes:options:usingBlock:")
#if __has_feature(blocks)
    NSArray		*a;
    NSOrderedSet	*s;
    NSMutableIndexSet	*indexes;
    NSMutableString	*seen;
    void		(^record)(id, NSUInteger, BOOL*);

    a = [NSArray arrayWithObjects: @"a", @"b", @"c", @"d", @"e", @"f", nil];
    s = [NSOrderedSet orderedSetWithArray: a];
    indexes = [NSMutableIndexSet indexSetWithIndexesInRange:
      NSMakeRange(1, 2)];
    [indexes addIndex: 4];
    seen = [NSMutableString string];
    record = ^(id o, NSUInteger i, BOOL *stop) {
      [seen appendFormat: @"%@%lu ", o, (unsigned long)i];
    };

    [a enumerateObjectsAtIndexes: indexes options: 0 usingBlock: record];
    PASS_EQUAL(seen, @"b1 c2 e4 ",
      "NSArray: the block gets the index of each object in the receiver");

    [seen setString: @""];
    [a enumerateObjectsAtIndexes: indexes
			 options: NSEnumerationReverse
		      usingBlock: record];
    PASS_EQUAL(seen, @"e4 c2 b1 ",
      "NSArray: a reverse enumeration gets the receiver's indexes");

    [seen setString: @""];
    [a enumerateObjectsAtIndexes: indexes
			 options: 0
		      usingBlock: ^(id o, NSUInteger i, BOOL *stop) {
      [seen appendFormat: @"%@%lu ", o, (unsigned long)i];
      *stop = (i == 2);
    }];
    PASS_EQUAL(seen, @"b1 c2 ", "NSArray: the block can stop the enumeration");

    [seen setString: @""];
    [s enumerateObjectsAtIndexes: indexes options: 0 usingBlock: record];
    PASS_EQUAL(seen, @"b1 c2 e4 ",
      "NSOrderedSet: the block gets the index of each object in the receiver");

    [seen setString: @""];
    [s enumerateObjectsAtIndexes: indexes
			 options: NSEnumerationReverse
		      usingBlock: record];
    PASS_EQUAL(seen, @"e4 c2 b1 ",
      "NSOrderedSet: a reverse enumeration gets the receiver's indexes");

    {
      NSMutableIndexSet	*got = [NSMutableIndexSet indexSet];
      NSLock		*lock = [NSLock new];

      [a enumerateObjectsAtIndexes: indexes
			   options: NSEnumerationConcurrent
			usingBlock: ^(id o, NSUInteger i, BOOL *stop) {
	[lock lock];
	if (o == [a objectAtIndex: i])
	  {
	    [got addIndex: i];
	  }
	[lock unlock];
      }];
      PASS_EQUAL(got, indexes,
	"NSArray: a concurrent enumeration gets the receiver's indexes");
      [lock release];
    }

    PASS_EXCEPTION([a enumerateObjectsAtIndexes:
      [NSIndexSet indexSetWithIndex: 6] options: 0 usingBlock: record],
      NSRangeException, "NSArray: an index beyond the end raises");
#else
    SKIP("Blocks support unavailable")
#endif
  END_SET("-enumerateObjectsAtIndexes:options:usingBlock:")

  [arp release];
  return 0;
}
