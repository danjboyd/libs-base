#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

/* An observed object may be deallocated while observers are still registered
 * with it.  As on Cocoa (since macOS 10.13), the observations are removed
 * along with the object: deallocating it does not raise or crash, and an
 * object it held, which outlives it, no longer reports changes for a key path
 * through it.
 */

@interface Leaf : NSObject
{
  int _value;
}
@end

@implementation Leaf
- (int) value { return _value; }
- (void) setValue: (int)v { _value = v; }
@end

@interface Node : NSObject
{
  int	_value;
  Leaf	*_leaf;
}
@end

static int	nodesDeallocated = 0;

@implementation Node
+ (NSSet *) keyPathsForValuesAffectingTotal
{
  return [NSSet setWithObjects: @"value", @"leaf.value", nil];
}
- (void) dealloc
{
  nodesDeallocated++;
  DESTROY(_leaf);
  [super dealloc];
}
- (int) value { return _value; }
- (void) setValue: (int)v { _value = v; }
- (Leaf *) leaf { return _leaf; }
- (void) setLeaf: (Leaf *)l { ASSIGN(_leaf, l); }
- (int) total { return _value + [_leaf value]; }
@end

@interface Counter : NSObject
{
@public
  int	count;
}
@end

@implementation Counter
- (void) observeValueForKeyPath: (NSString *)keyPath
		       ofObject: (id)object
			 change: (NSDictionary *)change
			context: (void *)context
{
  count++;
}
@end

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSAutoreleasePool	*pool;
  Counter		*counter = AUTORELEASE([Counter new]);
  Counter		*other = AUTORELEASE([Counter new]);
  Node			*node;
  Leaf			*leaf;

  /* Change notifications may leave the observed object in the autorelease
   * pool, so each set releases the pool before the object.
   */
  START_SET("deallocating an object with a key observed")
    pool = [NSAutoreleasePool new];
    node = [Node new];
    [node addObserver: counter
	   forKeyPath: @"value"
	      options: NSKeyValueObservingOptionNew
	      context: NULL];
    [node setValue: 1];
    PASS(1 == counter->count, "the observer is notified")
    [pool release];
    PASS_RUNS(DESTROY(node),
      "the object is deallocated with its observer still registered")
    PASS(1 == nodesDeallocated, "the object is deallocated at once")
  END_SET("deallocating an object with a key observed")

  START_SET("deallocating an object with several observations")
    pool = [NSAutoreleasePool new];
    node = [Node new];
    [node addObserver: counter forKeyPath: @"value" options: 0 context: NULL];
    [node addObserver: other forKeyPath: @"value" options: 0 context: NULL];
    [node addObserver: other forKeyPath: @"leaf" options: 0 context: NULL];
    [node addObserver: counter forKeyPath: @"total" options: 0 context: NULL];
    [node setValue: 1];
    [pool release];
    PASS_RUNS(DESTROY(node),
      "the object is deallocated with several observations, one dependent")
    PASS(2 == nodesDeallocated, "the object is deallocated at once")
  END_SET("deallocating an object with several observations")

  START_SET("deallocating the object at the head of an observed key path")
    if (nil == NSClassFromString(@"_NSKVOObservationInfo"))
      {
	SKIP("the original KVO keeps the observation of a key path's tail")
      }
    pool = [NSAutoreleasePool new];
    leaf = [Leaf new];
    node = [Node new];
    [node setLeaf: leaf];
    counter->count = 0;
    [node addObserver: counter
	   forKeyPath: @"leaf.value"
	      options: NSKeyValueObservingOptionNew
	      context: NULL];
    [node addObserver: counter
	   forKeyPath: @"total"
	      options: NSKeyValueObservingOptionNew
	      context: NULL];
    [leaf setValue: 1];
    PASS(2 == counter->count,
      "a change of the held object is reported for both key paths")
    [pool release];
    PASS_RUNS(DESTROY(node),
      "the object is deallocated with key paths through it observed")
    PASS(3 == nodesDeallocated, "the object is deallocated at once")
    counter->count = 0;
    PASS_RUNS([leaf setValue: 2],
      "the held object, which outlives it, can still change")
    PASS(0 == counter->count,
      "and no change is reported for the deallocated object")
    [leaf addObserver: counter forKeyPath: @"value" options: 0 context: NULL];
    [leaf setValue: 3];
    PASS(1 == counter->count, "the held object can still be observed")
    [leaf removeObserver: counter forKeyPath: @"value"];
    DESTROY(leaf);
  END_SET("deallocating the object at the head of an observed key path")

  [arp release]; arp = nil;
  return 0;
}
