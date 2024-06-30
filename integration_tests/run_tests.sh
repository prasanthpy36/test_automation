#!/bin/bash

TEST_REPORT=$1

# Check if the report file exists and delete it
if [ -f "$TEST_REPORT" ]; then
  rm "$TEST_REPORT"
fi

find integration_tests -name "test_*.py" | while read -r file
do
  {
    echo "====================================="
    echo "Running tests in $file..."
    python -m pytest "$file"
    echo "====================================="
  } >> "$TEST_REPORT"
done