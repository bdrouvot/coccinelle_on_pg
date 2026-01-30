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

@@
typedef XLogRecPtr;
typedef GistNSN;
type T = {XLogRecPtr, GistNSN};
T E;
identifier i;
@@

(
- E = 0;
+ E = InvalidXLogRecPtr;
|
- T i = 0;
+ T i = InvalidXLogRecPtr;
)

