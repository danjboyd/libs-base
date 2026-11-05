/* NSRunLoopCommonModes stands for the default and the AppKit modal and event
 * tracking modes, for timers, delayed performs and performers alike.
 */
#import "ObjectTesting.h"
#import <Foundation/Foundation.h>

@interface Counter : NSObject
{
@public
  unsigned	fired;
}
- (void) fire: (id)ignored;
@end
@implementation Counter
- (void) fire: (id)ignored
{
  fired++;
}
@end

static void
runFor(NSString *mode, NSTimeInterval seconds)
{
  NSDate	*end = [NSDate dateWithTimeIntervalSinceNow: seconds];

  while ([end timeIntervalSinceNow] > 0)
    {
      [[NSRunLoop currentRunLoop] runMode: mode beforeDate: end];
      if (NO == [[NSRunLoop currentRunLoop] limitDateForMode: mode])
	{
	  [NSThread sleepForTimeInterval: 0.01];
	}
    }
}

int main()
{
  ENTER_POOL
  NSRunLoop	*loop = [NSRunLoop currentRunLoop];
  NSArray	*common = [NSArray arrayWithObject: NSRunLoopCommonModes];
  NSArray	*modes = [NSArray arrayWithObjects:
    NSDefaultRunLoopMode, @"NSModalPanelRunLoopMode",
    @"NSEventTrackingRunLoopMode", nil];
  NSUInteger	i;

  for (i = 0; i < [modes count]; i++)
    {
      NSString	*mode = [modes objectAtIndex: i];
      Counter	*c = AUTORELEASE([Counter new]);
      NSTimer	*t;

      t = [NSTimer timerWithTimeInterval: 0.01 target: c
	selector: @selector(fire:) userInfo: nil repeats: NO];
      [loop addTimer: t forMode: NSRunLoopCommonModes];
      runFor(mode, 0.1);
      PASS(c->fired == 1, "a common modes timer fires once in %s",
	[mode UTF8String])

      c->fired = 0;
      [c performSelector: @selector(fire:) withObject: nil
	afterDelay: 0.01 inModes: common];
      runFor(mode, 0.1);
      PASS(c->fired == 1, "a common modes delayed perform runs once in %s",
	[mode UTF8String])

      c->fired = 0;
      [loop performSelector: @selector(fire:) target: c argument: nil
	order: 0 modes: common];
      runFor(mode, 0.1);
      PASS(c->fired == 1, "a common modes performer runs once in %s",
	[mode UTF8String])
      [loop cancelPerformSelectorsWithTarget: c];
    }

  {
    Counter	*c = AUTORELEASE([Counter new]);
    NSTimer	*t;

    t = [NSTimer timerWithTimeInterval: 0.01 target: c
      selector: @selector(fire:) userInfo: nil repeats: NO];
    [loop addTimer: t forMode: NSRunLoopCommonModes];
    runFor(@"SomeOtherMode", 0.05);
    PASS(c->fired == 0, "another mode doesn't fire a common modes timer")
    runFor(NSDefaultRunLoopMode, 0.05);
    PASS(c->fired == 1, "and the timer still fires later")
    PASS([t isValid] == NO, "a fired timer is finished in all its modes")

    t = [NSTimer timerWithTimeInterval: 0.01 target: c
      selector: @selector(fire:) userInfo: nil repeats: YES];
    [loop addTimer: t forMode: NSRunLoopCommonModes];
    c->fired = 0;
    runFor(NSDefaultRunLoopMode, 0.05);
    runFor(@"NSModalPanelRunLoopMode", 0.05);
    PASS(c->fired >= 2, "a repeating timer keeps firing across the modes")
    [t invalidate];
    c->fired = 0;
    runFor(NSDefaultRunLoopMode, 0.05);
    runFor(@"NSModalPanelRunLoopMode", 0.05);
    PASS(c->fired == 0, "an invalidated timer stops in all of them")
  }
  LEAVE_POOL
  return 0;
}
