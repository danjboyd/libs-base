/*
 * suspendedDelivery.m - regression test for the suspension behaviors of
 * the local distributed notification center.  gdnc held notifications for
 * an observer registered with
 * NSNotificationSuspensionBehaviorDeliverImmediately while its center was
 * suspended, as for NSNotificationSuspensionBehaviorHold.
 *
 * The test starts a gdnc of its own (and stops it at the end) unless one
 * is already running for the user.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

@interface	Observer : NSObject
{
@public
  NSUInteger	hits;
}
- (void) receive: (NSNotification *)notification;
@end

@implementation	Observer
- (void) receive: (NSNotification *)notification
{
  hits++;
}
@end

static void
runFor(NSTimeInterval seconds, Observer *observer)
{
  NSDate	*limit = [NSDate dateWithTimeIntervalSinceNow: seconds];

  while ((observer == nil || observer->hits == 0)
    && [limit timeIntervalSinceNow] > 0)
    {
      [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
			       beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
    }
}

int main(void)
{
  NSAutoreleasePool			*arp = [NSAutoreleasePool new];
  NSPortNameServer			*ns;
  NSDistributedNotificationCenter	*center;
  NSTask				*task = nil;
  Observer				*immediate;
  Observer				*held;
  NSString				*name;
  NSString				*path;
  NSDate				*limit;

  START_SET("NSDistributedNotificationCenter suspension behaviors")

    ns = [NSMessagePortNameServer sharedInstance];
    if ([ns portForName: @"GDNCServer"] == nil)
      {
	path = [NSTask launchPathForTool: @"gdnc"];
	if (path == nil)
	  {
	    SKIP("the gdnc tool is not installed")
	  }
	task = [NSTask launchedTaskWithLaunchPath: path
	  arguments: [NSArray arrayWithObject: @"--no-fork"]];
	limit = [NSDate dateWithTimeIntervalSinceNow: 10.0];
	while ([ns portForName: @"GDNCServer"] == nil
	  && [limit timeIntervalSinceNow] > 0)
	  {
	    [NSThread sleepForTimeInterval: 0.05];
	  }
      }
    PASS([ns portForName: @"GDNCServer"] != nil, "gdnc is running")

    center = [NSDistributedNotificationCenter defaultCenter];
    name = [NSString stringWithFormat: @"suspendedDelivery.%d",
      [[NSProcessInfo processInfo] processIdentifier]];
    immediate = [[Observer new] autorelease];
    held = [[Observer new] autorelease];
    [center addObserver: immediate
	       selector: @selector(receive:)
		   name: name
		 object: nil
     suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately];
    [center addObserver: held
	       selector: @selector(receive:)
		   name: name
		 object: nil
     suspensionBehavior: NSNotificationSuspensionBehaviorHold];

    [center setSuspended: YES];
    [center postNotificationName: name
			  object: @"object"
			userInfo: nil
	      deliverImmediately: NO];
    runFor(5.0, immediate);
    PASS(immediate->hits == 1,
      "an immediate delivery observer hears a notification while suspended")
    runFor(0.5, nil);
    PASS(held->hits == 0,
      "a holding observer does not hear it while suspended")

    [center setSuspended: NO];
    [center postNotificationName: name
			  object: @"object"
			userInfo: nil
	      deliverImmediately: NO];
    runFor(5.0, nil);
    PASS(immediate->hits == 2 && held->hits == 2,
      "after resuming, the held notification and the new one are heard")

    [center removeObserver: immediate name: name object: nil];
    [center removeObserver: held name: name object: nil];

    if (task != nil)
      {
	[task terminate];
	[task waitUntilExit];
      }

  END_SET("NSDistributedNotificationCenter suspension behaviors")

  [arp release];
  return 0;
}
