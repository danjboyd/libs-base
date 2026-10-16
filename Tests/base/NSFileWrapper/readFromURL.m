/*
 * readFromURL.m - regression test for -[NSFileWrapper readFromURL:options:error:]
 * and -initWithURL:options:error:.  The method rebuilt the wrapper and then
 * answered NO without setting the error, so -initWithURL:options:error:
 * answered nil for every URL; without NSFileWrapperReadingImmediate it also
 * left a directory wrapper empty.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSFileManager		*fm = [NSFileManager defaultManager];
  NSString		*dir;
  NSString		*file;
  NSFileWrapper		*w;
  NSError		*error;
  NSData		*contents;

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [[NSProcessInfo processInfo] globallyUniqueString]];
  [fm createDirectoryAtPath: dir
withIntermediateDirectories: YES
		 attributes: nil
		      error: NULL];
  file = [dir stringByAppendingPathComponent: @"a.txt"];
  contents = [@"contents" dataUsingEncoding: NSUTF8StringEncoding];
  [contents writeToFile: file atomically: NO];

  START_SET("NSFileWrapper readFromURL")

    error = nil;
    w = [[[NSFileWrapper alloc] initWithURL: [NSURL fileURLWithPath: file]
				    options: 0
				      error: &error] autorelease];
    PASS(w != nil && error == nil, "a regular file is read")
    PASS([w isRegularFile], "the wrapper is a regular file wrapper")
    PASS_EQUAL([w regularFileContents], contents, "the contents are read")
    PASS_EQUAL([w preferredFilename], @"a.txt", "the preferred name is set")

    w = [[[NSFileWrapper alloc] initWithURL: [NSURL fileURLWithPath: dir]
				    options: 0
				      error: &error] autorelease];
    PASS([w isDirectory], "a directory is read")
    PASS_EQUAL([[[w fileWrappers] objectForKey: @"a.txt"] regularFileContents],
      contents, "the directory wrapper has its children")

    w = [[[NSFileWrapper alloc] initWithURL: [NSURL fileURLWithPath: dir]
				    options: NSFileWrapperReadingImmediate
				      error: &error] autorelease];
    PASS([[w fileWrappers] count] == 1,
      "NSFileWrapperReadingImmediate reads the children")

    error = nil;
    w = [[NSFileWrapper alloc] initRegularFileWithContents: [NSData data]];
    PASS([w readFromURL: [NSURL fileURLWithPath: file] options: 0 error: &error]
      && [[w regularFileContents] isEqual: contents],
      "-readFromURL:options:error: answers YES and rereads the wrapper")
    [w release];

    error = nil;
    w = [[[NSFileWrapper alloc] initWithURL:
      [NSURL fileURLWithPath: [dir stringByAppendingPathComponent: @"none"]]
				    options: 0
				      error: &error] autorelease];
    PASS(w == nil, "a missing file is not read")
    PASS([[error domain] isEqual: NSCocoaErrorDomain]
      && [error code] == NSFileReadNoSuchFileError,
      "a missing file gives NSFileReadNoSuchFileError")

  END_SET("NSFileWrapper readFromURL")

  [fm removeItemAtPath: dir error: NULL];
  [arp release];
  return 0;
}
