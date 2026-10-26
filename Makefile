TOOL = scripts/swift-run.sh
SWIFT_FILE_PATHS = Package.swift Sources Tests Examples

.PHONY: proj
proj:
	SWIFT_PACKAGE_RESOURCES=.build/checkouts/XcodeGen/SettingPresets $(TOOL) xcodegen -s Examples/project.yml

.PHONY: format
format:
	swift format format -i -p -r $(SWIFT_FILE_PATHS)

.PHONY: lint
lint:
	swift format lint -s -p -r $(SWIFT_FILE_PATHS)

# Loom's workbench: figures played through their changes, with a frame meter.
# `make lab ARGS=--autoplay` plays every way of appearing, prints what the
# meter saw, and quits.
.PHONY: lab
lab:
	swift run --package-path Examples/LoomLab LoomLab $(ARGS)
