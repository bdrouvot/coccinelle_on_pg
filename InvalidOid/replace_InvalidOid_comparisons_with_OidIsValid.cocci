// Replace InvalidOid comparisons with OidIsValid() macro
// when dealing with Oid types.
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_InvalidOid_comparisons_with_OidIsValid.cocci \
//       --dir /path/to/postgres/src \
//       --all-includes \
//       > replace.patch

// Note that the current version avoids false positives by matching both
// the struct type AND field name together: one struct having Oid field
// and another struct having the same field name but different type will not
// generate false positive anymore.

// Collect all Oid fields from structs
@collect1@
identifier sname, fld;
attribute name pg_node_attr;
@@
  struct sname {
    ...
    Oid fld;
    ...
  };

@collect2@
identifier fld;
type T;
@@
  typedef struct {
    ...
    Oid fld;
    ...
  } T;

@collect3@
identifier sname, fld;
type T;
@@
  typedef struct sname {
    ...
    Oid fld;
    ...
  } T;

// Replace E->field == InvalidOid (or 0) with type-safe matching
@transform1 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- E->fld == InvalidOid
+ !OidIsValid(E->fld)
|
- E->fld == 0
+ !OidIsValid(E->fld)
)

@transform2 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- E->fld == InvalidOid
+ !OidIsValid(E->fld)
|
- E->fld == 0
+ !OidIsValid(E->fld)
)

@transform3 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- E->fld == InvalidOid
+ !OidIsValid(E->fld)
|
- E->fld == 0
+ !OidIsValid(E->fld)
)

// Replace InvalidOid (or 0) == E->field
@transform4 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- InvalidOid == E->fld
+ !OidIsValid(E->fld)
|
- 0 == E->fld
+ !OidIsValid(E->fld)
)

@transform5 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- InvalidOid == E->fld
+ !OidIsValid(E->fld)
|
- 0 == E->fld
+ !OidIsValid(E->fld)
)

@transform6 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- InvalidOid == E->fld
+ !OidIsValid(E->fld)
|
- 0 == E->fld
+ !OidIsValid(E->fld)
)

// Replace E->field != InvalidOid (or 0)
@transform7 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- E->fld != InvalidOid
+ OidIsValid(E->fld)
|
- E->fld != 0
+ OidIsValid(E->fld)
)

@transform8 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- E->fld != InvalidOid
+ OidIsValid(E->fld)
|
- E->fld != 0
+ OidIsValid(E->fld)
)

@transform9 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- E->fld != InvalidOid
+ OidIsValid(E->fld)
|
- E->fld != 0
+ OidIsValid(E->fld)
)

// Replace InvalidOid (or 0) != E->field
@transform10 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname *E;
@@
(
- InvalidOid != E->fld
+ OidIsValid(E->fld)
|
- 0 != E->fld
+ OidIsValid(E->fld)
)

@transform11 depends on collect2@
identifier collect2.fld;
type collect2.T;
T *E;
@@
(
- InvalidOid != E->fld
+ OidIsValid(E->fld)
|
- 0 != E->fld
+ OidIsValid(E->fld)
)

@transform12 depends on collect3@
identifier collect3.fld;
type collect3.T;
T *E;
@@
(
- InvalidOid != E->fld
+ OidIsValid(E->fld)
|
- 0 != E->fld
+ OidIsValid(E->fld)
)

// Replace E.field == InvalidOid (or 0)
@transform13 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- E.fld == InvalidOid
+ !OidIsValid(E.fld)
|
- E.fld == 0
+ !OidIsValid(E.fld)
)

@transform14 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- E.fld == InvalidOid
+ !OidIsValid(E.fld)
|
- E.fld == 0
+ !OidIsValid(E.fld)
)

@transform15 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- E.fld == InvalidOid
+ !OidIsValid(E.fld)
|
- E.fld == 0
+ !OidIsValid(E.fld)
)

// Replace InvalidOid (or 0) == E.field
@transform16 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- InvalidOid == E.fld
+ !OidIsValid(E.fld)
|
- 0 == E.fld
+ !OidIsValid(E.fld)
)

@transform17 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- InvalidOid == E.fld
+ !OidIsValid(E.fld)
|
- 0 == E.fld
+ !OidIsValid(E.fld)
)

@transform18 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- InvalidOid == E.fld
+ !OidIsValid(E.fld)
|
- 0 == E.fld
+ !OidIsValid(E.fld)
)

// Replace E.field != InvalidOid (or 0)
@transform19 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- E.fld != InvalidOid
+ OidIsValid(E.fld)
|
- E.fld != 0
+ OidIsValid(E.fld)
)

@transform20 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- E.fld != InvalidOid
+ OidIsValid(E.fld)
|
- E.fld != 0
+ OidIsValid(E.fld)
)

@transform21 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- E.fld != InvalidOid
+ OidIsValid(E.fld)
|
- E.fld != 0
+ OidIsValid(E.fld)
)

// Replace InvalidOid (or 0) != E.field
@transform22 depends on collect1@
identifier collect1.sname, collect1.fld;
struct sname E;
@@
(
- InvalidOid != E.fld
+ OidIsValid(E.fld)
|
- 0 != E.fld
+ OidIsValid(E.fld)
)

@transform23 depends on collect2@
identifier collect2.fld;
type collect2.T;
T E;
@@
(
- InvalidOid != E.fld
+ OidIsValid(E.fld)
|
- 0 != E.fld
+ OidIsValid(E.fld)
)

@transform24 depends on collect3@
identifier collect3.fld;
type collect3.T;
T E;
@@
(
- InvalidOid != E.fld
+ OidIsValid(E.fld)
|
- 0 != E.fld
+ OidIsValid(E.fld)
)

// Replace simple identifiers with type checking
// Local variables - uninitialized
@ exists @
identifier L;
@@
  Oid L;
  ... when any
(
- L == InvalidOid
+ !OidIsValid(L)
|
- InvalidOid == L
+ !OidIsValid(L)
|
- L != InvalidOid
+ OidIsValid(L)
|
- InvalidOid != L
+ OidIsValid(L)
|
- L == 0
+ !OidIsValid(L)
|
- 0 == L
+ !OidIsValid(L)
|
- L != 0
+ OidIsValid(L)
|
- 0 != L
+ OidIsValid(L)
)

// Local variables - initialized
@ exists @
identifier L;
expression E;
@@
  Oid L = E;
  ... when any
(
- L == InvalidOid
+ !OidIsValid(L)
|
- InvalidOid == L
+ !OidIsValid(L)
|
- L != InvalidOid
+ OidIsValid(L)
|
- InvalidOid != L
+ OidIsValid(L)
|
- L == 0
+ !OidIsValid(L)
|
- 0 == L
+ !OidIsValid(L)
|
- L != 0
+ OidIsValid(L)
|
- 0 != L
+ OidIsValid(L)
)

// Handle global Oid variables
@@
global idexpression Oid G;
@@
(
- G == InvalidOid
+ !OidIsValid(G)
|
- InvalidOid == G
+ !OidIsValid(G)
|
- G != InvalidOid
+ OidIsValid(G)
|
- InvalidOid != G
+ OidIsValid(G)
|
- G == 0
+ !OidIsValid(G)
|
- 0 == G
+ !OidIsValid(G)
|
- G != 0
+ OidIsValid(G)
|
- 0 != G
+ OidIsValid(G)
)

// Handle known global Oid identifiers explicitly
// List is result of "git grep "extern PGDLLIMPORT Oid" "*.h""
@@
identifier id = {MyDatabaseId, MyDatabaseTableSpace, CurrentExtensionObject,
                 binary_upgrade_next_pg_tablespace_oid, binary_upgrade_next_pg_type_oid,
                 binary_upgrade_next_array_pg_type_oid, binary_upgrade_next_mrng_pg_type_oid,
                 binary_upgrade_next_mrng_array_pg_type_oid, binary_upgrade_next_heap_pg_class_oid,
                 binary_upgrade_next_index_pg_class_oid, binary_upgrade_next_toast_pg_class_oid,
                 binary_upgrade_next_pg_enum_oid, binary_upgrade_next_pg_authid_oid};
@@
(
- id == InvalidOid
+ !OidIsValid(id)
|
- InvalidOid == id
+ !OidIsValid(id)
|
- id != InvalidOid
+ OidIsValid(id)
|
- InvalidOid != id
+ OidIsValid(id)
|
- id == 0
+ !OidIsValid(id)
|
- 0 == id
+ !OidIsValid(id)
|
- id != 0
+ OidIsValid(id)
|
- 0 != id
+ OidIsValid(id)
)


// Handle functions
@@
identifier func;
identifier arg;
@@
func(..., Oid arg, ...) {
<...
(
- arg == InvalidOid
+ !OidIsValid(arg)
|
- InvalidOid == arg
+ !OidIsValid(arg)
|
- arg != InvalidOid
+ OidIsValid(arg)
|
- InvalidOid != arg
+ OidIsValid(arg)
|
- arg == 0
+ !OidIsValid(arg)
|
- 0 == arg
+ !OidIsValid(arg)
|
- arg != 0
+ OidIsValid(arg)
|
- 0 != arg
+ OidIsValid(arg)
)
...>
}


@@
identifier func;
identifier arg;
@@
func(..., Oid *arg, ...) {
<...
(
- *arg == InvalidOid
+ !OidIsValid(*arg)
|
- InvalidOid == *arg
+ !OidIsValid(*arg)
|
- *arg != InvalidOid
+ OidIsValid(*arg)
|
- InvalidOid != *arg
+ OidIsValid(*arg)
|
- *arg == 0
+ !OidIsValid(*arg)
|
- 0 == *arg
+ !OidIsValid(*arg)
|
- *arg != 0
+ OidIsValid(*arg)
|
- 0 != *arg
+ OidIsValid(*arg)
)
...>
}

// Handle assignments within comparisons: (var = expr) != InvalidOid
// Type-safe version: only transforms if var is declared as Oid
@@
identifier L;
expression E;
@@
Oid L;
<...
(
- (L = E) != InvalidOid
+ OidIsValid((L = E))
|
- InvalidOid != (L = E)
+ OidIsValid((L = E))
|
- (L = E) == InvalidOid
+ !OidIsValid((L = E))
|
- InvalidOid == (L = E)
+ !OidIsValid((L = E))
|
- (L = E) != 0
+ OidIsValid((L = E))
|
- 0 != (L = E)
+ OidIsValid((L = E))
|
- (L = E) == 0
+ !OidIsValid((L = E))
|
- 0 == (L = E)
+ !OidIsValid((L = E))
)
...>

@@
identifier L;
expression E, E2;
@@
Oid L = E2;
<...
(
- (L = E) != InvalidOid
+ OidIsValid((L = E))
|
- InvalidOid != (L = E)
+ OidIsValid((L = E))
|
- (L = E) == InvalidOid
+ !OidIsValid((L = E))
|
- InvalidOid == (L = E)
+ !OidIsValid((L = E))
|
- (L = E) != 0
+ OidIsValid((L = E))
|
- 0 != (L = E)
+ OidIsValid((L = E))
|
- (L = E) == 0
+ !OidIsValid((L = E))
|
- 0 == (L = E)
+ !OidIsValid((L = E))
)
...>
