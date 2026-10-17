#import <Foundation/Foundation.h>

#if defined(__OBJC__) && defined(__clang__) && defined(_MSC_VER)
id __work_around_clang_bug2 = @"__unused__";
#endif

#if GS_HAVE_NSURLSESSION

#import "Helpers/HTTPServer.h"
#import "NSRunLoop+TimeOutAdditions.h"
#import "Testing.h"

/* The delegate of an upload is told how much of the body has been sent.
 * URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:
 * used never to be sent, although the task counted the bytes.
 */
@interface ProgressDelegate : NSObject <NSURLSessionTaskDelegate>
{
@public
  NSLock	*lock;
  int64_t	sum;
  int64_t	lastTotal;
  int64_t	expected;
  BOOL		ordered;
  BOOL		done;
}
@end

@implementation ProgressDelegate
- (id) init
{
  if ((self = [super init]) != nil)
    {
      lock = [NSLock new];
      ordered = YES;
    }
  return self;
}

- (void) dealloc
{
  [lock release];
  [super dealloc];
}

- (void) URLSession: (NSURLSession *)session
               task: (NSURLSessionTask *)task
    didSendBodyData: (int64_t)bytesSent
     totalBytesSent: (int64_t)totalBytesSent
totalBytesExpectedToSend: (int64_t)totalBytesExpectedToSend
{
  [lock lock];
  sum += bytesSent;
  if (bytesSent <= 0 || totalBytesSent != lastTotal + bytesSent)
    {
      ordered = NO;
    }
  lastTotal = totalBytesSent;
  expected = totalBytesExpectedToSend;
  [lock unlock];
}

- (void) URLSession: (NSURLSession *)session
               task: (NSURLSessionTask *)task
didCompleteWithError: (NSError *)error
{
  [lock lock];
  done = YES;
  [lock unlock];
}
@end

int
main(int argc, char *argv[])
{
  CREATE_AUTORELEASE_POOL(arp);
  NSString		*currentDirectory;
  NSBundle		*bundle;
  NSData		*body;
  Class			routeClass;
  NSArray		*routes;
  HTTPServer		*server;
  NSURL			*url;
  NSMutableURLRequest	*request;
  ProgressDelegate	*delegate;
  NSURLSession		*session;
  NSURLSessionUploadTask	*task;
  NSDate		*deadline;

  currentDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
  bundle = [NSBundle bundleWithPath: [currentDirectory
    stringByAppendingString: @"/Helpers/HTTPServer.bundle"]];
  if (![bundle load])
    {
      [NSException raise: NSInternalInconsistencyException
                  format: @"failed to load HTTPServer.bundle"];
    }
  body = [NSData dataWithContentsOfFile: [currentDirectory
    stringByAppendingString: @"/Resources/largeBody.txt"]];
  PASS(body != nil, "the body can be loaded")

  routeClass = [bundle classNamed: @"Route"];
  routes = [NSArray arrayWithObject: [routeClass
    routeWithURL: [NSURL URLWithString: @"/upload"]
          method: @"POST"
        response: [@"HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n"
                    dataUsingEncoding: NSASCIIStringEncoding]]];
  server = [[[bundle principalClass] alloc] initWithPort: 0 routes: routes];
  [server resume];
  url = [NSURL URLWithString: [NSString stringWithFormat:
    @"http://127.0.0.1:%ld/upload", (long)[server port]]];

  delegate = [ProgressDelegate new];
  session = [NSURLSession
    sessionWithConfiguration:
      [NSURLSessionConfiguration ephemeralSessionConfiguration]
                    delegate: delegate
               delegateQueue: nil];
  request = [NSMutableURLRequest requestWithURL: url];
  [request setHTTPMethod: @"POST"];
  task = [session uploadTaskWithRequest: request fromData: body];
  [task resume];

  deadline = [NSDate dateWithTimeIntervalSinceNow: 60];
  while ([[NSRunLoop currentRunLoop] runSliceUntil: deadline])
    {
      BOOL	finished;

      [delegate->lock lock];
      finished = delegate->done;
      [delegate->lock unlock];
      if (finished)
        {
          break;
        }
    }

  PASS(delegate->done, "the upload completed")
  PASS(delegate->sum == (int64_t)[body length],
    "the delegate is told of every byte of the body")
  PASS(delegate->ordered,
    "each report adds the bytes sent since the previous one")
  PASS(delegate->lastTotal == (int64_t)[body length],
    "the last report gives the whole body as sent")
  PASS(delegate->expected == (int64_t)[body length],
    "the reports give the length of the body")

  [session finishTasksAndInvalidate];
  [server suspend];
  [server release];
  [delegate release];
  DESTROY(arp);
  return 0;
}

#else

int
main(int argc, char *argv[])
{
  return 0;
}

#endif
