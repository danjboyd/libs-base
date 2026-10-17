#import "ObjectTesting.h"
#import <Foundation/Foundation.h>

/* +URLByResolvingAliasFileAtURL:options:error: follows the symbolic links
 * a file URL names and reports a missing file.  It used to answer nil for
 * any URL.
 */
int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSFileManager		*manager = [NSFileManager defaultManager];
  NSString		*dir;
  NSString		*file;
  NSString		*link;
  NSString		*chain;
  NSURL			*url;
  NSURL			*resolved;
  NSError		*error = nil;

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [NSString stringWithFormat: @"resolveAlias-%d",
      [[NSProcessInfo processInfo] processIdentifier]]];
  [manager createDirectoryAtPath: dir withIntermediateDirectories: YES
    attributes: nil error: NULL];
  file = [dir stringByAppendingPathComponent: @"file"];
  link = [dir stringByAppendingPathComponent: @"link"];
  chain = [dir stringByAppendingPathComponent: @"chain"];
  [@"content" writeToFile: file atomically: NO
    encoding: NSUTF8StringEncoding error: NULL];
  [manager createSymbolicLinkAtPath: link withDestinationPath: @"file"
    error: NULL];
  [manager createSymbolicLinkAtPath: chain withDestinationPath: link
    error: NULL];

  url = [NSURL fileURLWithPath: file];
  resolved = [NSURL URLByResolvingAliasFileAtURL: url options: 0
    error: &error];
  PASS_EQUAL(resolved, url, "a file that is not a link resolves to itself")

  resolved = [NSURL URLByResolvingAliasFileAtURL:
    [NSURL fileURLWithPath: link] options: 0 error: &error];
  PASS_EQUAL([resolved path], file, "a relative link resolves to its file")

  resolved = [NSURL URLByResolvingAliasFileAtURL:
    [NSURL fileURLWithPath: chain] options: 0 error: &error];
  PASS_EQUAL([resolved path], file, "a chain of links resolves to its file")

  [manager removeItemAtPath: file error: NULL];
  error = nil;
  resolved = [NSURL URLByResolvingAliasFileAtURL:
    [NSURL fileURLWithPath: link] options: 0 error: &error];
  PASS(resolved == nil, "a link to a missing file does not resolve")
  PASS([error code] == NSFileReadNoSuchFileError
    && [[error domain] isEqualToString: NSCocoaErrorDomain],
    "the error says the file does not exist")

  url = [NSURL URLWithString: @"http://www.gnustep.org/"];
  PASS_EQUAL([NSURL URLByResolvingAliasFileAtURL: url options: 0
    error: NULL], url, "a URL that is not a file URL is answered unchanged")

  [manager removeItemAtPath: dir error: NULL];
  [arp release];
  return 0;
}
