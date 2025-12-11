// Improve memory allocation by using sizeof(*var) instead of sizeof(Type),
// making the code more maintainable and less error prone.

// This is the preferred form for the Linux kernel (see [1] "Allocating memory"):
// [1]: https://www.kernel.org/doc/html/latest/process/coding-style.html

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// This one is in standby because we have
// #define palloc_array(type, count) ((type *) palloc(sizeof(type) * (count)))
// and then would produce things like:
//  - os_page_status = palloc_array(int, os_page_count);
//  + os_page_status = palloc_array(*os_page_status, os_page_count);
// which leads to "error: expected expression before ')' token" due to "(type *)"
// for this to work we'd need:
// #define palloc_array(type, count) ((typeof(type) *) palloc(sizeof(type) * (count)))
//@@
//type T;
//expression var, count;
//@@
//- var = palloc_array(T, count);
//+ var = palloc_array(*var, count);

@@
type T;
T *var;
expression E1;
@@

  var = \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\|calloc\)(
-       sizeof(T)
+       sizeof(*var)
        * E1)

@@
type T;
T *var;
expression E1;
@@

  var = \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\|calloc\)(E1 *
-       sizeof(T)
+       sizeof(*var)
        )

@@
type T;
T *var;
expression E1;
@@

  var = (T *) \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(
-       sizeof(T)
+       sizeof(*var)
        * E1)

@@
type T;
T *var;
expression E1;
@@

  var = (T *) \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(E1 *
-       sizeof(T)
+       sizeof(*var)
        )

@@
type T;
T *var;
@@

  var = \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\|calloc\)(
-       sizeof(T)
+       sizeof(*var)
        )

@@
type T;
T *var;
@@

  var = (T *) \(palloc\|palloc0\|pg_malloc\|pg_malloc0\|malloc\)(
-       sizeof(T)
+       sizeof(*var)
        )
