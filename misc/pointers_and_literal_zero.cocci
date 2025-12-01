// Search for pointers comparisons or assignments with literal zero
// While 0 is technically correct, NULL is the semantically appropriate choice
// for pointers.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@r disable is_zero,isnt_zero@
expression *E;
position p;
@@
(
  E@p == 0
|
  E@p != 0
|
  0 == E@p
|
  0 != E@p
|
  E@p = 0
|
  0 = E@p
)

@@
position r.p;
expression *E;
@@

*E@p
