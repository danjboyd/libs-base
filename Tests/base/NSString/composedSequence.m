#import "ObjectTesting.h"
#import <Foundation/Foundation.h>

/* A subclass with only the primitive methods, which uses NSString's own code.
 */
@interface PlainString : NSString
{
  NSString	*s;
}
@end
@implementation PlainString
- (id) initWithString: (NSString*)aString
{
  if ((self = [super init]) != nil)
    {
      s = [aString copy];
    }
  return self;
}
- (void) dealloc
{
  [s release];
  [super dealloc];
}
- (NSUInteger) length
{
  return [s length];
}
- (unichar) characterAtIndex: (NSUInteger)i
{
  return [s characterAtIndex: i];
}
@end

static NSString *
make(const unichar *u, NSUInteger n, BOOL plain)
{
  NSString	*str = [NSString stringWithCharacters: u length: n];

  return plain ? AUTORELEASE([[PlainString alloc] initWithString: str]) : str;
}

/* Every index in [from, from+len) gives the range [from, from+len).
 */
static BOOL
spans(NSString *str, NSUInteger from, NSUInteger len)
{
  NSUInteger	i;

  for (i = from; i < from + len; i++)
    {
      NSRange	r = [str rangeOfComposedCharacterSequenceAtIndex: i];

      if (r.location != from || r.length != len)
	{
	  return NO;
	}
    }
  return YES;
}

#define	N(a)	(sizeof(a)/sizeof(unichar))

int main()
{
  ENTER_POOL
  int	plain;

  for (plain = 0; plain < 2; plain++)
    {
      static const unichar accent[] = {'e', 0x301, 'x'};
      static const unichar pair[] = {0xd83d, 0xde00, 'x'};
      static const unichar thumb[] = {'a', 0xd83d, 0xdc4d, 0xd83c, 0xdffd, '!'};
      static const unichar family[] = {0xd83d, 0xdc68, 0x200d, 0xd83d, 0xdc69,
	0x200d, 0xd83d, 0xdc67, 'x'};
      static const unichar flags[] = {0xd83c, 0xddfa, 0xd83c, 0xddf8,
	0xd83c, 0xddeb, 0xd83c, 0xddf7, 0xd83c, 0xddee};
      static const unichar keycap[] = {'1', 0xfe0f, 0x20e3, '2'};
      static const unichar heart[] = {0x2764, 0xfe0f, 'x'};
      static const unichar joiner[] = {'a', 0x200d, 'b'};
      static const unichar lone[] = {0xd83d, 'a', 0xd83d};
      static const unichar leading[] = {0x301, 'a'};
      NSString	*str;
      NSRange	r;

      START_SET(plain ? "NSString's own code" : "the concrete string class")

      str = make(accent, N(accent), plain);
      PASS(spans(str, 0, 2) && spans(str, 2, 1), "a combining accent groups")
      str = make(pair, N(pair), plain);
      PASS(spans(str, 0, 2) && spans(str, 2, 1), "a surrogate pair groups")
      str = make(thumb, N(thumb), plain);
      PASS(spans(str, 0, 1) && spans(str, 1, 4) && spans(str, 5, 1),
	"an emoji modifier groups with its emoji")
      str = make(family, N(family), plain);
      PASS(spans(str, 0, 8) && spans(str, 8, 1), "a joined emoji groups")
      str = make(flags, N(flags), plain);
      PASS(spans(str, 0, 4) && spans(str, 4, 4) && spans(str, 8, 2),
	"regional indicators group in pairs from the start of the run")
      str = make(keycap, N(keycap), plain);
      PASS(spans(str, 0, 3) && spans(str, 3, 1), "a keycap sequence groups")
      str = make(heart, N(heart), plain);
      PASS(spans(str, 0, 2) && spans(str, 2, 1), "a variation selector groups")
      str = make(joiner, N(joiner), plain);
      PASS(spans(str, 0, 2) && spans(str, 2, 1),
	"a joiner doesn't join letters")
      str = make(lone, N(lone), plain);
      PASS(spans(str, 0, 1) && spans(str, 1, 1) && spans(str, 2, 1),
	"a lone surrogate stands alone")
      str = make(leading, N(leading), plain);
      PASS(spans(str, 0, 1) && spans(str, 1, 1),
	"a mark with nothing before it stands alone")

      str = make(thumb, N(thumb), plain);
      r = [str rangeOfComposedCharacterSequencesForRange: NSMakeRange(2, 2)];
      PASS(r.location == 1 && r.length == 4,
	"a range inside a sequence widens to the sequence")
      PASS_EXCEPTION([str rangeOfComposedCharacterSequenceAtIndex: N(thumb)],
	NSRangeException, "an index past the end raises")

      END_SET(plain ? "NSString's own code" : "the concrete string class")
    }
  LEAVE_POOL
  return 0;
}
