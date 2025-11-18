// Replace InvalidOid comparisons with RegProcedureIsValid() macro
// when dealing with functions returing RegProcedure types.
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_InvalidOid_comparisons_with_RegProcedureIsValid_for_functions.cocci \
//       --dir /path/to/postgres/src \
//       --all-includes \
//       > replace.patch

// Collect all RegProcedure returning functions
@collect@
identifier func;
@@
RegProcedure func(...);

@transform depends on collect@
identifier collect.func;
expression list E;
@@
(
- func(E) == InvalidOid
+ !RegProcedureIsValid(func(E))
|
- func(E) == 0
+ !RegProcedureIsValid(func(E))
|
- func(E) != InvalidOid
+ RegProcedureIsValid(func(E))
|
- func(E) != 0
+ RegProcedureIsValid(func(E))
|
- InvalidRegProcedure == func(E)
+ !RegProcedureIsValid(func(E))
|
- 0 == func(E)
+ !RegProcedureIsValid(func(E))
|
- InvalidRegProcedure != func(E)
+ RegProcedureIsValid(func(E))
|
- 0 != func(E)
+ RegProcedureIsValid(func(E))
)
