/*
 * contentsOfURLError.m - regression test for the NSString URL contents
 * initializers.  The error forms answered nil without setting the error
 * when the URL could not be read, and all three answered nil instead of
 * an empty string for an empty resource (they released the receiver and
 * then initialized nil).
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSFileManager		*fm = [NSFileManager defaultManager];
  NSString		*base;
  NSURL			*missing;
  NSURL			*empty;
  NSString		*s;
  NSError		*error;
  NSStringEncoding	used;

  base = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  missing = [NSURL fileURLWithPath: base];
  empty = [NSURL fileURLWithPath: [base stringByAppendingPathExtension: @"txt"]];
  [[NSData data] writeToURL: empty atomically: NO];

  START_SET("NSString URL contents with an error")

    error = nil;
    s = [NSString stringWithContentsOfURL: missing
				 encoding: NSUTF8StringEncoding
				    error: &error];
    PASS(s == nil, "a missing file gives nil")
    PASS([[error domain] isEqual: NSCocoaErrorDomain]
      && [error code] == NSFileReadNoSuchFileError,
      "-initWithContentsOfURL:encoding:error: sets NSFileReadNoSuchFileError")

    error = nil;
    s = [NSString stringWithContentsOfURL: missing
			     usedEncoding: &used
				    error: &error];
    PASS(s == nil && [error code] == NSFileReadNoSuchFileError,
      "-initWithContentsOfURL:usedEncoding:error: sets"
      " NSFileReadNoSuchFileError")

    s = [NSString stringWithContentsOfURL: empty
				 encoding: NSUTF8StringEncoding
				    error: &error];
    PASS_EQUAL(s, @"",
      "-initWithContentsOfURL:encoding:error: reads an empty file")
    s = [NSString stringWithContentsOfURL: empty
			     usedEncoding: &used
				    error: &error];
    PASS_EQUAL(s, @"",
      "-initWithContentsOfURL:usedEncoding:error: reads an empty file")
    s = [NSString stringWithContentsOfURL: empty];
    PASS_EQUAL(s, @"", "-initWithContentsOfURL: reads an empty file")

  END_SET("NSString URL contents with an error")

  [fm removeItemAtURL: empty error: NULL];
  [arp release];
  return 0;
}
