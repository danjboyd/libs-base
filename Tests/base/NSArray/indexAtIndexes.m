/*
 * indexAtIndexes.m - regression test for
 * -indexOfObjectAtIndexes:options:passingTest: of NSArray and NSOrderedSet,
 * which ignored its options and, when no object passed, read the index set
 * at NSNotFound instead of answering NSNotFound.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("-indexOfObjectAtIndexes:options:passingTest:")
#if __has_feature(blocks)
    NSArray		*a;
    NSOrderedSet	*s;
    NSIndexSet		*indexes;
    BOOL		(^isB)(id, NSUInteger, BOOL*);
    BOOL		(^none)(id, NSUInteger, BOOL*);

    a = [NSArray arrayWithObjects: @"b", @"a", @"b", @"c", @"b", @"d", nil];
    s = [NSOrderedSet orderedSetWithObjects:
      @"b", @"a", @"B", @"c", @"b ", @"d", nil];
    indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(1, 4)];
    isB = ^(id o, NSUInteger i, BOOL *stop) {
      return (BOOL)[[o lowercaseString] hasPrefix: @"b"];
    };
    none = ^(id o, NSUInteger i, BOOL *stop) {
      return NO;
    };

    PASS([a indexOfObjectAtIndexes: indexes options: 0 passingTest: isB] == 2,
      "NSArray: a forward search answers the first match in the indexes");
    PASS([a indexOfObjectAtIndexes: indexes
			   options: NSEnumerationReverse
		       passingTest: isB] == 4,
      "NSArray: a reverse search answers the last match in the indexes");
    PASS([a indexOfObjectAtIndexes: indexes options: 0 passingTest: none]
      == NSNotFound, "NSArray: answers NSNotFound when no object passes");
    PASS([a indexOfObjectAtIndexes: [NSIndexSet indexSet]
			   options: 0
		       passingTest: isB] == NSNotFound,
      "NSArray: answers NSNotFound for an empty index set");

    PASS([s indexOfObjectAtIndexes: indexes options: 0 passingTest: isB] == 2,
      "NSOrderedSet: a forward search answers the first match in the indexes");
    PASS([s indexOfObjectAtIndexes: indexes
			   options: NSEnumerationReverse
		       passingTest: isB] == 4,
      "NSOrderedSet: a reverse search answers the last match in the indexes");
    PASS([s indexOfObjectAtIndexes: indexes options: 0 passingTest: none]
      == NSNotFound, "NSOrderedSet: answers NSNotFound when no object passes");
#else
    SKIP("Blocks support unavailable")
#endif
  END_SET("-indexOfObjectAtIndexes:options:passingTest:")

  [arp release];
  return 0;
}
