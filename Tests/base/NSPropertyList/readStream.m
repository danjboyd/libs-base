#import "ObjectTesting.h"
#import <Foundation/Foundation.h>

/* +propertyListWithStream:options:format:error: reads the stream to its end
 * and parses what it held.  It used to answer nil for any stream.
 */
int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSDictionary		*plist;
  NSData		*data;
  NSInputStream		*stream;
  NSPropertyListFormat	format = 0;
  NSError		*error = nil;
  id			result;

  plist = [NSDictionary dictionaryWithObjectsAndKeys:
    @"value", @"key", [NSArray arrayWithObject: @"item"], @"list", nil];

  data = [NSPropertyListSerialization dataWithPropertyList: plist
    format: NSPropertyListXMLFormat_v1_0 options: 0 error: NULL];
  stream = [NSInputStream inputStreamWithData: data];
  [stream open];
  result = [NSPropertyListSerialization propertyListWithStream: stream
    options: NSPropertyListImmutable format: &format error: &error];
  PASS_EQUAL(result, plist, "an XML property list is read from a stream")
  PASS(format == NSPropertyListXMLFormat_v1_0, "the format is reported")

  data = [NSPropertyListSerialization dataWithPropertyList: plist
    format: NSPropertyListBinaryFormat_v1_0 options: 0 error: NULL];
  stream = [NSInputStream inputStreamWithData: data];
  result = [NSPropertyListSerialization propertyListWithStream: stream
    options: NSPropertyListImmutable format: &format error: &error];
  PASS_EQUAL(result, plist,
    "a binary property list is read from a stream that was not opened")
  PASS(format == NSPropertyListBinaryFormat_v1_0, "the binary format is reported")

  data = [@"<plist><dict><key>" dataUsingEncoding: NSUTF8StringEncoding];
  stream = [NSInputStream inputStreamWithData: data];
  [stream open];
  error = nil;
  result = [NSPropertyListSerialization propertyListWithStream: stream
    options: NSPropertyListImmutable format: NULL error: &error];
  PASS(result == nil && error != nil, "a corrupt stream gives an error")

  [arp release];
  return 0;
}
