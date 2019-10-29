#!/bin/sh
set -e

# remove old ones and extract 
echo "Unzipping"
rm -f all.json
gunzip -k all.json.gz

# Run python fix
python fix.py

echo "Cleaning up ..."
rm all.json.fixed

echo "Done, you may now use 'all.json' as an import"