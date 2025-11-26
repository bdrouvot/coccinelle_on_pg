// Detect dead branches where a condition is contradicted within the same branch
// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Note: review with care the output as it generates false positive
// It would have detected 3b9c1189205 (which is fine)
// All the others reported at the time of 8fe4aef8297 are false positive

@@
expression E;
statement S;
@@
if (E) {
... when != E
* if (!E) S
...
}

@@
expression E1, E2;
statement S;
@@
(
if (E1 < E2) {
... when != E1
    when != E2
* if (E1 >= E2) S
...
}
|
if (E1 <= E2) {
... when != E1
    when != E2
* if (E1 > E2) S
...
}
|
if (E1 == E2) {
... when != E1
    when != E2
* if (E1 != E2) S
...
}
)
