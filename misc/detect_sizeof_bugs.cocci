// Replace sizeof(WrongType) with sizeof(CorrectType) when types don't match
// Would have fixed 3f83de20ba2 and 06761b6096b

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Note that it may generate false positive (due to typedef and const) so manual
// review is needed.

@fix_mismatch@
type T1 != void;
type T2 != T1;
T1 *var;
expression E;
@@

(
  var = \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\|calloc\)(
-       sizeof(T2)
+       sizeof(T1)
        * E);
|
  var = \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\|calloc\)(E *
-       sizeof(T2)
+       sizeof(T1)
        );
|
  var = \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\|calloc\)(
-       sizeof(T2)
+       sizeof(T1)
        );
|
  var = (T1 *) \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(
-       sizeof(T2)
+       sizeof(T1)
        * E);
|
  var = (T1 *) \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(E *
-       sizeof(T2)
+       sizeof(T1)
        );
|
  var = (T1 *) \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(
-       sizeof(T2)
+       sizeof(T1)
        );
)

@fix_wrong_cast@
type T1 != void;
type T2 != T1;
type T3 != T1;
T1 *var;
expression E;
@@

(
  var = 
- (T2 *)
+ (T1 *)
  \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(
-       sizeof(T3)
+       sizeof(T1)
        * E);
|
  var = 
- (T2 *)
+ (T1 *)
  \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(E *
-       sizeof(T3)
+       sizeof(T1)
        );
|
  var = 
- (T2 *)
+ (T1 *)
  \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(
-       sizeof(T3)
+       sizeof(T1)
        );
)
