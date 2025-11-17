// Replace literal 0 assignement with InvalidXLogRecPtr
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_literal_0_assignement_with_InvalidXLogRecPtr.cocci \
//       --dir /path/to/postgres/src \
//       -I /path/to/postgres/src/include \
//       --recursive-includes \
//       > replace.patch
//
// Note that --recursive-includes is needed to collect from all the structs
// Then it's strongly recommended to use wrappers/run_parallel.sh (read it's
// header as to why)

// Collect all XLogRecPtr fields from structs
@collect1@
identifier sname, fld;
typedef XLogRecPtr;
typedef GistNSN;
type T = {XLogRecPtr, GistNSN};
@@
  struct sname {
    ...
    T fld;
    ...
  };

@collect2@
identifier fld;
type T;
typedef XLogRecPtr;
typedef GistNSN;
type T1 = {XLogRecPtr, GistNSN};
@@
  typedef struct {
    ...
    T1 fld;
    ...
  } T;

@collect3@
identifier sname, fld;
type T;
typedef XLogRecPtr;
typedef GistNSN;
type T1 = {XLogRecPtr, GistNSN};
@@
  typedef struct sname {
    ...
    T1 fld;
    ...
  } T;

// Replace E->field = 0
@transform1 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- E->fld = 0
+ E->fld = InvalidXLogRecPtr
)

@transform2 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- E->fld = 0
+ E->fld = InvalidXLogRecPtr
)

@transform3 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- E->fld = 0
+ E->fld = InvalidXLogRecPtr
)

// Replace E.field = 0 (direct member access with .)
@transform4 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- E.fld = 0
+ E.fld = InvalidXLogRecPtr
)

@transform5 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- E.fld = 0
+ E.fld = InvalidXLogRecPtr
)

@transform6 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- E.fld = 0
+ E.fld = InvalidXLogRecPtr
)

// Replace simple identifiers with type checking
@ exists @
identifier L;
type T = {XLogRecPtr, GistNSN};
@@
  T L;
  ... when any
(
- L = 0
+ L = InvalidXLogRecPtr
)

@ exists @
identifier L;
type T = {XLogRecPtr, GistNSN};
@@
  T *L;
  ... when any
(
- *L = 0
+ *L = InvalidXLogRecPtr
)

// Replace initialization at declaration
@@
identifier L;
type T = {XLogRecPtr, GistNSN};
@@
(
- T L = 0;
+ T L = InvalidXLogRecPtr;
)

// Replace assignment to global XLogRecPtr variables
@@
type T = {XLogRecPtr, GistNSN};
global idexpression T L;
@@
(
- L = 0
+ L = InvalidXLogRecPtr
)
