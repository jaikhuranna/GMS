#!/bin/bash

# Navigate to the test directory
cd "$(dirname "$0")"

# Clean any previous builds
swift package clean

# Run the tests
swift test -v