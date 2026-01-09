// Detect direct nodeTag comparisons that could use the IsA() macro.
//
// This script identifies patterns like:
// - nodeTag(e) == T_SomeType  →  should use IsA(e, SomeType)
// - nodeTag(e) != T_SomeType  →  should use !IsA(e, SomeType)

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@@
identifier i;
expression e;
@@
* nodeTag(e) == i

@@
identifier i;
expression e;
@@
* nodeTag(e) != i
