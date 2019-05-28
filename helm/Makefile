#
# OS2display hosting makefile.

# =============================================================================
# MAIN COMMAND TARGETS
# =============================================================================
.DEFAULT_GOAL := help
# Include environment variables and re-export them.

help: ## Display a list of the public targets
# Find lines that starts with a word-character, contains a colon and then a
# doublehash (underscores are not word-characters, so this excludes private
# targets), then strip the hash and print.
	@grep -E -h "^\w.*:.*##" $(MAKEFILE_LIST) | sed -e 's/\(.*\):.*##\(.*\)/\1	\2/'

tag-release: ## Tag current HEAD as a chart release and push it. Pass in a semver version via TAG.
	tools/tag-release.sh $(TAG)

publish-release: ## Build a chart release and publish it. Pass in a semver version via TAG.
	tools/build-and-publish-release.sh $(TAG)
