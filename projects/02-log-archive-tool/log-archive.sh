#!/shell/bash

# Check that the user provided an argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <log-directory>"
    exit 1
fi

# Verify the directory exists
if [[ ! -d "$1" ]]; then
    echo "Error: '$1' is not a directory."
    exit 1
fi

archive_dir=archives
timestamp=$(date +%Y%m%d_%H%M%S)
archive_file="${archive_dir}/logs_archive_${timestamp}.tar.gz"

mkdir -p $archive_dir
if tar -czf "$archive_file" "$1"; then
    echo "Archive created: $archive_file"
else
    echo "Archive failed"
    exit 1
fi