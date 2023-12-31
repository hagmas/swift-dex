TOOL = scripts/swift-run.sh
SWIFT_FILE_PATHS = Package.swift Sources Tests Examples

.PHONY: proj
proj:
	SWIFT_PACKAGE_RESOURCES=.build/checkouts/XcodeGen/SettingPresets $(TOOL) xcodegen -s Examples/project.yml

.PHONY: format
format:
	$(TOOL) swift-format format -i -p -r $(SWIFT_FILE_PATHS)

.PHONY: lint
lint:
	$(TOOL) swift-format lint -s -p -r $(SWIFT_FILE_PATHS)
