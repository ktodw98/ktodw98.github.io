.PHONY: help preview doctor drafts templates categories tags new import-summary import-repost validate

help:
	@echo "make preview"
	@echo "make doctor"
	@echo "make drafts"
	@echo "make templates"
	@echo "make categories"
	@echo "make tags"
	@echo "make new TEMPLATE=tutorial TITLE=\"...\" CATEGORY=backend TAGS=\"go,api\" DESCRIPTION=\"...\""
	@echo "make import-summary TITLE=\"...\" CATEGORY=writing TAGS=\"summary,reference\" SOURCE_URL=\"...\" SOURCE_NAME=\"...\" DESCRIPTION=\"...\""
	@echo "make import-repost TITLE=\"...\" CATEGORY=writing TAGS=\"reference\" SOURCE_URL=\"...\" SOURCE_NAME=\"...\" DESCRIPTION=\"...\""
	@echo "make validate"

preview:
	@bundle exec jekyll serve --livereload

doctor:
	@ruby scripts/validate-i18n.rb
	@ruby scripts/validate-frontmatter.rb
	@bundle exec jekyll build

drafts:
	@ruby scripts/list-drafts.rb

templates:
	@ruby scripts/posts.rb list-templates

categories:
	@ruby scripts/posts.rb list-categories

tags:
	@ruby scripts/posts.rb list-tags

new:
	@ruby scripts/posts.rb new

import-summary:
	@ruby scripts/posts.rb import-summary

import-repost:
	@ruby scripts/posts.rb import-repost

validate:
	@$(MAKE) doctor
