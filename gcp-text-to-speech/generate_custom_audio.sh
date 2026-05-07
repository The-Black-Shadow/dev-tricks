#!/bin/bash
# Usage: ./generate_custom_audio.sh "Text to speak" "output_filename"

# Dynamically retrieve the active project ID from your gcloud config
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

# Verify a project is actually set
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" == "(unset)" ]; then
  echo "Error: No active Google Cloud project detected."
  echo "Please run: gcloud config set project [YOUR_PROJECT_ID]"
  exit 1
fi

TOKEN=$(gcloud auth print-access-token)
TEXT=$1
FILENAME=$2

# Check if both arguments are provided
if [ -z "$TEXT" ] || [ -z "$FILENAME" ]; then
  echo "Usage: ./generate_custom_audio.sh 'Text to speak' 'output_filename'"
  exit 1
fi

# Create the JSON payload
cat <<EOF > request.json
{
  "input": { "text": "$TEXT" },
  "voice": { "languageCode": "en-US", "name": "en-US-Neural2-F" },
  "audioConfig": { "audioEncoding": "MP3", "speakingRate": 0.85, "pitch": 2.0 }
}
EOF

# Call the API using the dynamically retrieved Project ID
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-goog-user-project: $PROJECT_ID" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d @request.json \
  "https://texttospeech.googleapis.com/v1/text:synthesize" -o response.json

# Decode MP3 from Base64
if grep -q "audioContent" response.json; then
  python3 -c "import json, base64; data = json.load(open('response.json')); open('${FILENAME}.mp3', 'wb').write(base64.b64decode(data['audioContent']))"
  echo "Successfully saved ${FILENAME}.mp3 using project: $PROJECT_ID"
else
  echo "Error: $(cat response.json)"
fi

rm request.json response.json