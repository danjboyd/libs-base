/*
 * terminationHandler.m - regression test for
 * +[NSTask launchedTaskWithExecutableURL:arguments:error:terminationHandler:],
 * which kept the handler block without copying it (so a block from the
 * caller's stack was called after its frame had gone) and never released it.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

static BOOL	trackerDead = NO;

/* An object for the handler to capture: it records its deallocation.
 */
@interface	Tracker : NSObject
@end

@implementation	Tracker
- (void) dealloc
{
  trackerDead = YES;
  [super dealloc];
}
@end

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("+launchedTaskWithExecutableURL:arguments:error:terminationHandler:")
#if __has_feature(blocks)
    NSString		*helpers;
    NSURL		*url;
    NSError		*error = nil;
    NSTask		*task;
    Tracker		*tracker;
    NSDate		*limit;
    __block int		calls = 0;

    helpers = [[NSFileManager defaultManager] currentDirectoryPath];
    helpers = [helpers stringByAppendingPathComponent: @"Helpers"];
    helpers = [helpers stringByAppendingPathComponent: @"obj"];
#if defined(_WIN32)
    helpers = [helpers stringByAppendingPathComponent: @"testsimple.exe"];
#else
    helpers = [helpers stringByAppendingPathComponent: @"testsimple"];
#endif
    url = [NSURL fileURLWithPath: helpers];

    tracker = [Tracker new];
    ENTER_POOL
    /* The handler compares the tracker without sending it a message, so
     * that it is safe to call even if the tracker has gone.
     */
    task = [NSTask launchedTaskWithExecutableURL: url
				       arguments: [NSArray array]
					   error: &error
			      terminationHandler: ^{
      calls += (tracker != nil) ? 1 : 100;
    }];
    RETAIN(task);
    LEAVE_POOL
    PASS(task != nil && error == nil, "the task is launched");

    RELEASE(tracker);
    PASS(NO == trackerDead,
      "the task keeps a copy of the handler, which retains what it captures");

    limit = [NSDate dateWithTimeIntervalSinceNow: 10.0];
    while (0 == calls && [limit timeIntervalSinceNow] > 0.0)
      {
	[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
				 beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
      }
    [task waitUntilExit];
    PASS(1 == calls, "the handler is called once when the task ends");

    ENTER_POOL
    RELEASE(task);
    LEAVE_POOL
    PASS(trackerDead, "the task releases its handler when deallocated");
#else
    SKIP("blocks support unavailable")
#endif
  END_SET("+launchedTaskWithExecutableURL:arguments:error:terminationHandler:")

  [arp release];
  return 0;
}
