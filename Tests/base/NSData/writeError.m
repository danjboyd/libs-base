/* -writeToFile:options:error: sets the error when it fails, as Cocoa
   does: an NSCocoaErrorDomain error naming the path, with the system
   error as its underlying error.  Every failure returned NO without
   setting the error. */
#import <Foundation/Foundation.h>
#import "Testing.h"

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSData		*data = [@"hello" dataUsingEncoding: NSUTF8StringEncoding];
  NSString		*dir;
  NSString		*missing;
  NSError		*error;
  BOOL			ok;

  START_SET("NSData write errors")

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [NSString stringWithFormat: @"NSDataWriteError-%d",
      [[NSProcessInfo processInfo] processIdentifier]]];
  missing = [dir stringByAppendingPathComponent: @"missing/file.dat"];

  error = nil;
  ok = [data writeToFile: missing options: 0 error: &error];
  PASS(ok == NO, "writing into a missing directory fails");
  PASS(error != nil, "writing into a missing directory sets the error");
  PASS_EQUAL([error domain], NSCocoaErrorDomain,
    "the error is in the Cocoa domain");
  PASS([error code] == NSFileNoSuchFileError,
    "the error code is NSFileNoSuchFileError");
  PASS_EQUAL([[error userInfo] objectForKey: NSFilePathErrorKey], missing,
    "the error names the path");
  PASS_EQUAL([[[error userInfo] objectForKey: NSUnderlyingErrorKey] domain],
    NSPOSIXErrorDomain, "the underlying error is the system error");

  error = nil;
  ok = [data writeToFile: missing options: NSDataWritingAtomic error: &error];
  PASS(ok == NO && error != nil && [error code] == NSFileNoSuchFileError,
    "an atomic write into a missing directory sets the error");

  error = nil;
  ok = [data writeToURL: [NSURL fileURLWithPath: missing]
		options: 0
		  error: &error];
  PASS(ok == NO && [[error domain] isEqual: NSCocoaErrorDomain],
    "writing to a file URL in a missing directory sets the error");

  error = nil;
  ok = [data writeToFile: @"" options: 0 error: &error];
  PASS(ok == NO && [[error domain] isEqual: NSCocoaErrorDomain],
    "writing to an empty path sets the error");

  [[NSFileManager defaultManager] createDirectoryAtPath: dir
			    withIntermediateDirectories: YES
					     attributes: nil
						  error: NULL];
  error = nil;
  ok = [data writeToFile: dir options: 0 error: &error];
  PASS(ok == NO && [[error domain] isEqual: NSCocoaErrorDomain],
    "writing over a directory sets the error");

  error = nil;
  ok = [data writeToFile: [dir stringByAppendingPathComponent: @"file.dat"]
		 options: NSDataWritingAtomic
		   error: &error];
  PASS(ok == YES && error == nil, "a successful write leaves the error alone");

  [[NSFileManager defaultManager] removeItemAtPath: dir error: NULL];

  END_SET("NSData write errors")

  [arp release];
  return 0;
}
