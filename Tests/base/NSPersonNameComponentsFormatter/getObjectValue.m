/*
 * getObjectValue.m - regression test for
 * -[NSPersonNameComponentsFormatter getObjectValue:forString:errorDescription:],
 * which answered NO for a string it had parsed and wrote the error
 * description without checking for a NULL pointer.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool			*arp = [NSAutoreleasePool new];
  NSPersonNameComponentsFormatter	*f;
  NSPersonNameComponents		*pnc = nil;
  NSString				*err = @"unset";
  BOOL					ok;

  f = AUTORELEASE([NSPersonNameComponentsFormatter new]);

  START_SET("-getObjectValue:forString:errorDescription:")
    ok = [f getObjectValue: &pnc
		 forString: @"Ada Lovelace"
	  errorDescription: &err];
    PASS(ok, "a parsed name answers YES")
    PASS([pnc isKindOfClass: [NSPersonNameComponents class]]
      && [[pnc givenName] isEqual: @"Ada"]
      && [[pnc familyName] isEqual: @"Lovelace"],
      "the parsed components are returned")
    PASS_EQUAL(err, @"unset",
      "the error description is left alone on success")
    pnc = nil;
    PASS_RUNS(ok = [f getObjectValue: &pnc
			   forString: @"Grace Hopper"
		    errorDescription: NULL],
      "a NULL error description pointer is accepted")
    PASS(ok && [[pnc familyName] isEqual: @"Hopper"],
      "a name parses with a NULL error description pointer")
  END_SET("-getObjectValue:forString:errorDescription:")

  [arp release];
  return 0;
}
