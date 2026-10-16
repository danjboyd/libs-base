/*
 * streamedBody.m - regression test for streamed uploads.  The reply to
 * -URLSession:taskNeedsNewBodyStream:, -resumeWithBodyStream:, resumed
 * the paused transfer from the delegate's thread instead of the session's
 * work thread, so the body was never sent and the task timed out.
 */

#import <Foundation/Foundation.h>

#if GS_HAVE_NSURLSESSION

#import "Testing.h"
#import "EchoServer.h"

int
main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  EchoDelegate		*delegate;
  NSString		*base;
  NSData		*data;

  START_SET("NSURLSession streamed upload")

    base = echoServerStart();
    PASS(base != nil, "the loopback server starts")
    data = [@"streamed body" dataUsingEncoding: NSUTF8StringEncoding];
    delegate = echoUpload([base stringByAppendingString: @"/echo"],
      nil, data, NO);
    PASS(delegate->asked, "the delegate is asked for a body stream")
    PASS(delegate->done, "the task completes")
    PASS_EQUAL([delegate bodyString], @"echo:streamed body",
      "the body from the stream is sent")

  END_SET("NSURLSession streamed upload")

  [arp release];
  return 0;
}

#else

int
main(void)
{
  return 0;
}

#endif /* GS_HAVE_NSURLSESSION */
