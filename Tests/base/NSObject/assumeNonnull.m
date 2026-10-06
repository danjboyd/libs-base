/* Build the NSObject declarations the way a client that defines
 * GNUSTEP_ASSUME_NONULL sees them (with clang, inside audited non-null
 * regions), and check that the methods the header leaves non-null return
 * an object while the coder hooks accept a nil coder, as the keyed
 * archiver relies on.
 *
 * Nullability qualifiers do not change code generation, so this test
 * passes with or without the audited regions; what it guards is that the
 * header still compiles with the assumption turned on and that the
 * annotated contract matches the implementation.
 */
#define GNUSTEP_ASSUME_NONULL 1
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSAutoreleasePool.h>
#import "Testing.h"

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSObject		*o;

  START_SET("NSObject non-null contract")

  o = [[NSObject new] autorelease];
  PASS(o != nil, "+new returns an object");
  PASS([[[NSObject alloc] init] autorelease] != nil,
    "+alloc and -init return an object");
  PASS([o self] == o, "-self returns the receiver");
  PASS([o class] == [NSObject class], "-class returns the class");
  PASS([o description] != nil, "-description returns a string");
  PASS([o classForCoder] == [NSObject class],
    "-classForCoder returns the class");
  PASS([o classForArchiver] == [NSObject class],
    "-classForArchiver returns the class");
  PASS([o replacementObjectForCoder: nil] == o,
    "-replacementObjectForCoder: accepts a nil coder");
  PASS([o replacementObjectForArchiver: nil] == o,
    "-replacementObjectForArchiver: accepts a nil archiver");

  END_SET("NSObject non-null contract")

  [arp release];
  return 0;
}
