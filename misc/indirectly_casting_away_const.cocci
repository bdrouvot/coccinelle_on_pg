// Look for functions that cast away const qualification when returning
// a pointer that refers to (or is derived from) data accessed through a const
// qualified pointer parameter.

// Then, add const back (if needed) to variables that receive pointers from those
// or some known functions.

// It added a few in 8f1791c6183 (but needs to be improved to detect the ones
// in formatting.c and the match_start and match_end ones in win32setlocale.c)

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@collect_direct disable optional_qualifier forall@
identifier func;
type T;
identifier arg;
position p;
@@
T *
func@p (..., const T *arg, ...)
{
<+...
return (T*) arg;
...+>
}

// Found skip_drive (path.c)
@script:python@
func << collect_direct.func;
p << collect_direct.p;
@@
print(f"Found direct: {func} at {p[0].file}:{p[0].line}")

// Found bsearch_arg (bsearch_arg.c)
@collect_indirect disable optional_qualifier exists@
identifier func;
type T, T2;
identifier arg, intermediate;
expression e;
position p;
@@
T *
func (..., const T *arg, ...)
{
...
(
  e = <+... arg ...+>;
|
  T2 intermediate = <+... arg ...+>;
  ...
  e = <+... intermediate ...+>;
|
  intermediate = <+... arg ...+>;
  ...
  e = <+... intermediate ...+>;
)
...
return@p (T*) e;
...
}

@script:python@
func << collect_indirect.func;
p << collect_indirect.p;
@@
print(f"Found indirect: {func} at {p[0].file}:{p[0].line}")

// Add const back to variables that receive pointers from some known functions
@r1 disable optional_qualifier forall@
identifier ptr;
const char *str;
identifier func =~ "^(strchr|strrchr|strstr|strpbrk|strcasestr|strchrnul|skip_drive)$";
@@

- char
+ const char 
  *ptr = func(str, ...); 

@r2 disable optional_qualifier forall@
identifier ptr;
const char *str;
identifier func =~ "^(strchr|strrchr|strstr|strpbrk|strcasestr|strchrnul|skip_drive)$";
@@

- char *ptr;
+ const char *ptr;
<+... 
ptr = func(str, ...)
...+>

@r3 disable optional_qualifier forall@
const char *str;
type T = char*;
T ptr;
identifier func =~ "^(strchr|strrchr|strstr|strpbrk|strcasestr|strchrnul|skip_drive)$";
position p;
@@
<+...
ptr@p = func(str, ...)
...+>

@script:python@
p << r3.p;
ptr << r3.ptr;
func << r3.func;
@@

print(f"{p[0].file}:{p[0].line}: assignment discards const qualifier from pointer target type")
print(f"  Suggestion: change 'char *{ptr}' to 'const char *{ptr}'")

// Add const back to variables that receive pointers from some known functions
@b1 disable optional_qualifier forall@
identifier ptr;
expression key, nmemb, size, compar;
type T;
identifier m;
const T *arr;
identifier func =~ "^(bsearch|bsearch_arg)$";
@@

- void
+ const void
  *ptr = func(key, arr->m, nmemb, size, compar, ...);

@b2 disable optional_qualifier forall@
identifier ptr;
expression key, nmemb, size, compar;
type T;
identifier m;
const T *arr;
identifier func =~ "^(bsearch|bsearch_arg)$";
@@

- void *ptr;
+ const void *ptr;
<+...
ptr = func(key, arr->m, nmemb, size, compar, ...)
...+>

@b3 disable optional_qualifier forall@
expression key, nmemb, size, compar;
type T;
type T1 = void*;
identifier m;
const T *arr;
position p;
T1 ptr;
identifier func =~ "^(bsearch|bsearch_arg)$";
@@

ptr@p = func(key, arr->m, nmemb, size, compar, ...)

@script:python@
p << b3.p;
ptr << b3.ptr;
@@

print(f"{p[0].file}:{p[0].line}: assignment discards const qualifier from pointer target type")
print(f"  Suggestion: change 'void *{ptr}' to 'const void *{ptr}'")

@b32 disable optional_qualifier forall@
type T, T2;
const T2 *arr;
identifier m;
type T1 = T*;
T key;
position p;
T1 ptr;
identifier func =~ "^(bsearch|bsearch_arg)$";
@@

ptr@p = (T1) func(&key, arr->m, ...)

@script:python@
p << b32.p;
ptr << b32.ptr;
T << b32.T;
@@

print(f"{p[0].file}:{p[0].line}: assignment discards const qualifier from pointer target type")
print(f"  Suggestion: change '{T} *{ptr}' to 'const {T} *{ptr}'")

// Add const back to variables that receive pointers from the collected functions
@c1 disable optional_qualifier forall@
identifier collect_direct.func;
identifier ptr;
type T;
const T *arg;
@@

- T
+ const T
  *ptr = func(..., arg, ...);

@c2 disable optional_qualifier forall@
identifier collect_direct.func;
identifier ptr;
type T;
const T *arg;
@@

- T *ptr;
+ const T *ptr;
<+...
ptr = func(..., arg, ...)
...+>

@c22 disable optional_qualifier forall@
type T = collect_direct.T;
const T *arg;
T *ptr;
identifier func = collect_direct.func;
position p;
@@

ptr@p = func(..., arg, ...)

@script:python@
p << c22.p;
ptr << c22.ptr;
func << c22.func;
T << c22.T;
@@

print(f"{p[0].file}:{p[0].line}: assignment discards const qualifier from pointer target type")
print(f"  Suggestion: change '{T} *{ptr}' to 'const {T} *{ptr}'")

@c3 disable optional_qualifier forall@
identifier collect_indirect.func;
identifier ptr;
type T;
const T *arg;
@@

- T
+ const T
  *ptr = func(..., arg, ...);

@c32 disable optional_qualifier forall@
type T = collect_indirect.T;
const T *arg;
T *ptr;
identifier func = collect_indirect.func;
position p;
@@

ptr@p = func(..., arg, ...)

@script:python@
p << c32.p;
ptr << c32.ptr;
func << c32.func;
T << c32.T;
@@

print(f"{p[0].file}:{p[0].line}: assignment discards const qualifier from pointer target type")
print(f"  Suggestion: change '{T} *{ptr}' to 'const {T} *{ptr}'")

@c4 disable optional_qualifier forall@
identifier collect_indirect.func;
identifier ptr;
type T;
const T *arg;
@@

- T *ptr;
+ const T *ptr;
<+...
ptr = func(..., arg, ...)
...+>
