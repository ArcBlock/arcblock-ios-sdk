TOP_DIR=.
README=$(TOP_DIR)/README.md

VERSION=$(strip $(shell cat version))

build:
	@echo "Building the software..."
	@carthage build --platform ios --no-skip-current --cache-builds

init: install dep
	@echo "Initializing the repo..."

travis-init: install
	@echo "Initialize software required for travis (normally ubuntu software)"

install:
	@echo "Install software required for this repo..."
	@brew install carthage | true
	@gem install xcpretty -N
	@brew install swiftlint | true
	@gem install jazzy

dep:
	@echo "Install dependencies required for this repo..."
	@carthage update --platform ios --cache-builds
	@rm -rf Carthage/Checkouts/SwiftPhoenixClient/Example/Pods/

pre-build: install dep
	@echo "Running scripts before the build..."

post-build:
	@echo "Running scripts after the build is done..."
	@carthage archive --output build/ArcBlockSDK.zip

all: pre-build build post-build

test:
	@echo "Running test suites..."
	@xcodebuild -project ArcBlockSDK.xcodeproj -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 8' -configuration Debug -scheme ArcBlockSDK build test | xcpretty -c

lint:
	@echo "Linting the software..."
	@swiftlint

doc:
	@echo "Building the documenation..."
	@jazzy

precommit: dep lint doc test

travis:
	@set -o pipefail
	@make precommit

travis-deploy:
	if ! [ -f "./build/ArcBlockSDK.zip" ]; then \
		echo "Preparing for deployment..."; \
		make release; \
		rm -rf Carthage; \
		tar -zcvf docs/Templates.tar.gz Templates; \
		make doc; \
	fi

protobuf-codegen:
	@echo "Generating protobuf swift codes..."
	@protoc --swift_out=ArcBlockSDK/ABSDKWalletKit/protobuf/ --proto_path=ArcBlockSDK/ABSDKWalletKit/protobuf ArcBlockSDK/ABSDKWalletKit/protobuf/*.proto --swift_opt=Visibility=Public

clean:
	@echo "Cleaning the build..."

watch:
	@echo "Watching templates and slides changes..."

run:
	@echo "Running the software..."

deploy: release
	@echo "Deploy software into local machine..."

include .makefiles/release.mk

.PHONY: build init travis-init install dep pre-build post-build all test doc precommit travis clean watch run travis-deploy
