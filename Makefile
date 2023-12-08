# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

BUILD_DIR := build/bin
GENERATOR_BINARY := graph-generator
SERVER_BINARY := graph-server

TARGETOS ?= $(shell go env GOOS)
TARGETARCH ?= $(shell go env GOARCH)

MULTI_TARGETOS ?= linux darwin
MULTI_TARGETARCH ?= amd64 arm64

.PHONY: all build-generator build-server build-generator-multi build-server-multi

all: build-generator-multi build-server-multi ## Build the generator and server for multiple platforms

build-generator: ## Build the generator
	@echo "Building graph-tester generator"
	@CGO_ENABLED=0 GOARCH=${TARGETARCH} GOOS=${TARGETOS} go build -ldflags '-w -extldflags "-static"' -o ${BUILD_DIR}/${TARGETOS}/${TARGETARCH}/${GENERATOR_BINARY} ./cmd/generator

build-server: ## Build the server
	@echo "Building graph-tester server"
	@CGO_ENABLED=0 GOARCH=${TARGETARCH} GOOS=${TARGETOS} go build -ldflags '-w -extldflags "-static"' -o ${BUILD_DIR}/${TARGETOS}/${TARGETARCH}/${SERVER_BINARY} ./cmd/server

build-generator-multi: ## Build the generator for multiple platforms
	@echo "Building graph-tester generator for multiple platforms"
	@$(foreach GOOS, $(MULTI_TARGETOS), \
		$(foreach GOARCH, $(MULTI_TARGETARCH), \
			CGO_ENABLED=0 GOARCH=$(GOARCH) GOOS=$(GOOS) go build -ldflags '-w -extldflags "-static"' -o ${BUILD_DIR}/$(GOOS)/$(GOARCH)/${GENERATOR_BINARY} ./cmd/generator; \
		) \
	)

build-server-multi: ## Build the server for multiple platforms
	@echo "Building graph-tester server for multiple platforms"
	@$(foreach GOOS, $(MULTI_TARGETOS), \
		$(foreach GOARCH, $(MULTI_TARGETARCH), \
			CGO_ENABLED=0 GOARCH=$(GOARCH) GOOS=$(GOOS) go build -ldflags '-w -extldflags "-static"' -o ${BUILD_DIR}/$(GOOS)/$(GOARCH)/${SERVER_BINARY} ./cmd/server; \
		) \
	)