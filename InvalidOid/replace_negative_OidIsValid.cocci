// Replace ternary operators with !OidIsValid() and negated
// OidIsValid equality to use positive logic
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Generate a patch file:
// spatch --sp-file replace_negative_OidIsValid.cocci \
//       --dir /path/to/postgres/src \
//       --include-headers \
//       > replace.patch

// Replace unnecessary parentheses around !OidIsValid() when not in ternary
@@
expression ptr;
@@
- (!OidIsValid(ptr))
+ !OidIsValid(ptr)

// Replace ternary operators with !OidIsValid() to use positive logic
@@
expression ptr, val_if_invalid, val_if_valid;
@@
- !OidIsValid(ptr) ? val_if_invalid : val_if_valid
+ OidIsValid(ptr) ? val_if_valid : val_if_invalid

// Replace negated OidIsValid equality to use positive logic
@@
expression ptr, tli;
@@
- !OidIsValid(ptr) == (tli == 0)
+ OidIsValid(ptr) == (tli != 0)

// Replace negated OidIsValid with != to use positive logic
@@
expression ptr, expr;
@@
- !OidIsValid(ptr) != expr
+ OidIsValid(ptr) == expr
