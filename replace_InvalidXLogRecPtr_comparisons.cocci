// Replace InvalidXLogRecPtr comparisons with XLogRecPtrIsValid() macro
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file
//
// Generate a patch file:
// spatch --sp-file replace_InvalidXLogRecPtr_comparisons.cocci \
//       --dir /path/to/postgres/src \
//       --include-headers \
//       > replace.patch

// Replace comparisons for simple identifiers only
// Using idexpression ensures we don't match complex expressions like (x % y)
@@
idexpression L;
@@
(
- L == InvalidXLogRecPtr
+ !XLogRecPtrIsValid(L)
|
- InvalidXLogRecPtr == L
+ !XLogRecPtrIsValid(L)
|
- L != InvalidXLogRecPtr
+ XLogRecPtrIsValid(L)
|
- InvalidXLogRecPtr != L
+ XLogRecPtrIsValid(L)
)

// Replace comparisons for pointers
@@
expression E1;
identifier member;
@@
(
- E1->member == InvalidXLogRecPtr
+ !XLogRecPtrIsValid(E1->member)
|
- InvalidXLogRecPtr == E1->member
+ !XLogRecPtrIsValid(E1->member)
|
- E1->member != InvalidXLogRecPtr
+ XLogRecPtrIsValid(E1->member)
|
- InvalidXLogRecPtr != E1->member
+ XLogRecPtrIsValid(E1->member)
)

// Replace comparisons for struct.member
@@
expression E1;
identifier member;
@@
(
- E1.member == InvalidXLogRecPtr
+ !XLogRecPtrIsValid(E1.member)
|
- InvalidXLogRecPtr == E1.member
+ !XLogRecPtrIsValid(E1.member)
|
- E1.member != InvalidXLogRecPtr
+ XLogRecPtrIsValid(E1.member)
|
- InvalidXLogRecPtr != E1.member
+ XLogRecPtrIsValid(E1.member)
)

// Replace comparisons for dereferenced pointers
@@
expression E1;
@@
(
- *E1 == InvalidXLogRecPtr
+ !XLogRecPtrIsValid(*E1)
|
- InvalidXLogRecPtr == *E1
+ !XLogRecPtrIsValid(*E1)
|
- *E1 != InvalidXLogRecPtr
+ XLogRecPtrIsValid(*E1)
|
- InvalidXLogRecPtr != *E1
+ XLogRecPtrIsValid(*E1)
)

// Replace explicit function call patterns
@@
identifier func;
expression list args;
@@
(
- func(args) == InvalidXLogRecPtr
+ !XLogRecPtrIsValid(func(args))
|
- InvalidXLogRecPtr == func(args)
+ !XLogRecPtrIsValid(func(args))
|
- func(args) != InvalidXLogRecPtr
+ XLogRecPtrIsValid(func(args))
|
- InvalidXLogRecPtr != func(args)
+ XLogRecPtrIsValid(func(args))
)
