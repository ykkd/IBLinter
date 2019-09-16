PREFIX?=/usr/local

build:
		swift build --disable-sandbox -c release --static-swift-stdlib

clean_build:
		rm -rf .build
		make build

portable_zip: build
		rm -rf portable_iblinter
		mkdir portable_iblinter
		mkdir portable_iblinter/bin
		cp -f .build/release/iblinter portable_iblinter/bin/iblinter
		cp -f LICENSE portable_iblinter
		cd portable_iblinter
		(cd portable_iblinter; zip -yr - "bin" "LICENSE") > "./portable_iblinter.zip"
		rm -rf portable_iblinter

install: build
		mkdir -p "$(PREFIX)/bin"
		cp -f ".build/release/iblinter" "$(PREFIX)/bin/iblinter"

current_version:
		@cat .version

bump_version:
		$(eval NEW_VERSION := $(filter-out $@,$(MAKECMDGOALS)))
		@echo $(NEW_VERSION) > .version
		@sed 's/__VERSION__/$(NEW_VERSION)/g' script/Version.swift.template > Sources/IBLinterFrontend/Version.swift
		git commit -am"Bump version to $(NEW_VERSION)"

publish:
		brew update && brew bump-formula-pr --tag=$(shell git describe --tags) --revision=$(shell git rev-parse HEAD) iblinter
		pod trunk push IBLinter.podspec

%:
	@:
