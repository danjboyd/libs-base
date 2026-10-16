/*
 * soleOwner.m - regression test for NSMutableOrderedSet removal,
 * replacement and sorting of objects that only the set retains.
 * -[GSMutableOrderedSet removeObjectAtIndex:] released the object (by
 * removing it from its array) before hashing it to remove it from its map,
 * and -sortRange:options:usingComparator: removed the objects and then
 * inserted the same, by then deallocated, objects again.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

/* Instances of Item are never freed: -dealloc marks them dead instead, so
 * a message to a deallocated item is safe and is recorded.
 */
static BOOL	usedAfterDealloc = NO;

@interface Item : NSObject
{
@public
  int	value;
  BOOL	dead;
}
+ (id) item: (int)v;
@end

@implementation Item
+ (id) item: (int)v
{
  Item	*i = [self new];

  i->value = v;
  return i;	/* The caller owns the only reference. */
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void) dealloc
{
  dead = YES;	/* Intentionally not freed; see above. */
}
#pragma clang diagnostic pop
- (NSUInteger) hash
{
  if (dead) usedAfterDealloc = YES;
  return value;
}
- (BOOL) isEqual: (id)other
{
  if (dead) usedAfterDealloc = YES;
  return [other isKindOfClass: [Item class]]
    && ((Item*)other)->value == value;
}
@end

/* A set of count items, each retained only by the set. */
static NSMutableOrderedSet *
makeSet(int count)
{
  NSMutableOrderedSet	*s = [NSMutableOrderedSet orderedSet];
  int			i;

  for (i = 0; i < count; i++)
    {
      Item	*item = [Item item: i];

      [s addObject: item];
      [item release];
    }
  return s;
}

/* YES if the values of the items in s are those in v, in order. */
static BOOL
hasValues(NSOrderedSet *s, const int *v, NSUInteger count)
{
  NSUInteger	i;

  if ([s count] != count)
    {
      return NO;
    }
  for (i = 0; i < count; i++)
    {
      Item	*item = [s objectAtIndex: i];

      if (item->dead || item->value != v[i])
	{
	  return NO;
	}
    }
  return YES;
}

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSMutableOrderedSet	*s;
  Item			*a;
  Item			*b;

  START_SET("NSMutableOrderedSet objects retained only by the set")

    s = makeSet(3);
    usedAfterDealloc = NO;
    [s removeObjectAtIndex: 1];
    PASS(usedAfterDealloc == NO,
      "-removeObjectAtIndex: does not use the object after releasing it");
    {
      int v[] = {0, 2};
      PASS(hasValues(s, v, 2), "-removeObjectAtIndex: removes the object");
    }
    PASS([s containsObject: [[Item item: 1] autorelease]] == NO,
      "-removeObjectAtIndex: removes the object from the hash map");

    s = makeSet(4);
    usedAfterDealloc = NO;
    [s removeObjectsInRange: NSMakeRange(1, 2)];
    [s removeObjectsAtIndexes: [NSIndexSet indexSetWithIndex: 0]];
    {
      int v[] = {3};
      PASS(usedAfterDealloc == NO && hasValues(s, v, 1),
	"-removeObjectsInRange: and -removeObjectsAtIndexes:");
    }

    s = makeSet(3);
    a = [Item item: 10];
    b = [Item item: 11];
    usedAfterDealloc = NO;
    [s replaceObjectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange:
      NSMakeRange(0, 2)] withObjects: [NSArray arrayWithObjects: a, b, nil]];
    {
      int v[] = {10, 11, 2};
      PASS(usedAfterDealloc == NO && hasValues(s, v, 3),
	"-replaceObjectsAtIndexes:withObjects:");
    }
    [s replaceObjectsInRange: NSMakeRange(1, 2) withObjects: &a count: 1];
    {
      int v[] = {10};
      PASS(usedAfterDealloc == NO && hasValues(s, v, 1),
	"-replaceObjectsInRange:withObjects:count:");
    }
    [a release];
    [b release];

#if __has_feature(blocks)
    s = makeSet(4);
    usedAfterDealloc = NO;
    [s sortWithOptions: 0 usingComparator: ^(id x, id y) {
      int	l = ((Item*)x)->value;
      int	r = ((Item*)y)->value;

      return l > r ? NSOrderedAscending
	: (l < r ? NSOrderedDescending : NSOrderedSame);
    }];
    {
      int v[] = {3, 2, 1, 0};
      PASS(usedAfterDealloc == NO && hasValues(s, v, 4),
	"-sortWithOptions:usingComparator: keeps the objects alive");
    }

    s = makeSet(4);
    usedAfterDealloc = NO;
    [s sortRange: NSMakeRange(1, 3) options: NSSortStable
      usingComparator: ^(id x, id y) {
      int	l = ((Item*)x)->value;
      int	r = ((Item*)y)->value;

      return l > r ? NSOrderedAscending
	: (l < r ? NSOrderedDescending : NSOrderedSame);
    }];
    {
      int v[] = {0, 3, 2, 1};
      PASS(usedAfterDealloc == NO && hasValues(s, v, 4),
	"-sortRange:options:usingComparator: keeps the objects alive");
    }
#else
    SKIP("Blocks support unavailable")
#endif

  END_SET("NSMutableOrderedSet objects retained only by the set")

  [arp release];
  return 0;
}
