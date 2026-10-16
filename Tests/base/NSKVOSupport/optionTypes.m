/* NSKeyValueObservingOptions is an NS_OPTIONS type and NSKeyValueChange
   and NSKeyValueSetMutationKind are NS_ENUM types, as in Cocoa, so Swift
   can import them as an option set and enumerations.  They were NSUInteger
   typedefs beside anonymous enumerations.  The constants keep their values,
   the types keep the size and type encoding of NSUInteger, and combined
   options still reach the observer. */
#import <Foundation/Foundation.h>
#import "Testing.h"

@interface OptionTypesObserver : NSObject
{
@public
  NSKeyValueChange	kind;
  BOOL			sawOld;
  BOOL			sawNew;
}
@end

@implementation OptionTypesObserver
- (void) observeValueForKeyPath: (NSString *)keyPath
		       ofObject: (id)object
			 change: (NSDictionary *)change
			context: (void *)context
{
  kind = [[change objectForKey: NSKeyValueChangeKindKey] unsignedIntegerValue];
  sawOld = [change objectForKey: NSKeyValueChangeOldKey] != nil;
  sawNew = [change objectForKey: NSKeyValueChangeNewKey] != nil;
}
@end

@interface OptionTypesSubject : NSObject
{
  NSString	*name;
}
@end

@implementation OptionTypesSubject
- (NSString *) name
{
  return name;
}
- (void) setName: (NSString *)aName
{
  ASSIGN(name, aName);
}
- (void) dealloc
{
  DESTROY(name);
  [super dealloc];
}
@end

int
main(int argc, const char **argv)
{
  ENTER_POOL
  NSKeyValueObservingOptions	options;
  OptionTypesObserver		*observer;
  OptionTypesSubject		*subject;

  START_SET("NSKeyValueObservingOptions, NSKeyValueChange, NSKeyValueSetMutationKind")

  PASS(sizeof(NSKeyValueObservingOptions) == sizeof(NSUInteger)
    && strcmp(@encode(NSKeyValueObservingOptions), @encode(NSUInteger)) == 0,
    "NSKeyValueObservingOptions has the size and encoding of NSUInteger");
  PASS(sizeof(NSKeyValueChange) == sizeof(NSUInteger)
    && strcmp(@encode(NSKeyValueChange), @encode(NSUInteger)) == 0,
    "NSKeyValueChange has the size and encoding of NSUInteger");
  PASS(sizeof(NSKeyValueSetMutationKind) == sizeof(NSUInteger)
    && strcmp(@encode(NSKeyValueSetMutationKind), @encode(NSUInteger)) == 0,
    "NSKeyValueSetMutationKind has the size and encoding of NSUInteger");
  PASS(NSKeyValueObservingOptionNew == 1
    && NSKeyValueObservingOptionOld == 2
    && NSKeyValueObservingOptionInitial == 4
    && NSKeyValueObservingOptionPrior == 8,
    "the observing options have Cocoa's values");
  PASS(NSKeyValueChangeSetting == 1
    && NSKeyValueChangeInsertion == 2
    && NSKeyValueChangeRemoval == 3
    && NSKeyValueChangeReplacement == 4,
    "the change kinds have Cocoa's values");
  PASS(NSKeyValueUnionSetMutation == 1
    && NSKeyValueMinusSetMutation == 2
    && NSKeyValueIntersectSetMutation == 3
    && NSKeyValueSetSetMutation == 4,
    "the set mutation kinds have Cocoa's values");

  options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
  observer = AUTORELEASE([OptionTypesObserver new]);
  subject = AUTORELEASE([OptionTypesSubject new]);
  [subject setName: @"before"];
  [subject addObserver: observer
	    forKeyPath: @"name"
	       options: options
	       context: NULL];
  [subject setName: @"after"];
  [subject removeObserver: observer forKeyPath: @"name"];
  PASS(observer->kind == NSKeyValueChangeSetting,
    "a setter reports NSKeyValueChangeSetting");
  PASS(observer->sawOld && observer->sawNew,
    "combined options give the observer the old and the new value");

  END_SET("NSKeyValueObservingOptions, NSKeyValueChange, NSKeyValueSetMutationKind")

  LEAVE_POOL
  return 0;
}
