/*
 * contentsOfFileError.m - regression test for the NSString file contents
 * initializers with an error argument.  -initWithContentsOfFile:encoding:error:
 * (and so +stringWithContentsOfFile:encoding:error:) answered nil without
 * setting the error when the file could not be read.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSString		*missing;
  NSString		*path;
  NSString		*s;
  NSError		*error;
  NSStringEncoding	used;

  missing = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  path = [missing stringByAppendingPathExtension: @"txt"];
  [@"contents" writeToFile: path
		atomically: NO
		  encoding: NSUTF8StringEncoding
		     error: NULL];

  START_SET("NSString file contents with an error")

    error = nil;
    s = [[NSString alloc] initWithContentsOfFile: missing
					encoding: NSUTF8StringEncoding
					   error: &error];
    PASS(s == nil, "-initWithContentsOfFile:encoding:error: answers nil");
    PASS(error != nil && [[error domain] isEqual: NSCocoaErrorDomain]
      && [error code] == NSFileReadNoSuchFileError,
      "-initWithContentsOfFile:encoding:error: sets a no such file error");

    error = nil;
    s = [NSString stringWithContentsOfFile: missing
				  encoding: NSUTF8StringEncoding
				     error: &error];
    PASS(s == nil && error != nil && [error code] == NSFileReadNoSuchFileError,
      "+stringWithContentsOfFile:encoding:error: sets the error");

    error = nil;
    s = [NSMutableString stringWithContentsOfFile: missing
					 encoding: NSUTF8StringEncoding
					    error: &error];
    PASS(s == nil && error != nil && [error code] == NSFileReadNoSuchFileError,
      "+[NSMutableString stringWithContentsOfFile:encoding:error:]");

    error = nil;
    s = [NSString stringWithContentsOfFile: missing
			      usedEncoding: &used
				     error: &error];
    PASS(s == nil && error != nil && [error code] == NSFileReadNoSuchFileError,
      "+stringWithContentsOfFile:usedEncoding:error: sets the error");

    PASS([NSString stringWithContentsOfFile: missing
				   encoding: NSUTF8StringEncoding
				      error: NULL] == nil,
      "a NULL error pointer is allowed");

    error = nil;
    s = [NSString stringWithContentsOfFile: path
				  encoding: NSUTF8StringEncoding
				     error: &error];
    PASS_EQUAL(s, @"contents", "a readable file is read");
    PASS(error == nil, "the error is not set when the file is read");

  END_SET("NSString file contents with an error")

  [[NSFileManager defaultManager] removeItemAtPath: path error: NULL];
  [arp release];
  return 0;
}
