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

# === Prompt Management ===
bootstrap-prompts:
	bash scripts/bootstrap_prompts.sh

upload-secrets:
	bash scripts/upload_secrets_from_env.sh

update-prompts: bootstrap-prompts upload-secrets
