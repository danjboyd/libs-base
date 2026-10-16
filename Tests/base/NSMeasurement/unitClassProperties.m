/* The predefined units are class properties, as in Cocoa, so Swift can
   import them as static properties (UnitLength.kilometers).  They were
   class methods.  The class methods remain their getters, so message
   syntax and property syntax answer the same units, and the runtime
   describes each unit as a class property. */
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Testing.h"

int
main(int argc, char *argv[])
{
  ENTER_POOL
  NSUnitLength		*kilometers;
  NSUnitTemperature	*celsius;
  NSMeasurement		*distance;

  START_SET("NSUnit class properties")

  kilometers = NSUnitLength.kilometers;
  PASS([kilometers isKindOfClass: [NSUnitLength class]],
    "NSUnitLength.kilometers is a length unit")
  PASS_EQUAL([kilometers symbol], [[NSUnitLength kilometers] symbol],
    "NSUnitLength.kilometers is the unit +[NSUnitLength kilometers] answers")

  celsius = NSUnitTemperature.celsius;
  PASS_EQUAL([celsius symbol], [[NSUnitTemperature celsius] symbol],
    "NSUnitTemperature.celsius is the unit +[NSUnitTemperature celsius] answers")

  distance = AUTORELEASE([[NSMeasurement alloc]
    initWithDoubleValue: 1.5 unit: NSUnitLength.kilometers]);
  PASS(fabs([[distance measurementByConvertingToUnit: NSUnitLength.meters]
    doubleValue] - 1500.0) < 1e-9,
    "a measurement converts between units named by property syntax")

  PASS(class_getProperty(object_getClass([NSUnitLength class]),
    "kilometers") != NULL,
    "kilometers is a class property of NSUnitLength")
  PASS(class_getProperty([NSUnitLength class], "kilometers") == NULL,
    "kilometers is not an instance property of NSUnitLength")

  END_SET("NSUnit class properties")

  LEAVE_POOL
  return 0;
}
