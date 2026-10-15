#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>

/* Queues blocks on the main run loop from a thread of its own. */
@interface BlockQueuer : NSObject
{
@public
  NSMutableArray	*calls;
}
- (void) queue: (id)ignored;
@end

@implementation BlockQueuer
- (void) queue: (id)ignored
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  NSRunLoop		*main = [NSRunLoop mainRunLoop];
  NSMutableArray	*c = calls;
  int			i;

  for (i = 0; i < 100; i++)
    {
      NSString	*s = [NSString stringWithFormat: @"%d", i];

      [main performBlock: ^{
        [c addObject: [NSArray arrayWithObjects: s,
          [NSNumber numberWithBool: [NSThread isMainThread]], nil]]; }];
    }
  [pool release];
}
@end

/* -performBlock: and -performInModes:block: call the block once, before
   the next iteration of the loop in one of the modes; NSRunLoopCommonModes
   covers the default, modal panel and event tracking modes.  Blocks may be
   queued from another thread: they run on the loop's own thread, in the
   order queued. */

int main()
{
  START_SET("NSRunLoop performBlock")
#if __has_feature(blocks)
  NSRunLoop		*run = [NSRunLoop currentRunLoop];
  NSDate		*past = [NSDate distantPast];
  NSMutableArray	*calls = [NSMutableArray array];
  NSString		*custom = @"GSTestRunLoopMode";

  [run performBlock: ^{ [calls addObject: @"a"]; }];
  [run performBlock: ^{ [calls addObject: @"b"]; }];
  PASS([calls count] == 0, "a block is not called at once");
  [run runMode: NSDefaultRunLoopMode beforeDate: past];
  PASS_EQUAL(calls, ([NSArray arrayWithObjects: @"a", @"b", nil]),
    "blocks are called in order when the loop runs");
  [run runMode: NSDefaultRunLoopMode beforeDate: past];
  PASS([calls count] == 2, "a block is called only once");

  [calls removeAllObjects];
  [run performBlock: ^{ [calls addObject: @"modal"]; }];
  [run runMode: @"NSModalPanelRunLoopMode" beforeDate: past];
  PASS_EQUAL(calls, [NSArray arrayWithObject: @"modal"],
    "-performBlock: runs in the modal panel mode");
  [run runMode: NSDefaultRunLoopMode beforeDate: past];
  PASS([calls count] == 1, "and not again in another mode");

  [calls removeAllObjects];
  [run performBlock: ^{ [calls addObject: @"tracking"]; }];
  [run runMode: @"NSEventTrackingRunLoopMode" beforeDate: past];
  PASS_EQUAL(calls, [NSArray arrayWithObject: @"tracking"],
    "-performBlock: runs in the event tracking mode");

  [calls removeAllObjects];
  [run performInModes: [NSArray arrayWithObject: custom]
                block: ^{ [calls addObject: @"custom"]; }];
  [run runMode: NSDefaultRunLoopMode beforeDate: past];
  PASS([calls count] == 0, "a block for another mode waits");
  [run runMode: custom beforeDate: past];
  PASS_EQUAL(calls, [NSArray arrayWithObject: @"custom"],
    "-performInModes:block: runs the block in its mode");

  [calls removeAllObjects];
  [run performInModes: [NSArray arrayWithObject: NSRunLoopCommonModes]
                block: ^{ [calls addObject: @"common"]; }];
  [run runMode: custom beforeDate: past];
  PASS([calls count] == 0, "the common modes do not include other modes");
  [run runMode: NSDefaultRunLoopMode beforeDate: past];
  PASS_EQUAL(calls, [NSArray arrayWithObject: @"common"],
    "NSRunLoopCommonModes includes the default mode");

  [calls removeAllObjects];
  [run performSelector: @selector(addObject:)
                target: calls
              argument: @"selector"
                 order: 0
                 modes: [NSArray arrayWithObject: NSDefaultRunLoopMode]];
  [run performBlock: ^{ [calls addObject: @"block"]; }];
  [run runMode: NSDefaultRunLoopMode beforeDate: past];
  PASS_EQUAL(calls, ([NSArray arrayWithObjects: @"selector", @"block", nil]),
    "blocks and selector performers of the same order run as queued");

  {
    BlockQueuer	*q = AUTORELEASE([BlockQueuer new]);
    NSDate	*until = [NSDate dateWithTimeIntervalSinceNow: 5.0];
    BOOL	ordered = YES;
    BOOL	onMain = YES;
    int		i;

    q->calls = [NSMutableArray array];
    [NSThread detachNewThreadSelector: @selector(queue:)
                             toTarget: q
                           withObject: nil];
    while ([q->calls count] < 100 && [until timeIntervalSinceNow] > 0)
      {
        [run runMode: NSDefaultRunLoopMode
          beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
      }
    PASS([q->calls count] == 100,
      "blocks queued from another thread run in the main loop");
    for (i = 0; i < (int)[q->calls count]; i++)
      {
        NSArray	*call = [q->calls objectAtIndex: i];

        if ([[call objectAtIndex: 0] intValue] != i)
          ordered = NO;
        if ([[call objectAtIndex: 1] boolValue] == NO)
          onMain = NO;
      }
    PASS(ordered && onMain,
      "they run on the main thread in the order queued");
  }

  [calls removeAllObjects];
  [run performInModes: [NSArray array]
                block: ^{ [calls addObject: @"none"]; }];
  [run runMode: NSDefaultRunLoopMode beforeDate: past];
  PASS([calls count] == 0, "an empty modes array has no effect");
#else
  SKIP("blocks are not supported by the compiler")
#endif
  END_SET("NSRunLoop performBlock")
  return 0;
}
