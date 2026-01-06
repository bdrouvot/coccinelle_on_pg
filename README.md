Some Coccinelle scripts for PostgreSQL
=============================================================

Some [Coccinelle](https://coccinelle.gitlabpages.inria.fr/website/) scripts that could be used in relation with PostgreSQL.

Overview of related PostgreSQL commits:


| Scripts | Commits |
| ------------- |-------------|
| [replace_XLogRecPtrIsInvalid.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/replace_XLogRecPtrIsInvalid.cocci)| [Use XLogRecPtrIsValid() in various places](https://postgr.es/c/a2b02293bc6)|
| [remove_useless_casts_to_void_star.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/remove_useless_casts_to_void_star.cocci)| [Remove useless casts to (void *)](https://postgr.es/c/ef8fe693606)|
| [unused_struct_fields.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/unused_struct_fields.cocci)| [Remove a few unused struct members](https://postgr.es/c/9446f918ace)|
| [pointers_and_literal_zero.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/pointers_and_literal_zero.cocci)| [Replace pointer comparisons and assignments to literal zero with NULL](https://postgr.es/c/ec782f56b0c)|
| [remove_cast_to_same_type.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/remove_cast_to_same_type.cocci)| [Remove useless casting to same type](https://postgr.es/c/4f941d432b4)|
| [use_func_void.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/use_func_void.cocci)| [Use "foo(void)" for definitions of functions with no parameters](https://postgr.es/c/9b05e2ec08a)|
| [indirectly_casting_away_const.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/indirectly_casting_away_const.cocci)| Part of [Fix some cases of indirectly casting away const](https://postgr.es/c/8f1791c6183)|
| [indirectly_casting_away_const.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/indirectly_casting_away_const.cocci)| [Fix another case of indirectly casting away const](https://postgr.es/c/9f7565c6c2d)|
| [detect_sizeof_bugs.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/detect_sizeof_bugs.cocci)| [btree_gist: Fix memory allocation formula](https://postgr.es/c/5cf03552fbb)|
| [mismatched_open_close_pairs.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/mismatched_open_close_pairs.cocci)| [Use table/index_close() more consistently](https://postgr.es/c/9d0f7996e58)|
| [mismatched_open_close_pairs.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/mismatched_open_close_pairs.cocci)| [Use relation_close() more consistently in contrib](https://postgr.es/c/8b9b93e39b1)|
| [search_const_away.cocci](https://github.com/bdrouvot/coccinelle_on_pg/blob/main/misc/search_const_away.cocci)| [Separate read and write pointers in pg_saslprep](https://postgr.es/c/de746e0d2a5)|
