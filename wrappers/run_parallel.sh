#!/bin/bash

# Wrapper to run .cocci script on each .c file one by one using --recursive-includes.
# Indeed running on the directory:
#  spatch --sp-file <.cocci>
#         --dir $PGSRC -I $PGSRC/src/include --recursive-includes
# does not include header files recursively (confirmed by using --verbose-includes)

set -euo pipefail
ulimit -s unlimited

usage() {
    cat << EOF
Usage: $(basename "$0") <cocci_script> [options]

Arguments:
    cocci_script    Path to the Coccinelle script (.cocci file)

Options:
    -s, --source    PostgreSQL source directory (default: /home/postgres/postgresql/postgres)
    -j, --jobs      Number of parallel jobs (default: 8)
    -o, --output    Output file name (default: based on cocci script name)
    -g, --grep      Only process files containing this pattern (optional)
    -h, --help      Show this help message

Examples:
    $(basename "$0") replace_literal_0.cocci
    $(basename "$0") my_script.cocci -j 16 -o custom_output.patch
    $(basename "$0") /path/to/script.cocci -s /path/to/postgres
    $(basename "$0") replace.cocci -g "InvalidXLogRecPtr"
EOF
    exit 1
}

# Check if at least one argument provided
if [[ $# -eq 0 ]]; then
    usage
fi

# Parse arguments
COCCI_SCRIPT=""
PGSRC=${PGSRC:-/home/postgres/postgresql/postgres}
JOBS=${JOBS:-8}
OUTPUT_FILE=""
GREP_PATTERN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            PGSRC="$2"
            shift 2
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -g|--grep)
            GREP_PATTERN="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            if [[ -z "$COCCI_SCRIPT" ]]; then
                COCCI_SCRIPT="$1"
            else
                echo "Error: Multiple cocci scripts specified" >&2
                usage
            fi
            shift
            ;;
    esac
done

# Validate cocci script exists
if [[ ! -f "$COCCI_SCRIPT" ]]; then
    echo "Error: Coccinelle script not found: $COCCI_SCRIPT" >&2
    exit 1
fi

# Validate PostgreSQL source directory exists
if [[ ! -d "$PGSRC" ]]; then
    echo "Error: PostgreSQL source directory not found: $PGSRC" >&2
    exit 1
fi

# Check if GNU Parallel is available
if ! command -v parallel &> /dev/null; then
    echo "Error: GNU Parallel is not installed" >&2
    exit 1
fi

# Generate output filename from cocci script name if not provided
if [[ -z "$OUTPUT_FILE" ]]; then
    COCCI_BASENAME=$(basename "$COCCI_SCRIPT" .cocci)
    OUTPUT_FILE="${COCCI_BASENAME}.patch"
fi

echo "Coccinelle script: $COCCI_SCRIPT"
echo "PostgreSQL source: $PGSRC"
echo "Parallel jobs: $JOBS"
if [[ -n "$GREP_PATTERN" ]]; then
    echo "Grep filter: $GREP_PATTERN"
fi
echo "Output file: $OUTPUT_FILE"
echo ""

cd "$PGSRC"
rm -f "$OUTPUT_FILE"

echo "Processing files with $JOBS parallel jobs..."

# Process files in parallel
if [[ -n "$GREP_PATTERN" ]]; then
    # Only process files containing the grep pattern
    find . -name "*.c" -type f -exec grep -l "$GREP_PATTERN" {} \; | \
        parallel -j"$JOBS" --bar \
            spatch --sp-file "$COCCI_SCRIPT" {} \
                -I "$PGSRC/src/include" \
                --recursive-includes \
                --disable-worth-trying-opt \
            >> "$OUTPUT_FILE"
else
    # Process all .c files
    find . -name "*.c" -type f | \
        parallel -j"$JOBS" --bar \
            spatch --sp-file "$COCCI_SCRIPT" {} \
                -I "$PGSRC/src/include" \
                --recursive-includes \
                --disable-worth-trying-opt \
            >> "$OUTPUT_FILE"
fi

echo ""
echo "Processing complete. Results in $OUTPUT_FILE"

#cat $OUTPUT_FILE | patch -p0
