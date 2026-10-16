/*
 * dotSegments.m - regression test for resolving a relative URL against a
 * base.  The resolved -absoluteString and -path kept the '.' and '..'
 * segments, which RFC 3986 section 5.2.4 (and Cocoa) remove.  The cases
 * are those of RFC 3986 section 5.4 for the base http://a/b/c/d.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

static NSURL	*base = nil;

static void
check(NSString *rel, NSString *expected)
{
  NSURL	*u = [NSURL URLWithString: rel relativeToURL: base];

  PASS_EQUAL([u absoluteString], expected, "%s resolves to %s",
    [rel UTF8String], [expected UTF8String])
}

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSURL			*u;

  START_SET("NSURL dot segments")

    base = [NSURL URLWithString: @"http://a/b/c/d"];
    check(@"g", @"http://a/b/c/g");
    check(@"./g", @"http://a/b/c/g");
    check(@"g/", @"http://a/b/c/g/");
    check(@".", @"http://a/b/c/");
    check(@"./", @"http://a/b/c/");
    check(@"..", @"http://a/b/");
    check(@"../", @"http://a/b/");
    check(@"../g", @"http://a/b/g");
    check(@"../..", @"http://a/");
    check(@"../../", @"http://a/");
    check(@"../../g", @"http://a/g");
    check(@"../../../g", @"http://a/g");
    check(@"../../../../g", @"http://a/g");
    check(@"/./g", @"http://a/g");
    check(@"/../g", @"http://a/g");
    check(@"g.", @"http://a/b/c/g.");
    check(@".g", @"http://a/b/c/.g");
    check(@"g..", @"http://a/b/c/g..");
    check(@"..g", @"http://a/b/c/..g");
    check(@"./../g", @"http://a/b/g");
    check(@"./g/.", @"http://a/b/c/g/");
    check(@"g/./h", @"http://a/b/c/g/h");
    check(@"g/../h", @"http://a/b/c/h");
    check(@"g?y/./x", @"http://a/b/c/g?y/./x");

    u = [NSURL URLWithString: @"../d" relativeToURL:
      [NSURL URLWithString: @"http://example.test/a/b/c"]];
    PASS_EQUAL([u path], @"/a/d", "the resolved path has no dot segments")
    PASS_EQUAL([u relativeString], @"../d",
      "the relative string keeps its dot segments")

    u = [NSURL URLWithString: @"http://a/b/../c"];
    PASS_EQUAL([u absoluteString], @"http://a/b/../c",
      "a URL without a base keeps its dot segments")

  END_SET("NSURL dot segments")

  [arp release];
  return 0;
}
