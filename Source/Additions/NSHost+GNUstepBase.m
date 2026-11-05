/* Implementation of extension methods to base additions

   Copyright (C) 2026 Free Software Foundation, Inc.

   Written by:   Richard Frith-Macdonald <rfm@gnu.org>

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.

*/
#import "common.h"
#import "Foundation/Foundation.h"
#import "GNUstepBase/NSHost+GNUstepBase.h"
#import "GNUstepBase/GSBoxWeak.h"
#import "GSPrivate.h"

@interface GSAsyncHostClient : NSObject
{
@public
  GSBoxWeak	*target;
  SEL		selector;
  NSThread	*thread;
  NSArray	*modes;
}
@end
@implementation	GSAsyncHostClient
- (void) dealloc
{
  RELEASE(target);
  RELEASE(thread);
  RELEASE(modes);
  DEALLOC
}
@end

@interface GSAsyncHost : NSObject <GSOperationCompletion>
{
  NSLock		*lock;
  NSString		*name;
  NSMutableArray	*clients;
  GSOperation		*operation;
  NSHost		*resolved;	/* Set if c-ares answered.	*/
}
+ (void) lookupName: (NSString*)name
             thread: (NSThread*)thread
             target: (id)anObject
           selector: (SEL)aSelector
              modes: (NSArray*)modes;
- (BOOL) addThread: (NSThread*)thread
	    target: (id)anObject
	  selector: (SEL)aSelector
	     modes: (NSArray*)modes;
- (instancetype) initWithName: (NSString*)n;
- (void) notifyClients;
- (void) operationCompleted;
- (void) resolvedHost: (NSHost*)host;
- (void) start;
@end

#if	!defined(__APPLE__)
@interface NSHost (GSAsyncHost)
+ (BOOL) _resolveName: (NSString*)name forLookup: (id)client;
@end
#endif

@implementation GSAsyncHost 

static NSLock			*activeLock = nil;
static NSMutableDictionary	*active = nil;
static NSLock			*queueLock = nil;
static NSOperationQueue		*operationQueue = nil;

+ (void) initialize
{
  if (nil == activeLock)
    {
      activeLock = [NSLock new];
      active = [NSMutableDictionary new];
      queueLock = [NSLock new];
    }
}

+ (void) lookupName: (NSString*)name
             thread: (NSThread*)thread
             target: (id)anObject
           selector: (SEL)aSelector
              modes: (NSArray*)modes
{
  GSAsyncHost	*h;
  BOOL		start;

  if (nil == thread)
    {
      thread = [NSThread currentThread];
    }

#if     !defined(__APPLE__)
  {
    NSHost	*found = [NSHost cachedHostWithName: name];

    if (found)
      {
	[anObject performSelector: aSelector
			 onThread: thread
		       withObject: found
		    waitUntilDone: NO
			    modes: modes];
	return;
      }
  }
#endif

  [activeLock lock];
  h = [active objectForKey: name];
  if (nil == h)
    {
      h = [[self alloc] initWithName: name];
      [active setObject: h forKey: h->name];
      RELEASE(h);
    }
  start = [h addThread: thread target: anObject selector: aSelector modes: modes];
  RETAIN(h);
  [activeLock unlock];
  /* Outside the locks, as the lookup may complete before -start returns.
   */
  if (start)
    {
      [h start];
    }
  RELEASE(h);
}

+ (NSOperationQueue*) queue
{
  if (nil == operationQueue)
    {
      [queueLock lock];
      if (nil == operationQueue)
	{
	  operationQueue = [NSOperationQueue new];
	}
      [queueLock unlock];
    }
  return operationQueue;
}

/* Answers YES if the caller must send -start once it holds no locks.
 */
- (BOOL) addThread: (NSThread*)thread
	    target: (id)anObject
	  selector: (SEL)aSelector
	     modes: (NSArray*)modes
{
  GSAsyncHostClient	*c = [GSAsyncHostClient new];
  BOOL			start = NO;

  c->target = [[GSBoxWeak alloc] initWithValue: anObject];
  c->selector = aSelector;
  c->thread = RETAIN(thread);
  c->modes = [modes copy];
  [lock lock];
  [clients addObject: c];
  RELEASE(c);
  if ([clients count] == 1)
    {
      /* No other items in the queue - either the lookup has not been
       * started yet or it finished (and queued clients have been notified).
       */
      if (resolved != nil || [operation isFinished])
	{
	  [lock unlock];
	  [self notifyClients];
	  return NO;
	}
      start = YES;
    }
  [lock unlock];
  return start;
}

- (void) dealloc
{
  DESTROY(resolved);
  DESTROY(operation);
  DESTROY(clients);
  DESTROY(name);
  DESTROY(lock);
  DEALLOC
}

- (instancetype) initWithName: (NSString*)n
{
  if (nil != (self = [super init]))
    {
      lock = [NSLock new];
      name = [n copy];
      clients = [NSMutableArray new];
      operation = [[GSOperation alloc] initTarget: [NSHost class]
					 selector: @selector(hostWithName:)
					   object: name];
      [operation setDelegate: self];
    }
  return self;
}

- (void) notifyClients
{
  ENTER_POOL
  NSArray	*a;
  id		r;

  [lock lock];
  a = AUTORELEASE([clients copy]);
  if (resolved != nil)
    {
      r = resolved;
    }
  else
    {
      [operation getTarget: NULL selector: NULL object: NULL
		    result: &r ofItem: 0];
    }
  AUTORELEASE(RETAIN(r));
  [clients removeAllObjects];
  [lock unlock];

  if ([a count])
    {
      GS_FOR_IN(GSAsyncHostClient*, c, a)
	NS_DURING
	  [[c->target value] performSelector: c->selector
				    onThread: c->thread
				  withObject: r
			       waitUntilDone: NO
				       modes: c->modes];
	NS_HANDLER
	  NSLog(@"Problem sending host lookup result to client: %@",
	    localException);
	NS_ENDHANDLER
      GS_END_FOR(a)
    }
  LEAVE_POOL
}

- (void) operationCompleted
{
  [activeLock lock];
  if ([active objectForKey: name] == self)
    {
      AUTORELEASE(RETAIN(self));
      [active removeObjectForKey: name];
    }
  [activeLock unlock];
  [self notifyClients];
}

/* c-ares has answered.  With no host it may only be that the name isn't in
 * the DNS, so the system's own lookup gets to decide.
 */
- (void) resolvedHost: (NSHost*)host
{
  if (nil == host)
    {
      [[GSAsyncHost queue] addOperation: operation];
    }
  else
    {
      [lock lock];
      ASSIGN(resolved, host);
      [lock unlock];
      [self operationCompleted];
    }
}

- (void) start
{
#if	!defined(__APPLE__)
  if ([NSHost _resolveName: name forLookup: self])
    {
      return;
    }
#endif
  [[GSAsyncHost queue] addOperation: operation];
}

@end





@implementation NSHost (GNUstepBase)
+ (void) lookupName: (NSString*)name
             thread: (NSThread*)thread
             target: (id)anObject
           selector: (SEL)aSelector
              modes: (NSArray*)modes
{
  if (NO == [name isKindOfClass: [NSString class]] || [name length] == 0)
    {
      [NSException raise: NSInvalidArgumentException
	          format: @"+[%@ %@] name is not valid",
	NSStringFromClass(self), NSStringFromSelector(_cmd)];
    }
  if (nil == thread)
    {
      thread = [NSThread currentThread];
    }
  else if (NO == [thread isKindOfClass: [NSThread class]]
    || NO == [thread isExecuting])
    {
      [NSException raise: NSInvalidArgumentException
	          format: @"+[%@ %@] thread is not running",
	NSStringFromClass(self), NSStringFromSelector(_cmd)];
    }
  if (NULL == aSelector)
    {
      [NSException raise: NSInvalidArgumentException
	          format: @"+[%@ %@] selector is NULL",
	NSStringFromClass(self), NSStringFromSelector(_cmd)];
    }
  if (NO == [anObject respondsToSelector: aSelector])
    {
      [NSException raise: NSInvalidArgumentException
	          format: @"+[%@ %@] target does not respond to selector",
	NSStringFromClass(self), NSStringFromSelector(_cmd)];
    }
  if (nil == modes)
    {
      modes = [NSArray arrayWithObject: NSDefaultRunLoopMode];
    }
  else if (NO == [modes isKindOfClass: [NSArray class]])
    {
      [NSException raise: NSInvalidArgumentException
	          format: @"+[%@ %@] modes is not an array",
	NSStringFromClass(self), NSStringFromSelector(_cmd)];
    }
  else if ([modes count] == 0)
    {
      modes = [NSArray arrayWithObject: NSDefaultRunLoopMode];
    }
  [GSAsyncHost lookupName: name
		   thread: thread
	           target: anObject
		 selector: aSelector
		    modes: modes];
}
@end
