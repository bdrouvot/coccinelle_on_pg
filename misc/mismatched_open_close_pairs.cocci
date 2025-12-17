// Detect functions that are using mismatched pairs of open/close functions:
//
// - Opening with index_open() but closing with relation_close()
// - Opening with relation_open() but closing with index_close()

// The index_close() and relation_close() functions are currently identical in
// implementation.

// However, the open functions differ: index_open() validates that the relation is
// an index, while relation_open() accepts any relation type.

// Using matching pairs improves code clarity and ensures proper validation.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@@
identifier i;
expression e;
@@
i = index_open(...);
...
- relation_close(i, e);
+ index_close(i, e);

@@
identifier i;
expression e;
@@
i = relation_open(...);
...
- index_close(i, e);
+ relation_close(i, e);
