/*
 * itemReplacementDirectory.m - regression test for
 * -URLForDirectory:inDomain:appropriateForURL:create:error: with
 * NSItemReplacementDirectory.  It answered the temporary directory
 * itself, which a caller removes when done; Cocoa creates a new, unique
 * directory for each call.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSFileManager		*fm = [NSFileManager defaultManager];
  NSString		*temporary;
  NSURL			*target;
  NSURL			*first;
  NSURL			*second;
  NSError		*error = nil;
  BOOL			isDir = NO;

  temporary = [NSTemporaryDirectory() stringByStandardizingPath];
  target = [NSURL fileURLWithPath:
    [temporary stringByAppendingPathComponent: @"replace.txt"]];

  START_SET("NSFileManager item replacement directory")

    first = [fm URLForDirectory: NSItemReplacementDirectory
		       inDomain: NSUserDomainMask
	      appropriateForURL: target
			 create: YES
			  error: &error];
    second = [fm URLForDirectory: NSItemReplacementDirectory
			inDomain: NSUserDomainMask
	       appropriateForURL: target
			  create: YES
			   error: &error];
    PASS(first != nil && second != nil, "a directory is answered")
    PASS(![[[first path] stringByStandardizingPath] isEqual: temporary],
      "it is not the temporary directory itself")
    PASS(![first isEqual: second], "each call answers a new directory")
    PASS([fm fileExistsAtPath: [first path] isDirectory: &isDir] && isDir,
      "the directory exists")
    PASS([[fm contentsOfDirectoryAtPath: [first path] error: NULL] count] == 0,
      "the directory is empty")

    /* Never remove the temporary directory itself (as an unfixed
     * library would answer).
     */
    if (![[[first path] stringByStandardizingPath] isEqual: temporary])
      {
	[fm removeItemAtURL: first error: NULL];
      }
    if (![[[second path] stringByStandardizingPath] isEqual: temporary])
      {
	[fm removeItemAtURL: second error: NULL];
      }
    PASS(![fm fileExistsAtPath: [first path]]
      && [fm fileExistsAtPath: temporary],
      "removing it leaves the temporary directory")

  END_SET("NSFileManager item replacement directory")

  [arp release];
  return 0;
}
