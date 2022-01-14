## This Makefile describe common operation for testing Epinio.

KD3_CLUSTER_NAME=epinio-lab

.PHONY: help
help: ## Show this Makefile's help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install_epinio
install_epinio: ## Install Epinio helm chart
	helmfile -f clusters.d/epinio-installer.yaml apply

.PHONY: k3d.init
k3d_init: ## Bootstrapp a kubernetes cluseter using k3d
	@echo "# Installing k3d cluster $(KD3_CLUSTER_NAME)"
	@k3d cluster list $(KD3_CLUSTER_NAME) ;\
	if [ $$? -ne '0' ]; then \
		k3d cluster create $(KD3_CLUSTER_NAME) --volume /dev/mapper:/dev/mapper/ --servers 3 --agents 3; \
	fi 

.PHONY: k3d.destroy 
k3d_destroy: ## Delete the local sandbox Kubernetes cluster
	@echo "# Removing k3d cluster $(KD3_CLUSTER_NAME)"
	@k3d cluster list $(KD3_CLUSTER_NAME) ;\
	if [ $$? -eq '0' ]; then \
		k3d cluster delete $(KD3_CLUSTER_NAME); \
	fi

.PHONY: delete
delete: k3d_destroy ## Fully remove the Epinio lab

.PHONY: install
install: k3d_init install_epinio ## Fully installer the Epinio lab
	
.PHONY: reset
reset: delete install ## Ensure that all component are remove before reinstalling them
