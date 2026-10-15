/* An observed object keeps the structure values given to its setters, and
   its observers are told of each change.  The notifying setters re-sent
   a structure as integer words, so on x86-64 an NSPoint, NSSize or NSRect,
   passed in floating point registers or in memory, reached the original
   setter as garbage. */
#import <Foundation/Foundation.h>
#import "Testing.h"

typedef struct {
  double	x;
  int		count;
  char		flag;
} Mixed;

@interface StructHolder : NSObject
{
  NSPoint	point;
  NSSize	size;
  NSRect	rect;
  NSRange	range;
  Mixed		mixed;
}
- (NSPoint) point;
- (void) setPoint: (NSPoint)v;
- (NSSize) size;
- (void) setSize: (NSSize)v;
- (NSRect) rect;
- (void) setRect: (NSRect)v;
- (NSRange) range;
- (void) setRange: (NSRange)v;
- (Mixed) mixed;
- (void) setMixed: (Mixed)v;
@end

@implementation StructHolder
- (NSPoint) point { return point; }
- (void) setPoint: (NSPoint)v { point = v; }
- (NSSize) size { return size; }
- (void) setSize: (NSSize)v { size = v; }
- (NSRect) rect { return rect; }
- (void) setRect: (NSRect)v { rect = v; }
- (NSRange) range { return range; }
- (void) setRange: (NSRange)v { range = v; }
- (Mixed) mixed { return mixed; }
- (void) setMixed: (Mixed)v { mixed = v; }
@end

@interface StructObserver : NSObject
{
@public
  NSMutableArray	*keys;
  NSMutableArray	*values;
}
@end

@implementation StructObserver
- (id) init
{
  if ((self = [super init]) != nil)
    {
      keys = [NSMutableArray new];
      values = [NSMutableArray new];
    }
  return self;
}
- (void) dealloc
{
  [keys release];
  [values release];
  [super dealloc];
}
- (void) observeValueForKeyPath: (NSString *)keyPath
		       ofObject: (id)object
			 change: (NSDictionary *)change
			context: (void *)context
{
  id	value = [change objectForKey: NSKeyValueChangeNewKey];

  [keys addObject: keyPath];
  [values addObject: value ? value : (id)[NSNull null]];
}
@end

int
main(int argc, char *argv[])
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  StructHolder		*holder = [[StructHolder new] autorelease];
  StructObserver	*observer = [[StructObserver new] autorelease];
  NSArray		*observed;
  NSEnumerator		*e;
  NSString		*key;
  Mixed			m;

  START_SET("KVO structure setters")

  observed = [NSArray arrayWithObjects:
    @"point", @"size", @"rect", @"range", @"mixed", nil];
  e = [observed objectEnumerator];
  while ((key = [e nextObject]) != nil)
    {
      [holder addObserver: observer
	       forKeyPath: key
		  options: NSKeyValueObservingOptionNew
		  context: NULL];
    }

  [holder setPoint: NSMakePoint(1.5, -2.25)];
  PASS(NSEqualPoints([holder point], NSMakePoint(1.5, -2.25)),
    "an observed NSPoint setter stores the value");
  [holder setSize: NSMakeSize(30.5, 40.75)];
  PASS(NSEqualSizes([holder size], NSMakeSize(30.5, 40.75)),
    "an observed NSSize setter stores the value");
  [holder setRect: NSMakeRect(10, 20, 300, 400.5)];
  PASS(NSEqualRects([holder rect], NSMakeRect(10, 20, 300, 400.5)),
    "an observed NSRect setter stores the value");
  [holder setRange: NSMakeRange(7, 11)];
  PASS(NSEqualRanges([holder range], NSMakeRange(7, 11)),
    "an observed NSRange setter stores the value");
  m.x = 3.125;
  m.count = 42;
  m.flag = 'z';
  [holder setMixed: m];
  /* A structure other than the geometry ones is passed through a libffi
   * closure.  A build without libffi copies the value as integer words,
   * which loses this mixed structure on x86-64, so the check is hopeful.
   */
  testHopeful = YES;
  PASS([holder mixed].x == 3.125 && [holder mixed].count == 42
    && [holder mixed].flag == 'z',
    "an observed setter of another structure stores the value (libffi)");
  testHopeful = NO;

  PASS_EQUAL(observer->keys, observed,
    "each structure setter notifies the observer once");
  PASS_EQUAL([observer->values objectAtIndex: 0],
    [NSValue valueWithPoint: NSMakePoint(1.5, -2.25)],
    "the NSPoint change carries the new value");
  PASS_EQUAL([observer->values objectAtIndex: 2],
    [NSValue valueWithRect: NSMakeRect(10, 20, 300, 400.5)],
    "the NSRect change carries the new value");
  PASS_EQUAL([observer->values objectAtIndex: 3],
    [NSValue valueWithRange: NSMakeRange(7, 11)],
    "the NSRange change carries the new value");

  e = [observed objectEnumerator];
  while ((key = [e nextObject]) != nil)
    {
      [holder removeObserver: observer forKeyPath: key];
    }
  [holder setRect: NSMakeRect(1, 2, 3, 4)];
  PASS(NSEqualRects([holder rect], NSMakeRect(1, 2, 3, 4)),
    "an NSRect setter stores the value once observers are removed");
  PASS([observer->keys count] == [observed count],
    "no notification is sent once observers are removed");

  END_SET("KVO structure setters")

  [pool release];
  return 0;
}
