// Remove unused function parameters
// It tries to detect callbacks and discard them
// It focus only on static functions

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// Note that it may generate false positive so manual review is needed.
// For example, it would detect restart_lsn in create_logical_replication_slot()
// as unused because it does not detect it's being used in the CreateInitDecodingContext()
// call (due to the XL_ROUTINE macro)

// Also note that if multiple parameters are unused, multiple executions are needed.

@initialize:python@
@@

protected_types = {'FmgrInfo', 'FunctionCallInfo'}
param_info = {}  # Maps (file, func) -> (position, param_name)

// Find all functions with unused parameters
@r disable optional_storage forall@
type RT, T;
identifier fn, unused;
parameter list ps1, ps2;
position p;
@@

static RT fn(ps1, T unused@p, ps2) {
  ... when != unused
      when strict
}

// Check if this specific function is used as a callback
@is_callback@
identifier r.fn;
identifier other_func;
@@

(
other_func(..., fn, ...)
|
other_func(..., &fn, ...)
)

// Check if this specific function is assigned to pointer
@is_callback_assign@
identifier r.fn;
expression str;
identifier f;
@@

(
str->f = fn;
|
str->f = &fn;
|
str.f = &fn;
|
str.f = fn;
)

// Check if this specific function is in struct/array initializer
@is_callback_init@
identifier r.fn;
type T;
identifier I;
@@
(
  T I = { fn };
|
  T I = { fn, ... };
|
  T I = { ..., fn };
|
  T I = { ..., fn, ... };
)

@is_struct_init@
identifier r.fn;
type T;
identifier I, f;
@@
  T I = {
   .f = fn,
  };

// Now discard unwanted ones
@script:python check depends on r && !is_callback && !is_callback_assign && !is_callback_init &&!is_struct_init@
fn << r.fn;
unused << r.unused;
ps1 << r.ps1;
T << r.T;
p << r.p;
@@

fn_name = str(fn)
param_name = str(unused)
param_type = str(T)
filename = p[0].file

# Calculate parameter position
ps1_str = str(ps1).strip()
param_position = 0
if ps1_str:
    param_position = ps1_str.count(',') + 1

# Check if protected type
if any(pt in param_type for pt in protected_types):
    cocci.include_match(False)
else:
    key = (filename, fn_name)
    param_info[key] = (param_position, param_name)
    print("Will remove parameter '%s' at position %d in %s()" % (param_name, param_position, fn_name))

// Remove parameters: single parameter becomes (void)
@remove_single depends on check@
type r.RT, r.T;
identifier r.fn, r.unused;
@@

-static RT fn(T unused)
+static RT fn(void)
 {
  ...
}

// Remove parameters: multiple parameters
@remove_multi depends on check@
type r.RT, r.T;
identifier r.fn, r.unused;
parameter list r.ps1, r.ps2;
@@

static RT fn(ps1,
-T unused,
ps2) {
  ...
}

//// Now update the callers ////

// Remove first argument (position 0)
@call_remove_first@
identifier fn;
expression e1;
expression list[n] es;
position p;
@@

fn@p(e1, es)

@script:python check_remove_first@
fn << call_remove_first.fn;
p << call_remove_first.p;
@@

fn_name = str(fn)
call_file = p[0].file
key = (call_file, fn_name)

if key in param_info and param_info[key][0] == 0:
    print("Removing first argument from call to %s()" % fn_name)
else:
    cocci.include_match(False)

@do_remove_first depends on check_remove_first@
identifier call_remove_first.fn;
expression call_remove_first.e1;
expression list call_remove_first.es;
@@

-fn(e1, es)
+fn(es)

// Remove if it is the only argument
@call_remove_only@
identifier fn;
expression e1;
position p;
@@

fn@p(e1)

@script:python check_remove_only@
fn << call_remove_only.fn;
p << call_remove_only.p;
@@

fn_name = str(fn)
call_file = p[0].file
key = (call_file, fn_name)

if key in param_info and param_info[key][0] == 0:
    print("Removing only argument from call to %s()" % fn_name)
else:
    cocci.include_match(False)

@do_remove_only depends on check_remove_only@
identifier call_remove_only.fn;
expression call_remove_only.e1;
@@

-fn(e1)
+fn()

// Remove if it is last argument
@call_remove_last@
identifier fn;
expression list[n] es;
expression e_last;
position p;
@@

fn@p(es, e_last)

@script:python check_remove_last@
fn << call_remove_last.fn;
es << call_remove_last.es;
p << call_remove_last.p;
@@

fn_name = str(fn)
call_file = p[0].file
key = (call_file, fn_name)

if key not in param_info:
    cocci.include_match(False)
else:
    # Count how many expressions in es
    es_str = str(es).strip()
    if es_str:
        num_before = es_str.count(',') + 1
    else:
        num_before = 0
    
    target_position = param_info[key][0]
    
    # Last argument is at position = num_before
    if target_position == num_before:
        print("Removing last argument from call to %s()" % fn_name)
    else:
        cocci.include_match(False)

@do_remove_last depends on check_remove_last@
identifier call_remove_last.fn;
expression list call_remove_last.es;
expression call_remove_last.e_last;
@@

-fn(es, e_last)
+fn(es)

// Remove if it is a middle argument
@call_remove_middle@
identifier fn;
expression list[n1] es1;
expression e_middle;
expression list[n2] es2;
position p;
@@

fn@p(es1, e_middle, es2)

@script:python check_remove_middle@
fn << call_remove_middle.fn;
es1 << call_remove_middle.es1;
es2 << call_remove_middle.es2;
p << call_remove_middle.p;
@@

fn_name = str(fn)
call_file = p[0].file
key = (call_file, fn_name)

if key not in param_info:
    cocci.include_match(False)
else:
    # Count position
    es1_str = str(es1).strip()
    if es1_str:
        num_before = es1_str.count(',') + 1
    else:
        num_before = 0
    
    target_position = param_info[key][0]
    
    # Middle argument is at position = num_before
    if target_position == num_before and num_before > 0:
        es2_str = str(es2).strip()
        # Make sure there are args after
        if es2_str:
            print("Removing middle argument at position %d from call to %s()" % (target_position, fn_name))
        else:
            cocci.include_match(False)
    else:
        cocci.include_match(False)

@do_remove_middle depends on check_remove_middle@
identifier call_remove_middle.fn;
expression list call_remove_middle.es1;
expression call_remove_middle.e_middle;
expression list call_remove_middle.es2;
@@

-fn(es1, e_middle, es2)
+fn(es1, es2)
