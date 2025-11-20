// Remove useless casts to (void *)
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Their presence causes (small) risks of hiding actual type mismatches or
// silently discarding qualifiers.

@find_func@
type T;
identifier func;
identifier arg;
@@
T func(..., void *arg, ...);

@transform depends on find_func exists@
//@transform@
identifier find_func.func;
//identifier func;
identifier arg;
@@

func(...,
(
- (void *) arg
+ arg
|
- (void *) &arg
+ &arg
)
,...)

@@
type T = void*;
T x;
type T1;
T1 *E;
@@

x =
-  (T)
    E;
