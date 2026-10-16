/*
 * readError.m - regression test for the error from a malformed property
 * list.  Cocoa reports it in NSCocoaErrorDomain with the code
 * NSPropertyListReadCorruptError (3840); libs-base used the domain
 * NSPropertyListSerialization and code 0.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

static NSError *
errorFor(NSString *plist)
{
  NSError	*error = nil;
  id		obj;

  obj = [NSPropertyListSerialization
    propertyListWithData: [plist dataUsingEncoding: NSUTF8StringEncoding]
		 options: NSPropertyListImmutable
		  format: NULL
		   error: &error];
  return obj == nil ? error : nil;
}

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSError		*error;

  START_SET("NSPropertyListSerialization read errors")

    error = errorFor(@"{ a = (1, 2; }");
    PASS_EQUAL([error domain], NSCocoaErrorDomain,
      "a malformed OpenStep property list gives NSCocoaErrorDomain")
    PASS([error code] == NSPropertyListReadCorruptError,
      "a malformed OpenStep property list gives"
      " NSPropertyListReadCorruptError")
    PASS([[error localizedDescription] length] > 0,
      "the error has a description")

    error = errorFor(@"<?xml version=\"1.0\"?><plist><dict><key>a</key>");
    PASS_EQUAL([error domain], NSCocoaErrorDomain,
      "a malformed XML property list gives NSCocoaErrorDomain")
    PASS([error code] == NSPropertyListReadCorruptError,
      "a malformed XML property list gives NSPropertyListReadCorruptError")

  END_SET("NSPropertyListSerialization read errors")

  [arp release];
  return 0;
}
