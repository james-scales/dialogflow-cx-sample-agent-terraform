"""
Cloud Function (Gen2) — Insurance Policy Lookup
Serves two routes:
  POST /webhook  — Dialogflow CX webhook contract (called from Flow pages)
  POST /tool     — Dialogflow CX tool contract (called from Playbook)

Both routes look up a mock policy record and use Gemini on Vertex AI
to generate a natural-language response.

Deploy:
  gcloud functions deploy policy-lookup \
    --gen2 \
    --runtime=python312 \
    --region=us-central1 \
    --source=. \
    --entry-point=main \
    --trigger-http \
    --allow-unauthenticated   # swap for --no-allow-unauthenticated in prod

NOTE: If Gemini 2.0 Flash is not yet available in us-east1, set
VERTEX_LOCATION env var to "us-central1" at deploy time.
"""

import os
import functions_framework
import vertexai
from vertexai.generative_models import GenerativeModel
from flask import Request, jsonify

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# GOOGLE_CLOUD_PROJECT is automatically set by the Cloud Functions runtime.
# Leave blank here; inject via --set-env-vars if running locally.
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT", "")

# Override with --set-env-vars VERTEX_LOCATION=... if deploying outside us-central1.
VERTEX_LOCATION = os.environ.get("VERTEX_LOCATION", "us-central1")

MODEL_NAME = "gemini-2.5-flash"

# ---------------------------------------------------------------------------
# Mock policy database — replace with a real Firestore / Cloud SQL call
# ---------------------------------------------------------------------------

MOCK_POLICIES = {
    "POL-12345": {
        "policy_type": "auto",
        "coverage": "comprehensive and collision coverage",
        "deductible": 500,
        "roadside_assistance": True,
        "rental_car": True,
        "balance_due": 250.00,
    },
    "POL-67890": {
        "policy_type": "home",
        "coverage": "dwelling, personal property, and liability coverage",
        "deductible": 1000,
        "roadside_assistance": False,
        "rental_car": False,
        "balance_due": 175.00,
    },
    "POL-11111": {
        "policy_type": "life",
        "coverage": "term life coverage",
        "deductible": 0,
        "roadside_assistance": False,
        "rental_car": False,
        "balance_due": 89.99,
    },
}

# ---------------------------------------------------------------------------
# Gemini helper
# ---------------------------------------------------------------------------

def gemini_generate(prompt: str) -> str:
    """Send a prompt to Gemini and return the text response."""
    vertexai.init(project=PROJECT_ID, location=VERTEX_LOCATION)
    model = GenerativeModel(MODEL_NAME)
    response = model.generate_content(prompt)
    return response.text.strip()

# ---------------------------------------------------------------------------
# Entry point — routes /webhook and /tool
# ---------------------------------------------------------------------------

@functions_framework.http
def main(request: Request):
    path = request.path.rstrip("/")

    if path.endswith("/webhook"):
        return handle_webhook(request)
    if path.endswith("/tool"):
        return handle_tool(request)

    return jsonify({"error": f"Unknown path: {path}"}), 404

# ---------------------------------------------------------------------------
# /webhook  — Dialogflow CX Flow webhook contract
#
# Dialogflow sends:
#   fulfillmentInfo.tag       — which handler to run
#   sessionInfo.parameters    — collected form params (policy_number, etc.)
#
# Dialogflow expects back:
#   fulfillmentResponse.messages  — agent text to speak/display
#   sessionInfo.parameters        — any new params to write into the session
# ---------------------------------------------------------------------------

def handle_webhook(request: Request):
    body = request.get_json(silent=True) or {}

    tag = (body.get("fulfillmentInfo") or {}).get("tag", "")
    params = (body.get("sessionInfo") or {}).get("parameters") or {}

    if tag == "lookup_balance":
        return _webhook_lookup_balance(params)

    # Default fallback — extend with more tags as needed
    return _webhook_text_response("I received your request but I'm not sure how to handle it yet.")


def _webhook_lookup_balance(params: dict):
    """
    Tag: lookup_balance
    Called from the Confirm Payment page after policy_number and policy_type
    are collected. Returns the current balance due via Gemini-generated text
    and writes the balance back to the session.
    """
    policy_number = params.get("policy_number", "")
    policy = MOCK_POLICIES.get(policy_number)

    if not policy:
        return _webhook_text_response(
            f"I'm sorry, I couldn't find a policy with number {policy_number}. "
            "Please double-check the number and try again."
        )

    prompt = (
        f"You are a friendly insurance virtual assistant. "
        f"A customer has a {policy['policy_type']} insurance policy (number {policy_number}). "
        f"Their current balance due is ${policy['balance_due']:.2f}. "
        f"Write one short, friendly sentence confirming their balance and inviting them to proceed with payment. "
        f"Do not include any extra information or caveats."
    )

    message = gemini_generate(prompt)

    return jsonify({
        "fulfillmentResponse": {
            "messages": [{"text": {"text": [message]}}]
        },
        "sessionInfo": {
            "parameters": {
                "balance_due": str(policy["balance_due"]),
                "policy_type_confirmed": policy["policy_type"],
            }
        },
    })


def _webhook_text_response(text: str):
    """Helper — wrap a plain string in the Dialogflow webhook response envelope."""
    return jsonify({
        "fulfillmentResponse": {
            "messages": [{"text": {"text": [text]}}]
        }
    })

# ---------------------------------------------------------------------------
# /tool  — Dialogflow CX Playbook tool contract
#
# Playbook sends:
#   { "policy_number": "POL-12345", "query_type": "coverage" }
#
# Expects back:
#   { "policy_number": "...", "query_type": "...", "result": "...", "covered": bool }
#
# query_type enum (defined in modules/tool/main.tf):
#   coverage | deductible | roadside_assistance | rental_car
# ---------------------------------------------------------------------------

def handle_tool(request: Request):
    body = request.get_json(silent=True) or {}

    policy_number = body.get("policy_number", "")
    query_type = body.get("query_type", "")

    policy = MOCK_POLICIES.get(policy_number)

    if not policy:
        return jsonify({
            "policy_number": policy_number,
            "query_type": query_type,
            "result": f"No policy found with number {policy_number}.",
            "covered": False,
        })

    covered, raw_fact = _resolve_query(policy, policy_number, query_type)

    if not raw_fact:
        return jsonify({
            "policy_number": policy_number,
            "query_type": query_type,
            "result": f"Unrecognised query type: {query_type}.",
            "covered": False,
        })

    prompt = (
        f"You are a friendly insurance virtual assistant. "
        f"Based on this policy fact: '{raw_fact}' "
        f"Write one clear, friendly sentence that answers the customer's question "
        f"about {query_type.replace('_', ' ')}. Do not add extra information or caveats."
    )

    result = gemini_generate(prompt)

    return jsonify({
        "policy_number": policy_number,
        "query_type": query_type,
        "result": result,
        "covered": covered,
    })


def _resolve_query(policy: dict, policy_number: str, query_type: str):
    """
    Map a query_type to a (covered: bool, raw_fact: str) tuple.
    raw_fact is a plain English sentence passed to Gemini as context.
    Returns (False, "") for unknown query types.
    """
    if query_type == "coverage":
        return True, (
            f"Policy {policy_number} is a {policy['policy_type']} policy "
            f"with {policy['coverage']}."
        )
    if query_type == "deductible":
        return True, (
            f"The deductible for policy {policy_number} is ${policy['deductible']}."
        )
    if query_type == "roadside_assistance":
        covered = policy["roadside_assistance"]
        status = "included" if covered else "not included"
        return covered, f"Roadside assistance is {status} in policy {policy_number}."
    if query_type == "rental_car":
        covered = policy["rental_car"]
        status = "included" if covered else "not included"
        return covered, f"Rental car coverage is {status} in policy {policy_number}."

    return False, ""
