// Replace InvalidOid comparisons with OidIsValid() macro
// when dealing with pointer Oid types.
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

// Collect all Oid field pointers from structs
@collect_ptr1@
identifier sname, fld;
@@
  struct sname {
    ...
    Oid *fld;
    ...
  };

@collect_ptr2@
identifier fld;
type T;
@@
  typedef struct {
    ...
    Oid *fld;
    ...
  } T;

@collect_ptr3@
identifier sname, fld;
type T;
@@
  typedef struct sname {
    ...
    Oid *fld;
    ...
  } T;

// Replace E->ptr_field[idx] == InvalidOid (or 0)
@transform_ptr_array1 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname *E;
expression idx;
@@
(
- E->fld[idx] == InvalidOid
+ !OidIsValid(E->fld[idx])
|
- E->fld[idx] == 0
+ !OidIsValid(E->fld[idx])
)

@transform_ptr_array2 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T *E;
expression idx;
@@
(
- E->fld[idx] == InvalidOid
+ !OidIsValid(E->fld[idx])
|
- E->fld[idx] == 0
+ !OidIsValid(E->fld[idx])
)

@transform_ptr_array3 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T *E;
expression idx;
@@
(
- E->fld[idx] == InvalidOid
+ !OidIsValid(E->fld[idx])
|
- E->fld[idx] == 0
+ !OidIsValid(E->fld[idx])
)

// Replace InvalidOid (or 0) == E->ptr_field[idx]
@transform_ptr_array4 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname *E;
expression idx;
@@
(
- InvalidOid == E->fld[idx]
+ !OidIsValid(E->fld[idx])
|
- 0 == E->fld[idx]
+ !OidIsValid(E->fld[idx])
)

@transform_ptr_array5 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T *E;
expression idx;
@@
(
- InvalidOid == E->fld[idx]
+ !OidIsValid(E->fld[idx])
|
- 0 == E->fld[idx]
+ !OidIsValid(E->fld[idx])
)

@transform_ptr_array6 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T *E;
expression idx;
@@
(
- InvalidOid == E->fld[idx]
+ !OidIsValid(E->fld[idx])
|
- 0 == E->fld[idx]
+ !OidIsValid(E->fld[idx])
)

// Replace E->ptr_field[idx] != InvalidOid (or 0)
@transform_ptr_array7 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname *E;
expression idx;
@@
(
- E->fld[idx] != InvalidOid
+ OidIsValid(E->fld[idx])
|
- E->fld[idx] != 0
+ OidIsValid(E->fld[idx])
)

@transform_ptr_array8 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T *E;
expression idx;
@@
(
- E->fld[idx] != InvalidOid
+ OidIsValid(E->fld[idx])
|
- E->fld[idx] != 0
+ OidIsValid(E->fld[idx])
)

@transform_ptr_array9 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T *E;
expression idx;
@@
(
- E->fld[idx] != InvalidOid
+ OidIsValid(E->fld[idx])
|
- E->fld[idx] != 0
+ OidIsValid(E->fld[idx])
)

// Replace InvalidOid (or 0) != E->ptr_field[idx]
@transform_ptr_array10 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname *E;
expression idx;
@@
(
- InvalidOid != E->fld[idx]
+ OidIsValid(E->fld[idx])
|
- 0 != E->fld[idx]
+ OidIsValid(E->fld[idx])
)

@transform_ptr_array11 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T *E;
expression idx;
@@
(
- InvalidOid != E->fld[idx]
+ OidIsValid(E->fld[idx])
|
- 0 != E->fld[idx]
+ OidIsValid(E->fld[idx])
)

@transform_ptr_array12 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T *E;
expression idx;
@@
(
- InvalidOid != E->fld[idx]
+ OidIsValid(E->fld[idx])
|
- 0 != E->fld[idx]
+ OidIsValid(E->fld[idx])
)

// Replace E.ptr_field[idx] == InvalidOid (or 0)
@transform_ptr_array13 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname E;
expression idx;
@@
(
- E.fld[idx] == InvalidOid
+ !OidIsValid(E.fld[idx])
|
- E.fld[idx] == 0
+ !OidIsValid(E.fld[idx])
)

@transform_ptr_array14 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T E;
expression idx;
@@
(
- E.fld[idx] == InvalidOid
+ !OidIsValid(E.fld[idx])
|
- E.fld[idx] == 0
+ !OidIsValid(E.fld[idx])
)

@transform_ptr_array15 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T E;
expression idx;
@@
(
- E.fld[idx] == InvalidOid
+ !OidIsValid(E.fld[idx])
|
- E.fld[idx] == 0
+ !OidIsValid(E.fld[idx])
)

// Replace InvalidOid (or 0) == E.ptr_field[idx]
@transform_ptr_array16 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname E;
expression idx;
@@
(
- InvalidOid == E.fld[idx]
+ !OidIsValid(E.fld[idx])
|
- 0 == E.fld[idx]
+ !OidIsValid(E.fld[idx])
)

@transform_ptr_array17 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T E;
expression idx;
@@
(
- InvalidOid == E.fld[idx]
+ !OidIsValid(E.fld[idx])
|
- 0 == E.fld[idx]
+ !OidIsValid(E.fld[idx])
)

@transform_ptr_array18 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T E;
expression idx;
@@
(
- InvalidOid == E.fld[idx]
+ !OidIsValid(E.fld[idx])
|
- 0 == E.fld[idx]
+ !OidIsValid(E.fld[idx])
)

// Replace E.ptr_field[idx] != InvalidOid (or 0)
@transform_ptr_array19 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname E;
expression idx;
@@
(
- E.fld[idx] != InvalidOid
+ OidIsValid(E.fld[idx])
|
- E.fld[idx] != 0
+ OidIsValid(E.fld[idx])
)

@transform_ptr_array20 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T E;
expression idx;
@@
(
- E.fld[idx] != InvalidOid
+ OidIsValid(E.fld[idx])
|
- E.fld[idx] != 0
+ OidIsValid(E.fld[idx])
)

@transform_ptr_array21 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T E;
expression idx;
@@
(
- E.fld[idx] != InvalidOid
+ OidIsValid(E.fld[idx])
|
- E.fld[idx] != 0
+ OidIsValid(E.fld[idx])
)

// Replace InvalidOid (or 0) != E.ptr_field[idx]
@transform_ptr_array22 depends on collect_ptr1@
identifier collect_ptr1.sname, collect_ptr1.fld;
struct sname E;
expression idx;
@@
(
- InvalidOid != E.fld[idx]
+ OidIsValid(E.fld[idx])
|
- 0 != E.fld[idx]
+ OidIsValid(E.fld[idx])
)

@transform_ptr_array23 depends on collect_ptr2@
identifier collect_ptr2.fld;
type collect_ptr2.T;
T E;
expression idx;
@@
(
- InvalidOid != E.fld[idx]
+ OidIsValid(E.fld[idx])
|
- 0 != E.fld[idx]
+ OidIsValid(E.fld[idx])
)

@transform_ptr_array24 depends on collect_ptr3@
identifier collect_ptr3.fld;
type collect_ptr3.T;
T E;
expression idx;
@@
(
- InvalidOid != E.fld[idx]
+ OidIsValid(E.fld[idx])
|
- 0 != E.fld[idx]
+ OidIsValid(E.fld[idx])
)

// Handle Oid pointer parameters in functions
@@
identifier func;
identifier arg;
expression idx;
@@
func(..., Oid *arg, ...) {
<...
(
- arg[idx] == InvalidOid
+ !OidIsValid(arg[idx])
|
- InvalidOid == arg[idx]
+ !OidIsValid(arg[idx])
|
- arg[idx] != InvalidOid
+ OidIsValid(arg[idx])
|
- InvalidOid != arg[idx]
+ OidIsValid(arg[idx])
|
- arg[idx] == 0
+ !OidIsValid(arg[idx])
|
- 0 == arg[idx]
+ !OidIsValid(arg[idx])
|
- arg[idx] != 0
+ OidIsValid(arg[idx])
|
- 0 != arg[idx]
+ OidIsValid(arg[idx])
)
...>
}

// Replace simple identifiers with type checking
// Local variables - uninitialized
@ exists @
identifier L;
expression idx;
@@
  Oid *L;
  ... when any
(
- L[idx] == InvalidOid
+ !OidIsValid(L[idx])
|
- InvalidOid == L[idx]
+ !OidIsValid(L[idx])
|
- L[idx] != InvalidOid
+ OidIsValid(L[idx])
|
- InvalidOid != L[idx]
+ OidIsValid(L[idx])
|
- L[idx] == 0
+ !OidIsValid(L[idx])
|
- 0 == L[idx]
+ !OidIsValid(L[idx])
|
- L[idx] != 0
+ OidIsValid(L[idx])
|
- 0 != L[idx]
+ OidIsValid(L[idx])
)

// Local variables - initialized
@ exists @
identifier L;
expression E;
expression idx;
@@
  Oid *L = E;
  ... when any
(
- L[idx] == InvalidOid
+ !OidIsValid(L[idx])
|
- InvalidOid == L[idx]
+ !OidIsValid(L[idx])
|
- L[idx] != InvalidOid
+ OidIsValid(L[idx])
|
- InvalidOid != L[idx]
+ OidIsValid(L[idx])
|
- L[idx] == 0
+ !OidIsValid(L[idx])
|
- 0 == L[idx]
+ !OidIsValid(L[idx])
|
- L[idx] != 0
+ OidIsValid(L[idx])
|
- 0 != L[idx]
+ OidIsValid(L[idx])
)

@ exists @
identifier L;
@@
  Oid *L;
  ... when any
(
- *L == InvalidOid
+ !OidIsValid(*L)
|
- InvalidOid == *L
+ !OidIsValid(*L)
|
- *L != InvalidOid
+ OidIsValid(*L)
|
- InvalidOid != *L
+ OidIsValid(*L)
|
- *L == 0
+ !OidIsValid(*L)
|
- 0 == *L
+ !OidIsValid(*L)
|
- *L != 0
+ OidIsValid(*L)
|
- 0 != *L
+ OidIsValid(*L)
)

@ exists @
identifier L;
expression E;
@@
  Oid *L = E;
  ... when any
(
- *L == InvalidOid
+ !OidIsValid(*L)
|
- InvalidOid == *L
+ !OidIsValid(*L)
|
- *L != InvalidOid
+ OidIsValid(*L)
|
- InvalidOid != *L
+ OidIsValid(*L)
|
- *L == 0
+ !OidIsValid(*L)
|
- 0 == *L
+ !OidIsValid(*L)
|
- *L != 0
+ OidIsValid(*L)
|
- 0 != *L
+ OidIsValid(*L)
)
