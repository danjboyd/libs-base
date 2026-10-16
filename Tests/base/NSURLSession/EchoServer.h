/* A loopback HTTP server for the upload tests.  It answers each POST with
 * "echo:" and the request body, reading a body sent with Content-Length or
 * chunked transfer coding.  When the request asks for it with
 * "Expect: 100-continue", it sends an interim 100 Continue response before
 * reading the body.  It serves connections one at a time, on a thread of
 * its own, until the process ends.
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <pthread.h>
#include <string.h>
#include <strings.h>
#include <sys/socket.h>
#include <unistd.h>

static NSMutableData *
echoRead(int sock, NSMutableData *buffer, NSUInteger wanted)
{
  char	bytes[4096];

  while ([buffer length] < wanted)
    {
      ssize_t	n = recv(sock, bytes, sizeof(bytes), 0);

      if (n <= 0)
	{
	  return nil;
	}
      [buffer appendBytes: bytes length: n];
    }
  return buffer;
}

/* Reads until the buffer holds marker, and answers the length up to the
 * end of the marker, or NSNotFound if the connection ends first.
 */
static NSUInteger
echoReadTo(int sock, NSMutableData *buffer, const char *marker)
{
  NSData	*m = [NSData dataWithBytes: marker length: strlen(marker)];

  for (;;)
    {
      NSRange	r = [buffer rangeOfData: m
				options: 0
				  range: NSMakeRange(0, [buffer length])];

      if (r.location != NSNotFound)
	{
	  return NSMaxRange(r);
	}
      if (echoRead(sock, buffer, [buffer length] + 1) == nil)
	{
	  return NSNotFound;
	}
    }
}

static void
echoConsume(NSMutableData *buffer, NSUInteger length)
{
  [buffer replaceBytesInRange: NSMakeRange(0, length)
		    withBytes: NULL
		       length: 0];
}

static void
echoServe(int sock)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSMutableData		*buffer = [NSMutableData data];
  NSMutableData		*body = [NSMutableData data];
  NSMutableData		*reply;
  NSString		*head;
  NSString		*lower;
  NSUInteger		end;
  NSRange		r;

  if ((end = echoReadTo(sock, buffer, "\r\n\r\n")) == NSNotFound)
    {
      [arp release];
      return;
    }
  head = [[[NSString alloc] initWithBytes: [buffer bytes]
				   length: end
				 encoding: NSISOLatin1StringEncoding]
    autorelease];
  lower = [head lowercaseString];
  echoConsume(buffer, end);
  if ([lower rangeOfString: @"\r\nexpect: 100-continue"].location
    != NSNotFound)
    {
      const char	*interim = "HTTP/1.1 100 Continue\r\n\r\n";

      send(sock, interim, strlen(interim), 0);
    }
  if ([lower rangeOfString: @"\r\ntransfer-encoding: chunked"].location
    != NSNotFound)
    {
      for (;;)
	{
	  NSString	*line;
	  unsigned	size;

	  if ((end = echoReadTo(sock, buffer, "\r\n")) == NSNotFound)
	    {
	      break;
	    }
	  line = [[[NSString alloc] initWithBytes: [buffer bytes]
					   length: end - 2
					 encoding: NSISOLatin1StringEncoding]
	    autorelease];
	  echoConsume(buffer, end);
	  size = 0;
	  sscanf([line UTF8String], "%x", &size);
	  if (echoRead(sock, buffer, size + 2) == nil)
	    {
	      break;
	    }
	  [body appendBytes: [buffer bytes] length: size];
	  echoConsume(buffer, size + 2);
	  if (size == 0)
	    {
	      break;
	    }
	}
    }
  else if ((r = [lower rangeOfString: @"\r\ncontent-length:"]).location
    != NSNotFound)
    {
      NSUInteger	length;

      length = [[lower substringFromIndex: NSMaxRange(r)] intValue];
      if (echoRead(sock, buffer, length) != nil)
	{
	  [body appendBytes: [buffer bytes] length: length];
	}
    }
  reply = [NSMutableData data];
  [reply appendData: [[NSString stringWithFormat:
    @"HTTP/1.1 200 OK\r\nContent-Length: %lu\r\nConnection: close\r\n\r\n"
    @"echo:", (unsigned long)[body length] + 5]
    dataUsingEncoding: NSASCIIStringEncoding]];
  [reply appendData: body];
  send(sock, [reply bytes], [reply length], 0);
  [arp release];
}

static void *
echoLoop(void *arg)
{
  int	listener = (int)(intptr_t)arg;

  for (;;)
    {
      int	sock = accept(listener, NULL, NULL);

      if (sock < 0)
	{
	  break;
	}
      echoServe(sock);
      close(sock);
    }
  return NULL;
}

/* Starts the server and answers its base URL, or nil if it cannot start.
 */
static NSString *
echoServerStart(void)
{
  struct sockaddr_in	addr;
  socklen_t		len = sizeof(addr);
  pthread_t		thread;
  int			listener;

  listener = socket(AF_INET, SOCK_STREAM, 0);
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  if (listener < 0
    || bind(listener, (struct sockaddr *)&addr, sizeof(addr)) != 0
    || listen(listener, 4) != 0
    || getsockname(listener, (struct sockaddr *)&addr, &len) != 0
    || pthread_create(&thread, NULL, echoLoop, (void *)(intptr_t)listener))
    {
      return nil;
    }
  pthread_detach(thread);
  return [NSString stringWithFormat: @"http://127.0.0.1:%d",
    ntohs(addr.sin_port)];
}

/* A delegate recording the status of each response it is told about, the
 * body received, and whether it was asked for a body stream.
 */
@interface EchoDelegate : NSObject <NSURLSessionDataDelegate>
{
@public
  NSMutableArray	*statuses;
  NSMutableData		*body;
  NSData		*streamedBody;
  volatile BOOL		done;
  volatile BOOL		asked;
}
@end

@implementation EchoDelegate
- (id) init
{
  if ((self = [super init]) != nil)
    {
      statuses = [NSMutableArray new];
      body = [NSMutableData new];
    }
  return self;
}

- (void) dealloc
{
  [statuses release];
  [body release];
  [streamedBody release];
  [super dealloc];
}

- (void) URLSession: (NSURLSession *)session
	   dataTask: (NSURLSessionDataTask *)dataTask
 didReceiveResponse: (NSURLResponse *)response
{
  @synchronized (self)
    {
      [statuses addObject: [NSNumber numberWithInteger:
	[(NSHTTPURLResponse *)response statusCode]]];
    }
  [dataTask resumeWithResponseDisposition: NSURLSessionResponseAllow];
}

- (void) URLSession: (NSURLSession *)session
	   dataTask: (NSURLSessionDataTask *)dataTask
     didReceiveData: (NSData *)data
{
  @synchronized (self)
    {
      [body appendData: data];
    }
}

- (void) URLSession: (NSURLSession *)session
taskNeedsNewBodyStream: (NSURLSessionTask *)task
{
  asked = YES;
  [task resumeWithBodyStream: [NSInputStream inputStreamWithData: streamedBody]];
}

- (void) URLSession: (NSURLSession *)session
	       task: (NSURLSessionTask *)task
didCompleteWithError: (NSError *)error
{
  done = YES;
}

- (NSString *) bodyString
{
  @synchronized (self)
    {
      return [[[NSString alloc] initWithData: body
				    encoding: NSUTF8StringEncoding]
	autorelease];
    }
}
@end

/* Runs an upload of data to url (a streamed one when data is nil) and
 * answers the delegate once the task completes or ten seconds pass.
 */
static EchoDelegate *
echoUpload(NSString *url, NSData *data, NSData *streamed, BOOL expect)
{
  NSURLSessionConfiguration	*configuration;
  EchoDelegate			*delegate;
  NSURLSession			*session;
  NSMutableURLRequest		*request;
  NSURLSessionTask		*task;
  NSDate			*limit;

  configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
  [configuration setTimeoutIntervalForRequest: 8];
  [configuration setTimeoutIntervalForResource: 8];
  delegate = [[EchoDelegate new] autorelease];
  ASSIGN(delegate->streamedBody, streamed);
  session = [NSURLSession sessionWithConfiguration: configuration
					  delegate: delegate
				     delegateQueue: nil];
  request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
  [request setHTTPMethod: @"POST"];
  if (expect)
    {
      [request setValue: @"100-continue" forHTTPHeaderField: @"Expect"];
    }
  if (nil == data)
    {
      task = [session uploadTaskWithStreamedRequest: request];
    }
  else
    {
      task = [session uploadTaskWithRequest: request fromData: data];
    }
  [task resume];
  limit = [NSDate dateWithTimeIntervalSinceNow: 10.0];
  while (!delegate->done && [limit timeIntervalSinceNow] > 0)
    {
      [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
			       beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
    }
  [session invalidateAndCancel];
  return delegate;
}
