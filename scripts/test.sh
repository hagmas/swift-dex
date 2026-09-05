#!/bin/bash

set -eu

# The package vends more than one library, so Xcode no longer auto-generates a
# scheme named after the package. "swift-dex-Package" is the aggregate scheme
# that covers every target, including all the test targets.
xcodebuild test -scheme swift-dex-Package -destination "platform=macOS"
