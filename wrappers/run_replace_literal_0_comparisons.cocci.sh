#!/bin/bash

# Wrapper to run replace_literal_0_comparisons.cocci on each .c file one by
# one using --recursive-includes.
# Indeed running on the directory:
#  spatch --sp-file replace_literal_0_comparisons.cocci
#         --dir $PGSRC -I $PGSRC/src/include --recursive-includes
# does not include header files recursively (confirmed by using --verbose-includes)

PGSRC=/home/postgres/postgresql/postgres
COCCI=/home/postgres/coccinelle_on_pg

cd $PGSRC
rm report.patch_cocci

find src -name "*.c" | while read f; do
  spatch --sp-file $COCCI/replace_literal_0_comparisons.cocci "$f" \
    -I $PGSRC/src/include \
    --recursive-includes >> report.patch_cocci
done

# cat report.patch_cocci | patch -p0
