/*
 * hash.m - regression test for -[NSLocale hash]: NSLocale compared
 * locales by identifier in -isEqual: but kept NSObject's -hash, so
 * equal locales could hash differently and be missed in sets or as
 * dictionary keys.  Locales made from one identifier are one object,
 * so the test makes a second, equal locale with -copyWithZone: in
 * another zone.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSLocale		*a;
  NSLocale		*b;
  NSDictionary		*d;
  NSSet			*s;

  START_SET("-[NSLocale hash]")
    a = [NSLocale localeWithLocaleIdentifier: @"fr_FR"];
    b = [a copyWithZone: NSCreateZone(1024, 1024, YES)];
    PASS(a != b && [a isEqual: b] && [b isEqual: a],
      "a copy in another zone is a different, equal locale")
    PASS([a hash] == [b hash], "equal locales have the same hash")
    s = [NSSet setWithObjects: a, b, nil];
    PASS([s count] == 1, "a set holds equal locales once")
    d = [NSDictionary dictionaryWithObject: @"x" forKey: a];
    PASS_EQUAL([d objectForKey: b], @"x",
      "an equal locale finds a dictionary value")
  END_SET("-[NSLocale hash]")

  [arp release];
  return 0;
}
