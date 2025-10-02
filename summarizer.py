import os
import json
from google import genai
from google.genai import types

# --- Flask & CORS Imports ---
from flask import Flask, request, jsonify
from flask_cors import CORS

# --- FLASK SETUP ---
app = Flask(__name__)
CORS(app)  # Allows Flutter (running on a different port) to connect


# -------------------


# --- GEMINI CLIENT INITIALIZATION ---

# Function to safely get the client instance
def initialize_gemini_client():
    """Initializes the Gemini Client, checking for the API Key."""
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key:
        # Raise exception if key is missing, stopping server startup
        raise EnvironmentError("GEMINI_API_KEY environment variable is not set.")
    return genai.Client(api_key=api_key)


# Initialize the client ONCE when the server starts
try:
    client = initialize_gemini_client()
except Exception:
    # Print error and exit if key is missing during startup
    print("FATAL ERROR: Gemini Client setup failed. Please check GEMINI_API_KEY.")
    exit()


# --- END GEMINI CLIENT INITIALIZATION ---


# --- CORE SUMMARIZATION LOGIC ---

def run_summarizer(email_text):
    """
    Calls the Gemini API with strict JSON schema to summarize the provided text.

    Args:
        email_text (str): The raw text of all emails sent from the frontend.

    Returns:
        str: The raw JSON string containing the summaries.
    """

    # 1. Define the Strict Prompt Instructions
    PROMPT_INSTRUCTIONS = f"""
    You are an expert email summarization and data extraction system.
    Process the following block of emails. For each email, extract the sender, subject, and a concise 3-4 bullet point summary of the main request or deadline.
    The final output MUST be a single, valid JSON array of objects. Do not include any introductory text or prose.

    EMAIL DATA TO ANALYZE:
    ---
    {email_text}
    ---
    """

    # 2. Define the JSON Schema (The "100% Efficiency" Tool)
    output_schema = types.Schema(
        type=types.Type.ARRAY,
        items=types.Schema(
            type=types.Type.OBJECT,
            properties={
                "sender": types.Schema(type=types.Type.STRING, description="The sender's name or email."),
                "subject": types.Schema(type=types.Type.STRING, description="The email's subject line."),
                "summary": types.Schema(
                    type=types.Type.ARRAY,
                    items=types.Schema(type=types.Type.STRING),
                    description="3-4 bullet points for the key action/request/deadline."
                )
            },
            required=["sender", "subject", "summary"]
        )
    )

    # 3. API Call with JSON Configuration
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=PROMPT_INSTRUCTIONS,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=output_schema,
        ),
    )

    return response.text  # Returns the raw JSON string


# --- FLASK API ROUTE ---

@app.route('/summarize', methods=['POST'])
def summarize_emails():
    """
    Handles POST requests from the Flutter frontend.
    """

    # 1. Get the raw text from the request body
    try:
        data = request.get_json()
        email_text = data.get('text', '')

        if not email_text:
            return jsonify({"error": "No email text provided."}), 400
    except Exception:
        return jsonify({"error": "Invalid JSON format received from client."}), 400

    # 2. Run the Gemini Summarization function
    try:
        json_summary_string = run_summarizer(email_text)

        # 3. Return the summary to the frontend
        # Flask needs the Python object, so we load the string first
        return jsonify(json.loads(json_summary_string))

    except Exception as e:
        # Catch any errors during processing (Gemini service issues, network problems)
        print(f"Processing Error: {e}")
        return jsonify({"error": "Internal AI processing failed.", "details": str(e)}), 500


# --- SERVER RUN BLOCK ---

if __name__ == '__main__':
    # Start the Flask web server
    print("Starting combined Flask API on http://127.0.0.1:5000")
    # Setting debug=True is useful for development as it auto-reloads the server on code changes
    app.run(debug=True)