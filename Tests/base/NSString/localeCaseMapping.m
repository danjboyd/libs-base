/*
 * localeCaseMapping.m - regression test for -uppercaseStringWithLocale:,
 * -lowercaseStringWithLocale: and -capitalizedStringWithLocale:, which
 * answered the converted string followed by a U+0000.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSLocale		*en = [NSLocale localeWithLocaleIdentifier: @"en_US"];
  NSLocale		*tr = [NSLocale localeWithLocaleIdentifier: @"tr_TR"];
  NSString		*s;

  START_SET("locale case mapping")
    s = [@"hello world" uppercaseStringWithLocale: en];
    PASS_EQUAL(s, @"HELLO WORLD", "-uppercaseStringWithLocale: converts")
    PASS([s length] == 11, "-uppercaseStringWithLocale: adds no character")
    s = [@"HELLO World" lowercaseStringWithLocale: en];
    PASS_EQUAL(s, @"hello world", "-lowercaseStringWithLocale: converts")
    PASS([s length] == 11, "-lowercaseStringWithLocale: adds no character")
    s = [@"hello world" capitalizedStringWithLocale: en];
    PASS_EQUAL(s, @"Hello World", "-capitalizedStringWithLocale: converts")
    PASS([s length] == 11, "-capitalizedStringWithLocale: adds no character")
    PASS_EQUAL([@"i" uppercaseStringWithLocale: tr], @"İ",
      "the locale's rules apply (Turkish dotted capital I)")
    PASS_EQUAL([@"straße" uppercaseStringWithLocale: en], @"STRASSE",
      "a conversion that lengthens the string keeps every character")
    PASS_EQUAL([@"" uppercaseStringWithLocale: en], @"",
      "an empty string converts to an empty string")
  END_SET("locale case mapping")

  [arp release];
  return 0;
}
