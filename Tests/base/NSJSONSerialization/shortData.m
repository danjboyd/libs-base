/*
 * shortData.m - regression test for JSON data shorter than four bytes.
 * +JSONObjectWithData:options:error: read four bytes to detect the
 * encoding without checking the length of the data, so the bytes after
 * a short buffer decided the encoding.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  static char		one[4] = { '3', 0, 0, 0 };
  static char		two[4] = { '[', ']', 0, 0 };
  static char		odd[4] = { '7', 0, ' ', ' ' };
  static char		utf16[4] = { '5', 0, 0, 0 };
  NSData		*data;
  NSError		*error;
  id			obj;

  START_SET("NSJSONSerialization short data")

    data = [NSData dataWithBytesNoCopy: one length: 1 freeWhenDone: NO];
    error = nil;
    obj = [NSJSONSerialization JSONObjectWithData: data
      options: NSJSONReadingAllowFragments error: &error];
    PASS_EQUAL(obj, [NSNumber numberWithInt: 3],
      "a one byte number followed by NUL bytes in memory is read as UTF-8")

    data = [NSData dataWithBytesNoCopy: odd length: 1 freeWhenDone: NO];
    obj = [NSJSONSerialization JSONObjectWithData: data
      options: NSJSONReadingAllowFragments error: &error];
    PASS_EQUAL(obj, [NSNumber numberWithInt: 7],
      "a one byte number followed by a NUL byte in memory is read as UTF-8")

    data = [NSData dataWithBytesNoCopy: two length: 2 freeWhenDone: NO];
    obj = [NSJSONSerialization JSONObjectWithData: data
      options: 0 error: &error];
    PASS_EQUAL(obj, [NSArray array], "a two byte array is read")

    data = [NSData dataWithBytesNoCopy: utf16 length: 2 freeWhenDone: NO];
    obj = [NSJSONSerialization JSONObjectWithData: data
      options: NSJSONReadingAllowFragments error: &error];
    PASS_EQUAL(obj, [NSNumber numberWithInt: 5],
      "a two byte UTF-16 little endian number is read")

    data = [NSData data];
    error = nil;
    obj = [NSJSONSerialization JSONObjectWithData: data
      options: NSJSONReadingAllowFragments error: &error];
    PASS(obj == nil && error != nil, "empty data is an error")

  END_SET("NSJSONSerialization short data")

  [arp release];
  return 0;
}
