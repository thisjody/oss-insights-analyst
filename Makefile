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

# === Agent Cloud Function Scaffolding ===
init-cf:
	@echo "📦 Creating Cloud Function scaffold for agent: $(AGENT_NAME)"
	@mkdir -p agents/$(AGENT_NAME)
	@touch agents/$(AGENT_NAME)/main.py
	@ln -sf ../../requirements.txt agents/$(AGENT_NAME)/requirements.txt
	@printf "__pycache__/\n*.pyc\n*.pyo\n*.pyd\n.env\n.venv\n.terraform\n.DS_Store\n" > agents/$(AGENT_NAME)/.gcloudignore
	@printf "GEN2=gen2\nRUNTIME=python311\nREGION=us-central1\nPROJECT_ID=oss-insights-analyst\nSOURCE=agents/$(AGENT_NAME)\nCLOUDFUNCTION=$(shell echo $(AGENT_NAME) | tr '_' '-')\nENTRY_POINT=main\nMEMORY=512MB\nTIMEOUT=60s\nSERVICE_ACCOUNT=cf-oss-agent@oss-insights-analyst.iam.gserviceaccount.com\n" > agents/$(AGENT_NAME)/.env.deploy
	@echo "✅ Scaffolding complete for $(AGENT_NAME)"

# === deploy CFs ===

deploy-vc-strategist:
	bash scripts/deploy_cf.sh agents/vc_strategist/.env.deploy

deploy-tech-architect:
	bash scripts/deploy_cf.sh agents/tech_architect/.env.deploy

deploy-trend-watcher:
	bash scripts/deploy_cf.sh agents/trend_watcher/.env.deploy

deploy-oss-purist:
	bash scripts/deploy_cf.sh agents/oss_purist/.env.deploy

deploy-trend-watcher:
	bash scripts/deploy_cf.sh agents/trend_watcher/.env.deploy
