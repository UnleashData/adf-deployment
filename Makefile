#!/bin/bash

SUBSCRIPTION?=""

help:
	@echo "Update later"
deploy:
	@if [ -z ${SUBSCRIPTION} ]; then \
        echo "Add a valid value for subscription."; \
		echo "Run: 'make deploy SUBSCRIPTION=<subscriptionId>'"; \
		exit 1; \
	else \
		echo "Start deploying Azure Data Factories to subscription ${SUBSCRIPTION}"; \
		az deployment sub create \
			--name 'adf-deployment' \
			--subscription ${SUBSCRIPTION} \
			--location westeurope \
			--template-file ./bicep/main.bicep \
			--only-show-errors \
		>> resources.json; \
    fi
clean:
	@if [ -z ${SUBSCRIPTION} ]; then \
        echo "Add a valid value for subscription."; \
		echo "Run: 'make clean SUBSCRIPTION=<subscriptionId>'"; \
		exit 1; \
	else \
		echo "Removing resource groups (rg-adf-dev, rg-adf-tst, rg-adf-prd) from subscription $(SUBSCRIPTION)"; \
		az account set --subscription ${SUBSCRIPTION}; \
		az group delete --name rg-adf-dev --no-wait --yes; \
		az group delete --name rg-adf-tst --no-wait --yes; \
		az group delete --name rg-adf-prd --no-wait --yes; \
		echo "This process may take several minutes. Please check later if all resources have been removed."; \
	fi
what-if:
	@if [ -z ${SUBSCRIPTION} ]; then \
			echo "Add a valid value for subscription."; \
			echo "Run: 'make clean SUBSCRIPTION=<subscriptionId>'"; \
			exit 1; \
	else \
		echo "Checking changes after deploying to subscription ${SUBSCRIPTION}"; \
		az deployment sub create \
			--name 'adf-deployment' \
			--subscription ${SUBSCRIPTION} \
			--location westeurope \
			--template-file ./bicep/main.bicep \
			--only-show-errors \
			--what-if; \
	fi
