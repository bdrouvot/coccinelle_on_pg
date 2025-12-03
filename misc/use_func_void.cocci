// Use func(void) for functions with no parameters

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// In C standards till C17, func() means "unspecified parameters" while func(void)
// means "no parameters". The former disables compile time type checking and was
// marked obsolescent in C99.

// This script replaces empty parameter lists with explicit void to enable proper
// type checking and eliminate possible undefined behavior if the function is called
// with parameters. This also prevents real bugs (API misuse for example).

// Note: C23 made func() and func(void) equivalent.

// C99: https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1256.pdf (§6.11.6 and §6.5.2.2/6)
// C23: https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3220.pdf (§6.7.6.3)

@@
type RT;
identifier fn != main;
@@
  RT
- fn()
+ fn(void)
{
    ...
}

@@
type RT;
identifier fn != main;
@@
  RT
- fn();
+ fn(void);
