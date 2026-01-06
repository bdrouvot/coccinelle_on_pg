// Remove useless casting to same type

// This removes some casts where the input already has the same type as the type
// specified by the cast. Their presence could cause risks of hiding actual type
// mismatches in the future or silently discarding qualifiers.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@@
type T;
T E;
@@

- (T)
  E
