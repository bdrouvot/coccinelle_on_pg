// Detect functions where const was incorrectly added i.e where the function
// modifies data through non const nested pointers or struct members, making
// the const qualification misleading.

// Author: Bertrand Drouvot
// Licensed under the PostgreSQL license
// For license terms, see the LICENSE file

@find_for exists@
identifier func, param, ptr, member;
type T, T2, RT;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr;
  for (ptr = param->member; ...; ...)
  {
    ...
    *ptr = ...;
    ...
  }
  ...
}

@find_init exists@
identifier func, param, ptr, member;
type T, T2, RT;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr = param->member;
  ...
  *ptr = ...;
  ...
}

@find_assign exists@
identifier func, param, ptr, member;
type T, T2, RT;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr;
  ...
  ptr = param->member;
  ...
  *ptr = ...;
  ...
}

@find_array exists@
identifier func, param, ptr, member;
type T, T2, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr = param->member;
  ...
  ptr[E] = ...;
  ...
}

@find_incdec exists@
identifier func, param, ptr, member;
type T, T2, RT;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr = param->member;
  ...
(
  (*ptr)++
|
  (*ptr)--
|
  ++(*ptr)
|
  --(*ptr)
)
  ...
}

@find_funcall exists@
identifier func, param, ptr, member;
type T, T2, RT;
position p;
identifier other_func !~ "^(printf|fprintf|sprintf|snprintf|vprintf|vfprintf|vsprintf|vsnprintf|ereport|elog|errmsg|errdetail|errhint|errcode|errmsg_plural|appendStringInfo|appendStringInfoString|appendStringInfoChar|appendBinaryStringInfo|appendPQExpBuffer|appendPQExpBufferStr|appendPQExpBufferChar|psprintf|pstrdup|pnstrdup|strcmp|strncmp|strcasecmp|strncasecmp|pg_strcasecmp|pg_strncasecmp|strlen|strnlen|pg_mbstrlen|strstr|strchr|strrchr|strspn|strcspn|strpbrk|atoi|atol|atof|strtol|strtoul|strtod|strtoll|strtoull|memcmp|memcpy|memmove|pg_char_to_encoding|pg_encoding_to_char|quote_identifier|quote_literal_cstr|atooid|DatumGetCString|TextDatumGetCString|ahprintf|skip_drive|fmtId|pg_fatal|pg_log_error|pg_log_warning|pg_log_info|sanitize_line|strcpy|strncpy|strlcpy|strcat|strncat|pg_free|free|XLogArchiveCleanup|ReindexMultipleInternal|Assert|get_namespace_oid|aclcheck_error|get_tsearch_config_filename)$";
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr = param->member;
  ...
  other_func(..., ptr, ...);
  ...
}

@find_funcall2 exists@
identifier func, param, ptr, member;
type T, T2, RT;
position p;
identifier other_func !~ "^(printf|fprintf|sprintf|snprintf|vprintf|vfprintf|vsprintf|vsnprintf|ereport|elog|errmsg|errdetail|errhint|errcode|errmsg_plural|appendStringInfo|appendStringInfoString|appendStringInfoChar|appendBinaryStringInfo|appendPQExpBuffer|appendPQExpBufferStr|appendPQExpBufferChar|psprintf|pstrdup|pnstrdup|strcmp|strncmp|strcasecmp|strncasecmp|pg_strcasecmp|pg_strncasecmp|strlen|strnlen|pg_mbstrlen|strstr|strchr|strrchr|strspn|strcspn|strpbrk|atoi|atol|atof|strtol|strtoul|strtod|strtoll|strtoull|memcmp|memcpy|memmove|pg_char_to_encoding|pg_encoding_to_char|quote_identifier|quote_literal_cstr|atooid|DatumGetCString|TextDatumGetCString|ahprintf|skip_drive|fmtId|pg_fatal|pg_log_error|pg_log_warning|pg_log_info|sanitize_line|strcpy|strncpy|strlcpy|strcat|strncat|pg_free|free|XLogArchiveCleanup|ReindexMultipleInternal|Assert|get_namespace_oid|aclcheck_error|get_tsearch_config_filename)$";
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr;
  ...
  ptr = param->member;
  ...
  other_func(..., ptr, ...);
  ...
}

@find_ptrarith exists@
identifier func, param, ptr, member;
type T, T2, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr = param->member;
  ...
  *(ptr + E) = ...;
  ...
}

@find_ptrarith2 exists@
identifier func, param, ptr, member;
type T, T2, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *ptr;
  ...
  ptr = param->member;
  ...
  *(ptr + E) = ...;
  ...
}

@find_direct exists@
identifier func, param, member;
type T, T2, RT;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  *(param->member) = ...;
  ...
}

@find_direct_ptrarith exists@
identifier func, param, member;
type T, T2, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  *(param->member + E) = ...;
  ...
}

@find_direct_array exists@
identifier func, param, member;
type T, T2, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  param->member[E] = ...;
  ...
}

@find_direct_incdec exists@
identifier func, param, member;
type T, T2, RT;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
(
  (*(param->member))++
|
  (*(param->member))--
|
  ++(*(param->member))
|
  --(*(param->member))
)
  ...
}

@find_array_elem_addr exists@
identifier func, param, array, fld, elem_ptr;
type T, T2, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *elem_ptr = &param->array[E];
  ...
(
  elem_ptr->fld = ...;
|
  elem_ptr->fld++
|
  elem_ptr->fld--
|
  ++elem_ptr->fld
|
  --elem_ptr->fld
)
  ...
}

@find_array_elem_addr_sep exists@
identifier func, param, array, fld, elem_ptr;
type T, T2, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
  T2 *elem_ptr;
  ...
  elem_ptr = &param->array[E];
  ...
(
  elem_ptr->fld = ...;
|
  elem_ptr->fld++
|
  elem_ptr->fld--
|
  ++elem_ptr->fld
|
  --elem_ptr->fld
)
  ...
}

@find_direct_array_elem exists@
identifier func, param, array, fld;
type T, RT;
expression E;
position p;
@@
static RT func(..., const T *param@p, ...)
{
  ...
(
  param->array[E].fld = ...;
|
  param->array[E].fld++
|
  param->array[E].fld--
|
  ++param->array[E].fld
|
  --param->array[E].fld
)
  ...
}

//@find_cast_away_const disable optional_storage exists@
//identifier func, param;
//type T3, RT;
//type T != void*;
//type T2 != const T3;
//position p;
//@@
//static RT func(..., const T *param@p, ...)
//{
//  ...
//  (T2 *) param
//  ...
//}

@remove_for depends on find_for@
type find_for.T;
type RT;
identifier find_for.func, find_for.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_init depends on find_init@
type find_init.T;
type RT;
identifier find_init.func, find_init.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_assign depends on find_assign@
type find_assign.T;
type RT;
identifier find_assign.func, find_assign.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_array depends on find_array@
type find_array.T;
type RT;
identifier find_array.func, find_array.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_incdec depends on find_incdec@
type find_incdec.T;
type RT;
identifier find_incdec.func, find_incdec.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_funcall depends on find_funcall@
type find_funcall.T;
type RT;
identifier find_funcall.func, find_funcall.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_funcall2 depends on find_funcall2@
type find_funcall2.T;
type RT;
identifier find_funcall2.func, find_funcall2.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_ptrarith depends on find_ptrarith@
type find_ptrarith.T;
type RT;
identifier find_ptrarith.func, find_ptrarith.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_ptrarith2 depends on find_ptrarith2@
type find_ptrarith2.T;
type RT;
identifier find_ptrarith2.func, find_ptrarith2.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_direct depends on find_direct@
type find_direct.T;
type RT;
identifier find_direct.func, find_direct.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_direct_ptrarith depends on find_direct_ptrarith@
type find_direct_ptrarith.T;
type RT;
identifier find_direct_ptrarith.func, find_direct_ptrarith.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_direct_array depends on find_direct_array@
type find_direct_array.T;
type RT;
identifier find_direct_array.func, find_direct_array.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_direct_incdec depends on find_direct_incdec@
type find_direct_incdec.T;
type RT;
identifier find_direct_incdec.func, find_direct_incdec.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_array_elem_addr depends on find_array_elem_addr@
type find_array_elem_addr.T;
type RT;
identifier find_array_elem_addr.func, find_array_elem_addr.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_array_elem_addr_sep depends on find_array_elem_addr_sep@
type find_array_elem_addr_sep.T;
type RT;
identifier find_array_elem_addr_sep.func, find_array_elem_addr_sep.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

@remove_direct_array_elem depends on find_direct_array_elem@
type find_direct_array_elem.T;
type RT;
identifier find_direct_array_elem.func, find_direct_array_elem.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2)
  {
    ...
  }

//@remove_cast_away_const depends on find_cast_away_const@
//type find_cast_away_const.T;
//type RT;
//identifier find_cast_away_const.func, find_cast_away_const.param;
//parameter list ps1, ps2;
//@@
//  static RT func(ps1,
//- const T *param
//+ T *param
//  , ps2)
//  {
//    ...
//  }

@remove_for_decl depends on find_for@
type find_for.T;
type RT;
identifier find_for.func, find_for.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_init_decl depends on find_init@
type find_init.T;
type RT;
identifier find_init.func, find_init.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_assign_decl depends on find_assign@
type find_assign.T;
type RT;
identifier find_assign.func, find_assign.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_array_decl depends on find_array@
type find_array.T;
type RT;
identifier find_array.func, find_array.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_incdec_decl depends on find_incdec@
type find_incdec.T;
type RT;
identifier find_incdec.func, find_incdec.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_funcall_decl depends on find_funcall@
type find_funcall.T;
type RT;
identifier find_funcall.func, find_funcall.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_funcall2_decl depends on find_funcall2@
type find_funcall2.T;
type RT;
identifier find_funcall2.func, find_funcall2.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_ptrarith_decl depends on find_ptrarith@
type find_ptrarith.T;
type RT;
identifier find_ptrarith.func, find_ptrarith.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_ptrarith2_decl depends on find_ptrarith2@
type find_ptrarith2.T;
type RT;
identifier find_ptrarith2.func, find_ptrarith2.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_direct_decl depends on find_direct@
type find_direct.T;
type RT;
identifier find_direct.func, find_direct.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_direct_ptrarith_decl depends on find_direct_ptrarith@
type find_direct_ptrarith.T;
type RT;
identifier find_direct_ptrarith.func, find_direct_ptrarith.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_direct_array_decl depends on find_direct_array@
type find_direct_array.T;
type RT;
identifier find_direct_array.func, find_direct_array.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_direct_incdec_decl depends on find_direct_incdec@
type find_direct_incdec.T;
type RT;
identifier find_direct_incdec.func, find_direct_incdec.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_array_elem_addr_decl depends on find_array_elem_addr@
type find_array_elem_addr.T;
type RT;
identifier find_array_elem_addr.func, find_array_elem_addr.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_array_elem_addr_sep_decl depends on find_array_elem_addr_sep@
type find_array_elem_addr_sep.T;
type RT;
identifier find_array_elem_addr_sep.func, find_array_elem_addr_sep.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

@remove_direct_array_elem_decl depends on find_direct_array_elem@
type find_direct_array_elem.T;
type RT;
identifier find_direct_array_elem.func, find_direct_array_elem.param;
parameter list ps1, ps2;
@@
  static RT func(ps1,
- const T *param
+ T *param
  , ps2);

//@remove_cast_away_const_decl depends on find_cast_away_const@
//type find_cast_away_const.T;
//type RT;
//identifier find_cast_away_const.func, find_cast_away_const.param;
//parameter list ps1, ps2;
//@@
//  static RT func(ps1,
//- const T *param
//+ T *param
//  , ps2);
