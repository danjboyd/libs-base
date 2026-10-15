/* -enumerateAttribute:inRange:options:usingBlock: and
   -enumerateAttributesInRange:options:usingBlock: call the block for each
   run of an attribute (or of all attributes) in a range, forwards or in
   reverse, as Cocoa does.  The methods were missing. */
#import <Foundation/Foundation.h>
#import "Testing.h"

/* Describes a run as its label and range, such as "k0+4". */
static NSString *
run(NSString *label, NSRange r)
{
  return [NSString stringWithFormat: @"%@%lu+%lu", label,
    (unsigned long)r.location, (unsigned long)r.length];
}

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSAttributedString enumeration")
#if __has_feature(blocks)
  NSMutableAttributedString	*s;
  NSMutableArray		*runs = [NSMutableArray array];
  __block NSMutableArray	*seen = runs;
  __block NSUInteger		calls = 0;

  /* "aaaabbbbcccc": "k" is 1 over 0-3, unset over 4-7, 2 over 8-11;
     "o" is set over 2-5, which splits the attribute runs. */
  s = [[NSMutableAttributedString alloc] initWithString: @"aaaabbbbcccc"];
  [s addAttribute: @"k" value: @"1" range: NSMakeRange(0, 4)];
  [s addAttribute: @"k" value: @"2" range: NSMakeRange(8, 4)];
  [s addAttribute: @"o" value: @"x" range: NSMakeRange(2, 4)];

  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(0, 12)
		options: 0
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    [seen addObject: run(value ? value : @"-", range)];
  }];
  PASS_EQUAL([runs componentsJoinedByString: @" "],
    @"10+4 -4+4 28+4",
    "attribute runs are the longest runs, with nil where unset");

  [runs removeAllObjects];
  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(2, 8)
		options: NSAttributedStringEnumerationReverse
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    [seen addObject: run(value ? value : @"-", range)];
  }];
  PASS_EQUAL([runs componentsJoinedByString: @" "],
    @"28+2 -4+4 12+2",
    "reverse enumeration runs backwards and clips to the range");

  [runs removeAllObjects];
  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(0, 12)
		options: NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    [seen addObject: run(@"", range)];
  }];
  PASS([runs count] >= 3 && [[runs lastObject] isEqual: @"8+4"],
    "runs need not be the longest without longest effective ranges");

  [runs removeAllObjects];
  [s enumerateAttributesInRange: NSMakeRange(0, 12)
			options: 0
		     usingBlock: ^(NSDictionary *attrs, NSRange range, BOOL *stop) {
    [seen addObject: run([NSString stringWithFormat: @"%lu:",
      (unsigned long)[attrs count]], range)];
  }];
  PASS_EQUAL([runs componentsJoinedByString: @" "],
    @"1:0+2 2:2+2 1:4+2 0:6+2 1:8+4",
    "attributes runs change wherever any attribute changes");

  [s enumerateAttributesInRange: NSMakeRange(0, 12)
			options: NSAttributedStringEnumerationReverse
		     usingBlock: ^(NSDictionary *attrs, NSRange range, BOOL *stop) {
    calls++;
    if (range.location == 4)
      {
	*stop = YES;
      }
  }];
  PASS(calls == 3, "setting the stop flag ends the enumeration");

  calls = 0;
  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(5, 0)
		options: 0
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    calls++;
  }];
  PASS(calls == 0, "an empty range calls the block no times");

  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(0, 12)
		options: 0
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    if (value != nil)
      {
	[s replaceCharactersInRange: range withString: @"Z"];
      }
  }];
  PASS_EQUAL([s string], @"ZbbbbZ",
    "the block may change the run it is given");

  /* "ZbbbbZ": "k" is 1 over 0, unset over 1-4, 2 over 5.  Going
     backwards, replacing each run leaves the runs before it alone. */
  [runs removeAllObjects];
  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(0, 6)
		options: NSAttributedStringEnumerationReverse
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    [seen addObject: run(value ? value : @"-", range)];
    [s replaceCharactersInRange: range
		     withString: (value ? @"" : @"yy")];
  }];
  PASS_EQUAL([runs componentsJoinedByString: @" "], @"25+1 -1+4 10+1",
    "reverse enumeration sees each run when the block changes it");
  PASS_EQUAL([s string], @"yy",
    "the changes made going backwards are all kept");

  /* Going forwards, a run made longer moves the runs after it. */
  [s release];
  s = [[NSMutableAttributedString alloc] initWithString: @"abc"];
  [s addAttribute: @"k" value: @"1" range: NSMakeRange(0, 1)];
  [s addAttribute: @"k" value: @"2" range: NSMakeRange(2, 1)];
  [runs removeAllObjects];
  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(0, 3)
		options: 0
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    [seen addObject: run(value ? value : @"-", range)];
    if (value == nil)
      {
	[s replaceCharactersInRange: range withString: @"BBBB"];
      }
  }];
  PASS_EQUAL([runs componentsJoinedByString: @" "], @"10+1 -1+1 25+1",
    "a run made longer moves the runs after it");
  PASS_EQUAL([s string], @"aBBBBc", "the longer run is kept");

  /* A change beyond the run must not take the enumeration past the end. */
  calls = 0;
  [s enumerateAttribute: @"k"
		inRange: NSMakeRange(0, 6)
		options: 0
	     usingBlock: ^(id value, NSRange range, BOOL *stop) {
    calls++;
    if (calls == 1)
      {
	[s deleteCharactersInRange: NSMakeRange(3, 3)];
      }
  }];
  PASS(calls >= 2 && calls < 10,
    "a change outside the run does not take the enumeration past the end");

  PASS_EXCEPTION([s enumerateAttribute: @"k"
			       inRange: NSMakeRange(0, 99)
			       options: 0
			    usingBlock: ^(id value, NSRange range, BOOL *stop) {}],
    NSRangeException, "a range beyond the string raises");

  [s release];
#else
  SKIP("blocks support unavailable")
#endif
  END_SET("NSAttributedString enumeration")

  [arp release];
  return 0;
}
