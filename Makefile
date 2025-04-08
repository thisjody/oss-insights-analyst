# === Setup & Code Quality ===

setup:
	pip install -r requirements.txt

format:
	black .
	isort .

lint:
	black --check .
	isort --check-only .

deploy:
	bash scripts/deploy_all.sh


# === Prompt & Secret Management ===

bootstrap-prompts:
	bash scripts/bootstrap_prompts.sh

rebuild-env:
	bash scripts/regenerate_env.sh

upload-secrets:
	bash scripts/upload_secrets_from_env.sh

update-prompts: rebuild-env upload-secrets


# === Utilities ===

.PHONY: help
help:
	@echo ""
	@echo "🛠  OSS Insights Analyst - Make Targets"
	@echo ""
	@echo "Setup & Linting:"
	@echo "  make setup              - Install Python deps"
	@echo "  make format             - Auto-format with black & isort"
	@echo "  make lint               - Lint-only check for formatting"
	@echo "  make deploy             - Run all deployment scripts"
	@echo ""
	@echo "Prompts & Secrets:"
	@echo "  make bootstrap-prompts  - Generate .md prompts and .env from scratch"
	@echo "  make rebuild-env        - Rebuild .env from .mds, keep API key"
	@echo "  make upload-secrets     - Upload all .env values to GCP Secret Manager"
	@echo "  make update-prompts     - Rebuild .env + upload (fast sync)"
	@echo ""

