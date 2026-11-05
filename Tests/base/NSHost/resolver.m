#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSUserDefaults.h>
#import "GNUstepBase/GSConfig.h"
#import "GNUstepBase/NSHost+GNUstepBase.h"

/* Host name lookup through c-ares, against a small DNS server in this
 * process, so that it depends on no outside server.  The names are under
 * .invalid, which the system's own lookup can't find, so a host found for
 * one of them was found through c-ares.  The fallback to the system's lookup
 * is checked only by a name that nothing finds: making the system's lookup
 * answer for a name would need changing the machine's configuration.
 * async.m checks the lookup itself, with or without c-ares.
 */

#if	GS_USE_CARES && !defined(_WIN32)

#include <arpa/inet.h>
#include <netinet/in.h>
#include <strings.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>

static int	queries = 0;	/* Questions other than for "drop" names. */
static NSLock	*queriesLock = nil;

static unsigned
addRecord(unsigned char *p, unsigned type, const void *data, unsigned length)
{
  unsigned char	*s = p;

  *p++ = 0xc0; *p++ = 12;		/* The name in the question.	*/
  *p++ = 0; *p++ = type;
  *p++ = 0; *p++ = 1;			/* Class IN.			*/
  *p++ = 0; *p++ = 0; *p++ = 0; *p++ = 60;	/* TTL.			*/
  *p++ = 0; *p++ = length;
  memcpy(p, data, length);
  return p + length - s;
}

@interface	Server : NSObject
{
@public
  int	fd;
}
- (void) run;
@end
@implementation	Server
- (void) run
{
  for (;;)
    {
      struct sockaddr_in	from;
      socklen_t			fromLength = sizeof(from);
      unsigned char		q[512];
      unsigned char		r[1024];
      char			name[256];
      unsigned			at = 12;
      unsigned			out = 0;
      unsigned			type;
      unsigned			n = 0;
      unsigned			answers = 0;
      int			rcode = 0;
      ssize_t			got;

      got = recvfrom(fd, q, sizeof(q), 0, (struct sockaddr*)&from, &fromLength);
      if (got < 12)
	{
	  continue;
	}
      while (at < (unsigned)got && q[at] != 0 && out + q[at] + 1 < sizeof(name))
	{
	  memcpy(name + out, q + at + 1, q[at]);
	  out += q[at];
	  name[out++] = '.';
	  at += q[at] + 1;
	}
      name[out > 0 ? out - 1 : 0] = '\0';
      at++;				/* The root label.		*/
      type = q[at + 1];
      at += 4;				/* Type and class.		*/
      if (strncasecmp(name, "drop", 4) == 0)
	{
	  continue;
	}
      [queriesLock lock];
      queries++;
      [queriesLock unlock];

      memcpy(r, q, at);
      n = at;
      if (strcasecmp(name, "a4.gstest.invalid") == 0 && 1 == type)
	{
	  static const unsigned char	a[4] = {192, 0, 2, 1};

	  n += addRecord(r + n, 1, a, 4); answers++;
	}
      else if (strcasecmp(name, "a6.gstest.invalid") == 0 && 28 == type)
	{
	  static const unsigned char	a[16] = {0x20, 1, 0xd, 0xb8,
	    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};

	  n += addRecord(r + n, 28, a, 16); answers++;
	}
      else if (strcasecmp(name, "both.gstest.invalid") == 0
	|| strcasecmp(name, "alias.gstest.invalid") == 0
	|| strcasecmp(name, "shared.gstest.invalid") == 0
	|| strcasecmp(name, "again.gstest.invalid") == 0)
	{
	  static const unsigned char	a4[4] = {192, 0, 2, 2};
	  static const unsigned char	a6[16] = {0x20, 1, 0xd, 0xb8,
	    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2};

	  if (strcasecmp(name, "alias.gstest.invalid") == 0)
	    {
	      /* Canonical name: canon.gstest.invalid, and its addresses
	       * follow as the addresses of that name. */
	      static const unsigned char	c[] = {5, 'c', 'a', 'n', 'o',
		'n', 6, 'g', 's', 't', 'e', 's', 't', 7, 'i', 'n', 'v', 'a',
		'l', 'i', 'd', 0};
	      unsigned		target = n + 12;

	      n += addRecord(r + n, 5, c, sizeof(c)); answers++;
	      if (1 == type || 28 == type)
		{
		  unsigned	before = n;

		  n += addRecord(r + n, type, 1 == type ? a4 : a6,
		    1 == type ? 4 : 16); answers++;
		  r[before] = 0xc0 | (target >> 8);
		  r[before + 1] = target & 0xff;
		}
	    }
	  else if (1 == type)
	    {
	      n += addRecord(r + n, 1, a4, 4); answers++;
	    }
	  else if (28 == type)
	    {
	      n += addRecord(r + n, 28, a6, 16); answers++;
	    }
	}
      else if (strcasecmp(name, "a4.gstest.invalid") != 0
	&& strcasecmp(name, "a6.gstest.invalid") != 0)
	{
	  rcode = 3;			/* NXDOMAIN.			*/
	}
      r[2] = 0x81;			/* Response, recursion desired.	*/
      r[3] = 0x80 | rcode;		/* Recursion available.		*/
      r[4] = 0; r[5] = 1;
      r[6] = 0; r[7] = answers;
      r[8] = r[9] = r[10] = r[11] = 0;
      sendto(fd, r, n, 0, (struct sockaddr*)&from, fromLength);
    }
}
@end

@interface	Receiver : NSObject
{
@public
  BOOL		called;
  NSHost	*host;
}
- (void) gotHost: (NSHost*)h;
@end
@implementation	Receiver
- (void) dealloc
{
  RELEASE(host);
  DEALLOC
}
- (void) gotHost: (NSHost*)h
{
  called = YES;
  ASSIGN(host, h);
}
@end

static void
start(NSString *name, Receiver *receiver)
{
  [NSHost lookupName: name
	      thread: nil
	      target: receiver
	    selector: @selector(gotHost:)
	       modes: nil];
}

static BOOL
waitFor(Receiver *receiver, NSTimeInterval seconds)
{
  NSDate	*limit = [NSDate dateWithTimeIntervalSinceNow: seconds];

  while (NO == receiver->called && [limit timeIntervalSinceNow] > 0)
    {
      NSAutoreleasePool	*pool = [NSAutoreleasePool new];

      [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
			       beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
      [pool release];
    }
  return receiver->called;
}

static NSSet *
lookup(NSString *name)
{
  Receiver	*receiver = AUTORELEASE([Receiver new]);

  start(name, receiver);
  waitFor(receiver, 15.0);
  return [receiver->host addresses] == nil ? [NSSet set]
    : [NSSet setWithArray: [receiver->host addresses]];
}

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  Server		*server = [Server new];
  struct sockaddr_in	address;
  socklen_t		length = sizeof(address);
  Receiver		*r;
  Receiver		*r2;
  NSDate		*before;
  NSSet			*expected;
  int			count;

  queriesLock = [NSLock new];
  server->fd = socket(AF_INET, SOCK_DGRAM, 0);
  memset(&address, 0, sizeof(address));
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  PASS(0 == bind(server->fd, (struct sockaddr*)&address, sizeof(address))
    && 0 == getsockname(server->fd, (struct sockaddr*)&address, &length),
    "the test's DNS server has a port")
  [NSThread detachNewThreadSelector: @selector(run)
			   toTarget: server
			 withObject: nil];

  /* Both of these are read when the first lookup is made.
   */
  setenv("RES_OPTIONS", "timeout:1 attempts:1", 1);
  [[NSUserDefaults standardUserDefaults] registerDefaults:
    [NSDictionary dictionaryWithObject:
      [NSString stringWithFormat: @"127.0.0.1:%d", ntohs(address.sin_port)]
				forKey: @"GSHostResolverServers"]];

  PASS_EQUAL(lookup(@"a4.gstest.invalid"),
    [NSSet setWithObject: @"192.0.2.1"], "an IPv4 address is found")
  PASS_EQUAL(lookup(@"a6.gstest.invalid"),
    [NSSet setWithObject: @"2001:db8::1"], "an IPv6 address is found")
  expected = [NSSet setWithObjects: @"192.0.2.2", @"2001:db8::2", nil];
  PASS_EQUAL(lookup(@"both.gstest.invalid"), expected,
    "IPv4 and IPv6 addresses are found together")

  r = AUTORELEASE([Receiver new]);
  start(@"alias.gstest.invalid", r);
  PASS(waitFor(r, 15.0), "a name with an alias is answered")
  PASS_EQUAL([NSSet setWithArray: [r->host addresses]], expected,
    "the addresses of the name it's an alias of are found")
  PASS([[r->host names] containsObject: @"alias.gstest.invalid"]
    && [[r->host names] containsObject: @"canon.gstest.invalid"],
    "the host has the name asked for and the canonical name")

  /* The cache: nothing more goes to the server.
   */
  PASS_EQUAL([NSSet setWithArray: [[NSHost cachedHostWithName:
    @"both.gstest.invalid"] addresses]], expected,
    "a host found by a lookup is in the cache")
  PASS([NSHost cachedHostWithName: @"192.0.2.2"] != nil,
    "the cache has it by its address too")
  [queriesLock lock]; count = queries; [queriesLock unlock];
  PASS_EQUAL(lookup(@"both.gstest.invalid"), expected,
    "a second lookup of the name gets the host")
  [queriesLock lock]; PASS(count == queries,
    "a second lookup asks no server"); [queriesLock unlock];

  /* Two lookups of a name at once ask only once.  c-ares asks A and AAAA.
   */
  [queriesLock lock]; count = queries; [queriesLock unlock];
  r = AUTORELEASE([Receiver new]);
  r2 = AUTORELEASE([Receiver new]);
  start(@"shared.gstest.invalid", r);
  start(@"shared.gstest.invalid", r2);
  PASS(waitFor(r, 15.0) && waitFor(r2, 15.0), "two lookups of a name are answered")
  PASS(r->host != nil && r->host == r2->host, "they get the same host")
  [queriesLock lock]; PASS(queries - count == 2,
    "they share their questions to the server"); [queriesLock unlock];

  /* A name nothing has: c-ares says so, and then so does the system's lookup.
   */
  r = AUTORELEASE([Receiver new]);
  start(@"missing.gstest.invalid", r);
  PASS(waitFor(r, 30.0), "a name that isn't found is answered")
  PASS([[r->host addresses] count] == 0, "the answer has no addresses")

  /* A server that doesn't answer holds up neither the caller nor other names:
   * this is what libs-base issue #789 reports.
   */
  r = AUTORELEASE([Receiver new]);
  before = [NSDate date];
  start(@"drop1.gstest.invalid", r);
  PASS([before timeIntervalSinceNow] > -0.5,
    "starting a lookup returns while the server isn't answering")
  r2 = AUTORELEASE([Receiver new]);
  start(@"again.gstest.invalid", r2);
  PASS(waitFor(r2, 0.9) && r2->host != nil && NO == r->called,
    "another name is answered while that lookup waits")
  PASS(waitFor(r, 30.0), "the lookup ends when the server never answers")
  PASS([[r->host addresses] count] == 0, "its answer has no addresses")

  /* A lookup has no cancel: its target goes away and gets nothing.
   */
  r = [Receiver new];
  start(@"drop2.gstest.invalid", r);
  DESTROY(r);
  r2 = AUTORELEASE([Receiver new]);
  start(@"drop2.gstest.invalid", r2);
  PASS(waitFor(r2, 30.0), "a lookup whose first target went away still ends")
  r = AUTORELEASE([Receiver new]);
  PASS(waitFor(r, 0.2) == NO, "and nothing crashed sending to the old target")

  [arp release]; arp = nil;
  return 0;
}

#else

int main(void)
{
  START_SET("host name lookup through c-ares")
    SKIP("gnustep-base wasn't built with c-ares, or this test's DNS server"
      " (POSIX sockets) can't run here")
  END_SET("host name lookup through c-ares")
  return 0;
}

#endif
