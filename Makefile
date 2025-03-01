#!/bin/bash

TENANT?=""

help:
	@echo "Update later"
deploy:
	@if [ -z ${TENANT} ]; then \
        echo "Add a valid value for tenant."; \
		echo "Run: 'make deploy TENANT=<tenantId>'"; \
		exit 1; \
	else \
		echo "Start deploying Azure Data Factories to tenant ${TENANT}"; \
    fi
clean:
	@echo clean
whatif:
	@echo what if
