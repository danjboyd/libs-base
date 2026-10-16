/*
 * explicitParent.m - regression test for
 * +[NSProgress progressWithTotalUnitCount:parent:pendingUnitCount:],
 * which raised for a parent other than the current progress.
 */

#import <Foundation/Foundation.h>
#import "ObjectTesting.h"

int main(void)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSProgress		*parent;
  NSProgress		*child = nil;
  NSProgress		*next;

  START_SET("+progressWithTotalUnitCount:parent:pendingUnitCount:")
    parent = [NSProgress discreteProgressWithTotalUnitCount: 10];
    PASS_RUNS(child = [NSProgress progressWithTotalUnitCount: 2
						      parent: parent
					    pendingUnitCount: 4],
      "a parent that is not the current progress is accepted")
    PASS(child != nil && [child totalUnitCount] == 2,
      "the child has its own unit count")
    [child setCompletedUnitCount: 1];
    PASS(fabs([parent fractionCompleted] - 0.2) < 1e-9,
      "the child's progress counts in the parent's fraction")
    [child setCompletedUnitCount: 2];
    PASS([parent completedUnitCount] == 4,
      "the pending unit count is added to the parent when the child finishes")

    /* With the parent current and waiting for an implicit child, the
     * explicit child is added once, with its own pending unit count, and
     * the next progress made is still the implicit child.
     */
    parent = [NSProgress discreteProgressWithTotalUnitCount: 10];
    [parent becomeCurrentWithPendingUnitCount: 3];
    child = [NSProgress progressWithTotalUnitCount: 1
					    parent: parent
				  pendingUnitCount: 4];
    next = [NSProgress progressWithTotalUnitCount: 1];
    [parent resignCurrent];
    [child setCompletedUnitCount: 1];
    PASS([parent completedUnitCount] == 4,
      "the explicit child of the current progress counts its own units")
    [next setCompletedUnitCount: 1];
    PASS([parent completedUnitCount] == 7,
      "the explicit child does not take the place of the implicit child")
  END_SET("+progressWithTotalUnitCount:parent:pendingUnitCount:")

  [arp release];
  return 0;
}
