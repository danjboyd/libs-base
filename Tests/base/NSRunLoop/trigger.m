#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSTimer.h>

/* A run loop watcher that triggers (its -runLoopShouldBlock: answers NO
   with the trigger flag set) counts as input handled: -runMode:beforeDate:
   returns after sending it its event instead of waiting on. */

static NSString	*mode = @"GSTriggerTestMode";

/* Triggers once, then removes itself. */
@interface OneShot : NSObject <RunLoopEvents>
{
@public
  int	received;
}
- (void) add: (id)ignored;
@end

@implementation OneShot
- (void) add: (id)ignored
{
  [[NSRunLoop currentRunLoop] addEvent: (void*)self
				  type: ET_TRIGGER
			       watcher: self
			       forMode: mode];
}
- (BOOL) runLoopShouldBlock: (BOOL*)trigger
{
  *trigger = YES;
  return NO;
}
- (void) receivedEvent: (void*)data
		  type: (RunLoopEventType)type
		 extra: (void*)extra
	       forMode: (NSString*)m
{
  received++;
  [[NSRunLoop currentRunLoop] removeEvent: (void*)self
				     type: ET_TRIGGER
				  forMode: mode
				      all: YES];
}
@end

/* Triggers every time the loop runs. */
@interface Always : OneShot
@end

@implementation Always
- (void) receivedEvent: (void*)data
		  type: (RunLoopEventType)type
		 extra: (void*)extra
	       forMode: (NSString*)m
{
  received++;
}
@end

/* Sends a message to the main thread from a thread of its own. */
@interface Poker : NSObject
{
@public
  BOOL	poked;
}
@end

@implementation Poker
- (void) poke: (id)ignored
{
  poked = YES;
}
- (void) run: (id)ignored
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];

  [NSThread sleepForTimeInterval: 0.1];
  [self performSelector: @selector(poke:)
	       onThread: [NSThread mainThread]
	     withObject: nil
	  waitUntilDone: NO
		  modes: [NSArray arrayWithObject: mode]];
  [pool release];
}
@end

static NSTimeInterval
runFor(NSTimeInterval limit, BOOL *result)
{
  NSDate	*start = [NSDate date];

  *result = [[NSRunLoop currentRunLoop] runMode: mode
    beforeDate: [NSDate dateWithTimeIntervalSinceNow: limit]];
  return -[start timeIntervalSinceNow];
}

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSRunLoop		*run = [NSRunLoop currentRunLoop];
  OneShot		*once = AUTORELEASE([OneShot new]);
  Always		*always = AUTORELEASE([Always new]);
  Poker			*poker = AUTORELEASE([Poker new]);
  NSTimer		*keep;
  NSTimeInterval	t;
  BOOL			r;

  START_SET("NSRunLoop trigger watchers")

  /* A far timer gives the mode something to wait for. */
  keep = [NSTimer timerWithTimeInterval: 100.0 target: once
    selector: @selector(add:) userInfo: nil repeats: NO];
  [run addTimer: keep forMode: mode];

  [run addTimer: [NSTimer timerWithTimeInterval: 0.1 target: once
    selector: @selector(add:) userInfo: nil repeats: NO] forMode: mode];
  t = runFor(5.0, &r);
  PASS(r == YES && t < 1.0 && once->received == 1,
    "a watcher added by a timer while the loop waits ends -runMode:beforeDate:");

  t = runFor(0.3, &r);
  PASS(t >= 0.25 && once->received == 1,
    "once it has removed itself the loop waits until the limit date");

  [once add: nil];
  t = runFor(5.0, &r);
  PASS(r == YES && t < 0.5 && once->received == 2,
    "a watcher added before the loop runs ends it at once");

  [always add: nil];
  {
    NSDate	*start = [NSDate date];
    NSDate	*until = [NSDate dateWithTimeIntervalSinceNow: 0.2];

    while ([until timeIntervalSinceNow] > 0)
      {
	[run runMode: mode beforeDate: until];
      }
    t = -[start timeIntervalSinceNow];
  }
  PASS(t < 1.0 && always->received > 1,
    "a loop run until a date with a watcher that always triggers ends");
  [run removeEvent: (void*)always type: ET_TRIGGER forMode: mode all: YES];

  [NSThread detachNewThreadSelector: @selector(run:)
			   toTarget: poker
			 withObject: nil];
  t = runFor(5.0, &r);
  if (NO == poker->poked)
    {
      /* The wake-up may end a pass before the message is performed. */
      t += runFor(5.0 - t, &r);
    }
  PASS(poker->poked && t < 2.0,
    "a message from another thread ends -runMode:beforeDate:");

  [keep invalidate];
  END_SET("NSRunLoop trigger watchers")
  [arp release];
  return 0;
}
