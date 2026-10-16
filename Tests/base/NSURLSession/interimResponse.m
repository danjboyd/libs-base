/*
 * interimResponse.m - regression test for interim responses.  When a
 * server answered an upload sent with "Expect: 100-continue" with an
 * interim 100 Continue response, the delegate was told about it with
 * -URLSession:dataTask:didReceiveResponse: as well as about the final
 * response.  Cocoa reports only the final response.
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

  START_SET("NSURLSession interim responses")

    base = echoServerStart();
    PASS(base != nil, "the loopback server starts")
    data = [@"continued body" dataUsingEncoding: NSUTF8StringEncoding];
    delegate = echoUpload([base stringByAppendingString: @"/echo"],
      data, nil, YES);
    PASS(delegate->done, "the task completes")
    PASS_EQUAL(delegate->statuses,
      [NSArray arrayWithObject: [NSNumber numberWithInt: 200]],
      "the delegate is told only about the final response")
    PASS_EQUAL([delegate bodyString], @"echo:continued body",
      "the body is sent and the reply received")

  END_SET("NSURLSession interim responses")

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
