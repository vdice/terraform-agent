CHART_NAME ?= tfc-agent
CHART_DIR ?= charts/$(CHART_NAME)
CHART_VERSION := $(shell grep '^version:' $(CHART_DIR)/Chart.yaml | awk '{print $$2}')
REGISTRY ?= ghcr.io/vdice/$(CHART_NAME)

.PHONY: lint
lint:
	@echo "Linting Helm chart..."
	helm lint $(CHART_DIR)

.PHONY: package
package:
	@echo "Packaging Helm chart..."
	helm package $(CHART_DIR) --destination ./

.PHONY: publish
publish: lint package
	@echo "Pushing Helm chart to OCI registry..."
	helm push $(CHART_NAME)-$(CHART_VERSION).tgz oci://$(REGISTRY)

.PHONY: clean
clean:
	@echo "Cleaning packaged chart files..."
	rm -f $(CHART_NAME)-$(CHART_VERSION).tgz
