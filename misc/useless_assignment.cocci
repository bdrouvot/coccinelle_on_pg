// This removes unnecessary initializations from variable declarations when the
// initial value is never used before being overwritten.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// To discard expression that touch the variable.
// But keep a fonction call (where the name contains the variable) with other
// variables as arguments.
@initialize:python@
@@
import re
def var_not_in_expr(var, expr):
    pattern = r'\b' + re.escape(var) + r'\b'
    return re.search(pattern, expr) is None

@find_candidates@
type T1 != T*;
identifier i;
expression E != NULL;
position p;
@@
  T1 i@p = E;

@var_at_label exists@
identifier find_candidates.i;
identifier label;
expression E1;
type T1;
expression E;
position find_candidates.p;
@@
(
  T1 i@p = E;
  ... when != i = E1
  goto label;
  ...
  label:
  ... when != i = ...
  i
|
  T1 i@p = E;
  ...
  goto label;
  ...
  i = E1;
  ...
  label:
  ... when != i = ...
  i
)

@has_reassignment@
identifier find_candidates.i;
expression E1 : script:python(i) { var_not_in_expr(i, E1) };
position find_candidates.p;
type T1;
expression E;
@@
  T1 i@p = E;
  ... when != i
  i = E1;

@removal depends on has_reassignment && !var_at_label@
type T;
type T1 != T*;
identifier find_candidates.i;
expression E1 : script:python(i) { var_not_in_expr(i, E1) };
expression E != NULL;
position find_candidates.p;
@@
- T1 i@p = E;
+ T1 i;
  ... when != i
  i = E1;
  ... when any
      when != return i;
