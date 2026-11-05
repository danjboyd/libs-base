#if defined(__ELF__) && !defined(_GNU_SOURCE)
#define _GNU_SOURCE	/* for dladdr() */
#endif
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

#if defined(__ELF__)
#include <dlfcn.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#import <objc/runtime.h>
#endif
#if defined(_WIN32)
#include <windows.h>
#import <objc/runtime.h>
#endif

/* Mutating a collection while a for-in loop enumerates it makes the loop
 * call objc_enumerationMutation(), and with gnustep-base that raises
 * NSGenericException.  The runtime library defines its own
 * objc_enumerationMutation(), which aborts; gnustep-base either asks the
 * runtime to call its handler instead or defines the function itself, and
 * the latter only takes effect when the dynamic linker finds gnustep-base's
 * definition first.  A program which loads the runtime before gnustep-base
 * (a Swift program, for example) gets the runtime's, unless the runtime
 * calls the handler.
 */

static void
addToArray(id array)
{
  for (id o in array)
    {
      [array addObject: o];
    }
}

static void
removeFromDictionary(id dictionary)
{
  for (id k in dictionary)
    {
      [dictionary removeObjectForKey: k];
    }
}

static void
addToSet(id set)
{
  for (id o in set)
    {
      [set addObject: [o stringByAppendingString: @"x"]];
    }
}

static BOOL
raisesGeneric(void (*function)(id), id collection)
{
  BOOL	raised = NO;

  NS_DURING
    function(collection);
  NS_HANDLER
    raised = [[localException name] isEqual: NSGenericException];
  NS_ENDHANDLER
  return raised;
}

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSMutableArray	*array = nil;

  START_SET("mutating a collection while enumerating it")
#if defined(_WIN32)
    HMODULE	runtime = NULL;

    /* A DLL's references to objc_enumerationMutation() bind to the runtime's
     * own function, which aborts unless the runtime can be told to call
     * gnustep-base's handler.  This is a real limitation of such a runtime
     * (MSYS2's libobjc2 has no handler), not something this test can run.
     */
    if (!GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS
      | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
      (LPCSTR)class_getName, &runtime)
      || NULL == GetProcAddress(runtime, "objc_setEnumerationMutationHandler"))
      {
        SKIP("this runtime has no objc_setEnumerationMutationHandler(),"
	  " so a mutated for-in loop aborts")
      }
#endif
  /* Retained: the set below drains its own pool, and a later set uses this. */
  array = [[NSMutableArray arrayWithObjects: @"a", @"b", @"c", nil] retain];
  PASS(raisesGeneric(addToArray, array),
    "adding to an array while enumerating it raises NSGenericException")
  PASS(3 == [array count] || 4 == [array count],
    "the array was added to at most once")

  NSMutableDictionary	*dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    @"1", @"a", @"2", @"b", nil];
  PASS(raisesGeneric(removeFromDictionary, dictionary),
    "removing from a dictionary while enumerating it raises")

  NSMutableSet		*set = [NSMutableSet setWithObjects: @"a", @"b", nil];
  PASS(raisesGeneric(addToSet, set),
    "adding to a set while enumerating it raises")
  END_SET("mutating a collection while enumerating it")

#if defined(__ELF__)
  START_SET("the runtime's objc_enumerationMutation()")
    Dl_info	info;
    void	*runtime;
    void	(*mutation)(id) = NULL;
    pid_t	child;
    int		status = 0;

    /* Look the function up in the runtime library itself, as a program
     * which loads the runtime first would find it.
     */
    if (dladdr((void *)class_getName, &info) != 0
      && (runtime = dlopen(info.dli_fname, RTLD_NOW | RTLD_NOLOAD)) != NULL)
      {
        mutation = (void (*)(id))dlsym(runtime, "objc_enumerationMutation");
      }
    if (NULL == mutation)
      {
        SKIP("objc_enumerationMutation() not found in the runtime library")
      }
    /* Without objc_setEnumerationMutationHandler() the runtime cannot be
     * told to call gnustep-base's handler.
     */
    testHopeful = (NULL == dlsym(RTLD_DEFAULT,
      "objc_setEnumerationMutationHandler"));
    /* The runtime's own function aborts, so call it in a child process. */
    [NSObject class];
    child = fork();
    if (0 == child)
      {
        _exit(raisesGeneric(mutation, array) ? 0 : 1);
      }
    PASS(child > 0 && waitpid(child, &status, 0) == child
      && WIFEXITED(status) && 0 == WEXITSTATUS(status),
      "the runtime's objc_enumerationMutation() raises NSGenericException")
    testHopeful = NO;
  END_SET("the runtime's objc_enumerationMutation()")
#endif

  [array release];
  [arp release]; arp = nil;
  return 0;
}
