// Look for functions that cast away const qualification

// Review the outcome with care as it would produce things like:
// -       RangeType  *r1 = *(RangeType **) key1;
// +       RangeType  *r1 = *(const RangeType **) key1;
//
// Instead of
// +       RangeType  *r1 = *(RangeType *const *) key1;
// until improved.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@disable optional_qualifier@
type T, T1;
const T *i;
identifier j;
@@
(
- T1 *j = (T1 *) i;
+ const T1 *j = (const T1 *) i;
|
- (T1 *) i
+ (const T1 *) i
)
