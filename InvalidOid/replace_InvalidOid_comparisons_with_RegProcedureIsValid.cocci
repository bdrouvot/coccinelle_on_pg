// Replace InvalidRegProcedure comparisons with RegProcedureIsValid() macro
// when dealing with RegProcedure types.
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_InvalidOid_comparisons_with_RegProcedureIsValid.cocci \
//       --dir /path/to/postgres/src \
//       --all-includes \
//       > replace.patch

// Note that the current version avoids false positives by matching both
// the struct type AND field name together: one struct having RegProcedure field
// and another struct having the same field name but different type will not
// generate false positive anymore.

// Collect all RegProcedure fields from structs
@collect1@
identifier sname, fld;
attribute name pg_node_attr;
@@
  struct sname {
    ...
    RegProcedure fld;
    ...
  };

@collect2@
identifier fld;
type T;
@@
  typedef struct {
    ...
    RegProcedure fld;
    ...
  } T;

@collect3@
identifier sname, fld;
type T;
@@
  typedef struct sname {
    ...
    RegProcedure fld;
    ...
  } T;

// Replace E->field == InvalidRegProcedure (or 0) with type-safe matching
@transform1 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- E->fld == InvalidOid
+ !RegProcedureIsValid(E->fld)
|
- E->fld == 0
+ !RegProcedureIsValid(E->fld)
)

@transform2 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- E->fld == InvalidOid
+ !RegProcedureIsValid(E->fld)
|
- E->fld == 0
+ !RegProcedureIsValid(E->fld)
)

@transform3 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- E->fld == InvalidOid
+ !RegProcedureIsValid(E->fld)
|
- E->fld == 0
+ !RegProcedureIsValid(E->fld)
)

// Replace InvalidRegProcedure (or 0) == E->field
@transform4 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- InvalidRegProcedure == E->fld
+ !RegProcedureIsValid(E->fld)
|
- 0 == E->fld
+ !RegProcedureIsValid(E->fld)
)

@transform5 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- InvalidRegProcedure == E->fld
+ !RegProcedureIsValid(E->fld)
|
- 0 == E->fld
+ !RegProcedureIsValid(E->fld)
)

@transform6 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- InvalidRegProcedure == E->fld
+ !RegProcedureIsValid(E->fld)
|
- 0 == E->fld
+ !RegProcedureIsValid(E->fld)
)

// Replace E->field != InvalidRegProcedure (or 0)
@transform7 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- E->fld != InvalidOid
+ RegProcedureIsValid(E->fld)
|
- E->fld != 0
+ RegProcedureIsValid(E->fld)
)

@transform8 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- E->fld != InvalidOid
+ RegProcedureIsValid(E->fld)
|
- E->fld != 0
+ RegProcedureIsValid(E->fld)
)

@transform9 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- E->fld != InvalidOid
+ RegProcedureIsValid(E->fld)
|
- E->fld != 0
+ RegProcedureIsValid(E->fld)
)

// Replace InvalidRegProcedure (or 0) != E->field
@transform10 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- InvalidRegProcedure != E->fld
+ RegProcedureIsValid(E->fld)
|
- 0 != E->fld
+ RegProcedureIsValid(E->fld)
)

@transform11 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- InvalidRegProcedure != E->fld
+ RegProcedureIsValid(E->fld)
|
- 0 != E->fld
+ RegProcedureIsValid(E->fld)
)

@transform12 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- InvalidRegProcedure != E->fld
+ RegProcedureIsValid(E->fld)
|
- 0 != E->fld
+ RegProcedureIsValid(E->fld)
)

// Replace E.field == InvalidRegProcedure (or 0)
@transform13 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- E.fld == InvalidOid
+ !RegProcedureIsValid(E.fld)
|
- E.fld == 0
+ !RegProcedureIsValid(E.fld)
)

@transform14 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- E.fld == InvalidOid
+ !RegProcedureIsValid(E.fld)
|
- E.fld == 0
+ !RegProcedureIsValid(E.fld)
)

@transform15 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- E.fld == InvalidOid
+ !RegProcedureIsValid(E.fld)
|
- E.fld == 0
+ !RegProcedureIsValid(E.fld)
)

// Replace InvalidRegProcedure (or 0) == E.field
@transform16 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- InvalidRegProcedure == E.fld
+ !RegProcedureIsValid(E.fld)
|
- 0 == E.fld
+ !RegProcedureIsValid(E.fld)
)

@transform17 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- InvalidRegProcedure == E.fld
+ !RegProcedureIsValid(E.fld)
|
- 0 == E.fld
+ !RegProcedureIsValid(E.fld)
)

@transform18 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- InvalidRegProcedure == E.fld
+ !RegProcedureIsValid(E.fld)
|
- 0 == E.fld
+ !RegProcedureIsValid(E.fld)
)

// Replace E.field != InvalidRegProcedure (or 0)
@transform19 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- E.fld != InvalidOid
+ RegProcedureIsValid(E.fld)
|
- E.fld != 0
+ RegProcedureIsValid(E.fld)
)

@transform20 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- E.fld != InvalidOid
+ RegProcedureIsValid(E.fld)
|
- E.fld != 0
+ RegProcedureIsValid(E.fld)
)

@transform21 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- E.fld != InvalidOid
+ RegProcedureIsValid(E.fld)
|
- E.fld != 0
+ RegProcedureIsValid(E.fld)
)

// Replace InvalidRegProcedure (or 0) != E.field
@transform22 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- InvalidRegProcedure != E.fld
+ RegProcedureIsValid(E.fld)
|
- 0 != E.fld
+ RegProcedureIsValid(E.fld)
)

@transform23 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- InvalidRegProcedure != E.fld
+ RegProcedureIsValid(E.fld)
|
- 0 != E.fld
+ RegProcedureIsValid(E.fld)
)

@transform24 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- InvalidRegProcedure != E.fld
+ RegProcedureIsValid(E.fld)
|
- 0 != E.fld
+ RegProcedureIsValid(E.fld)
)

// Replace simple identifiers with type checking
// Local variables - uninitialized
@ exists @
identifier L;
@@
  RegProcedure L;
  ... when any
(
- L == InvalidOid
+ !RegProcedureIsValid(L)
|
- InvalidRegProcedure == L
+ !RegProcedureIsValid(L)
|
- L != InvalidOid
+ RegProcedureIsValid(L)
|
- InvalidRegProcedure != L
+ RegProcedureIsValid(L)
|
- L == 0
+ !RegProcedureIsValid(L)
|
- 0 == L
+ !RegProcedureIsValid(L)
|
- L != 0
+ RegProcedureIsValid(L)
|
- 0 != L
+ RegProcedureIsValid(L)
)

// Local variables - initialized
@ exists @
identifier L;
expression E;
@@
  RegProcedure L = E;
  ... when any
(
- L == InvalidOid
+ !RegProcedureIsValid(L)
|
- InvalidRegProcedure == L
+ !RegProcedureIsValid(L)
|
- L != InvalidOid
+ RegProcedureIsValid(L)
|
- InvalidRegProcedure != L
+ RegProcedureIsValid(L)
|
- L == 0
+ !RegProcedureIsValid(L)
|
- 0 == L
+ !RegProcedureIsValid(L)
|
- L != 0
+ RegProcedureIsValid(L)
|
- 0 != L
+ RegProcedureIsValid(L)
)

// Handle global RegProcedure variables
@@
global idexpression RegProcedure G;
@@
(
- G == InvalidOid
+ !RegProcedureIsValid(G)
|
- InvalidRegProcedure == G
+ !RegProcedureIsValid(G)
|
- G != InvalidOid
+ RegProcedureIsValid(G)
|
- InvalidRegProcedure != G
+ RegProcedureIsValid(G)
|
- G == 0
+ !RegProcedureIsValid(G)
|
- 0 == G
+ !RegProcedureIsValid(G)
|
- G != 0
+ RegProcedureIsValid(G)
|
- 0 != G
+ RegProcedureIsValid(G)
)

// Handle functions
@@
identifier func;
identifier arg;
@@
func(..., RegProcedure arg, ...) {
<...
(
- arg == InvalidOid
+ !RegProcedureIsValid(arg)
|
- InvalidRegProcedure == arg
+ !RegProcedureIsValid(arg)
|
- arg != InvalidOid
+ RegProcedureIsValid(arg)
|
- InvalidRegProcedure != arg
+ RegProcedureIsValid(arg)
|
- arg == 0
+ !RegProcedureIsValid(arg)
|
- 0 == arg
+ !RegProcedureIsValid(arg)
|
- arg != 0
+ RegProcedureIsValid(arg)
|
- 0 != arg
+ RegProcedureIsValid(arg)
)
...>
}


@@
identifier func;
identifier arg;
@@
func(..., RegProcedure *arg, ...) {
<...
(
- *arg == InvalidOid
+ !RegProcedureIsValid(*arg)
|
- InvalidRegProcedure == *arg
+ !RegProcedureIsValid(*arg)
|
- *arg != InvalidOid
+ RegProcedureIsValid(*arg)
|
- InvalidRegProcedure != *arg
+ RegProcedureIsValid(*arg)
|
- *arg == 0
+ !RegProcedureIsValid(*arg)
|
- 0 == *arg
+ !RegProcedureIsValid(*arg)
|
- *arg != 0
+ RegProcedureIsValid(*arg)
|
- 0 != *arg
+ RegProcedureIsValid(*arg)
)
...>
}

// Handle assignments within comparisons: (var = expr) != InvalidOid
// Type-safe version: only transforms if var is declared as Oid
@@
identifier L;
expression E;
@@
RegProcedure L;
<...
(
- (L = E) != InvalidOid
+ RegProcedureIsValid((L = E))
|
- InvalidRegProcedure != (L = E)
+ RegProcedureIsValid((L = E))
|
- (L = E) == InvalidOid
+ !RegProcedureIsValid((L = E))
|
- InvalidRegProcedure == (L = E)
+ !RegProcedureIsValid((L = E))
|
- (L = E) != 0
+ RegProcedureIsValid((L = E))
|
- 0 != (L = E)
+ RegProcedureIsValid((L = E))
|
- (L = E) == 0
+ !RegProcedureIsValid((L = E))
|
- 0 == (L = E)
+ !RegProcedureIsValid((L = E))
)
...>

@@
identifier L;
expression E, E2;
@@
RegProcedure L = E2;
<...
(
- (L = E) != InvalidOid
+ RegProcedureIsValid((L = E))
|
- InvalidRegProcedure != (L = E)
+ RegProcedureIsValid((L = E))
|
- (L = E) == InvalidOid
+ !RegProcedureIsValid((L = E))
|
- InvalidRegProcedure == (L = E)
+ !RegProcedureIsValid((L = E))
|
- (L = E) != 0
+ RegProcedureIsValid((L = E))
|
- 0 != (L = E)
+ RegProcedureIsValid((L = E))
|
- (L = E) == 0
+ !RegProcedureIsValid((L = E))
|
- 0 == (L = E)
+ !RegProcedureIsValid((L = E))
)
...>
