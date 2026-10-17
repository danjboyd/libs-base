#import "ObjectTesting.h"
#import <Foundation/Foundation.h>

/* The activity methods answer a token and run the blocks they are given.
 * They used to answer nil and never run a block.
 */
int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSProcessInfo		*info = [NSProcessInfo processInfo];

  START_SET("NSProcessInfo activities")
#if __has_feature(blocks)
    __block int		ran = 0;
    __block BOOL	expired = YES;
    NSDate		*limit;
    id			activity;

    activity = [info beginActivityWithOptions: NSActivityUserInitiated
                                       reason: @"testing"];
    PASS(activity != nil, "beginning an activity answers a token")
    [info endActivity: activity];

    [info performActivityWithOptions: NSActivityBackground
                              reason: @"testing"
                          usingBlock: ^{ ran++; }];
    PASS(ran == 1, "a performed activity runs its block before returning")

    [info performExpiringActivityWithReason: @"testing"
                                 usingBlock: ^(BOOL hasExpired) {
      expired = hasExpired;
      ran++;
    }];
    limit = [NSDate dateWithTimeIntervalSinceNow: 5.0];
    while (ran < 2 && [limit timeIntervalSinceNow] > 0)
      {
        [NSThread sleepForTimeInterval: 0.01];
      }
    PASS(ran == 2 && expired == NO,
      "an expiring activity runs its block once, not expired")
#else
    SKIP("blocks are not supported by the compiler")
#endif
  END_SET("NSProcessInfo activities")

  [arp release];
  return 0;
}
