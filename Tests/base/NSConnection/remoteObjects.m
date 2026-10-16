/*
 * remoteObjects.m - regression test for -[NSConnection remoteObjects].
 * It added the keys of the remote proxy map (the target numbers) to
 * the array instead of the proxies, and crashed retaining them.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSConnection		*connection;
  NSArray		*remotes;
  id			first;
  id			second;

  START_SET("NSConnection remoteObjects")

    connection = [[NSConnection alloc] initWithReceivePort: [NSPort port]
						  sendPort: [NSPort port]];
    PASS([[connection remoteObjects] count] == 0,
      "a new connection has no remote objects")

    first = [NSDistantObject proxyWithTarget: 7 connection: connection];
    second = [NSDistantObject proxyWithTarget: 8 connection: connection];
    remotes = [connection remoteObjects];
    PASS([remotes count] == 2, "the connection lists both proxies")
    PASS([remotes indexOfObjectIdenticalTo: first] != NSNotFound
      && [remotes indexOfObjectIdenticalTo: second] != NSNotFound,
      "the remote objects are the proxies")

    [connection invalidate];
    [connection release];

  END_SET("NSConnection remoteObjects")

  [arp release];
  return 0;
}
