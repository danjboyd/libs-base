#import "ObjectTesting.h"

#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSDate.h"
#import "Foundation/NSRunLoop.h"
#import "GNUstepBase/GSConfig.h"

/* With libdispatch run loop integration, the main queue is drained in
   the common modes: work queued on it runs while the main run loop runs
   a modal panel or tracks events, not only in the default mode. */

#if GS_USE_LIBDISPATCH_RUNLOOP && __has_feature(blocks)
#  define DISPATCH_RL_INTEGRATION 1
#  if __has_include(<dispatch.h>)
#    include <dispatch.h>
#  else
#    include <dispatch/dispatch.h>
#  endif

static BOOL
drainsInMode(NSString *mode)
{
  NSRunLoop	*run = [NSRunLoop currentRunLoop];
  NSDate	*until = [NSDate dateWithTimeIntervalSinceNow: 1.0];
  __block BOOL	done = NO;

  dispatch_async(dispatch_get_main_queue(), ^{ done = YES; });
  while (NO == done && [until timeIntervalSinceNow] > 0)
    {
      [run runMode: mode
        beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
    }
  return done;
}
#endif

int main(int argc, char *argv[])
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  START_SET("NSRunLoop libdispatch main queue modes")
# ifndef DISPATCH_RL_INTEGRATION
  SKIP("No libdispatch, no blocks support or no runloop integration hooks in libdispatch")
# else
  PASS(drainsInMode(NSDefaultRunLoopMode),
    "the main queue is drained in the default mode");
  PASS(drainsInMode(@"NSModalPanelRunLoopMode"),
    "the main queue is drained in the modal panel mode");
  PASS(drainsInMode(@"NSEventTrackingRunLoopMode"),
    "the main queue is drained in the event tracking mode");
# endif
  END_SET("NSRunLoop libdispatch main queue modes")
  [pool release];
  return 0;
}
