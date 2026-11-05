#import "ObjectTesting.h"
#import <Foundation/Foundation.h>
#include <errno.h>
#include <sys/stat.h>
#include <unistd.h>

int main()
{
  ENTER_POOL
  NSFileManager	*mgr = [NSFileManager defaultManager];
  NSString	*dir;
  NSString	*missing;
  NSString	*file;
  NSError	*error = nil;
  NSError	*underlying;
  BOOL		ok;

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  PASS([mgr createDirectoryAtPath: dir withIntermediateDirectories: YES
		       attributes: nil error: NULL], "made a directory")
  missing = [dir stringByAppendingPathComponent: @"missing"];
  file = [dir stringByAppendingPathComponent: @"file"];

  ok = [mgr removeItemAtPath: missing error: &error];
  PASS(ok == NO, "removing a missing file fails")
  PASS_EQUAL([error domain], NSCocoaErrorDomain, "its error is a Cocoa error")
  PASS([error code] == NSFileNoSuchFileError, "the code says there's no file")
  PASS_EQUAL([[error userInfo] objectForKey: NSFilePathErrorKey], missing,
    "the error names the path")
  underlying = [[error userInfo] objectForKey: NSUnderlyingErrorKey];
  PASS_EQUAL([underlying domain], NSPOSIXErrorDomain,
    "the underlying error is the system's")
  PASS([underlying code] == ENOENT, "the underlying code is the system's")

  error = nil;
  ok = [mgr removeItemAtURL: [NSURL fileURLWithPath: missing] error: &error];
  PASS(ok == NO && [error code] == NSFileNoSuchFileError
    && [[error domain] isEqual: NSCocoaErrorDomain],
    "removing by URL gives the same error")

  PASS([mgr removeItemAtPath: missing error: NULL] == NO,
    "a NULL error pointer is fine")

  PASS([mgr createFileAtPath: file contents: [NSData data] attributes: nil],
    "made a file")
  error = nil;
#if !defined(_WIN32)
  if (geteuid() != 0)
    {
      chmod([dir fileSystemRepresentation], 0555);
      ok = [mgr removeItemAtPath: file error: &error];
      chmod([dir fileSystemRepresentation], 0755);
      PASS(ok == NO, "removing from a read-only directory fails")
      PASS_EQUAL([error domain], NSCocoaErrorDomain,
	"its error is a Cocoa error")
      PASS([error code] == NSFileWriteNoPermissionError,
	"the code says there's no permission")
      error = nil;
    }
#endif
  PASS([mgr removeItemAtPath: file error: &error] && error == nil,
    "a successful removal sets no error")
  [mgr removeItemAtPath: dir error: NULL];
  LEAVE_POOL
  return 0;
}
