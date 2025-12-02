// Search for pointer updates when the pointer is not used after the update.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Note that it may generate false positive (like when E is a function call)
// so manual review is needed.

@f_call@
type T;
local idexpression T* ptr;
identifier func;
@@
  ptr += func(..., ptr, ...)

@r depends on !f_call@
type T;
local idexpression T* ptr;
expression E;
@@

- ptr += E;
  ... when != ptr
