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
@property (class, readonly, copy) NSUnitAcceleration *metersPerSecondSquared;

/**
 * Units of accelleration equal to the gravitational constant.
 */
@property (class, readonly, copy) NSUnitAcceleration *gravity;

@end

/**
 * Angle units.  Base unit - degrees
 */
GS_EXPORT_CLASS
@interface NSUnitAngle : NSDimension

/**
 * Units of angle in degrees.
 */
@property (class, readonly, copy) NSUnitAngle *degrees;

/**
 * Units of angle in arc minutes.
 */
@property (class, readonly, copy) NSUnitAngle *arcMinutes;

/**
 * Units of angle arc seconds.
 */
@property (class, readonly, copy) NSUnitAngle *arcSeconds;

/**
 * Units of angle in radians.
 */
@property (class, readonly, copy) NSUnitAngle *radians;

/**
 * Units of area in square megameters.
 */
@property (class, readonly, copy) NSUnitAngle *gradians;

/**
 * Units of area in square megameters.
 */
@property (class, readonly, copy) NSUnitAngle *revolutions;

@end

/**
 * Units of area.  Base unit - squareMeters
 */
GS_EXPORT_CLASS
@interface NSUnitArea : NSDimension

/**
 * Units of area in square megameters.
 */
@property (class, readonly, copy) NSUnitArea *squareMegameters;

/**
 * Units of area in square kilometers.
 */
@property (class, readonly, copy) NSUnitArea *squareKilometers;

/**
 * Units of area in square meters.
 */
@property (class, readonly, copy) NSUnitArea *squareMeters;

/**
 * Units of area in square centimeters.
 */
@property (class, readonly, copy) NSUnitArea *squareCentimeters;

/**
 * Units of area in square millimeters.
 */
@property (class, readonly, copy) NSUnitArea *squareMillimeters;

/**
 * Units of area in square micrometers.
 */
@property (class, readonly, copy) NSUnitArea *squareMicrometers;

/**
 * Units of area in square nanometers.
 */
@property (class, readonly, copy) NSUnitArea *squareNanometers;

/**
 * Units of area in square inches.
 */
@property (class, readonly, copy) NSUnitArea *squareInches;

/**
 * Units of area in square feet.
 */
@property (class, readonly, copy) NSUnitArea *squareFeet;

/**
 * Units of area in square yards.
 */
@property (class, readonly, copy) NSUnitArea *squareYards;

/**
 * Units of area in square miles.
 */
@property (class, readonly, copy) NSUnitArea *squareMiles;

/**
 * Units of area in acres/
 */
@property (class, readonly, copy) NSUnitArea *acres;

/**
 * Units of area in ares.
 */
@property (class, readonly, copy) NSUnitArea *ares;

/**
 * Units of area in hectares.
 */
@property (class, readonly, copy) NSUnitArea *hectares;

@end

/**
 * Units of concentration.  Base unit - gramsPerLiter.
 */
GS_EXPORT_CLASS
@interface NSUnitConcentrationMass : NSDimension

/**
 * Concentration units in grams per liter.
 */
@property (class, readonly, copy) NSUnitConcentrationMass *gramsPerLiter;

/**
 * Concentration units in milligrams per deciliter.
 */
@property (class, readonly, copy) NSUnitConcentrationMass *milligramsPerDeciliter;

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
@property (class, readonly, copy) NSUnitDispersion *partsPerMillion;

@end

/**
 * Units of duration.  Base unit - seconds
 */
GS_EXPORT_CLASS
@interface NSUnitDuration : NSDimension

/**
 * Units of duration in seconds.
 */
@property (class, readonly, copy) NSUnitDuration *seconds;

/**
 * Units of duration in minutes.
 */
@property (class, readonly, copy) NSUnitDuration *minutes;

/**
 * Units of duration in hours.
 */
@property (class, readonly, copy) NSUnitDuration *hours;

@end

/**
 * Units of electric charge.  Base unit - coulombs
 */
GS_EXPORT_CLASS
@interface NSUnitElectricCharge : NSDimension

/**
 * The units of eletric charge in coulombs.
 */
@property (class, readonly, copy) NSUnitElectricCharge *coulombs;

/**
 * The units of eletric charge in megaampere hours.
 */
@property (class, readonly, copy) NSUnitElectricCharge *megaampereHours;

/**
 * The units of eletric charge in kiloampere hours.
 */
@property (class, readonly, copy) NSUnitElectricCharge *kiloampereHours;

/**
 * The units of eletric charge in ampere hours.
 */
@property (class, readonly, copy) NSUnitElectricCharge *ampereHours;

/**
 * The units of eletric charge in milliampere hours.
 */
@property (class, readonly, copy) NSUnitElectricCharge *milliampereHours;

/**
 * The units of eletric charge in microampere hours.
 */
@property (class, readonly, copy) NSUnitElectricCharge *microampereHours;

@end

/**
 * Units of electric current.  Base unit - amperes
 */
GS_EXPORT_CLASS
@interface NSUnitElectricCurrent : NSDimension

/**
 * The units of eletric current in megaamperes.
 */
@property (class, readonly, copy) NSUnitElectricCurrent *megaamperes;

/**
 * The units of eletric current in kiloamperes.
 */
@property (class, readonly, copy) NSUnitElectricCurrent *kiloamperes;

/**
 * The units of eletric current in amperes.
 */
@property (class, readonly, copy) NSUnitElectricCurrent *amperes;

/**
 * The units of eletric current in milliamperes.
 */
@property (class, readonly, copy) NSUnitElectricCurrent *milliamperes;

/**
 * The units of eletric current in microamperes.
 */
@property (class, readonly, copy) NSUnitElectricCurrent *microamperes;

@end

/**
 * Units of electric potential.  Base unit - volts
 */
GS_EXPORT_CLASS
@interface NSUnitElectricPotentialDifference : NSDimension

/**
 * The units of eletric potential in megavolts.
 */
@property (class, readonly, copy) NSUnitElectricPotentialDifference *megavolts;

/**
 * The units of eletric potential in kilovolts.
 */
@property (class, readonly, copy) NSUnitElectricPotentialDifference *kilovolts;

/**
 * The units of eletric potential in volts.
 */
@property (class, readonly, copy) NSUnitElectricPotentialDifference *volts;

/**
 * The units of eletric potential in millivolts.
 */
@property (class, readonly, copy) NSUnitElectricPotentialDifference *millivolts;

/**
 * The units of eletric potential in microvolts.
 */
@property (class, readonly, copy) NSUnitElectricPotentialDifference *microvolts;

@end

/**
 * Units of electric resistance. Base unit - ohms
 */
GS_EXPORT_CLASS
@interface NSUnitElectricResistance : NSDimension

/**
 * The units of eletric resistance in megaohms.
 */
@property (class, readonly, copy) NSUnitElectricResistance *megaohms;

/**
 * The units of eletric resistance in kiloohms.
 */
@property (class, readonly, copy) NSUnitElectricResistance *kiloohms;

/**
 * The units of eletric resistance in ohms.
 */
@property (class, readonly, copy) NSUnitElectricResistance *ohms;

/**
 * The units of eletric resistance in milliohms.
 */
@property (class, readonly, copy) NSUnitElectricResistance *milliohms;

/**
 * The units of eletric resistance in microohms.
 */
@property (class, readonly, copy) NSUnitElectricResistance *microohms;

@end

/**
 * Units of Energy.  Base unit - joules
 */
GS_EXPORT_CLASS
@interface NSUnitEnergy : NSDimension

/**
 * The units of energy in kilojoules.
 */
@property (class, readonly, copy) NSUnitEnergy *kilojoules;

/**
 * The units of energy in joules.
 */
@property (class, readonly, copy) NSUnitEnergy *joules;

/**
 * The units of energy in kilocalories.
 */
@property (class, readonly, copy) NSUnitEnergy *kilocalories;

/**
 * The units of energy in calories.
 */
@property (class, readonly, copy) NSUnitEnergy *calories;

/**
 * The units of energy in kilawatt hours.
 */
@property (class, readonly, copy) NSUnitEnergy *kilowattHours;

@end

/**
 * Units of frequency.  Base unit - hertz
 */
GS_EXPORT_CLASS
@interface NSUnitFrequency : NSDimension

/**
 * The units of frequency in terahertz.
 */
@property (class, readonly, copy) NSUnitFrequency *terahertz;

/**
 * The units of frequency in gigahertz.
 */
@property (class, readonly, copy) NSUnitFrequency *gigahertz;

/**
 * The units of frequency in megahertz.
 */
@property (class, readonly, copy) NSUnitFrequency *megahertz;

/**
 * The units of frequency in kilohertz.
 */
@property (class, readonly, copy) NSUnitFrequency *kilohertz;

/**
 * The units of frequency in hertz.
 */
@property (class, readonly, copy) NSUnitFrequency *hertz;

/**
 * The units of frequency in millihertz.
 */
@property (class, readonly, copy) NSUnitFrequency *millihertz;

/**
 * The units of frequency in microhertz.
 */
@property (class, readonly, copy) NSUnitFrequency *microhertz;

/**
 * The units of frequency in nanohertz.
 */
@property (class, readonly, copy) NSUnitFrequency *nanohertz;

@end

/**
 * Units of fuel efficiency.  Base unit - litersPer100Kilometers
 */
GS_EXPORT_CLASS
@interface NSUnitFuelEfficiency : NSDimension

/**
 * The units of fuel efficiency in liters per 100 kilometers.
 */
@property (class, readonly, copy) NSUnitFuelEfficiency *litersPer100Kilometers;

/**
 * The units of fuel efficiency in miles per imperial gallon.
 */
@property (class, readonly, copy) NSUnitFuelEfficiency *milesPerImperialGallon;

/**
 * The units of fuel efficiency in miles per gallon.
 */
@property (class, readonly, copy) NSUnitFuelEfficiency *milesPerGallon;

@end

/**
 * Units of length. Base unit - meters
 */
GS_EXPORT_CLASS
@interface NSUnitLength : NSDimension

/**
 * The units of length in megameters.
 */
@property (class, readonly, copy) NSUnitLength *megameters;

/**
 * The units of length in kilometers.
 */
@property (class, readonly, copy) NSUnitLength *kilometers;

/**
 * The units of length in hectometers.
 */
@property (class, readonly, copy) NSUnitLength *hectometers;

/**
 * The units of length in decameters.
 */
@property (class, readonly, copy) NSUnitLength *decameters;

/**
 * The units of length in meters.
 */
@property (class, readonly, copy) NSUnitLength *meters;

/**
 * The units of length in decimeters.
 */
@property (class, readonly, copy) NSUnitLength *decimeters;

/**
 * The units of length in centimeters.
 */
@property (class, readonly, copy) NSUnitLength *centimeters;

/**
 * The units of length in millimeters.
 */
@property (class, readonly, copy) NSUnitLength *millimeters;

/**
 * The units of length in micrometers.
 */
@property (class, readonly, copy) NSUnitLength *micrometers;

/**
 * The units of length in nanometers.
 */
@property (class, readonly, copy) NSUnitLength *nanometers;

/**
 * The units of length in picometers.
 */
@property (class, readonly, copy) NSUnitLength *picometers;

/**
 * The units of length in inches.
 */
@property (class, readonly, copy) NSUnitLength *inches;

/**
 * The units of length in feet.
 */
@property (class, readonly, copy) NSUnitLength *feet;

/**
 * The units of length in yards.
 */
@property (class, readonly, copy) NSUnitLength *yards;

/**
 * The units of length in miles.
 */
@property (class, readonly, copy) NSUnitLength *miles;

/**
 * The units of length in scandanavian miles.
 */
@property (class, readonly, copy) NSUnitLength *scandinavianMiles;

/**
 * The units of length in light years.
 */
@property (class, readonly, copy) NSUnitLength *lightyears;

/**
 * The units of length in nautical miles.
 */
@property (class, readonly, copy) NSUnitLength *nauticalMiles;

/**
 * The units of length in fathoms.
 */
@property (class, readonly, copy) NSUnitLength *fathoms;

/**
 * The units of length in furlongs.
 */
@property (class, readonly, copy) NSUnitLength *furlongs;

/**
 * The units of length in astronomical units.
 */
@property (class, readonly, copy) NSUnitLength *astronomicalUnits;

/**
 * The units of length in parsecs.
 */
@property (class, readonly, copy) NSUnitLength *parsecs;

@end

/**
 * Units of illumination.  Base unit - lux
 */
GS_EXPORT_CLASS
@interface NSUnitIlluminance : NSDimension

/**
 * The units of illuminance in lux.
 */
@property (class, readonly, copy) NSUnitIlluminance *lux;

@end

/**
 * Units of mass. Base unit - kilograms
 */
GS_EXPORT_CLASS
@interface NSUnitMass : NSDimension

/**
 * The mass units in kilograms.
 */
@property (class, readonly, copy) NSUnitMass *kilograms;

/**
 * The mass units in grams.
 */
@property (class, readonly, copy) NSUnitMass *grams;

/**
 * The mass units in decigrams.
 */
@property (class, readonly, copy) NSUnitMass *decigrams;

/**
 * The mass units in centigrams.
 */
@property (class, readonly, copy) NSUnitMass *centigrams;

/**
 * The mass units in milligrams.
 */
@property (class, readonly, copy) NSUnitMass *milligrams;

/**
 * The mass units in micrograms.
 */
@property (class, readonly, copy) NSUnitMass *micrograms;

/**
 * The mass units in nanograms.
 */
@property (class, readonly, copy) NSUnitMass *nanograms;

/**
 * The mass units in picograms.
 */
@property (class, readonly, copy) NSUnitMass *picograms;

/**
 * The mass units in ounces.
 */
@property (class, readonly, copy) NSUnitMass *ounces;

/**
 * The mass units in pounds (same as poundsMass).
 */
@property (class, readonly, copy) NSUnitMass *pounds;

/**
 * The mass units in pounds.
 */
@property (class, readonly, copy) NSUnitMass *poundsMass;

/**
 * The mass units in stones.
 */
@property (class, readonly, copy) NSUnitMass *stones;

/**
 * The mass units in metric tons.
 */
@property (class, readonly, copy) NSUnitMass *metricTons;

/**
 * The mass units in short tons.
 */
@property (class, readonly, copy) NSUnitMass *shortTons;

/**
 * The mass units in carats.
 */
@property (class, readonly, copy) NSUnitMass *carats;

/**
 * The mass units in ounces troy.
 */
@property (class, readonly, copy) NSUnitMass *ouncesTroy;

/**
 * The mass units in slugs.
 */
@property (class, readonly, copy) NSUnitMass *slugs;

@end

/**
 * Used to represent power.  Base unit - watts
 */
GS_EXPORT_CLASS
@interface NSUnitPower : NSDimension

/**
 * The power units in terawatts.
 */
@property (class, readonly, copy) NSUnitPower *terawatts;

/**
 * The power units in gigawatts.
 */
@property (class, readonly, copy) NSUnitPower *gigawatts;

/**
 * The power units in megawatts.
 */
@property (class, readonly, copy) NSUnitPower *megawatts;

/**
 * The power units in kilowatts.
 */
@property (class, readonly, copy) NSUnitPower *kilowatts;

/**
 * The power units in watts.
 */
@property (class, readonly, copy) NSUnitPower *watts;

/**
 * The power units in milliwatts.
 */
@property (class, readonly, copy) NSUnitPower *milliwatts;

/**
 * The power units in microwatts.
 */
@property (class, readonly, copy) NSUnitPower *microwatts;

/**
 * The power units in nanowatts.
 */
@property (class, readonly, copy) NSUnitPower *nanowatts;

/**
 * The power units in picowatts.
 */
@property (class, readonly, copy) NSUnitPower *picowatts;

/**
 * The power units in femtowatts.
 */
@property (class, readonly, copy) NSUnitPower *femtowatts;

/**
 * The power units in horsepower.
 */
@property (class, readonly, copy) NSUnitPower *horsepower;

@end

/** Used to represent pressure. Base unit - newtonsPerMetersSquared
 * (equivalent to 1 pascal)
 */
GS_EXPORT_CLASS
@interface NSUnitPressure : NSDimension

/**
 * The newtons per meters squared unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *newtonsPerMetersSquared;

/**
 * The gigapascals unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *gigapascals;

/**
 * The megapascals unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *megapascals;

/**
 * The kilopascals unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *kilopascals;

/**
 * The hetcopascals unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *hectopascals;

/**
 * The inches of mercury unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *inchesOfMercury;

/**
 * The bars unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *bars;

/**
 * The millibars unit of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *millibars;

/**
 * The millimeters of mercury of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *millimetersOfMercury;

/**
 * The pounds of per square inch of pressure.
 */
@property (class, readonly, copy) NSUnitPressure *poundsForcePerSquareInch;

@end

/**
 * Used to represent speed. Base unit is meters per second.
 */
GS_EXPORT_CLASS
@interface NSUnitSpeed : NSDimension

/**
 * The meters per second measurement of speed.
 */
@property (class, readonly, copy) NSUnitSpeed *metersPerSecond;

/**
 * The kilometers per hour measurement of speed.
 */
@property (class, readonly, copy) NSUnitSpeed *kilometersPerHour;

/**
 * The miles per hour measurement of speed.
 */
@property (class, readonly, copy) NSUnitSpeed *milesPerHour;

/**
 * The knots measurement of speed.
 */
@property (class, readonly, copy) NSUnitSpeed *knots;

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
@property (class, readonly, copy) NSUnitTemperature *kelvin;

/**
 * The kelvin unit of celsius.
 */
@property (class, readonly, copy) NSUnitTemperature *celsius;

/**
 * The kelvin unit of fahenheit.
 */
@property (class, readonly, copy) NSUnitTemperature *fahrenheit;

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
@property (class, readonly, copy) NSUnitVolume *megaliters;

/**
 * The kiloliters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *kiloliters;

/**
 * The liters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *liters;

/**
 * The deciliters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *deciliters;

/**
 * The centiliters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *centiliters;

/**
 * The milliliters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *milliliters;

/**
 * The cubic kilometers unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicKilometers;

/**
 * The cubic meters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicMeters;

/**
 * The cubic decimeters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicDecimeters;

/**
 * The cubic centimeteres unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicCentimeters;

/**
 * The cubic millimeters unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicMillimeters;

/**
 * The cubic inches unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicInches;

/**
 * The cubic feet unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicFeet;

/**
 * The cubic yards unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicYards;

/**
 * The cubic miles unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cubicMiles;

/**
 * The acre feet unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *acreFeet;

/**
 * The bushels unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *bushels;

/**
 * The teaspoons unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *teaspoons;

/**
 * The tablespoons unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *tablespoons;

/**
 * The fluid ounces unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *fluidOunces;

/**
 * The cups unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *cups;

/**
 * The pints unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *pints;

/**
 * The quarts unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *quarts;

/**
 * The gallons unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *gallons;

/**
 * The imperial teaspoons unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *imperialTeaspoons;

/**
 * The imperial tablespoons unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *imperialTablespoons;

/**
 * The imperial fluid ounces unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *imperialFluidOunces;

/**
 * The imperial pints unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *imperialPints;

/**
 * The imperial quarts unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *imperialQuarts;

/**
 * The imperial gallons unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *imperialGallons;

/**
 * The metric cups unit of volume.
 */
@property (class, readonly, copy) NSUnitVolume *metricCups;

@end

#if	defined(__cplusplus)
}
#endif

#endif	/* GS_API_MACOSX */

#endif	/* _NSUnit_h_GNUSTEP_BASE_INCLUDE */
