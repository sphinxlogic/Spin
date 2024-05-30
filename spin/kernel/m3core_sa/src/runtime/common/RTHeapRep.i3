(*| Copyright (C) 1990, Digital Equipment Corporation       *)
(*| All rights reserved.                                    *)
(*| See the file COPYRIGHT for a full description.          *)

(*| Last modified on Wed Oct 12 14:30:51 PDT 1994 by kalsow *)
(*|      modified on Tue Jun  1 13:03:23 PDT 1993 by muller *)
(*|      modified on Tue Mar  9 08:44:09 PST 1993 by jdd    *)

(* "RTHeapRep" is a private, implementation-dependent extension to
   "RTAllocator", "RTCollector", and "RTHeap". *)

(*
 * HISTORY
 * 14-Oct-97  Tian Fung Lim (tian) at the University of Washington
 *	Added TypeSecurityOn flag.  
 *
 * 16-Jul-97  Tian Fung Lim (tian) at the University of Washington
 *	Added WRITEBARRIER flag
 *
 * 06-May-97  Przemek Pardyak (pardy) at the University of Washington
 *	Made some collector data structures untraced to avoid traced 
 *      allocations during collector activities.
 *
 * 02-Nov-96  Przemek Pardyak (pardy) at the University of Washington
 *	Better counters of ambiguous roots and strongref-s.
 *
 * 14-Nov-96  Przemek Pardyak (pardy) at the University of Washington
 *	Added a StrongRef Note. verbose is a level of verbosity.
 *	Added blink. Made some procedures functional.
 *
 * 14-Oct-96  Przemek Pardyak (pardy) at the University of Washington
 *	Changed Desc to be same as in SRC distribution.  Removed PAD
 *	field.  Made MinAddress and MaxAddress FUNCTIONAL.
 *
 * 13-Aug-96  Frederick Gray (fgray) at the University of Washington
 *	Added padding to descriptor to please 32-bit machines.
 *
 * 22-Apr-96  Przemek Pardyak (pardy) at the University of Washington
 *	Added AddressToPage and PageToAddress.
 *
 * 17-Feb-96  Przemek Pardyak (pardy) at the University of Washington
 *	Added tracing and statistics of collector operations and ambiguous
 *	roots.
 *
 * 30-Nov-95  Charlie Garrett (garrett) at the University of Washington
 *	Added MinAddress and MaxAddress so that RTHeapStats can know
 *	what are valid addresses.
 *
 * 15-Aug-95  Przemek Pardyak (pardy) at the University of Washington
 *	Added free block length field to page descriptor to avoid
 *	scanning of the free page list at allocation time.
 *
 *)

UNSAFE INTERFACE RTHeapRep;

(* This interface provides low-level access to the storage allocator and
   garbage collector.  Some items here should be made private or moved
   elsewhere. *)

IMPORT RT0, RTHeapDep, Word, RTRefCount;
FROM RT0 IMPORT Typecode;

(* The allocator and collector maintain two heaps of objects.  One heap is
   "traced" (its objects are collected); the other is "untraced".

   The allocator for the untraced heap is simply "malloc".  Unless
   explicitly noted, all procedures and variables here are for the traced
   heap.  Unless explicitly noted, none of the variables in this interface
   are writable. *)

(****** PAGES ******)

(* The (traced) heap consists of a number of aligned pages, divided among
   three spaces: Free, Previous, and Current.  All other pages in the
   address space are in the "Unallocated" space.  Pages are numbered 0, 1,
   2, ....  The pagesize used is fixed; if incremental or generational
   collection is to be allowed, it must be at least the VM page size.

   The global variable p0 and p1 hold the bounds of the heap pages: only
   pages in the range [p0, p1) are in a space other than Unallocated.  For
   these pages, the array "desc" holds more information; desc[p - p0] holds
   state for page "p". *)

CONST
  BytesPerPage    = RTHeapDep.BytesPerPage;
  LogBytesPerPage = RTHeapDep.LogBytesPerPage;
  AdrPerPage      = RTHeapDep.AdrPerPage;
  LogAdrPerPage   = RTHeapDep.LogAdrPerPage;

TYPE Page = RTHeapDep.Page;

CONST
  Nil: Page = 0;                 (* page 0 cannot be part of the traced
                                    heap *)

VAR
  inFault : INTEGER := 0;

VAR
  p0, p1: Page := Nil;

VAR
  desc: UNTRACED REF ARRAY OF Desc;

TYPE
  Desc = RECORD
           space     : BITS 2 FOR Space;
           generation: BITS 1 FOR Generation;
           pure      : BITS 1 FOR BOOLEAN;
           note      : BITS 3 FOR Note;
           gray      : BITS 1 FOR BOOLEAN;
           protected : BITS 1 FOR BOOLEAN;
           continued : BITS 1 FOR BOOLEAN;
           stacked   : BITS 1 FOR BOOLEAN := FALSE;
           freechunk : BITS 1 FOR BOOLEAN := FALSE;
           frozen    : BITS 1 FOR BOOLEAN := FALSE;
           link: BITS BITSIZE(ADDRESS) - LogAdrPerPage FOR Page := Nil;

           (* EXTRA *)
           used      : BITS 16 FOR [0..8191] := 0;
           strong    : BITS 3 FOR [0..7] := 0;
           verystrong: BITS 1 FOR BOOLEAN := FALSE;
           cleanedup : BITS 1 FOR BOOLEAN := FALSE;
           reused    : BITS 1 FOR BOOLEAN := FALSE;
           (* EXTRA *)
         END;

VAR
  strong, verystrong: INTEGER;

TYPE Space = {Unallocated, Free, Previous, Current};

(* Each page has a short note attached, describing why it is in its current
   state.  This is usually used for performance monitoring. *)

TYPE
  Note = {OlderGeneration,       (* page promoted to current space because
                                    it it contained the older generation
                                    from the previous space *)
          AmbiguousRoot,         (* page promoted to current space because
                                    of a possible reference from a thread
                                    state *)
          StrongRef,             (* page promoted to current space because
                                    of a strong reference state *)
          PartialCleanup,        (* page promoted to current space because
                                    it is only partially cleaned up *)
          Large,                 (* page promoted to current space because
                                    it contains a single accessible object,
                                    so no garbage would be collected by
                                    copying the object *)
          Frozen,                (* page contains frozen ref *)
          Allocated,             (* page was allocated in current space *)
          Copied};               (* page contains elements that were copied
                                    from previous space *)

CONST
  Dirty = SET OF Note{Note.AmbiguousRoot, Note.StrongRef, Note.PartialCleanup};
  Pinned = SET OF Note{Note.AmbiguousRoot, Note.StrongRef};

(* The collector can be generational; the heap is divided into two
   generations. *)

TYPE Generation = {Older, Younger};

VAR
  allocatedPages: CARDINAL := 0; (* the number of pages in the Free,
                                    Previous, or Current spaces *)

(****** HEAP OBJECTS ******)

(* An object is a contiguous array of words on the heap.  The first word of
   an object is its header.  The object's body begins at the second word,
   its address is the object's REF.  All object bodies are aligned.

   "Small" objects never cross a page boundary.  "Large" objects are larger
   than a page; they span multiple contiguous pages.  For large objects,
   pages following the first are marked "continued".  The large object is
   the only object on its pages; it starts at the beginning of its first
   page, and no other objects follow it on its last page.

   Special "filler" objects are used to exactly fill out the end of a page
   of small objects, or to fill space between small objects when they
   cannot exactly follow the previous object because of alignment
   restrictions.  There are 1-word and multi-word filler objects.  The
   beginning of a page is always adequate alignment, so a filler object
   need never begin a page. *)

TYPE
  Header = RT0.RefHeader;
  RefHeader = UNTRACED REF Header;

CONST
  Fill_1_type: Typecode = LAST(Typecode); (* 1 word filler *)
  FillHeader1: Header = Header{typecode := Fill_1_type, forwarded := FALSE};

CONST
  Fill_N_type: Typecode = LAST(Typecode) - 1;
  FillHeaderN: Header = Header{typecode := Fill_N_type, forwarded := FALSE};
(* multi-word filler, the second word is the total size of the object,
   in bytes *)

PROCEDURE GetRealPointer (ref: ADDRESS): ADDRESS;

(****** OPEN ARRAYS ******)

(* An open array object with N open dimensions contains a header, then a
   pointer to the first data element, then N integers that hold the
   dimensions. *)

TYPE ArrayShape = UNTRACED REF ARRAY [0 .. (*N-1*) 999] OF INTEGER;

PROCEDURE UnsafeGetShape (    r          : REFANY;
                          VAR nDimensions: INTEGER;
                          VAR s          : ArrayShape);
(* if r is a reference to an open array, the number of open dimensions,
   nDimensions, and size of each dimension, s, is returned.  The array's
   shape vector is valid as long as r exists.  If r is not a reference to
   an open array, nDimensions = 0 and s is undefined.  It is an unchecked
   runtime error to modify s^, to free s, or to use it after r has been
   garbage collected. *)

(****** LOW-LEVEL ALLOCATOR/COLLECTOR *****)

PROCEDURE AllocForNew (size, alignment: CARDINAL): ADDRESS;
(* Return the address of "size" bytes of traced storage on an
   "alignment" byte boundary.  The storage is not zeroed.
   Assumes that the caller is holding the heap lock at the time
   of the call.
*)

PROCEDURE Malloc (size: INTEGER): ADDRESS;
(* Return the address of "size" bytes of untraced, zeroed storage *)

(****** MODULE OBJECTS ******)

(* A Modula-3 object is appears to the collector like any other object.
   The first word of its body is a pointer to its method list. *)

CONST MethodListOffset = 0;      (* byte offset in the object's body *)

(* RegisterFinalCleanup is available for low-level cleanup by the thread
   package.  If "r" is registered for cleanup, then just before "r" is
   freed, the cleanup procedure "p" is called.  This procedure is allowed
   to dereference "r" to copy out data, not including traced references.

   Although the thread package could use ordinary weak refs, this operation
   is easy to provide and is a little more efficient.  The thread package
   cannot use weak refs straight on public types because its clients should
   remain free to use weak refs on subtypes. *)

PROCEDURE RegisterFinalCleanup (r: REFANY; p: PROCEDURE (r: REFANY));

(****** COLLECTOR STATUS AND CONTROL ******)

(* There are various status variables. *)

VAR collections := 0;            (* the number of collections begun *)

VAR
  disableCount: CARDINAL := 0;   (* how many more Disables than Enables *)
  disableMotionCount: CARDINAL := 0; (* how many more DisableMotions than
                                        EnableMotions *)
  disableVMCount: CARDINAL := 0; (* how many more DisableVMs than
                                    EnableVMs *)
VAR 
  startedBackground := FALSE;

PROCEDURE Crash (): BOOLEAN;
(* Crash is called by the runtime when the program is about to crash.  When
   Crash returns, the entire heap is readable, and no further heap objects
   will move or be protected.  Crash attempts to finish the current
   collection.  If Crash returns TRUE, the current collection, if any,
   successfully completed. *)

(* We maintain counts of pages in the current pace allocated by "NEW", by
   copying, and by promotion, for pages for small objects and for large
   objects. *)

VAR
  smallNewPages, largeNewPages            : CARDINAL := 0;
  smallCopyPages, largeCopyPages          : CARDINAL := 0;
  smallPromotionPages, largePromotionPages: CARDINAL := 0;
  prevActivePages                         : CARDINAL := 0;
  activePages                             : CARDINAL := 0;
  freePages                               : CARDINAL := 0;

(* pointer and garbage collection statistics collected on each GC *)
VAR
  ambiguousReferences : UNTRACED REF ARRAY OF ADDRESS := NIL;
  tabledReferencesCnt : CARDINAL := 0;

  ambiguousReferencesCnt : CARDINAL := 0;
  strongReferencesCnt : CARDINAL := 0;
  unsafeAmbiguousReferencesCnt : CARDINAL := 0;

  uniqueStrongReferencesCnt : CARDINAL := 0;
  uniqueAmbiguousReferencesCnt : CARDINAL := 0;
  unsafeUniqueAmbiguousReferencesCnt : CARDINAL := 0;

TYPE
  MonitorClosure <: UNTRACED ROOT OBJECT
                    METHODS
                      before ();
                      after  ();
                    END;

PROCEDURE RegisterMonitor (cl: MonitorClosure);
(* Before each collection, the collector calls all registered 'before'
   procedures; after each collection, the collector calls all registered
   'after' procedures. *)

PROCEDURE UnregisterMonitor (cl: MonitorClosure);
(* removes procedures for cl from the registered set. *)

PROCEDURE InvokeMonitors (before: BOOLEAN);
(* called by the collector to trigger the registered monitors.
   If "before" is "TRUE", the "before" methods are called, otherwise
   the "after" methods are called. *)

(*** support for tracing objects ***)

CONST
  traceOn: BOOLEAN = FALSE;

VAR                     
  TrackTC  : INTEGER := 0;
  TrackRef : ADDRESS;

CONST
  doSanity  = FALSE;
  doChecks  = TRUE;
  doVerbose = TRUE;
  doStats   = FALSE;
  doPerf    = FALSE;

VAR
  allocCnt   : INTEGER := 0;
  deallocCnt : INTEGER := 0;
  promoteCnt : INTEGER := 0;
  moveCnt    : INTEGER := 0;
  foundCnt   : INTEGER := 0;

  allocCnts   : ARRAY [0..1024] OF INTEGER;
  deallocCnts : ARRAY [0..1024] OF INTEGER;
  promoteCnts : ARRAY [0..1024] OF INTEGER;
  moveCnts    : ARRAY [0..1024] OF INTEGER;
  foundCnts   : ARRAY [0..1024] OF INTEGER;

PROCEDURE ObjectAllocated(ref: REFANY; pc: ADDRESS);
PROCEDURE ObjectDeallocated(ref: Word.T);
PROCEDURE ObjectPromoted(ref: REFANY; stage: INTEGER; 
                         ptr: ADDRESS; loc: ADDRESS; src: REFANY);
PROCEDURE ObjectMoved(before: Word.T; after: REFANY; state: INTEGER);
PROCEDURE ObjectTenured(ref: REFANY);
PROCEDURE ObjectUntenured(ref: REFANY);

PROCEDURE GCStarted();
PROCEDURE GCDone();
PROCEDURE GCEnter();
PROCEDURE GCExit();

(*** VM support ***)

PROCEDURE Fault (addr: ADDRESS): BOOLEAN;
(* Fault is called from the RTHeapDep when a VM fault occurs.  If Fault
   returns TRUE, protection has been changed and the operation should be
   retried.  If Fault returns FALSE, the faulting address is not part of
   the traced heap, and the fault should be treated as an error. *)

PROCEDURE MutatorFault (addr: ADDRESS; pc: ADDRESS);
(* The mutator faulted but not on the traced heap *)

PROCEDURE EnableTraps ();
(* The traps are initialized *)

PROCEDURE Assignement (loc, lptr, rptr, pc: ADDRESS);
(* an assignement at pc of rptr was made to loc overwriting lptr *)

PROCEDURE ReferentSize (h: RefHeader): CARDINAL;

(****** DEBUGGING ******)

(* There are various routines for collecting or printing out information on
   the objects on the heap. *)

TYPE
  RefVisitor = OBJECT
               METHODS
                 visit (tc: Typecode; r: REFANY; size: CARDINAL): BOOLEAN;
                 (* returns TRUE to continue *)
               END;

PROCEDURE VisitAllRefs (proc: RefVisitor; fromGC: BOOLEAN := FALSE);
(* Visit all the traced references in the heap, and call proc.visit for
   each one of them.  Garbage collection is disabled during that visit and
   you should refrain from allocating memory in proc. *)

FUNCTIONAL PROCEDURE PageToAddress (p: Page): ADDRESS;
FUNCTIONAL PROCEDURE AddressToPage (a: ADDRESS): Page;

(* SPIN specific, for RTHeapStats *)
FUNCTIONAL PROCEDURE MinAddress(): ADDRESS;
FUNCTIONAL PROCEDURE MaxAddress(): ADDRESS;

VAR 
  verbose : INTEGER := 0;
  gcCnt   : INTEGER := 0;
  colCnt  : INTEGER := 0;

(* from MAS *)

PROCEDURE ReturnMem(a: ADDRESS);

PROCEDURE CheckSanity(msg: TEXT): BOOLEAN;

PROCEDURE LocateHeaderOf(a: ADDRESS): RefHeader;

(****** INITIALIZATION ******)

PROCEDURE CheckTypes ();
(* called after type registration to let the allocator sanity check the
   typecells. *)

PROCEDURE Init();
(* MUST be called to initialize allocator/collector state *)

PROCEDURE DistributeMemory(); 
(* For Wilson's collector.  Takes all remaining memory in the heap and
   distributes it across all the treadmills, according to the number
   of collections incurred by each.*)

CONST
  RefCount = RTRefCount.RefCount;
  WRITEBARRIER = RTRefCount.WRITEBARRIER;
  TypeSecurityOn = TRUE;

PROCEDURE ActiveBytesOnPage (p: Page; withOverhead: BOOLEAN := FALSE): INTEGER;

TYPE
  RefReferent = ADDRESS;

VAR
  collectorOn: BOOLEAN := FALSE;

END RTHeapRep.
