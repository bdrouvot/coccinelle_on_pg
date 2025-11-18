// Replace InvalidOid comparisons with OidIsValid() macro
// when dealing with functions returing Oid types.
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_InvalidOid_comparisons_with_OidIsValid_for_functions.cocci \
//       --dir /path/to/postgres/src \
//       --all-includes \
//       > replace.patch

// Collect all Oid returning functions
@collect@
identifier func;
@@
Oid func(...);

@transform depends on collect@
identifier collect.func;
expression list E;
@@
(
- func(E) == InvalidOid
+ !OidIsValid(func(E))
|
- func(E) == 0
+ !OidIsValid(func(E))
|
- func(E) != InvalidOid
+ OidIsValid(func(E))
|
- func(E) != 0
+ OidIsValid(func(E))
|
- InvalidOid == func(E)
+ !OidIsValid(func(E))
|
- 0 == func(E)
+ !OidIsValid(func(E))
|
- InvalidOid != func(E)
+ OidIsValid(func(E))
|
- 0 != func(E)
+ OidIsValid(func(E))
)
