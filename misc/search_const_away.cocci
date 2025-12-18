// Look for functions that cast away const qualification in local variables.

// Idea is to add const to local variables in functions that only read their
// input parameters, preserving the const qualifiers from the function signatures.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@disable optional_qualifier forall@
identifier func;
type T;
identifier arg, ptr;
position p;
type T1;
@@
func@p (..., const T *arg, ...)
{
...
* T1 *ptr = (T1 *) arg;
...
}

@disable optional_qualifier forall@
identifier func;
type T;
identifier arg;
position p;
type T1;
T1 *ptr;
@@
func@p (..., const T *arg, ...)
{
...
* ptr = (T1 *) arg;
...
}
