/** Definition of class NSByteCountFormatter
   Copyright (C) 2019 Free Software Foundation, Inc.
   
   Written by: 	Gregory Casamento <greg.casamento@gmail.com>
   Date: 	July 2019
   
   This file is part of the GNUstep Library.
   
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

#define	GS_NSByteCountFormatter_IVARS \
 NSFormattingContext _formattingContext; \
 NSByteCountFormatterCountStyle _countStyle; \
 BOOL _allowsNonnumericFormatting; \
 BOOL _includesActualByteCount; \
 BOOL _adaptive; \
 NSByteCountFormatterUnits _allowedUnits; \
 BOOL _includesCount; \
 BOOL _includesUnit; \
 BOOL _zeroPadsFractionDigits; 

#define	EXPOSE_NSByteCountFormatter_IVARS	1

#import "Foundation/NSArchiver.h"
#import "Foundation/NSKeyedArchiver.h"
#import "Foundation/NSByteCountFormatter.h"
#import "Foundation/NSString.h"
#import "Foundation/NSAttributedString.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSError.h"
#import "Foundation/NSLocale.h"
#import "Foundation/NSValue.h"

#define	GSInternal		NSByteCountFormatterInternal
#include	"GSInternal.h"
GS_PRIVATE_INTERNAL(NSByteCountFormatter)

#include	<math.h>

/* Unit definitions, in terms of the size of a kilobyte (kilo), which is
 * 1000 bytes for the file and decimal count styles and 1024 bytes for
 * the memory and binary ones.
 */
#define KB (kilo)
#define MB (KB * kilo)
#define GB (MB * kilo)
#define TB (GB * kilo)
#define PB (TB * kilo)
#define EB (PB * kilo)
#define ZB (EB * kilo)
#define YB (ZB * kilo)

@implementation NSByteCountFormatter
  
+ (NSString*) stringFromByteCount: (long long)byteCount
                       countStyle: (NSByteCountFormatterCountStyle)countStyle
{
  NSByteCountFormatter *formatter = AUTORELEASE([NSByteCountFormatter new]);

  [formatter setCountStyle: countStyle];
  return [formatter stringFromByteCount: byteCount];
}

- (NSString*) stringForObjectValue: (id)obj
{
  long long byteCount = 0;
  
  if ([obj respondsToSelector: @selector(longLongValue)])
    {
      byteCount = [obj longLongValue];
    }

  return [self stringFromByteCount: byteCount];
}

- (double) _kilo
{
  if (internal->_countStyle == NSByteCountFormatterCountStyleMemory
    || internal->_countStyle == NSByteCountFormatterCountStyleBinary)
    {
      return 1024.0;
    }
  return 1000.0;
}

- (NSByteCountFormatterUnits) _adaptiveSettings: (double)byteCount
{
  NSByteCountFormatterUnits units = NSByteCountFormatterUseBytes;
  double		    kilo = [self _kilo];
  
  if (byteCount >= KB) 
    {
      units = NSByteCountFormatterUseKB;
    }
  if (byteCount >= MB) 
    {
      units = NSByteCountFormatterUseMB;
    }
  if (byteCount >= GB) 
    {
      units = NSByteCountFormatterUseGB;
    }
  if (byteCount >= TB) 
    {
      units = NSByteCountFormatterUseTB;
    }
  if (byteCount >= PB) 
    {
      units = NSByteCountFormatterUsePB;
    }
  if (byteCount >= EB) 
    {
      units = NSByteCountFormatterUseEB;
    }
  if (byteCount >= YB) 
    {
      units = NSByteCountFormatterUseYBOrHigher;
    }
  
  return units;
}

- (NSString*) stringFromByteCount: (long long)byteCount
{
  NSString                      *result = nil;
  double                        bc = (double)byteCount;
  double                        count = 0;
  NSString                      *outputFormat = @"";
  NSString                      *unitName = @"";
  NSByteCountFormatterUnits     allowed = internal->_allowedUnits;
  double                        kilo = [self _kilo];

  if (internal->_adaptive)
    {
      allowed = [self _adaptiveSettings: bc];
    }
  else if (allowed == NSByteCountFormatterUseDefault)
    {
      allowed = NSByteCountFormatterUseMB;
    }

  if (allowed & NSByteCountFormatterUseYBOrHigher)
    {
      count = bc / YB;
      unitName = @"YB";
    }
  if (allowed & NSByteCountFormatterUseEB)
    {
      count = bc / EB;
      unitName = @"EB";
    }
  if (allowed & NSByteCountFormatterUsePB)
    {
      count = bc / PB;
      unitName = @"PB";
    }
  if (allowed & NSByteCountFormatterUseTB)
    {
      count = bc / TB;
      unitName = @"TB";
    }
  if (allowed & NSByteCountFormatterUseGB)
    {
      count = bc / GB;
      unitName = @"GB";
    }
  if (allowed & NSByteCountFormatterUseMB)
    {
      count = bc / MB;	    
      unitName = @"MB";
    }
  if (allowed & NSByteCountFormatterUseKB)
    {
      count = bc / KB;
      unitName = @"KB";      
    }
  if (allowed & NSByteCountFormatterUseBytes)
    {
      count = bc;
      unitName = @"bytes";
    }

  if (internal->_allowsNonnumericFormatting && count == 0.0)
    {
      outputFormat = @"Zero";
    }
  else
    {
      int	digits = 0;
      double	scale;

      /* Adaptive formatting shows no fraction digits for bytes and KB,
       * one for MB and two for larger units, rounded to the nearest.
       * Trailing zeros are dropped unless zeroPadsFractionDigits is set.
       */
      if (internal->_adaptive)
	{
	  if (allowed == NSByteCountFormatterUseMB)
	    {
	      digits = 1;
	    }
	  else if (allowed > NSByteCountFormatterUseMB)
	    {
	      digits = 2;
	    }
	}
      scale = pow(10.0, digits);
      count = round(count * scale) / scale;
      if (internal->_zeroPadsFractionDigits == NO)
	{
	  while (digits > 0
	    && fmod(round(count * pow(10.0, digits)), 10.0) == 0.0)
	    {
	      digits--;
	    }
	}
      outputFormat = [NSString stringWithFormat: @"%.*f", digits, count];
    }

  if (internal->_includesUnit)
    {
      outputFormat = [outputFormat stringByAppendingFormat: @" %@", unitName];
    }
  result = outputFormat;

  return result;
}

- (void) dealloc
{
   if (GS_EXISTS_INTERNAL)
    {
      GS_DESTROY_INTERNAL(NSByteCountFormatter)
    }
  DEALLOC
}

- (id) init
{
  if (nil == (self = [super init]))
    {
      return nil;
    }

  GS_CREATE_INTERNAL(NSByteCountFormatter);

  internal->_countStyle = NSByteCountFormatterCountStyleFile;
  internal->_allowedUnits = NSByteCountFormatterUseDefault;
  internal->_adaptive = YES;
  internal->_formattingContext = NSFormattingContextUnknown;
  internal->_allowsNonnumericFormatting = YES;
  internal->_includesUnit = YES;

  return self;
}

- (NSFormattingContext) formattingContext
{
  return internal->_formattingContext;
}

- (void) setFormattingContext: (NSFormattingContext)ctx
{
  internal->_formattingContext = ctx;
}

- (NSByteCountFormatterCountStyle) countStyle
{
  return internal->_countStyle;
}

- (void) setCountStyle: (NSByteCountFormatterCountStyle)style
{
  internal->_countStyle = style;
}

- (BOOL) allowsNonnumericFormatting
{
  return internal->_allowsNonnumericFormatting;
}

- (void) setAllowsNonnumericFormatting: (BOOL)flag
{
  internal->_allowsNonnumericFormatting = flag;
}

- (BOOL) includesActualByteCount
{
  return internal->_includesActualByteCount;
}

- (void) setIncludesActualByteCount: (BOOL)flag
{
  internal->_includesActualByteCount = flag;
}

- (BOOL) isAdaptive
{
  return internal->_adaptive;
}

- (void) setAdaptive: (BOOL)flag
{
  internal->_adaptive = flag;
}

- (NSByteCountFormatterUnits) allowedUnits
{
  return internal->_allowedUnits;
}

- (void) setAllowedUnits: (NSByteCountFormatterUnits)units
{
  internal->_allowedUnits = units;
}

- (BOOL) includesCount
{
  return internal->_includesCount;
}

- (void) setIncludesCount: (BOOL)flag
{
  internal->_includesCount = flag;
}

- (BOOL) includesUnit
{
  return internal->_includesUnit;
}

- (void) setIncludesUnit: (BOOL)flag
{
  internal->_includesUnit = flag;
}
  
- (BOOL) zeroPadsFractionDigits
{
  return internal->_zeroPadsFractionDigits;
}

- (void) setZeroPadsFractionDigits: (BOOL)flag
{
  internal->_zeroPadsFractionDigits = flag;
}

- (id) initWithCoder: (NSCoder *)coder
{
  if (nil == (self = [super init]))
    {
      return nil;
    }

  GS_CREATE_INTERNAL(NSByteCountFormatter);

  if ([coder allowsKeyedCoding])
    {
      internal->_formattingContext = [coder decodeIntegerForKey: @"NSFormattingContext"];
      internal->_countStyle = [coder decodeIntegerForKey: @"NSCountStyle"];
      internal->_allowsNonnumericFormatting = !([coder decodeBoolForKey: @"NSNoNonnumeric"]);
      internal->_includesActualByteCount = [coder decodeBoolForKey: @"NSIncludesActualByteCount"];
      internal->_adaptive = !([coder decodeBoolForKey: @"NSNoAdaptive"]);
      internal->_allowedUnits = [coder decodeIntegerForKey: @"NSAllowedUnits"];
      internal->_includesCount = !([coder decodeBoolForKey: @"NSNoCount"]);
      internal->_includesUnit = !([coder decodeBoolForKey: @"NSNoUnit"]);
      internal->_zeroPadsFractionDigits = [coder decodeBoolForKey: @"NSZeroPad"];
    }
  else
    {
      [coder decodeValueOfObjCType: @encode(NSFormattingContext) at: &internal->_formattingContext];
      [coder decodeValueOfObjCType: @encode(NSByteCountFormatterCountStyle) at: &internal->_countStyle];
      [coder decodeValueOfObjCType: @encode(BOOL) at: &internal->_allowsNonnumericFormatting];
      [coder decodeValueOfObjCType: @encode(BOOL) at: &internal->_includesActualByteCount];
      [coder decodeValueOfObjCType: @encode(BOOL) at: &internal->_adaptive];
      [coder decodeValueOfObjCType: @encode(NSByteCountFormatterUnits) at: &internal->_allowedUnits];
      [coder decodeValueOfObjCType: @encode(BOOL) at: &internal->_includesCount];
      [coder decodeValueOfObjCType: @encode(BOOL) at: &internal->_includesUnit];
      [coder decodeValueOfObjCType: @encode(BOOL) at: &internal->_zeroPadsFractionDigits];
    }

  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  [super encodeWithCoder: coder];
  if ([coder allowsKeyedCoding])
    {
      [coder encodeInteger: internal->_formattingContext forKey: @"NSFormattingContext"];
      [coder encodeInteger: internal->_countStyle forKey: @"NSCountStyle"];
      [coder encodeBool: !(internal->_allowsNonnumericFormatting) forKey: @"NSNoNonnumeric"];
      [coder encodeBool: internal->_includesActualByteCount forKey: @"NSIncludesActualByteCount"];
      [coder encodeBool: !(internal->_adaptive) forKey: @"NSNoAdaptive"];
      [coder encodeInteger: internal->_allowedUnits forKey: @"NSAllowedUnits"];
      [coder encodeBool: !(internal->_includesCount) forKey: @"NSNoCount"];
      [coder encodeBool: !(internal->_includesUnit) forKey: @"NSNoUnit"];
      [coder encodeBool: internal->_zeroPadsFractionDigits forKey: @"NSZeroPad"];
    }
  else
    {
      [coder encodeValueOfObjCType: @encode(NSFormattingContext) at: &internal->_formattingContext];
      [coder encodeValueOfObjCType: @encode(NSByteCountFormatterCountStyle) at: &internal->_countStyle];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &internal->_allowsNonnumericFormatting];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &internal->_includesActualByteCount];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &internal->_adaptive];
      [coder encodeValueOfObjCType: @encode(NSByteCountFormatterUnits) at: &internal->_allowedUnits];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &internal->_includesCount];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &internal->_includesUnit];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &internal->_zeroPadsFractionDigits];
    }
}

@end
