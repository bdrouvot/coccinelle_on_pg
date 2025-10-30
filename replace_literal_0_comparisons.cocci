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

// Note that the current version could generate false positives if 2 structs
// have the same field name: one being XLogRecPtr and one being whatever type
// not XLogRecPtr. The later would generate false positive.

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
expression E;
identifier collect1.fld;
@@
- E->fld == 0
+ !XLogRecPtrIsValid(E->fld)

@transform2 depends on collect2@
expression E;
identifier collect2.fld;
@@
- E->fld == 0
+ !XLogRecPtrIsValid(E->fld)

@transform3 depends on collect3@
expression E;
identifier collect3.fld;
@@
- E->fld == 0
+ !XLogRecPtrIsValid(E->fld)

// Replace 0 == E->field
@transform4 depends on collect1@
expression E;
identifier collect1.fld;
@@
- 0 == E->fld
+ !XLogRecPtrIsValid(E->fld)

@transform5 depends on collect2@
expression E;
identifier collect2.fld;
@@
- 0 == E->fld
+ !XLogRecPtrIsValid(E->fld)

@transform6 depends on collect3@
expression E;
identifier collect3.fld;
@@
- 0 == E->fld
+ !XLogRecPtrIsValid(E->fld)

// Replace E->field != 0
@transform7 depends on collect1@
expression E;
identifier collect1.fld;
@@
- E->fld != 0
+ XLogRecPtrIsValid(E->fld)

@transform8 depends on collect2@
expression E;
identifier collect2.fld;
@@
- E->fld != 0
+ XLogRecPtrIsValid(E->fld)

@transform9 depends on collect3@
expression E;
identifier collect3.fld;
@@
- E->fld != 0
+ XLogRecPtrIsValid(E->fld)

// Replace 0 != E->field
@transform10 depends on collect1@
expression E;
identifier collect1.fld;
@@
- 0 != E->fld
+ XLogRecPtrIsValid(E->fld)

@transform11 depends on collect2@
expression E;
identifier collect2.fld;
@@
- 0 != E->fld
+ XLogRecPtrIsValid(E->fld)

@transform12 depends on collect3@
expression E;
identifier collect3.fld;
@@
- 0 != E->fld
+ XLogRecPtrIsValid(E->fld)

// Replace E.field == 0
@transform13 depends on collect1@
expression E;
identifier collect1.fld;
@@
- E.fld == 0
+ !XLogRecPtrIsValid(E.fld)

@transform14 depends on collect2@
expression E;
identifier collect2.fld;
@@
- E.fld == 0
+ !XLogRecPtrIsValid(E.fld)

@transform15 depends on collect3@
expression E;
identifier collect3.fld;
@@
- E.fld == 0
+ !XLogRecPtrIsValid(E.fld)

// Replace 0 == E.field
@transform16 depends on collect1@
expression E;
identifier collect1.fld;
@@
- 0 == E.fld
+ !XLogRecPtrIsValid(E.fld)

@transform17 depends on collect2@
expression E;
identifier collect2.fld;
@@
- 0 == E.fld
+ !XLogRecPtrIsValid(E.fld)

@transform18 depends on collect3@
expression E;
identifier collect3.fld;
@@
- 0 == E.fld
+ !XLogRecPtrIsValid(E.fld)

// Replace E.field != 0
@transform19 depends on collect1@
expression E;
identifier collect1.fld;
@@
- E.fld != 0
+ XLogRecPtrIsValid(E.fld)

@transform20 depends on collect2@
expression E;
identifier collect2.fld;
@@
- E.fld != 0
+ XLogRecPtrIsValid(E.fld)

@transform21 depends on collect3@
expression E;
identifier collect3.fld;
@@
- E.fld != 0
+ XLogRecPtrIsValid(E.fld)

// Replace 0 != E.field
@transform22 depends on collect1@
expression E;
identifier collect1.fld;
@@
- 0 != E.fld
+ XLogRecPtrIsValid(E.fld)

@transform23 depends on collect2@
expression E;
identifier collect2.fld;
@@
- 0 != E.fld
+ XLogRecPtrIsValid(E.fld)

@transform24 depends on collect3@
expression E;
identifier collect3.fld;
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
