/* -registerUndoWithTarget:handler: records a block which is called with
   the target when the operation is undone, as in Cocoa.  A handler which
   registers again while it is being undone registers the redo operation.
   The method was missing. */
#import <Foundation/Foundation.h>
#import "Testing.h"

@interface Counter : NSObject
{
@public
  int	value;
}
@end

@implementation Counter
@end

#if __has_feature(blocks)
static void
setValue(NSUndoManager *um, Counter *c, int v)
{
  int	old = c->value;

  [um registerUndoWithTarget: c handler: ^(id target) {
    setValue(um, (Counter*)target, old);
  }];
  c->value = v;
}
#endif

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];

  START_SET("NSUndoManager handler")
#if __has_feature(blocks)
  NSUndoManager		*um = [NSUndoManager new];
  Counter		*c = [Counter new];
  Counter		*other = [Counter new];
  __block id		seen = nil;
  __block int		calls = 0;

  [um setGroupsByEvent: NO];

  [um beginUndoGrouping];
  setValue(um, c, 1);
  [um endUndoGrouping];
  [um beginUndoGrouping];
  setValue(um, c, 2);
  [um setActionName: @"Two"];
  [um endUndoGrouping];
  PASS([um canUndo], "a registered handler can be undone");
  PASS_EQUAL([um undoActionName], @"Two", "the group keeps its action name");

  [um undo];
  PASS(c->value == 1, "undo calls the handler with the target");
  PASS([um canRedo], "a handler registering during undo makes a redo");
  [um redo];
  PASS(c->value == 2, "redo calls the handler registered during undo");
  [um undo];
  [um undo];
  PASS(c->value == 0, "handlers undo in order");
  PASS([um canUndo] == NO, "the undo stack is then empty");
  [um redo];
  [um redo];
  PASS(c->value == 2, "and redo in order");

  [um removeAllActions];
  [um beginUndoGrouping];
  {
    /* The block is copied; this one captures a local variable. */
    int	marker = 42;

    [um registerUndoWithTarget: other handler: ^(id target) {
      seen = target;
      calls += marker;
    }];
  }
  [um endUndoGrouping];
  [um undo];
  PASS(seen == other && calls == 42,
    "a copied handler runs once with its captured state");

  [um removeAllActions];
  [um beginUndoGrouping];
  [um registerUndoWithTarget: other handler: ^(id target) { calls++; }];
  [um endUndoGrouping];
  [um removeAllActionsWithTarget: other];
  PASS([um canUndo] == NO, "removeAllActionsWithTarget: removes handlers");

  [um beginUndoGrouping];
  [um disableUndoRegistration];
  [um registerUndoWithTarget: other handler: ^(id target) { calls++; }];
  [um enableUndoRegistration];
  [um endUndoGrouping];
  PASS([um canUndo] == NO, "registration can be disabled");

  [um beginUndoGrouping];
  PASS_EXCEPTION([um registerUndoWithTarget: other handler: nil],
    NSInvalidArgumentException, "a nil handler raises");
  [um endUndoGrouping];

  [um release];
  [c release];
  [other release];
#else
  SKIP("blocks support unavailable")
#endif
  END_SET("NSUndoManager handler")

  [arp release];
  return 0;
}
