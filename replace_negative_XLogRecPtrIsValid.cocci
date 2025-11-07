// Replace ternary operators with !XLogRecPtrIsValid() and negated
// XLogRecPtrIsValid equality to use positive logic
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Generate a patch file:
// spatch --sp-file replace_negative_XLogRecPtrIsValid.cocci \
//       --dir /path/to/postgres/src \
//       --include-headers \
//       > replace.patch

// Replace ternary operators with !XLogRecPtrIsValid() to use positive logic
@@
expression ptr, val_if_invalid, val_if_valid;
@@
- !XLogRecPtrIsValid(ptr) ? val_if_invalid : val_if_valid
+ XLogRecPtrIsValid(ptr) ? val_if_valid : val_if_invalid

// Replace unnecessary parentheses around !XLogRecPtrIsValid() when not in ternary
@@
expression ptr;
@@
- (!XLogRecPtrIsValid(ptr))
+ !XLogRecPtrIsValid(ptr)

// Replace negated XLogRecPtrIsValid equality to use positive logic
@@
expression ptr, tli;
@@
- !XLogRecPtrIsValid(ptr) == (tli == 0)
+ XLogRecPtrIsValid(ptr) == (tli != 0)
