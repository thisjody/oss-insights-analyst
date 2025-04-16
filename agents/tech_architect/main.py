import json
import logging
import os
from datetime import datetime

import functions_framework
import requests
from google.cloud import secretmanager


# === Secret Loader ===
def get_secret(secret_name, version="latest"):
    client = secretmanager.SecretManagerServiceClient()
    project_id = os.getenv("PROJECT_ID")
    secret_path = f"projects/{project_id}/secrets/{secret_name}/versions/{version}"
    response = client.access_secret_version(name=secret_path)
    return response.payload.data.decode("UTF-8").strip()


# === Config ===
GEMINI_MODEL = "gemini-2.0-flash-001"
GEMINI_ENDPOINT = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"


# === Entry Point ===
@functions_framework.http
def main(request):
    """Tech Architect Cloud Function entrypoint"""
    logging.basicConfig(level=logging.INFO)

    try:
        input_data = request.get_json(silent=True) or {}
    except Exception as e:
        return {"error": f"Invalid JSON input: {str(e)}"}, 400

    try:
        api_key = get_secret("gemini_api_key")
        architect_prompt = get_secret("tech_architect_prompt")
    except Exception as e:
        return {"error": f"Secret loading failed: {str(e)}"}, 500

    current_date = datetime.utcnow().strftime("%Y-%m-%d")
    user_instruction = input_data.get(
        "instruction",
        "Please analyze the most technically sound open-source project gaining traction today.",
    )

    headers = {"Content-Type": "application/json", "x-goog-api-key": api_key}
    payload = {
        "contents": [
            {"role": "user", "parts": [{"text": architect_prompt}]},
            {
                "role": "user",
                "parts": [
                    {
                        "text": (
                            f"Today's date is {current_date}. Use RAG to pull live GitHub and dev ecosystem signals.\n\n"
                            f"{user_instruction}"
                        )
                    }
                ],
            },
        ]
    }

    try:
        response = requests.post(GEMINI_ENDPOINT, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()
        response_text = (
            result.get("candidates", [{}])[0]
            .get("content", {})
            .get("parts", [{}])[0]
            .get("text", "")
        )

        return {
            "agent": "tech_architect",
            "date": current_date,
            "response": response_text,
        }, 200

    except Exception as e:
        return {"error": f"Gemini request failed: {str(e)}"}, 500
