// Remove unused struct fields

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

// It generates a lot of false positive (needs to be improved) so manual
// review is needed.
// Better to invoke with: -I ~/postgresql/postgres/src/include \
//                        --recursive-includes --preprocess

@anon@
identifier field_name;
type typedef_name;
type T;
position p;
@@
  typedef struct {
    ...
    T field_name@p;
    ...
  } typedef_name;

@def_named@
identifier struct_name, field_name;
type typedef_name;
type T;
position p, struct_pos;
@@
  typedef struct struct_name@struct_pos {
    ...
    T field_name@p;
    ...
  } typedef_name;

@named@
identifier field_name;
type def_named.typedef_name;
identifier struct_name != typedef_name;
type T;
position p, struct_pos;
@@
  struct struct_name@struct_pos {
    ...
    T field_name@p;
    ...
  };

// Match plain named structs (no typedef)
// Exclude positions that were matched by def_named
@plain_named@
identifier struct_name, field_name;
type T;
position p, struct_pos != def_named.struct_pos;
@@
  struct struct_name@struct_pos {
    ...
    T field_name@p;
    ...
  };

// Match field access for named struct fields
@named_ptr depends on named@
identifier named.field_name;
expression E;
@@
  E->field_name

@named_direct depends on named@
identifier named.field_name;
expression E;
@@
  E.field_name

// Match field access for plain named struct fields
@plain_named_ptr depends on plain_named@
identifier plain_named.field_name;
expression E;
@@
  E->field_name

@plain_named_direct depends on plain_named@
identifier plain_named.field_name;
expression E;
@@
  E.field_name

// Match field access for typedef anonymous struct fields
@anon_ptr depends on anon@
identifier anon.field_name;
expression E;
@@
  E->field_name

@anon_direct depends on anon@
identifier anon.field_name;
expression E;
@@
  E.field_name

// Match field access for typedef named struct fields
@def_named_ptr depends on def_named@
identifier def_named.field_name;
expression E;
position p != named.p;
@@
  E->field_name@p

@def_named_direct depends on def_named@
identifier def_named.field_name;
expression E;
@@
  E.field_name

@named_hash depends on named@
identifier named.struct_name;
HASHCTL     ctl;
@@
  ctl.entrysize = sizeof(struct struct_name);

@anon_hash depends on anon@
type anon.typedef_name;
HASHCTL     ctl;
@@
  ctl.entrysize = sizeof(typedef_name);

@def_named_hash depends on def_named@
type def_named.typedef_name;
HASHCTL     ctl;
@@
  ctl.entrysize = sizeof(typedef_name);

// Match hash usage for plain named structs
@plain_named_hash depends on plain_named@
identifier plain_named.struct_name;
HASHCTL     ctl;
@@
  ctl.entrysize = sizeof(struct struct_name);

// Remove unused fields from named structs (with typedef)
@remove_named_struct depends on
  !named_ptr &&
  !named_direct &&
  !named_hash &&
  !def_named_hash@
identifier named.struct_name, named.field_name;
position named.struct_pos = def_named.struct_pos;
type T;
@@
  struct struct_name@struct_pos {
    ...
-   T field_name;
    ...
  };

// Remove unused fields from plain named structs (no typedef)
@remove_plain_named_struct depends on
  !plain_named_ptr &&
  !plain_named_direct &&
  !plain_named_hash@
identifier plain_named.struct_name, plain_named.field_name;
type T;
@@
  struct struct_name {
    ...
-   T field_name;
    ...
  };

// Remove unused fields from typedef anonymous structs
@remove_typedef_anon depends on
  !anon_ptr &&
  !anon_direct &&
  !anon_hash@
identifier anon.field_name;
type typedef_name;
type T;
@@
  typedef struct {
    ...
-   T field_name;
    ...
  } typedef_name;

// Remove unused fields from typedef named structs
@remove_typedef_named depends on
  !def_named_ptr &&
  !def_named_direct &&
  !def_named_hash@
identifier def_named.struct_name, def_named.field_name;
type typedef_name;
type T;
@@
  typedef struct struct_name {
    ...
-   T field_name;
    ...
  } typedef_name;
