// Mark function arguments of type "T *" as "const T *" where possible
// Several functions in the codebase accept "T *" parameters but do
// not modify the pointed-to data.  These have been updated to take "const T *"
// instead, improving type safety and making the interfaces clearer about their intent.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// The script currently produces some false positive so:
// Manually remove those that produce -Wdiscarded-qualifiers warnings
// Manually remove those that produce new -Wcast-qual warnings

@find_const_candidate disable optional_qualifier forall@
type T, T2, T3;
type T1 != T2*;
identifier fn;
identifier values, fld, fld2, fld3, other;
expression list args1, args2;
expression E;
assignment operator aop;
position p;
@@
  static T fn(...,
  T1 *values@p,
  ...)
  {
    ... when != values[...] aop ...
        when != values->fld[...] aop ...
        when != values->fld.fld2[...].fld3 aop ...
        when != *values aop ...
        when != (*values) aop ...
        when != values->fld aop ...
        when != values->fld.fld2 aop ...
        when != values->fld.fld2.fld3 aop ...
        when != values->fld.fld2.fld3++
        when != values->fld.fld2.fld3--
        when != ++values->fld.fld2.fld3
        when != --values->fld.fld2.fld3
        when != *values++
        when != (*values)++
        when != *values--
        when != (*values)--
        when != *++values
        when != ++(*values)
        when != *--values
        when != --(*values)
        when != *(values + ...) = ...
        when != values->fld++
        when != values->fld--
        when != ++values->fld
        when != --values->fld
        when != values->fld.fld2++
        when != values->fld.fld2--
        when != other = values
        when != other = (T3)values
        when != other = (T3 *)values
        when != E.fld = values
        when != E->fld = values
        when != &values
        when != return values;
        when != E(args1, values, args2)
        when != E(args1, values->fld, args2)
        when != E(args1, *values, args2)
        when != E(args1, &values, args2)
        when != E(args1, &values->fld, args2)
        when != values->fld[...].fld2 aop ...
        when != values->fld[...].fld2++
        when != values->fld[...].fld2--
        when != ++values->fld[...].fld2
        when != --values->fld[...].fld2
		when != values->fld[...]++
		when != values->fld[...]--
        when strict
}

// Detect functions where return involves cast or arithmetic on parameter
@returns_with_cast exists@
identifier find_const_candidate.fn;
type find_const_candidate.T;
type find_const_candidate.T1;
identifier find_const_candidate.values;
type T2, T3;
expression E;
position find_const_candidate.p;
@@
  static T fn(..., T1 *values@p, ...)
  {
    ...
(
  return (T2)values;
|
  return (T2)((T3)values + E);
|
  return (T2 *)((T3)values + E);  
|
  return (T2)(values + E);
|
  return (T2)(E + values);
|
  return values + E;
|  
  return E + values;
)
    ...
  }

// Exclude if parameter is completely unused
@is_unused@
type find_const_candidate.T, find_const_candidate.T1;
identifier find_const_candidate.fn;
identifier find_const_candidate.values;
position find_const_candidate.p;
parameter list ps1, ps2;
@@
  T fn(ps1, T1 *values@p, ps2) {
    ... when != values
        when strict
  }

// Check if this function is used as a callback (passed to another function)
@is_callback@
identifier find_const_candidate.fn;
identifier other_func;
@@
(
other_func(..., fn, ...)
|
other_func(..., &fn, ...)
)

// Check if this function is assigned to a function pointer
@is_callback_assign@
identifier find_const_candidate.fn;
expression str;
identifier f;
@@
(
str->f = fn;
|
str->f = &fn;
|
str.f = &fn;
|
str.f = fn;
)

// Check if this function is in struct/array initializer
@is_callback_init@
identifier find_const_candidate.fn;
type T;
identifier I;
@@
(
  T I = { fn };
|
  T I = { fn, ... };
|
  T I = { ..., fn };
|
  T I = { ..., fn, ... };
)

// Check if this function is in designated struct initializer
@is_struct_init@
identifier find_const_candidate.fn;
type T;
identifier I, f;
@@
  T I = {
   .f = fn,
  };

// Apply the transformation to function definitions
@add_const depends on find_const_candidate && !returns_with_cast && !is_unused && !is_callback && !is_callback_assign && !is_callback_init && !is_struct_init@
type find_const_candidate.T, find_const_candidate.T1;
identifier find_const_candidate.fn;
identifier find_const_candidate.values;
position find_const_candidate.p;
@@
  T fn(...,
- T1
+ const T1
  *values@p,
  ...)
  {
    ...
}

// Also update function declarations 
@add_const_decl depends on find_const_candidate && !returns_with_cast && !is_unused && !is_callback && !is_callback_assign && !is_callback_init && !is_struct_init@
type find_const_candidate.T, find_const_candidate.T1;
identifier find_const_candidate.fn;
identifier find_const_candidate.values;
parameter list ps1, ps2;
@@
  T fn(ps1,
- T1 *values
+ const T1 *values
  , ps2);
