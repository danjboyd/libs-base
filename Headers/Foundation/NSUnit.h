/** Definition of class NSUnit
   Copyright (C) 2019 Free Software Foundation, Inc.

   By: Gregory John Casamento <greg.casamento@gmail.com>
   Date: Mon Sep 30 15:58:21 EDT 2019

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

#ifndef _NSUnit_h_GNUSTEP_BASE_INCLUDE
#define _NSUnit_h_GNUSTEP_BASE_INCLUDE

#import <Foundation/NSObject.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_12, GS_API_LATEST)

#if	defined(__cplusplus)
extern "C" {
#endif

/* GCC has no class properties until recent versions, and can't use them even
 * then.  Either way the units are class methods with these names.
 */
#if defined(__clang__)
#define GS_UNIT_CLASS_PROPERTY(TYPE, NAME) \
  @property (class, readonly, copy) TYPE *NAME
#else
#define GS_UNIT_CLASS_PROPERTY(TYPE, NAME) + (TYPE *) NAME
#endif

/**
 * Unit converter.  This is an abstract class.
 */
GS_EXPORT_CLASS
@interface NSUnitConverter : NSObject
/** For a given unit, returns the specified value of that unit based
 * on the units dimension.
 */
- (double) baseUnitValueFromValue: (double)value;

/** For a unit, returns the specified value of the base unit in terms
 * of that unit.
 */
- (double) valueFromBaseUnitValue: (double)baseUnitValue;
@end

/**
 * Linear converter... for things like C to F conversion...
 */
GS_EXPORT_CLASS
@interface NSUnitConverterLinear : NSUnitConverter <NSCoding>
{
  double _coefficient;
  double _constant;
}

/**
 * Initialize with the coefficient.
 */
- (instancetype) initWithCoefficient: (double)coefficient;

/**
 * Initialize with the coefficient and constant.
 */
- (instancetype) initWithCoefficient: (double)coefficient
			    constant: (double)constant;

/**
 * Return the coefficient.
 */
- (double) coefficient;

/**
 * Return the constant.
 */
- (double) constant;
@end

/**
 * Units...  abstract...
 */
GS_EXPORT_CLASS
@interface NSUnit : NSObject <NSCopying, NSCoding>
{
  NSString *_symbol;
}
/**
 * Initialize an NSUnit instance.
 */
- (instancetype) init;

/**
 * Initialize NSUnit with a given symbol.
 */
- (instancetype) initWithSymbol: (NSString*)symbol;

/**
 * The symbol used by a given unit.
 */
- (NSString*) symbol;

@end

/**
 * Dimension using units....
 */
GS_EXPORT_CLASS
@interface NSDimension : NSUnit <NSCoding>
{
  double 		_value;
  NSUnitConverter	*_converter;
}

/**
 * The NSUnitConverter instance used for this NSDimension object.
 */
- (NSUnitConverter*) converter;

/**
 * Initialize with symbol and an NSUnitConverter.
 */
- (instancetype) initWithSymbol: (NSString*)symbol
		      converter: (NSUnitConverter*)converter;

/**
 * Return a base unit.
 */
+ (instancetype) baseUnit;

@end

// Predefined....
/**
 * Units of accelleration.  Base unit - metersPerSecondSquared
 */
GS_EXPORT_CLASS
@interface NSUnitAcceleration : NSDimension

/**
 * Units of accelleration in meters per second squared.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAcceleration, metersPerSecondSquared);

/**
 * Units of accelleration equal to the gravitational constant.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAcceleration, gravity);

@end

/**
 * Angle units.  Base unit - degrees
 */
GS_EXPORT_CLASS
@interface NSUnitAngle : NSDimension

/**
 * Units of angle in degrees.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAngle, degrees);

/**
 * Units of angle in arc minutes.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAngle, arcMinutes);

/**
 * Units of angle arc seconds.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAngle, arcSeconds);

/**
 * Units of angle in radians.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAngle, radians);

/**
 * Units of area in square megameters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAngle, gradians);

/**
 * Units of area in square megameters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitAngle, revolutions);

@end

/**
 * Units of area.  Base unit - squareMeters
 */
GS_EXPORT_CLASS
@interface NSUnitArea : NSDimension

/**
 * Units of area in square megameters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareMegameters);

/**
 * Units of area in square kilometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareKilometers);

/**
 * Units of area in square meters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareMeters);

/**
 * Units of area in square centimeters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareCentimeters);

/**
 * Units of area in square millimeters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareMillimeters);

/**
 * Units of area in square micrometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareMicrometers);

/**
 * Units of area in square nanometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareNanometers);

/**
 * Units of area in square inches.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareInches);

/**
 * Units of area in square feet.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareFeet);

/**
 * Units of area in square yards.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareYards);

/**
 * Units of area in square miles.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, squareMiles);

/**
 * Units of area in acres/
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, acres);

/**
 * Units of area in ares.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, ares);

/**
 * Units of area in hectares.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitArea, hectares);

@end

/**
 * Units of concentration.  Base unit - gramsPerLiter.
 */
GS_EXPORT_CLASS
@interface NSUnitConcentrationMass : NSDimension

/**
 * Concentration units in grams per liter.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitConcentrationMass, gramsPerLiter);

/**
 * Concentration units in milligrams per deciliter.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitConcentrationMass, milligramsPerDeciliter);

/**
 * Concentration units in grams per mole.
 */
+ (NSUnitConcentrationMass*) millimolesPerLiterWithGramsPerMole:
  (double)gramsPerMole;

@end

/**
 * Units of dispersion.  Base unit - partsPerMillion
 */
GS_EXPORT_CLASS
@interface NSUnitDispersion : NSDimension

/**
 * Units of dispersion in parts per million.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitDispersion, partsPerMillion);

@end

/**
 * Units of duration.  Base unit - seconds
 */
GS_EXPORT_CLASS
@interface NSUnitDuration : NSDimension

/**
 * Units of duration in seconds.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitDuration, seconds);

/**
 * Units of duration in minutes.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitDuration, minutes);

/**
 * Units of duration in hours.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitDuration, hours);

@end

/**
 * Units of electric charge.  Base unit - coulombs
 */
GS_EXPORT_CLASS
@interface NSUnitElectricCharge : NSDimension

/**
 * The units of eletric charge in coulombs.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCharge, coulombs);

/**
 * The units of eletric charge in megaampere hours.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCharge, megaampereHours);

/**
 * The units of eletric charge in kiloampere hours.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCharge, kiloampereHours);

/**
 * The units of eletric charge in ampere hours.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCharge, ampereHours);

/**
 * The units of eletric charge in milliampere hours.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCharge, milliampereHours);

/**
 * The units of eletric charge in microampere hours.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCharge, microampereHours);

@end

/**
 * Units of electric current.  Base unit - amperes
 */
GS_EXPORT_CLASS
@interface NSUnitElectricCurrent : NSDimension

/**
 * The units of eletric current in megaamperes.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCurrent, megaamperes);

/**
 * The units of eletric current in kiloamperes.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCurrent, kiloamperes);

/**
 * The units of eletric current in amperes.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCurrent, amperes);

/**
 * The units of eletric current in milliamperes.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCurrent, milliamperes);

/**
 * The units of eletric current in microamperes.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricCurrent, microamperes);

@end

/**
 * Units of electric potential.  Base unit - volts
 */
GS_EXPORT_CLASS
@interface NSUnitElectricPotentialDifference : NSDimension

/**
 * The units of eletric potential in megavolts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricPotentialDifference, megavolts);

/**
 * The units of eletric potential in kilovolts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricPotentialDifference, kilovolts);

/**
 * The units of eletric potential in volts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricPotentialDifference, volts);

/**
 * The units of eletric potential in millivolts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricPotentialDifference, millivolts);

/**
 * The units of eletric potential in microvolts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricPotentialDifference, microvolts);

@end

/**
 * Units of electric resistance. Base unit - ohms
 */
GS_EXPORT_CLASS
@interface NSUnitElectricResistance : NSDimension

/**
 * The units of eletric resistance in megaohms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricResistance, megaohms);

/**
 * The units of eletric resistance in kiloohms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricResistance, kiloohms);

/**
 * The units of eletric resistance in ohms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricResistance, ohms);

/**
 * The units of eletric resistance in milliohms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricResistance, milliohms);

/**
 * The units of eletric resistance in microohms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitElectricResistance, microohms);

@end

/**
 * Units of Energy.  Base unit - joules
 */
GS_EXPORT_CLASS
@interface NSUnitEnergy : NSDimension

/**
 * The units of energy in kilojoules.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitEnergy, kilojoules);

/**
 * The units of energy in joules.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitEnergy, joules);

/**
 * The units of energy in kilocalories.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitEnergy, kilocalories);

/**
 * The units of energy in calories.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitEnergy, calories);

/**
 * The units of energy in kilawatt hours.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitEnergy, kilowattHours);

@end

/**
 * Units of frequency.  Base unit - hertz
 */
GS_EXPORT_CLASS
@interface NSUnitFrequency : NSDimension

/**
 * The units of frequency in terahertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, terahertz);

/**
 * The units of frequency in gigahertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, gigahertz);

/**
 * The units of frequency in megahertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, megahertz);

/**
 * The units of frequency in kilohertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, kilohertz);

/**
 * The units of frequency in hertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, hertz);

/**
 * The units of frequency in millihertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, millihertz);

/**
 * The units of frequency in microhertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, microhertz);

/**
 * The units of frequency in nanohertz.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFrequency, nanohertz);

@end

/**
 * Units of fuel efficiency.  Base unit - litersPer100Kilometers
 */
GS_EXPORT_CLASS
@interface NSUnitFuelEfficiency : NSDimension

/**
 * The units of fuel efficiency in liters per 100 kilometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFuelEfficiency, litersPer100Kilometers);

/**
 * The units of fuel efficiency in miles per imperial gallon.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFuelEfficiency, milesPerImperialGallon);

/**
 * The units of fuel efficiency in miles per gallon.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitFuelEfficiency, milesPerGallon);

@end

/**
 * Units of length. Base unit - meters
 */
GS_EXPORT_CLASS
@interface NSUnitLength : NSDimension

/**
 * The units of length in megameters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, megameters);

/**
 * The units of length in kilometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, kilometers);

/**
 * The units of length in hectometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, hectometers);

/**
 * The units of length in decameters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, decameters);

/**
 * The units of length in meters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, meters);

/**
 * The units of length in decimeters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, decimeters);

/**
 * The units of length in centimeters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, centimeters);

/**
 * The units of length in millimeters.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, millimeters);

/**
 * The units of length in micrometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, micrometers);

/**
 * The units of length in nanometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, nanometers);

/**
 * The units of length in picometers.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, picometers);

/**
 * The units of length in inches.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, inches);

/**
 * The units of length in feet.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, feet);

/**
 * The units of length in yards.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, yards);

/**
 * The units of length in miles.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, miles);

/**
 * The units of length in scandanavian miles.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, scandinavianMiles);

/**
 * The units of length in light years.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, lightyears);

/**
 * The units of length in nautical miles.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, nauticalMiles);

/**
 * The units of length in fathoms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, fathoms);

/**
 * The units of length in furlongs.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, furlongs);

/**
 * The units of length in astronomical units.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, astronomicalUnits);

/**
 * The units of length in parsecs.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitLength, parsecs);

@end

/**
 * Units of illumination.  Base unit - lux
 */
GS_EXPORT_CLASS
@interface NSUnitIlluminance : NSDimension

/**
 * The units of illuminance in lux.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitIlluminance, lux);

@end

/**
 * Units of mass. Base unit - kilograms
 */
GS_EXPORT_CLASS
@interface NSUnitMass : NSDimension

/**
 * The mass units in kilograms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, kilograms);

/**
 * The mass units in grams.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, grams);

/**
 * The mass units in decigrams.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, decigrams);

/**
 * The mass units in centigrams.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, centigrams);

/**
 * The mass units in milligrams.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, milligrams);

/**
 * The mass units in micrograms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, micrograms);

/**
 * The mass units in nanograms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, nanograms);

/**
 * The mass units in picograms.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, picograms);

/**
 * The mass units in ounces.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, ounces);

/**
 * The mass units in pounds (same as poundsMass).
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, pounds);

/**
 * The mass units in pounds.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, poundsMass);

/**
 * The mass units in stones.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, stones);

/**
 * The mass units in metric tons.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, metricTons);

/**
 * The mass units in short tons.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, shortTons);

/**
 * The mass units in carats.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, carats);

/**
 * The mass units in ounces troy.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, ouncesTroy);

/**
 * The mass units in slugs.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitMass, slugs);

@end

/**
 * Used to represent power.  Base unit - watts
 */
GS_EXPORT_CLASS
@interface NSUnitPower : NSDimension

/**
 * The power units in terawatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, terawatts);

/**
 * The power units in gigawatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, gigawatts);

/**
 * The power units in megawatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, megawatts);

/**
 * The power units in kilowatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, kilowatts);

/**
 * The power units in watts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, watts);

/**
 * The power units in milliwatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, milliwatts);

/**
 * The power units in microwatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, microwatts);

/**
 * The power units in nanowatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, nanowatts);

/**
 * The power units in picowatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, picowatts);

/**
 * The power units in femtowatts.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, femtowatts);

/**
 * The power units in horsepower.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPower, horsepower);

@end

/** Used to represent pressure. Base unit - newtonsPerMetersSquared
 * (equivalent to 1 pascal)
 */
GS_EXPORT_CLASS
@interface NSUnitPressure : NSDimension

/**
 * The newtons per meters squared unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, newtonsPerMetersSquared);

/**
 * The gigapascals unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, gigapascals);

/**
 * The megapascals unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, megapascals);

/**
 * The kilopascals unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, kilopascals);

/**
 * The hetcopascals unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, hectopascals);

/**
 * The inches of mercury unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, inchesOfMercury);

/**
 * The bars unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, bars);

/**
 * The millibars unit of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, millibars);

/**
 * The millimeters of mercury of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, millimetersOfMercury);

/**
 * The pounds of per square inch of pressure.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitPressure, poundsForcePerSquareInch);

@end

/**
 * Used to represent speed. Base unit is meters per second.
 */
GS_EXPORT_CLASS
@interface NSUnitSpeed : NSDimension

/**
 * The meters per second measurement of speed.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitSpeed, metersPerSecond);

/**
 * The kilometers per hour measurement of speed.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitSpeed, kilometersPerHour);

/**
 * The miles per hour measurement of speed.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitSpeed, milesPerHour);

/**
 * The knots measurement of speed.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitSpeed, knots);

@end

/**
 * Used to represent temperature quantities.
 * The base unit of this class is kelvin.
 */
GS_EXPORT_CLASS
@interface NSUnitTemperature : NSDimension

/**
 * The kelvin unit of temperature.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitTemperature, kelvin);

/**
 * The kelvin unit of celsius.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitTemperature, celsius);

/**
 * The kelvin unit of fahenheit.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitTemperature, fahrenheit);

@end

/**
 * Typically this is used to represent specific quantities.
 * The base unit of this class is liters.
 */
GS_EXPORT_CLASS
@interface NSUnitVolume : NSDimension

/**
 * The megaliters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, megaliters);

/**
 * The kiloliters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, kiloliters);

/**
 * The liters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, liters);

/**
 * The deciliters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, deciliters);

/**
 * The centiliters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, centiliters);

/**
 * The milliliters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, milliliters);

/**
 * The cubic kilometers unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicKilometers);

/**
 * The cubic meters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicMeters);

/**
 * The cubic decimeters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicDecimeters);

/**
 * The cubic centimeteres unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicCentimeters);

/**
 * The cubic millimeters unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicMillimeters);

/**
 * The cubic inches unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicInches);

/**
 * The cubic feet unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicFeet);

/**
 * The cubic yards unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicYards);

/**
 * The cubic miles unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cubicMiles);

/**
 * The acre feet unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, acreFeet);

/**
 * The bushels unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, bushels);

/**
 * The teaspoons unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, teaspoons);

/**
 * The tablespoons unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, tablespoons);

/**
 * The fluid ounces unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, fluidOunces);

/**
 * The cups unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, cups);

/**
 * The pints unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, pints);

/**
 * The quarts unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, quarts);

/**
 * The gallons unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, gallons);

/**
 * The imperial teaspoons unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, imperialTeaspoons);

/**
 * The imperial tablespoons unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, imperialTablespoons);

/**
 * The imperial fluid ounces unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, imperialFluidOunces);

/**
 * The imperial pints unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, imperialPints);

/**
 * The imperial quarts unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, imperialQuarts);

/**
 * The imperial gallons unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, imperialGallons);

/**
 * The metric cups unit of volume.
 */
GS_UNIT_CLASS_PROPERTY(NSUnitVolume, metricCups);

@end

#if	defined(__cplusplus)
}
#endif

#endif	/* GS_API_MACOSX */

#endif	/* _NSUnit_h_GNUSTEP_BASE_INCLUDE */
