/*
 * setExpressions.m - regression test for the union, intersection and
 * minus set expressions, which raised "subexpression is not a set" for
 * NSSet operands and took only arrays.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSExpression		*l;
  NSExpression		*r;
  NSExpression		*a;
  NSSet			*s = nil;
  NSSet			*ab;
  NSSet			*bc;

  ab = [NSSet setWithObjects: @"a", @"b", nil];
  bc = [NSSet setWithObjects: @"b", @"c", nil];
  l = [NSExpression expressionForConstantValue: ab];
  r = [NSExpression expressionForConstantValue: bc];
  a = [NSExpression expressionForConstantValue:
    [NSArray arrayWithObjects: @"b", @"c", nil]];

  START_SET("set expressions with NSSet operands")
    PASS_RUNS(s = [[NSExpression expressionForUnionSet: l with: r]
      expressionValueWithObject: nil context: nil],
      "a union of two sets evaluates")
    PASS_EQUAL(s, ([NSSet setWithObjects: @"a", @"b", @"c", nil]),
      "the union has the members of both sets")
    s = nil;
    PASS_RUNS(s = [[NSExpression expressionForIntersectSet: l with: r]
      expressionValueWithObject: nil context: nil],
      "an intersection of two sets evaluates")
    PASS_EQUAL(s, [NSSet setWithObject: @"b"],
      "the intersection has the common members")
    s = nil;
    PASS_RUNS(s = [[NSExpression expressionForMinusSet: l with: r]
      expressionValueWithObject: nil context: nil],
      "a difference of two sets evaluates")
    PASS_EQUAL(s, [NSSet setWithObject: @"a"],
      "the difference has the left members not on the right")
    s = nil;
    PASS_RUNS(s = [[NSExpression expressionForMinusSet: l with: a]
      expressionValueWithObject: nil context: nil],
      "a set and an array evaluate together")
    PASS_EQUAL(s, [NSSet setWithObject: @"a"],
      "an array operand is taken as the set of its elements")
  END_SET("set expressions with NSSet operands")

  [arp release];
  return 0;
}
