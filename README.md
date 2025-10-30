Some Coccinelle scripts for PostgreSQL
=============================================================

Some [Coccinelle](https://coccinelle.gitlabpages.inria.fr/website/) scripts that could be used in relation with PostgreSQL:

* `replace_XLogRecPtrIsInvalid.cocci`: replace XLogRecPtrIsInvalid() with XLogRecPtrIsValid() macro
* `replace_InvalidXLogRecPtr_comparisons.cocci`: replace InvalidXLogRecPtr comparisons with XLogRecPtrIsValid() macro
* `replace_literal_0_comparisons.cocci`: replace literal 0 comparisons on XLogRecPtr with XLogRecPtrIsValid() macro
