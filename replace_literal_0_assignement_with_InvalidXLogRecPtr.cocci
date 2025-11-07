// Replace literal 0 assignement with InvalidXLogRecPtr
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_literal_0_assignement_with_InvalidXLogRecPtr.cocci \
//       --dir /path/to/postgres/src \
//       --include-headers \
//       > replace.patch

// Collect all XLogRecPtr fields from structs
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

// Handle cases where E is an expression (like MyProc which is extern PGPROC *MyProc)
@transform4 depends on collect1@
identifier collect1.fld;
expression E;
@@
(
- E->fld = 0
+ E->fld = InvalidXLogRecPtr
)

@transform5 depends on collect2@
identifier collect2.fld;
expression E;
@@
(
- E->fld = 0
+ E->fld = InvalidXLogRecPtr
)

@transform6 depends on collect3@
identifier collect3.fld;
expression E;
@@
(
- E->fld = 0
+ E->fld = InvalidXLogRecPtr
)

// Replace simple identifiers with type checking
@@
XLogRecPtr L;
@@
(
- L = 0
+ L = InvalidXLogRecPtr
)
