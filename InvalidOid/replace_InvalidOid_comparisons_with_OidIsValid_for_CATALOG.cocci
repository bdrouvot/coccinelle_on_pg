// Replace InvalidOid comparisons with OidIsValid() macro
// when dealing with Oid types in CATALOG macros.
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

//
// Generate a patch file with preprocessing:
// spatch --sp-file replace_InvalidOid_comparisons_with_OidIsValid_for_CATALOG.cocci \
//       --dir /path/to/postgres/src \
//       --all-includes \
//       --macro-file-builtins macro_file.txt \
//       > replace.patch
//

// We have to use --macro-file-builtins so that the preprocessor is run before
// the parsing. If not, there is parsing issue on "BKI_DEFAULT(-)" (due to "-")

// After CATALOG expansion, we get: typedef struct FormData_xxx { ... } FormData_xxx;
@collect_catalog@
attribute name BKI_LOOKUP, BKI_LOOKUP_OPT, BKI_DEFAULT, pg_node_attr;
identifier fld;
identifier sname =~ "^FormD";
type T;
@@
  typedef struct sname {
    ...
    Oid fld;
    ...
  } T;

// Match pointer access with explicit pointer type (T *E)
@transform_ptr depends on collect_catalog exists@
type collect_catalog.T;
identifier collect_catalog.fld;
T *E;
@@
(
- E->fld == InvalidOid
+ !OidIsValid(E->fld)
|
- E->fld == 0
+ !OidIsValid(E->fld)
|
- InvalidOid == E->fld
+ !OidIsValid(E->fld)
|
- 0 == E->fld
+ !OidIsValid(E->fld)
|
- E->fld != InvalidOid
+ OidIsValid(E->fld)
|
- E->fld != 0
+ OidIsValid(E->fld)
|
- InvalidOid != E->fld
+ OidIsValid(E->fld)
|
- 0 != E->fld
+ OidIsValid(E->fld)
)

// Match typedef pointer types (Form_pg_* which is already a pointer typedef)
@transform_typedef_ptr depends on collect_catalog exists@
type collect_catalog.T;
identifier collect_catalog.fld;
T E;
@@
(
- E->fld == InvalidOid
+ !OidIsValid(E->fld)
|
- E->fld == 0
+ !OidIsValid(E->fld)
|
- InvalidOid == E->fld
+ !OidIsValid(E->fld)
|
- 0 == E->fld
+ !OidIsValid(E->fld)
|
- E->fld != InvalidOid
+ OidIsValid(E->fld)
|
- E->fld != 0
+ OidIsValid(E->fld)
|
- InvalidOid != E->fld
+ OidIsValid(E->fld)
|
- 0 != E->fld
+ OidIsValid(E->fld)
)

// Match value access (T E)
@transform_val depends on collect_catalog exists@
type collect_catalog.T;
identifier collect_catalog.fld;
T E;
@@
(
- E.fld == InvalidOid
+ !OidIsValid(E.fld)
|
- E.fld == 0
+ !OidIsValid(E.fld)
|
- InvalidOid == E.fld
+ !OidIsValid(E.fld)
|
- 0 == E.fld
+ !OidIsValid(E.fld)
|
- E.fld != InvalidOid
+ OidIsValid(E.fld)
|
- E.fld != 0
+ OidIsValid(E.fld)
|
- InvalidOid != E.fld
+ OidIsValid(E.fld)
|
- 0 != E.fld
+ OidIsValid(E.fld)
)

// Nested Access: Handle patterns like rel->rd_rel->fld

// Collect structs that have a field that is a pointer to a catalog type
// e.g., struct RelationData { FormData_pg_class *rd_rel; ... }
@collect_container depends on collect_catalog@
attribute name BKI_LOOKUP, BKI_LOOKUP_OPT, BKI_DEFAULT;
type collect_catalog.T;
type T2;
identifier container_struct, catalog_field;
@@
typedef struct container_struct {
  ...
  T catalog_field;
  ...
} T2;

// Match nested access: container_struct->catalog_field->fld
@transform_nested depends on collect_container && collect_catalog exists@
identifier collect_container.catalog_field;
type collect_container.T2;
identifier collect_catalog.fld;
T2 E; 
@@
(
- E->catalog_field->fld == InvalidOid
+ !OidIsValid(E->catalog_field->fld)
|
- E->catalog_field->fld == 0
+ !OidIsValid(E->catalog_field->fld)
|
- InvalidOid == E->catalog_field->fld
+ !OidIsValid(E->catalog_field->fld)
|
- 0 == E->catalog_field->fld
+ !OidIsValid(E->catalog_field->fld)
|
- E->catalog_field->fld != InvalidOid
+ OidIsValid(E->catalog_field->fld)
|
- E->catalog_field->fld != 0
+ OidIsValid(E->catalog_field->fld)
|
- InvalidOid != E->catalog_field->fld
+ OidIsValid(E->catalog_field->fld)
|
- 0 != E->catalog_field->fld
+ OidIsValid(E->catalog_field->fld)
)

// Handle array access: arr[idx]->catalog_field->fld
@transform_array_nested depends on collect_container && collect_catalog exists@
identifier collect_container.catalog_field;
identifier collect_catalog.fld;
type collect_container.T2;
expression idx;
T2 arr;
@@
(
- arr[idx]->catalog_field->fld == InvalidOid
+ !OidIsValid(arr[idx]->catalog_field->fld)
|
- arr[idx]->catalog_field->fld == 0
+ !OidIsValid(arr[idx]->catalog_field->fld)
|
- InvalidOid == arr[idx]->catalog_field->fld
+ !OidIsValid(arr[idx]->catalog_field->fld)
|
- 0 == arr[idx]->catalog_field->fld
+ !OidIsValid(arr[idx]->catalog_field->fld)
|
- arr[idx]->catalog_field->fld != InvalidOid
+ OidIsValid(arr[idx]->catalog_field->fld)
|
- arr[idx]->catalog_field->fld != 0
+ OidIsValid(arr[idx]->catalog_field->fld)
|
- InvalidOid != arr[idx]->catalog_field->fld
+ OidIsValid(arr[idx]->catalog_field->fld)
|
- 0 != arr[idx]->catalog_field->fld
+ OidIsValid(arr[idx]->catalog_field->fld)
)

// Function parameters where arg->catalog_field->fld is valid
@transform_func_arg_nested depends on collect_container && collect_catalog exists@
identifier collect_container.catalog_field;
identifier collect_catalog.fld;
type collect_container.T2;
identifier func, arg;
@@
func(..., T2 arg, ...)
{
<... when any
(
- arg->catalog_field->fld != InvalidOid
+ OidIsValid(arg->catalog_field->fld)
|
- arg->catalog_field->fld != 0
+ OidIsValid(arg->catalog_field->fld)
|
- InvalidOid != arg->catalog_field->fld
+ OidIsValid(arg->catalog_field->fld)
|
- 0 != arg->catalog_field->fld
+ OidIsValid(arg->catalog_field->fld)
|
- arg->catalog_field->fld == InvalidOid
+ !OidIsValid(arg->catalog_field->fld)
|
- arg->catalog_field->fld == 0
+ !OidIsValid(arg->catalog_field->fld)
|
- InvalidOid == arg->catalog_field->fld
+ !OidIsValid(arg->catalog_field->fld)
|
- 0 == arg->catalog_field->fld
+ !OidIsValid(arg->catalog_field->fld)
)
...>
}

// Function parameters: func(..., Form_pg_class arg, ...)
@transform_func_arg_catalog depends on collect_catalog exists@
type collect_catalog.T;
identifier collect_catalog.fld;
identifier func, arg;
@@
func(..., T arg, ...)
{
<... when any
(
- arg->fld != InvalidOid
+ OidIsValid(arg->fld)
|
- arg->fld != 0
+ OidIsValid(arg->fld)
|
- InvalidOid != arg->fld
+ OidIsValid(arg->fld)
|
- 0 != arg->fld
+ OidIsValid(arg->fld)
|
- arg->fld == InvalidOid
+ !OidIsValid(arg->fld)
|
- arg->fld == 0
+ !OidIsValid(arg->fld)
|
- InvalidOid == arg->fld
+ !OidIsValid(arg->fld)
|
- 0 == arg->fld
+ !OidIsValid(arg->fld)
)
...>
}

// Local variables
@transform_local_var_nested depends on collect_container && collect_catalog exists@
identifier collect_container.catalog_field;
identifier collect_catalog.fld;
type collect_container.T2;
identifier var;
@@
T2 var;
<... when any
(
- var->catalog_field->fld != InvalidOid
+ OidIsValid(var->catalog_field->fld)
|
- var->catalog_field->fld != 0
+ OidIsValid(var->catalog_field->fld)
|
- InvalidOid != var->catalog_field->fld
+ OidIsValid(var->catalog_field->fld)
|
- 0 != var->catalog_field->fld
+ OidIsValid(var->catalog_field->fld)
|
- var->catalog_field->fld == InvalidOid
+ !OidIsValid(var->catalog_field->fld)
|
- var->catalog_field->fld == 0
+ !OidIsValid(var->catalog_field->fld)
|
- InvalidOid == var->catalog_field->fld
+ !OidIsValid(var->catalog_field->fld)
|
- 0 == var->catalog_field->fld
+ !OidIsValid(var->catalog_field->fld)
)
...>

// Initialized local variables
@transform_init_local_var_nested depends on collect_container && collect_catalog exists@
identifier collect_container.catalog_field;
identifier collect_catalog.fld;
type collect_container.T2;
identifier var;
expression E1;
@@
T2 var = E1;
<... when any
(
- var->catalog_field->fld != InvalidOid
+ OidIsValid(var->catalog_field->fld)
|
- var->catalog_field->fld != 0
+ OidIsValid(var->catalog_field->fld)
|
- InvalidOid != var->catalog_field->fld
+ OidIsValid(var->catalog_field->fld)
|
- 0 != var->catalog_field->fld
+ OidIsValid(var->catalog_field->fld)
|
- var->catalog_field->fld == InvalidOid
+ !OidIsValid(var->catalog_field->fld)
|
- var->catalog_field->fld == 0
+ !OidIsValid(var->catalog_field->fld)
|
- InvalidOid == var->catalog_field->fld
+ !OidIsValid(var->catalog_field->fld)
|
- 0 == var->catalog_field->fld
+ !OidIsValid(var->catalog_field->fld)
)
...>

// Local variables
@transform_local_var_catalog depends on collect_catalog exists@
type collect_catalog.T;
identifier collect_catalog.fld;
identifier var;
@@
T var;
<... when any
(
- var->fld != InvalidOid
+ OidIsValid(var->fld)
|
- var->fld != 0
+ OidIsValid(var->fld)
|
- InvalidOid != var->fld
+ OidIsValid(var->fld)
|
- 0 != var->fld
+ OidIsValid(var->fld)
|
- var->fld == InvalidOid
+ !OidIsValid(var->fld)
|
- var->fld == 0
+ !OidIsValid(var->fld)
|
- InvalidOid == var->fld
+ !OidIsValid(var->fld)
|
- 0 == var->fld
+ !OidIsValid(var->fld)
)
...>

// Initialized local variables
@transform_catalog_var_init depends on collect_catalog exists@
identifier collect_catalog.fld;
type collect_catalog.T;
identifier var;
expression E;
@@
T var = E;
<... when any
(
- var->fld != InvalidOid
+ OidIsValid(var->fld)
|
- var->fld != 0
+ OidIsValid(var->fld)
|
- InvalidOid != var->fld
+ OidIsValid(var->fld)
|
- 0 != var->fld
+ OidIsValid(var->fld)
|
- var->fld == InvalidOid
+ !OidIsValid(var->fld)
|
- var->fld == 0
+ !OidIsValid(var->fld)
|
- InvalidOid == var->fld
+ !OidIsValid(var->fld)
|
- 0 == var->fld
+ !OidIsValid(var->fld)
)
...>
