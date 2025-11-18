// Replace literal 0 assignement with InvalidOid
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_literal_0_assignement_with_InvalidOid_Oid.cocci \
//       --dir /path/to/postgres/src \
//       -I /path/to/postgres/src/include \
//       --recursive-includes \
//       > replace.patch
//
// Note that --recursive-includes is needed to collect from all the structs
// Then it's strongly recommended to use wrappers/run_parallel.sh (read it's
// header as to why)

// Collect all Oid fields from structs
@collect1@
identifier sname, fld;
typedef Oid;
type T = {Oid, RegProcedure};
attribute name pg_node_attr;
@@
  struct sname {
    ...
    T fld;
    ...
  };

@collect2@
identifier fld;
type T;
type T1 = {Oid, RegProcedure};
attribute name pg_node_attr;
@@
  typedef struct {
    ...
    T1 fld;
    ...
  } T;

@collect3@
identifier sname, fld;
type T;
type T1 = {Oid, RegProcedure};
attribute name pg_node_attr;
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
+ E->fld = InvalidOid
)

@transform2 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- E->fld = 0
+ E->fld = InvalidOid
)

@transform3 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- E->fld = 0
+ E->fld = InvalidOid
)

// Replace E.field = 0 (direct member access with .)
@transform4 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- E.fld = 0
+ E.fld = InvalidOid
)

@transform5 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- E.fld = 0
+ E.fld = InvalidOid
)

@transform6 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- E.fld = 0
+ E.fld = InvalidOid
)

// Replace simple identifiers with type checking
@ exists @
identifier L;
type T = {Oid, RegProcedure};
@@
  T L;
  ... when any
(
- L = 0
+ L = InvalidOid
)

@ exists @
identifier L;
type T = {Oid, RegProcedure};
@@
  T *L;
  ... when any
(
- *L = 0
+ *L = InvalidOid
)

// Replace initialization at declaration
@@
identifier L;
type T = {Oid, RegProcedure};
@@
(
- T L = 0;
+ T L = InvalidOid;
)

// Replace assignment to global Oid variables
@@
type T = {Oid, RegProcedure};
global idexpression T L;
@@
(
- L = 0
+ L = InvalidOid
)

// Handle functions
@@
identifier func;
identifier arg;
type T = {Oid, RegProcedure};
@@
func(..., T arg, ...) {
<...
(
- arg = 0
+ arg = InvalidOid
)
...>
}

@@
identifier func;
identifier arg;
type T = {Oid, RegProcedure};
@@
func(..., T *arg, ...) {
<...
(
- *arg = 0
+ *arg = InvalidOid
)
...>
}

@ exists @
identifier func;
identifier arg;
type T = {Oid, RegProcedure};
expression idx;
@@
func(..., T *arg, ...) {
<... when any
(
- arg[idx] = 0
+ arg[idx] = InvalidOid
)
...>
}
