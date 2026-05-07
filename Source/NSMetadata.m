/**Interface for NSMetadataQuery for GNUStep
   Copyright (C) 2012 Free Software Foundation, Inc.

   Written by: Gregory John Casamento <greg.casamento@gmail.com>
   Date: 2012
   
   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
*/ 

#import "common.h"

#define EXPOSE_NSMetadataItem_IVARS 1
#define EXPOSE_NSMetadataQuery_IVARS 1
#define EXPOSE_NSMetadataQueryAttributeValueTuple_IVARS 1
#define EXPOSE_NSMetadataQueryResultGroupInternal_IVARS 1
#define EXPOSE_NSMetadataQueryResultGroup_IVARS 1

#import "Foundation/NSMetadata.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSNotification.h"
#import "Foundation/NSPredicate.h"
#import "Foundation/NSString.h"
#import "Foundation/NSTimer.h"

@implementation NSMetadataItem

#define	myAttributes	((NSMutableDictionary*)_NSMetadataItemInternal)

- (NSArray *) attributes
{
  return [myAttributes allKeys];
}

- (void) dealloc
{
  [myAttributes release];
  [super dealloc];
}

- (id) init
{
  if (nil != (self = [super init]))
    {
      _NSMetadataItemInternal = (void*)[NSMutableDictionary new];
    }
  return self;
}

- (id) valueForAttribute: (NSString *)key
{
  return [myAttributes objectForKey: key];
}

- (NSDictionary *) valuesForAttributes: (NSArray *)keys
{
  NSMutableDictionary	*results = [NSMutableDictionary dictionary];
  NSEnumerator		*en = [keys objectEnumerator];
  id			key = nil;

  while ((key = [en nextObject]) != nil)
    {
      id value = [self valueForAttribute: key];

      [results setObject: value forKey: key];
    }

  return results;
}

@end

@interface	NSMetadataQueryInternal : NSObject
{
@public
  BOOL _isStopped;
  BOOL _isGathering;
  BOOL _isStarted;

  NSArray *_searchURLs;
  NSArray *_scopes;
  NSArray *_sortDescriptors;
  NSPredicate *_predicate;
  NSArray *_groupingAttributes;
  NSArray *_valueListAttributes;

  NSTimeInterval _notificationBatchingInterval;
  NSArray *_results;

  id<NSMetadataQueryDelegate> _delegate;
}
@end
@implementation	NSMetadataQueryInternal
@end

#ifdef	this
#undef	this
#endif
#define	this	((NSMetadataQueryInternal*)_NSMetadataQueryInternal)

@implementation NSMetadataQuery

- (void) dealloc
{
  RELEASE(this->_searchURLs);
  RELEASE(this->_scopes);
  RELEASE(this->_sortDescriptors);
  RELEASE(this->_predicate);
  RELEASE(this->_groupingAttributes);
  RELEASE(this->_valueListAttributes);
  RELEASE(this->_results);
  [this release];
  [super dealloc];
}

- (id<NSMetadataQueryDelegate>) delegate
{
  return this->_delegate;
}

- (void) disableUpdates
{
}

- (void) enableUpdates
{
}

- (NSArray *) groupedResults
{
  return [NSArray array];
}

- (NSArray *) groupingAttributes
{
  return this->_groupingAttributes;
}

- (NSUInteger) indexOfResult: (id)result
{
  return [this->_results indexOfObject: result];
}

- (id) init
{
  if ((self = [super init]) != nil)
    {
      _NSMetadataQueryInternal = (void*)[NSMetadataQueryInternal new];
      this->_isStopped = YES;
      this->_isGathering = NO;
      this->_isStarted = NO;
      this->_notificationBatchingInterval = (NSTimeInterval)0.0;
      this->_results = [NSArray new];
    }
  return self;
}

- (BOOL) isGathering
{
  return this->_isGathering;
}

- (BOOL) isStarted
{
  return this->_isStarted;
}

- (BOOL) isStopped
{
  return this->_isStopped;
}

- (NSTimeInterval) notificationBatchingInterval
{
  return this->_notificationBatchingInterval;
}

- (NSPredicate *) predicate
{
  return this->_predicate;
}

- (id) resultAtIndex: (NSUInteger)index
{
  return [this->_results objectAtIndex: index];
}

- (NSUInteger) resultCount
{
  return [this->_results count];
}

- (NSArray *) results
{
  return this->_results;
}

- (NSArray *) searchItemURLs
{
  return this->_searchURLs;
}

- (NSArray *) searchScopes
{
  return this->_scopes;
}

- (void) setDelegate: (id<NSMetadataQueryDelegate>)delegate
{
  this->_delegate = delegate;
}

- (void) setGroupingAttributes: (NSArray *)attrs
{
  ASSIGNCOPY(this->_groupingAttributes, attrs);
}

- (void) setNotificationBatchingInterval: (NSTimeInterval)interval
{
  this->_notificationBatchingInterval = interval;
}

- (void) setPredicate: (NSPredicate *)predicate
{
  ASSIGNCOPY(this->_predicate, predicate);
}

- (void) setSearchItemURLs: (NSArray *)urls
{
  ASSIGNCOPY(this->_searchURLs, urls); 
}

- (void) setSearchScopes: (NSArray *)scopes
{
  ASSIGNCOPY(this->_scopes, scopes);
}

- (void) setSortDescriptors: (NSArray *)descriptors
{
  ASSIGNCOPY(this->_sortDescriptors, descriptors);
}

- (void) setValueListAttributes: (NSArray *)attrs
{
  ASSIGNCOPY(this->_valueListAttributes, attrs);
}

- (NSArray *) sortDescriptors
{
  return this->_sortDescriptors;
}

- (BOOL) startQuery
{
  if (this->_isStarted == YES && this->_isStopped == NO)
    {
      return NO;
    }

  this->_isStopped = NO;
  this->_isGathering = YES;
  this->_isStarted = YES;
  [[NSNotificationCenter defaultCenter]
    postNotificationName: NSMetadataQueryDidStartGatheringNotification
		  object: self];
  this->_isGathering = NO;
  [[NSNotificationCenter defaultCenter]
    postNotificationName: NSMetadataQueryDidFinishGatheringNotification
		  object: self];
  return YES;
}

- (void) stopQuery
{
  this->_isStopped = YES;
  this->_isGathering = NO;
}

- (id) valueOfAttribute: (id)attr forResultAtIndex: (NSUInteger)index
{
  id	result = [self resultAtIndex: index];

  if ([result respondsToSelector: @selector(valueForAttribute:)])
    {
      return [result valueForAttribute: attr];
    }
  return nil;
}

- (NSDictionary *) valueLists
{
  return [NSDictionary dictionary];
}

- (NSArray *) valueListAttributes
{
  return this->_valueListAttributes;
}

@end

@interface NSMetadataQueryAttributeValueTupleInternal : NSObject
{
  @public
  id         _attribute;
  id         _value;
  NSUInteger _count;
}
@end
@implementation NSMetadataQueryAttributeValueTupleInternal
@end

#ifdef	this
#undef	this
#endif
#define	this	((NSMetadataQueryAttributeValueTupleInternal*)\
_NSMetadataQueryAttributeValueTupleInternal)

@implementation NSMetadataQueryAttributeValueTuple

- (NSString *) attribute
{
  return this->_attribute;
}

- (NSUInteger) count
{
  return this->_count;
}

- (void) dealloc
{
  [this release];
  [super dealloc];
}

- (id) init
{
  if (nil != (self = [super init]))
    {
      _NSMetadataQueryAttributeValueTupleInternal =
	(void*)[NSMetadataQueryAttributeValueTupleInternal new];
    }
  return self;
}

- (id) value
{
  return this->_value;
}

@end


@interface NSMetadataQueryResultGroupInternal : NSObject
{
  @public
  id         	_attribute;
  id         	_value;
  NSMutableArray *_subgroups;
}
@end
@implementation NSMetadataQueryResultGroupInternal
@end

#ifdef	this
#undef	this
#endif
#define	this	((NSMetadataQueryResultGroupInternal*)\
_NSMetadataQueryResultGroupInternal)

@implementation NSMetadataQueryResultGroup : NSObject

- (NSString *) attribute
{
  return this->_attribute;
}

- (void) dealloc
{
  [this release];
  [super dealloc];
}

- (id) init
{
  if (nil != (self = [super init]))
    {
      _NSMetadataQueryResultGroupInternal =
	(void*)[NSMetadataQueryResultGroupInternal new];
    }
  return self;
}

- (id) resultAtIndex: (NSUInteger)index
{
  return [this->_subgroups objectAtIndex:index];
}

- (NSUInteger) resultCount
{
  return [this->_subgroups count];
}

- (NSArray *) results
{
  return [self subgroups];
}

- (NSArray *) subgroups
{
  return this->_subgroups;
}

- (id) value
{
  return this->_value;
}

@end
