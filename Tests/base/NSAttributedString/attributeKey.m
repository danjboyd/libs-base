/* NSAttributedStringKey is declared with NS_TYPED_EXTENSIBLE_ENUM, as in
   Cocoa, so Swift imports it as NSAttributedString.Key, and the methods
   taking an attribute name take it.  In Objective-C it is still an
   NSString, so existing code is unchanged. */
#import <Foundation/Foundation.h>
#import "Testing.h"

/* The macros for typed constants can be used. */
typedef NSString *GSTestExtensibleKey NS_TYPED_EXTENSIBLE_ENUM;
typedef NSString *GSTestKey NS_TYPED_ENUM;
typedef NSString *GSTestStringKey NS_STRING_ENUM;
typedef NSString *GSTestExtensibleStringKey NS_EXTENSIBLE_STRING_ENUM;

int main()
{
  NSAutoreleasePool		*arp = [NSAutoreleasePool new];
  NSAttributedStringKey		key = @"GSTestAttribute";
  NSString			*name = key;
  GSTestExtensibleKey		other = @"GSTestOther";
  NSMutableAttributedString	*s;

  START_SET("NSAttributedStringKey")

  s = AUTORELEASE([[NSMutableAttributedString alloc] initWithString: @"abc"]);
  [s addAttribute: key value: @"v" range: NSMakeRange(0, 2)];
  PASS_EQUAL([s attribute: key atIndex: 1 effectiveRange: NULL], @"v",
    "an attribute added with a key is found with it");
  PASS_EQUAL([s attribute: name atIndex: 0 effectiveRange: NULL], @"v",
    "a key is an NSString");
  [s removeAttribute: key range: NSMakeRange(0, 1)];
  PASS([s attribute: key atIndex: 0 effectiveRange: NULL] == nil
    && [[s attribute: key atIndex: 1 effectiveRange: NULL] isEqual: @"v"],
    "an attribute is removed with its key");
  PASS([other isEqualToString: @"GSTestOther"],
    "a typed extensible enum is an NSString");

  {
    GS_GENERIC_CLASS(NSDictionary, NSAttributedStringKey, id)	*attrs;

    attrs = [NSDictionary dictionaryWithObject: @"w" forKey: key];
    [s setAttributes: attrs range: NSMakeRange(2, 1)];
    attrs = [s attributesAtIndex: 2 effectiveRange: NULL];
    PASS_EQUAL([attrs objectForKey: key], @"w",
      "attribute dictionaries are keyed by NSAttributedStringKey");
  }

  END_SET("NSAttributedStringKey")

  [arp release];
  return 0;
}
