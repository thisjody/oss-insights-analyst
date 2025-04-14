# OSS Insights Analyst

**OSS Insights Analyst** is a cloud-native system for evaluating open-source projects through the lens of multiple expert personas. It's designed for technical due diligence, investment analysis, and deep community evaluation, using LLM agents and structured prompts.

## 📁 Project Structure

```
oss-insights-analyst/
├── agents/                      # Cloud Functions per persona
│   └── common/                  # Shared logic (Firestore, secrets, etc.)
├── aggregator/                  # Aggregator agent that synthesizes persona outputs
├── deploy/                      # Cloud Function deployment scripts (stubbed)
├── prompts/                     # Prompt markdown files per persona
├── secrets/                     # .env file with prompts + keys (excluded from git)
├── scripts/                     # Utility scripts (prompt bootstrapping, secret uploads)
├── terraform/                   # Terraform config for GCP infrastructure
├── Makefile                     # Developer automation (build, update, deploy)
├── requirements.txt             # Shared Python dependencies
└── README.md                    # Project overview (this file)
```

## 🧠 Personas (LLM Agents)

Each agent is defined by a sophisticated prompt grounded in open-source practitioner thinking:

- `OSS Purist`: Ethics, licensing, governance
- `VC Strategist`: Traction, monetization, defensibility
- `Tech Architect`: Code quality, scalability, DevEx
- `Trend Watcher`: Buzz vs substance, narratives
- `Aggregator`: Synthesizes all above agents into a VC-ready report

Prompts are versioned in `prompts/*.md`, bootstrapped to `.env`, then uploaded to GCP Secret Manager.

## 🔐 Secret Management

- Secrets are managed via Google Secret Manager
- `.env` file (in `secrets/`) holds prompts + your API key
- Use `make update-prompts` to:
  - Rebuild `.env` from markdown prompts
  - Upload them to GCP Secrets

## 🌎 Infrastructure via Terraform

- GCP project setup (App Engine, Secret Manager)
- Region-configurable via `terraform.tfvars`
- To provision:
  ```bash
  terraform init
  terraform apply -var-file=terraform/terraform.tfvars
  ```

## 🛠️ Scripts

### scripts/bootstrap_prompts.sh
Generates:
- `prompts/*.md` for each agent
- `.env` file for Secret Manager upload

### scripts/upload_secrets_from_env.sh
Reads `secrets/.env` and uploads keys + prompt text to GCP Secret Manager

### scripts/regenerate_env.sh
Regenerates `.env` from `prompts/*.md`, preserving your existing API key

## ✅ Make Targets

```bash
make setup                # Install Python deps
make bootstrap-prompts    # Generate prompt files + .env
make upload-secrets       # Upload .env to GCP Secrets
make update-prompts       # Rebuild .env + upload
make deploy               # Stub for deploying Cloud Functions
```

## 🧪 Local Development

- Virtualenv created at `~/.virtualenvs/oss-insights-analyst`
- Project lives in `~/.dev/oss-insights-analyst`
- Automatically activated via `.envrc` and `direnv`

## ☁️ GCP Regions

- Default region: `us-central`
- Change via `terraform.tfvars` and re-`apply`

## 🧼 Pre-Commit Hooks

- Enforced with Black and isort
- Installed automatically via the scaffold
- Can be skipped with `--no-verify` if needed

## 📦 GitHub Setup

- Created during bootstrap
- Repo: https://github.com/thisjody/oss-insights-analyst

---

This is a structured, agent-powered framework for serious OSS due diligence. Use it to power VC insights, internal tech reviews, or trend detection.

> Questions, ideas, or feedback? Drop them into the repo or extend a persona!