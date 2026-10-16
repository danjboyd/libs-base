/*
 * readError.m - regression test for the error from malformed JSON.
 * Cocoa reports it in NSCocoaErrorDomain with the code
 * NSPropertyListReadCorruptError (3840); the parser used code 0.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

static NSError *
errorFor(NSString *json)
{
  NSError	*error = nil;
  id		obj;

  obj = [NSJSONSerialization
    JSONObjectWithData: [json dataUsingEncoding: NSUTF8StringEncoding]
	       options: 0
		 error: &error];
  return obj == nil ? error : nil;
}

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSError		*error;

  START_SET("NSJSONSerialization read errors")

    error = errorFor(@"{\"a\": }");
    PASS_EQUAL([error domain], NSCocoaErrorDomain,
      "malformed JSON gives an error in NSCocoaErrorDomain")
    PASS([error code] == NSPropertyListReadCorruptError,
      "malformed JSON gives NSPropertyListReadCorruptError")

    error = errorFor(@"[1, 2");
    PASS([error code] == NSPropertyListReadCorruptError,
      "truncated JSON gives NSPropertyListReadCorruptError")

  END_SET("NSJSONSerialization read errors")

  [arp release];
  return 0;
}
