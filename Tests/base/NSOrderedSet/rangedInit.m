/*
 * rangedInit.m - regression test for the NSOrderedSet initializers that
 * take a range, which copied the objects in the range and then created the
 * set with the count of the whole source, reading past the copied objects.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSMutableArray	*source = [NSMutableArray array];
  NSArray		*expected;
  NSOrderedSet		*sourceSet;
  NSOrderedSet		*s;
  int			i;

  for (i = 0; i < 20; i++)
    {
      [source addObject: [NSString stringWithFormat: @"%d", i]];
    }
  sourceSet = [NSOrderedSet orderedSetWithArray: source];
  expected = [source subarrayWithRange: NSMakeRange(5, 3)];

  START_SET("NSOrderedSet initializers with a range")

    s = [[[NSOrderedSet alloc] initWithArray: source
				       range: NSMakeRange(5, 3)
				   copyItems: NO] autorelease];
    PASS_EQUAL([s array], expected,
      "-initWithArray:range:copyItems: holds the objects in the range");

    s = [[[NSOrderedSet alloc] initWithArray: source
				       range: NSMakeRange(5, 3)
				   copyItems: YES] autorelease];
    PASS_EQUAL([s array], expected,
      "-initWithArray:range:copyItems: copies the objects in the range");

    s = [NSOrderedSet orderedSetWithArray: source
				    range: NSMakeRange(5, 3)
				copyItems: NO];
    PASS_EQUAL([s array], expected,
      "+orderedSetWithArray:range:copyItems: holds the objects in the range");

    s = [[[NSOrderedSet alloc] initWithOrderedSet: sourceSet
					    range: NSMakeRange(5, 3)
					copyItems: NO] autorelease];
    PASS_EQUAL([s array], expected,
      "-initWithOrderedSet:range:copyItems: holds the objects in the range");

    s = [[[NSMutableOrderedSet alloc] initWithOrderedSet: sourceSet
						   range: NSMakeRange(5, 3)
					       copyItems: YES] autorelease];
    PASS_EQUAL([s array], expected,
      "-initWithOrderedSet:range:copyItems: copies the objects in the range");

    s = [[[NSOrderedSet alloc] initWithArray: source
				       range: NSMakeRange(0, 20)
				   copyItems: NO] autorelease];
    PASS_EQUAL([s array], source, "a range of the whole source");

  END_SET("NSOrderedSet initializers with a range")

  [arp release];
  return 0;
}
