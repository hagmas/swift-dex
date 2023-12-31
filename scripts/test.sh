#!/bin/bash

set -eu

xcodebuild test -scheme swift-dex -destination platform="macos"
