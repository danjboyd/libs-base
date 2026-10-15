/** Implementation of the methods GNUstep adds to Protocol
   Copyright (C) 2026 Free Software Foundation, Inc.

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

#ifdef __GNUSTEP_RUNTIME__

/* The libobjc2 runtime makes Protocol a subclass of the method-less root
 * class Object, so a protocol object answers no messages, while in Cocoa
 * Protocol inherits from NSObject.  Code that treats a protocol as an
 * object, such as the Swift runtime, which sends -class to find an
 * object's class and -description to print it, then fails.
 *
 * As GSBlock does for _NSBlock, copy the methods of this class onto
 * Protocol when it loads.  A method the runtime already gives Protocol is
 * left alone.  The subclasses the runtime uses for protocol objects
 * inherit the methods.
 */
@interface GSProtocol : NSObject
@end

@implementation GSProtocol

+ (void) load
{
  unsigned int	methodCount;
  Method	*methods;
  Class		protocolClass = objc_getClass("Protocol");
  unsigned int	i;

  if (Nil == protocolClass)
    {
      return;
    }
  methods = class_copyMethodList(self, &methodCount);
  for (i = 0; i < methodCount; i++)
    {
      class_addMethod(protocolClass, method_getName(methods[i]),
	method_getImplementation(methods[i]),
	method_getTypeEncoding(methods[i]));
    }
  free(methods);
}

/* Answers the class of the protocol object.
 */
- (Class) class
{
  return object_getClass(self);
}

/* Protocols are permanent, so retaining, releasing and autoreleasing
 * one does nothing, as for a constant string.  This lets a protocol be
 * kept in a Foundation collection under manual reference counting.
 */
- (id) retain
{
  return self;
}

- (oneway void) release
{
}

- (id) autorelease
{
  return self;
}

/* Each protocol is one object, so a protocol is equal only to itself.
 */
- (BOOL) isEqual: (id)other
{
  return (self == other) ? YES : NO;
}

- (NSUInteger) hash
{
  return (NSUInteger)(uintptr_t)self;
}

/* Answers the description Cocoa gives a protocol, which is NSObject's:
 * the class name Protocol and the address.  Use protocol_getName() for
 * the protocol's name.
 */
- (NSString*) description
{
  return [NSString stringWithFormat: @"<Protocol: %p>", self];
}

@end

#endif /* __GNUSTEP_RUNTIME__ */
