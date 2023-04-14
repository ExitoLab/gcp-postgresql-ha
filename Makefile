.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: install-cloud_sql_proxy
install-cloud_sql_proxy:
	curl -LO https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64
	chmod +x cloud_sql_proxy.darwin.amd64
	sudo mv cloud_sql_proxy.darwin.amd64 /usr/local/bin/cloud_sql_proxy
	cloud_sql_proxy -version

.PHONY: install-psql
install-psql:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install postgresql

.PHONY: cleanup
cleanup:
	rm -rf cloud_sql_proxy.darwin.amd64