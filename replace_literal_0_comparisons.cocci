// Replace literal 0 comparisons on XLogRecPtr with XLogRecPtrIsValid() macro
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_literal_0_comparisons.cocci \
//       --dir /path/to/postgres/src \
//       -I /path/to/postgres/src/include
//       --all-includes
//       > replace.patch

// Note that the current version avoids false positives by matching both
// the struct type AND field name together: one struct having XLogRecPtr field
// and another struct having the same field name but different type will not
// generate false positive anymore.

// Collect all XLogRecPtr fields
// It also collects from the included header files thanks to --all-includes
@collect1@
identifier sname, fld;
@@
  struct sname {
    ...
    XLogRecPtr fld;
    ...
  };

@collect2@
identifier fld;
type T;
@@
  typedef struct {
    ...
    XLogRecPtr fld;
    ...
  } T;

@collect3@
identifier sname, fld;
type T;
@@
  typedef struct sname {
    ...
    XLogRecPtr fld;
    ...
  } T;

// Replace E->field == 0
@transform1 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
- E->fld == 0
+ !XLogRecPtrIsValid(E->fld)

@transform2 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
- E->fld == 0
+ !XLogRecPtrIsValid(E->fld)

@transform3 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
- E->fld == 0
+ !XLogRecPtrIsValid(E->fld)

// Replace 0 == E->field
@transform4 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
- 0 == E->fld
+ !XLogRecPtrIsValid(E->fld)

@transform5 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
- 0 == E->fld
+ !XLogRecPtrIsValid(E->fld)

@transform6 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
- 0 == E->fld
+ !XLogRecPtrIsValid(E->fld)

// Replace E->field != 0
@transform7 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
- E->fld != 0
+ XLogRecPtrIsValid(E->fld)

@transform8 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
- E->fld != 0
+ XLogRecPtrIsValid(E->fld)

@transform9 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
- E->fld != 0
+ XLogRecPtrIsValid(E->fld)

// Replace 0 != E->field
@transform10 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
- 0 != E->fld
+ XLogRecPtrIsValid(E->fld)

@transform11 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
- 0 != E->fld
+ XLogRecPtrIsValid(E->fld)

@transform12 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
- 0 != E->fld
+ XLogRecPtrIsValid(E->fld)

// Replace E.field == 0
@transform13 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
- E.fld == 0
+ !XLogRecPtrIsValid(E.fld)

@transform14 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
- E.fld == 0
+ !XLogRecPtrIsValid(E.fld)

@transform15 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
- E.fld == 0
+ !XLogRecPtrIsValid(E.fld)

// Replace 0 == E.field
@transform16 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
- 0 == E.fld
+ !XLogRecPtrIsValid(E.fld)

@transform17 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
- 0 == E.fld
+ !XLogRecPtrIsValid(E.fld)

@transform18 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
- 0 == E.fld
+ !XLogRecPtrIsValid(E.fld)

// Replace E.field != 0
@transform19 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
- E.fld != 0
+ XLogRecPtrIsValid(E.fld)

@transform20 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
- E.fld != 0
+ XLogRecPtrIsValid(E.fld)

@transform21 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
- E.fld != 0
+ XLogRecPtrIsValid(E.fld)

// Replace 0 != E.field
@transform22 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
- 0 != E.fld
+ XLogRecPtrIsValid(E.fld)

@transform23 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
- 0 != E.fld
+ XLogRecPtrIsValid(E.fld)

@transform24 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
- 0 != E.fld
+ XLogRecPtrIsValid(E.fld)

// Replace simple identifiers with type checking
// This requires a declaration of XLogRecPtr L to exist, ensuring type safety
@@
identifier L;
@@
  XLogRecPtr L;
  ...
- L == 0
+ !XLogRecPtrIsValid(L)

@@
identifier L;
@@
  XLogRecPtr L;
  ...
- 0 == L
+ !XLogRecPtrIsValid(L)

@@
identifier L;
@@
  XLogRecPtr L;
  ...
- L != 0
+ XLogRecPtrIsValid(L)

@@
identifier L;
@@
  XLogRecPtr L;
  ...
- 0 != L
+ XLogRecPtrIsValid(L)

