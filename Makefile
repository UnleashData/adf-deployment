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
			--template-file ./bicep/main.bicep; \
    fi
clean:
	@echo clean
what-if:
	@echo "Checking changes after deploying to subscription ${SUBSCRIPTION}"; \
	az deployment sub create \
		--name 'adf-deployment' \
		--subscription ${SUBSCRIPTION} \
		--location westeurope \
		--template-file ./bicep/main.bicep \
		--what-if;
