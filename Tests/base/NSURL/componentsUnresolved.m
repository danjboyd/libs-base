/*
 * componentsUnresolved.m - regression test for
 * -[NSURLComponents initWithURL:resolvingAgainstBaseURL:] with NO.  The
 * flag had no effect: the components were always those of the URL
 * resolved against its base.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSURL			*base;
  NSURL			*relative;
  NSURLComponents	*c;

  START_SET("NSURLComponents unresolved")

    base = [NSURL URLWithString: @"http://example.test/a/b"];
    relative = [NSURL URLWithString: @"d?q=1" relativeToURL: base];

    c = [NSURLComponents componentsWithURL: relative
		   resolvingAgainstBaseURL: NO];
    PASS_EQUAL([c string], @"d?q=1",
      "without resolving, the string is the relative string")
    PASS([c scheme] == nil && [c host] == nil,
      "without resolving, there is no scheme or host")
    PASS_EQUAL([c path], @"d", "without resolving, the path is relative")
    PASS_EQUAL([c query], @"q=1", "the query is kept")

    c = [NSURLComponents componentsWithURL: relative
		   resolvingAgainstBaseURL: YES];
    PASS_EQUAL([c string], @"http://example.test/a/d?q=1",
      "resolving gives the components of the absolute URL")
    PASS_EQUAL([c host], @"example.test", "resolving gives the host")

    c = [NSURLComponents componentsWithURL: base
		   resolvingAgainstBaseURL: NO];
    PASS_EQUAL([c string], @"http://example.test/a/b",
      "a URL without a base is used as it is")

  END_SET("NSURLComponents unresolved")

  [arp release];
  return 0;
}
