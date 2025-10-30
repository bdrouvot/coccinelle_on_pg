// Replace XLogRecPtrIsInvalid() with XLogRecPtrIsValid() macro
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Generate a patch file:
// spatch --sp-file replace_XLogRecPtrIsInvalid.cocci \
//       --dir /path/to/postgres/src \
//       --include-headers \
//       > replace.patch

// Replace !XLogRecPtrIsInvalid() with XLogRecPtrIsValid().
// To avoid double negation, this must come before the non negated rule
@@
expression E;
@@
- !XLogRecPtrIsInvalid(E)
+ XLogRecPtrIsValid(E)

// Replace XLogRecPtrIsInvalid() with !XLogRecPtrIsValid()
@@
expression E;
@@
- XLogRecPtrIsInvalid(E)
+ !XLogRecPtrIsValid(E)
