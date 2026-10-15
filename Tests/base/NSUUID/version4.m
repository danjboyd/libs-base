#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUUID.h>
#import "Testing.h"

/* +[NSUUID UUID] makes random (version 4) UUIDs as described in
 * RFC 4122 section 4.4: the high four bits of octet 6 hold the
 * version, 4, and the high two bits of octet 8 hold the variant, 0b10.
 * In the string form the third group starts with 4 and the fourth
 * group starts with 8, 9, A or B.
 */
int main(int argc, char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  unsigned		count = 1000;
  unsigned		badVersion = 0;
  unsigned		badVariant = 0;
  unsigned		badString = 0;
  unsigned		varied = 0;
  unsigned		i;

  for (i = 0; i < count; i++)
    {
      NSAutoreleasePool	*pool = [NSAutoreleasePool new];
      NSUUID		*uuid = [NSUUID UUID];
      NSString		*string = [uuid UUIDString];
      unsigned char	bytes[16];
      unichar		c;

      [uuid getUUIDBytes: bytes];
      if ((bytes[6] & 0xf0) != 0x40)
	{
	  badVersion++;
	}
      if ((bytes[8] & 0xc0) != 0x80)
	{
	  badVariant++;
	}
      /* The bits next to the fixed ones are random; over many UUIDs
       * some must be set.
       */
      if ((bytes[6] & 0x0f) != 0 || (bytes[7] != 0) || (bytes[8] & 0x3f) != 0)
	{
	  varied++;
	}
      c = [string characterAtIndex: 19];
      if ([string characterAtIndex: 14] != '4'
	|| (c != '8' && c != '9' && c != 'A' && c != 'B'))
	{
	  badString++;
	}
      [pool release];
    }

  PASS(badVersion == 0, "+[NSUUID UUID] sets version 4 in octet 6")
  PASS(badVariant == 0, "+[NSUUID UUID] sets the RFC 4122 variant in octet 8")
  PASS(badString == 0, "UUID strings have 4 and one of 8, 9, A, B"
    " at the start of the third and fourth groups")
  PASS(varied > count / 2, "the bits next to version and variant are random")

  [arp release];
  return 0;
}
