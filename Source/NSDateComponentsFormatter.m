/**Implementation of class NSDateComponentsFormatter
   Copyright (C) 2019 Free Software Foundation, Inc.
   
   Author: Gregory Casamento <greg.casamento@gmail.com>
   Date: Wed Nov  6 00:24:02 EST 2019

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

#import "Foundation/NSArchiver.h"
#import "Foundation/NSKeyedArchiver.h"
#import "Foundation/NSDateComponentsFormatter.h"
#import "Foundation/NSDate.h"
#import "Foundation/NSString.h"
#import "Foundation/NSValue.h"
#import "Foundation/NSException.h"
#import "Foundation/NSNumberFormatter.h"
#import "Foundation/NSCalendar.h"

@implementation NSDateComponentsFormatter

- (instancetype) init
{
  self = [super init];
  if (self != nil)
    {
      _calendar = nil;
      _referenceDate = nil;
      _allowsFractionalUnits = NO;
      _collapsesLargestUnit = NO;
      _includesApproximationPhrase = NO;
      _formattingContext = NSFormattingContextUnknown;
      _maximumUnitCount = 0;
      _zeroFormattingBehavior
	= NSDateComponentsFormatterZeroFormattingBehaviorDefault;
      _allowedUnits = NSCalendarUnitYear
	| NSCalendarUnitMonth
	| NSCalendarUnitDay
	| NSCalendarUnitHour
	| NSCalendarUnitMinute
	| NSCalendarUnitSecond;
      _unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    }
  return self;
}

- (instancetype) initWithCoder: (NSCoder *)coder
{
  self = [super initWithCoder: coder];
  if (self != nil)
    {
      if ([coder allowsKeyedCoding])
        {
          ASSIGN(_calendar, [coder decodeObjectForKey: @"NS.calendar"]);
          ASSIGN(_referenceDate, [coder decodeObjectForKey: @"NS.referenceDate"]);
          _allowsFractionalUnits = [coder decodeBoolForKey: @"NS.allowsFractionalUnits"];
          _collapsesLargestUnit = [coder decodeBoolForKey: @"NS.collapsesLargestUnit"];
          _includesApproximationPhrase = [coder decodeBoolForKey: @"NS.includesApproximationPhrase"];
          _formattingContext = [coder decodeIntegerForKey: @"NS.formattingContext"];
          _maximumUnitCount = [coder decodeIntegerForKey: @"NS.maximumUnitCount"];
          _zeroFormattingBehavior = [coder decodeIntegerForKey: @"NS.zeroFormattingBehavior"];
          _allowedUnits = [coder decodeIntegerForKey: @"NS.allowedUnits"];
          _unitsStyle = [coder decodeIntegerForKey: @"NS.unitsStyle"];
        }
      else
        {
          [coder decodeValueOfObjCType: @encode(id) at: &_calendar];
          [coder decodeValueOfObjCType: @encode(id) at: &_referenceDate];
          [coder decodeValueOfObjCType: @encode(BOOL) at: &_allowsFractionalUnits];
          [coder decodeValueOfObjCType: @encode(BOOL) at: &_collapsesLargestUnit];
          [coder decodeValueOfObjCType: @encode(BOOL) at: &_includesApproximationPhrase];
          [coder decodeValueOfObjCType: @encode(NSFormattingContext) at: &_formattingContext];
          [coder decodeValueOfObjCType: @encode(NSInteger) at: &_maximumUnitCount];
          [coder decodeValueOfObjCType: @encode(NSDateComponentsFormatterZeroFormattingBehavior) at: &_zeroFormattingBehavior];
          [coder decodeValueOfObjCType: @encode(NSCalendarUnit) at: &_allowedUnits];
          [coder decodeValueOfObjCType: @encode(NSDateComponentsFormatterUnitsStyle) at: &_unitsStyle];
        }
    }
  return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
  [super encodeWithCoder: coder];
  if ([coder allowsKeyedCoding])
    {
      [coder encodeObject: _calendar forKey: @"NS.calendar"];
      [coder encodeObject: _referenceDate forKey: @"NS.referenceDate"];
      [coder encodeBool: _allowsFractionalUnits forKey: @"NS.allowsFractionalUnits"];
      [coder encodeBool: _collapsesLargestUnit forKey: @"NS.collapsesLargestUnit"];
      [coder encodeBool: _includesApproximationPhrase forKey: @"NS.includesApproximationPhrase"];
      [coder encodeInteger: _formattingContext forKey: @"NS.formattingContext"];
      [coder encodeInteger: _maximumUnitCount forKey: @"NS.maximumUnitCount"];
      [coder encodeInteger: _zeroFormattingBehavior forKey: @"NS.zeroFormattingBehavior"];
      [coder encodeInteger: _allowedUnits forKey: @"NS.allowedUnits"];
      [coder encodeInteger: _unitsStyle forKey: @"NS.unitsStyle"];
    }
  else
    {
      [coder encodeValueOfObjCType: @encode(id) at: &_calendar];
      [coder encodeValueOfObjCType: @encode(id) at: &_referenceDate];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &_allowsFractionalUnits];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &_collapsesLargestUnit];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &_includesApproximationPhrase];
      [coder encodeValueOfObjCType: @encode(NSFormattingContext) at: &_formattingContext];
      [coder encodeValueOfObjCType: @encode(NSInteger) at: &_maximumUnitCount];
      [coder encodeValueOfObjCType: @encode(NSDateComponentsFormatterZeroFormattingBehavior) at: &_zeroFormattingBehavior];
      [coder encodeValueOfObjCType: @encode(NSCalendarUnit) at: &_allowedUnits];
      [coder encodeValueOfObjCType: @encode(NSDateComponentsFormatterUnitsStyle) at: &_unitsStyle];
    }
}

- (void) dealloc
{
  RELEASE(_calendar);
  RELEASE(_referenceDate);
  [super dealloc];
}

- (NSString *) stringForObjectValue: (id)obj
{
  NSString *result = nil;
  
  if (obj == nil)
    {
      result = @"";
    }
  else if ([obj isKindOfClass: [NSDateComponents class]])
    {
      result = [self stringFromDateComponents: obj];
    }
  else if ([obj isKindOfClass: [NSNumber class]])
    {
      NSTimeInterval ti = [obj longLongValue];
      result = [self stringFromTimeInterval: ti];
    }
  else
    {
      result = @"";
    }
    
  return result;
}

/* The units the formatter can show, largest first, with their labels
 * for the abbreviated, short, full (singular and plural) and brief
 * styles.  The spelled-out style uses the full labels.
 */
static struct {
  NSCalendarUnit	unit;
  NSString		*abbreviated;
  NSString		*shortName;
  NSString		*singular;
  NSString		*plural;
  NSString		*brief;
} unitTable[] = {
  { NSCalendarUnitYear, @"y", @"yr", @"year", @"years", @"yr" },
  { NSCalendarUnitMonth, @"mo", @"mth", @"month", @"months", @"mth" },
  { NSCalendarUnitWeekOfMonth, @"w", @"wk", @"week", @"weeks", @"wk" },
  { NSCalendarUnitDay, @"d", @"day", @"day", @"days", @"day" },
  { NSCalendarUnitHour, @"h", @"hr", @"hour", @"hours", @"hr" },
  { NSCalendarUnitMinute, @"m", @"min", @"minute", @"minutes", @"min" },
  { NSCalendarUnitSecond, @"s", @"sec", @"second", @"seconds", @"sec" },
};
#define	UNIT_COUNT	(sizeof(unitTable) / sizeof(unitTable[0]))

static NSInteger
componentValue(NSDateComponents *components, NSCalendarUnit unit)
{
  switch (unit)
    {
      case NSCalendarUnitYear: return [components year];
      case NSCalendarUnitMonth: return [components month];
      case NSCalendarUnitWeekOfMonth: return [components weekOfMonth];
      case NSCalendarUnitDay: return [components day];
      case NSCalendarUnitHour: return [components hour];
      case NSCalendarUnitMinute: return [components minute];
      case NSCalendarUnitSecond: return [components second];
      default: return NSDateComponentUndefined;
    }
}

- (NSString *) stringFromDateComponents: (NSDateComponents *)components
{
  NSUInteger		index[UNIT_COUNT];
  NSInteger		value[UNIT_COUNT];
  BOOL			keep[UNIT_COUNT];
  NSUInteger		count = 0;
  NSUInteger		i;
  NSInteger		first = -1;
  NSInteger		last = -1;
  NSUInteger		kept;
  NSUInteger		behavior = _zeroFormattingBehavior;
  BOOL			positional;
  NSMutableString	*result;
  NSNumberFormatter	*speller = nil;

  if (nil == components)
    {
      return nil;
    }
  positional = (_unitsStyle == NSDateComponentsFormatterUnitsStylePositional);
  if (behavior & NSDateComponentsFormatterZeroFormattingBehaviorDefault)
    {
      /* Positional fields drop leading zeros only; the other styles
       * drop every zero unit.
       */
      behavior |= positional
	? NSDateComponentsFormatterZeroFormattingBehaviorDropLeading
	: NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    }

  /* The allowed units that the components define, largest first.
   */
  for (i = 0; i < UNIT_COUNT; i++)
    {
      NSInteger	v;

      if ((_allowedUnits & unitTable[i].unit) == 0)
	{
	  continue;
	}
      v = componentValue(components, unitTable[i].unit);
      if (NSDateComponentUndefined == v)
	{
	  continue;
	}
      index[count] = i;
      value[count] = v;
      if (v != 0)
	{
	  if (first < 0)
	    {
	      first = count;
	    }
	  last = count;
	}
      count++;
    }
  if (0 == count)
    {
      return @"";
    }

  /* Drop zero units as the zero formatting behavior asks, but keep the
   * smallest unit when every unit is zero.
   */
  for (i = 0; i < count; i++)
    {
      keep[i] = YES;
      if (value[i] != 0)
	{
	  continue;
	}
      if (first < 0)
	{
	  if (i + 1 < count && (behavior
	    & NSDateComponentsFormatterZeroFormattingBehaviorDropAll))
	    {
	      keep[i] = NO;
	    }
	}
      else if ((NSInteger)i < first)
	{
	  keep[i] = (behavior
	    & NSDateComponentsFormatterZeroFormattingBehaviorDropLeading) == 0;
	}
      else if ((NSInteger)i > last)
	{
	  keep[i] = (behavior
	    & NSDateComponentsFormatterZeroFormattingBehaviorDropTrailing) == 0;
	}
      else
	{
	  keep[i] = (behavior
	    & NSDateComponentsFormatterZeroFormattingBehaviorDropMiddle) == 0;
	}
    }

  if (_unitsStyle == NSDateComponentsFormatterUnitsStyleSpellOut)
    {
      speller = AUTORELEASE([NSNumberFormatter new]);
      [speller setNumberStyle: NSNumberFormatterSpellOutStyle];
    }
  result = [NSMutableString string];
  kept = 0;
  for (i = 0; i < count; i++)
    {
      NSUInteger	u = index[i];
      NSInteger		v = value[i];

      if (keep[i] == NO)
	{
	  continue;
	}
      if (_maximumUnitCount > 0 && kept == (NSUInteger)_maximumUnitCount)
	{
	  break;
	}
      if (positional)
	{
	  if (0 == kept && (behavior
	    & NSDateComponentsFormatterZeroFormattingBehaviorPad) == 0)
	    {
	      [result appendFormat: @"%ld", (long)v];
	    }
	  else
	    {
	      [result appendFormat: (0 == kept) ? @"%02ld" : @":%02ld",
		(long)v];
	    }
	}
      else
	{
	  NSString	*plural;

	  plural = (v == 1 || v == -1)
	    ? unitTable[u].singular : unitTable[u].plural;
	  switch (_unitsStyle)
	    {
	      case NSDateComponentsFormatterUnitsStyleAbbreviated:
		[result appendFormat: @"%@%ld%@", (kept ? @" " : @""),
		  (long)v, unitTable[u].abbreviated];
		break;
	      case NSDateComponentsFormatterUnitsStyleBrief:
		[result appendFormat: @"%@%ld%@", (kept ? @" " : @""),
		  (long)v, unitTable[u].brief];
		break;
	      case NSDateComponentsFormatterUnitsStyleShort:
		[result appendFormat: @"%@%ld %@", (kept ? @", " : @""),
		  (long)v, unitTable[u].shortName];
		break;
	      case NSDateComponentsFormatterUnitsStyleSpellOut:
		[result appendFormat: @"%@%@ %@", (kept ? @", " : @""),
		  [speller stringFromNumber: [NSNumber numberWithInteger: v]],
		  plural];
		break;
	      default:
		[result appendFormat: @"%@%ld %@", (kept ? @", " : @""),
		  (long)v, plural];
		break;
	    }
	}
      kept++;
    }
  return result;
}

- (NSString *) stringFromDate: (NSDate *)startDate
                       toDate: (NSDate *)endDate
{
  NSDateComponents	*dc;
  NSCalendar		*calendar;

  calendar = ( _calendar != nil ) ? _calendar : [NSCalendar currentCalendar];
  dc = [calendar components: _allowedUnits
                   fromDate: startDate
                     toDate: endDate
                    options: NSCalendarMatchStrictly];
  return [self stringFromDateComponents: dc];
}

- (NSString *) stringFromTimeInterval: (NSTimeInterval)ti
{
  NSDate *startDate = [NSDate date];
  NSDate *endDate = [startDate dateByAddingTimeInterval: (ti > 0) ? ti : -ti];
  return [self stringFromDate: startDate toDate: endDate];
}

- (NSDateComponentsFormatterUnitsStyle) unitsStyle
{
  return _unitsStyle;
}

- (void) setUnitsStyle: (NSDateComponentsFormatterUnitsStyle)style
{
  _unitsStyle = style;
}
  
- (NSCalendarUnit) allowedUnits
{
  return _allowedUnits;
}

- (void) setAllowedUnits: (NSCalendarUnit)units
{
  if (units & NSCalendarUnitYear
    && units & NSCalendarUnitMonth
    && units & NSCalendarUnitDay
    && units & NSCalendarUnitHour
    && units & NSCalendarUnitMinute
    && units & NSCalendarUnitSecond
    && units & NSCalendarUnitWeekOfMonth)
    {
      [NSException raise: NSInvalidArgumentException
                  format: @"Passed invalid unit into allowedUnits"];
    }
  _allowedUnits = units;
}

- (NSDateComponentsFormatterZeroFormattingBehavior) zeroFormattingBehavior
{
  return _zeroFormattingBehavior;
}

- (void) setZeroFormattingBehavior: (NSDateComponentsFormatterZeroFormattingBehavior)behavior
{
  _zeroFormattingBehavior = behavior;
}

- (NSCalendar *) calendar
{
  return _calendar;
}

- (void) setCalendar: (NSCalendar *)calendar
{
  ASSIGNCOPY(_calendar, calendar);
}

- (NSDate *) referenceDate
{
  return _referenceDate;
}

- (void) setReferenceDate: (NSDate *)referenceDate
{
  ASSIGNCOPY(_referenceDate, referenceDate);
}

- (BOOL) allowsFractionalUnits
{
  return _allowsFractionalUnits;
}

- (void) setAllowsFractionalUnits: (BOOL)allowsFractionalUnits
{
  _allowsFractionalUnits = allowsFractionalUnits;
}

- (NSInteger) maximumUnitCount
{
  return _maximumUnitCount;
}

- (void) setMaximumUnitCount: (NSInteger)maximumUnitCount
{
  _maximumUnitCount = maximumUnitCount;
}

- (BOOL) collapsesLargestUnit
{
  return _collapsesLargestUnit;
}

- (void) setCollapsesLargestUnit: (BOOL)collapsesLargestUnit
{
  _collapsesLargestUnit = collapsesLargestUnit;
}

- (BOOL) includesApproximationPhrase
{
  return _includesApproximationPhrase;
}

- (void) setIncludesApproximationPhrase: (BOOL)includesApproximationPhrase
{
  _includesApproximationPhrase = includesApproximationPhrase;
}

- (NSFormattingContext) formattingContext
{
  return _formattingContext;
}

- (void) setFormattingContext: (NSFormattingContext)formattingContext
{
  _formattingContext = formattingContext;
}

- (BOOL) getObjectValue: (id*)obj
	      forString: (NSString *)string
       errorDescription: (NSString **)error
{
  return NO;
}

+ (NSString *) localizedStringFromDateComponents: (NSDateComponents *)components
                                      unitsStyle: (NSDateComponentsFormatterUnitsStyle)unitsStyle
{
  NSDateComponentsFormatter *fmt = [[NSDateComponentsFormatter alloc] init];
  [fmt setUnitsStyle: unitsStyle];
  AUTORELEASE(fmt);
  return [fmt stringFromDateComponents: components];
}
  
@end

