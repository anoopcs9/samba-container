CONTAINER_CMD ?=
ifeq ($(CONTAINER_CMD),)
	CONTAINER_CMD:=$(shell podman version >/dev/null 2>&1 && echo podman)
endif
ifeq ($(CONTAINER_CMD),)
	CONTAINER_CMD:=$(shell docker version >/dev/null 2>&1 && echo docker)
endif

BUILD_CMD:=$(CONTAINER_CMD) build $(BUILD_OPTS)
PUSH_CMD:=$(CONTAINER_CMD) push $(PUSH_OPTS)

SERVER_DIR:=images/server
AD_SERVER_DIR:=images/ad-server
CLIENT_DIR:=images/client
SERVER_SRC_FILE:=$(SERVER_DIR)/Dockerfile.fedora
AD_SERVER_SRC_FILE:=$(AD_SERVER_DIR)/Containerfile
CLIENT_SRC_FILE:=$(CLIENT_DIR)/Dockerfile

TAG?=latest
SERVER_NAME:=samba-container:$(TAG)
AD_SERVER_NAME:=samba-ad-container:$(TAG)
CLIENT_NAME:=samba-client-container:$(TAG)
SERVER_REPO_NAME:=quay.io/samba.org/samba-server:$(TAG)
AD_SERVER_REPO_NAME:=quay.io/samba.org/samba-ad-server:$(TAG)
CLIENT_REPO_NAME:=quay.io/samba.org/samba-client:$(TAG)


build: build-server build-ad-server build-client
.PHONY: build

build-server:
	$(BUILD_CMD) --tag $(SERVER_NAME) --tag $(SERVER_REPO_NAME) -f $(SERVER_SRC_FILE) $(SERVER_DIR)
.PHONY: build-server

push-server: build-server
	$(PUSH_CMD) $(SERVER_REPO_NAME)
.PHONY: push-server

build-ad-server:
	$(BUILD_CMD) --tag $(AD_SERVER_NAME) --tag $(AD_SERVER_REPO_NAME) -f $(AD_SERVER_SRC_FILE) $(AD_SERVER_DIR)
.PHONY: build-ad-server

push-ad-server: build-ad-server
	$(PUSH_CMD) $(AD_SERVER_REPO_NAME)
.PHONY: push-ad-server

build-client:
	$(BUILD_CMD) --tag $(CLIENT_NAME) --tag $(CLIENT_REPO_NAME) -f $(CLIENT_SRC_FILE) $(CLIENT_DIR)
.PHONY: build-client

push-client: build-client
	$(PUSH_CMD) $(CLIENT_REPO_NAME)
.PHONY: push-client

test: test-server
.PHONY: test

test-server: build-server
	CONTAINER_CMD=$(CONTAINER_CMD) LOCAL_TAG=$(SERVER_NAME) hack/test-samba-container.sh
.PHONY: test-server
