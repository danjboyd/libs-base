#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSString.h>

/* Mapping a file that does not exist answers nil, whether or not the
   caller asks for the error.  Without an error pointer, the mapped-file
   initializer let the file reader store its error through NULL, which
   crashed. */

int main()
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  NSString *missing = @"/tmp/GSTestNoSuchMappedFile.dat";
  NSError *error = nil;
  id data = @"unset";

  START_SET("NSData mapping a missing file")

  PASS_RUNS(data = [NSData dataWithContentsOfMappedFile: missing],
    "mapping a missing file does not crash");
  PASS(data == nil, "mapping a missing file answers nil");

  data = [NSData dataWithContentsOfFile: missing
                                options: NSDataReadingMappedAlways
                                  error: &error];
  PASS(data == nil && error != nil,
    "mapping a missing file reports an error when asked");

  END_SET("NSData mapping a missing file")

  [arp release];
  return 0;
}
