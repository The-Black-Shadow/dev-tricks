# Google Cloud Text-to-Speech Script

## 1. Prerequisites

**Install and Initialize gcloud:**
If you haven't already, install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) and initialize it to log in to your account:

```bash
gcloud init
```

**Set the Quota Project:**
Ensure your local credentials bill the correct project.

```bash
gcloud auth application-default set-quota-project [YOUR_PROJECT_ID]
```

**Enable the TTS API:**
Turn on the Text-to-Speech API for the project.

```bash
gcloud services enable texttospeech.googleapis.com --project [YOUR_PROJECT_ID]
```

## 2. Generating Custom Audio (Any Word/Sentence)

To generate any arbitrary text (e.g., words, phrases, phonics instructions), you can use the [`generate_custom_audio.sh`](./generate_custom_audio.sh) script. This script dynamically retrieves your active project ID from your gcloud configuration.

**Usage:**

Before running the script for the first time, make it executable.

**Mac/Linux:**

```bash
chmod +x generate_custom_audio.sh
./generate_custom_audio.sh "Text to speak" "output_filename"
```

**Windows (PowerShell):**
Since this is a bash script, you can run it directly using the `bash` executable (requires Git Bash, WSL, or similar installed):

```powershell
bash ./generate_custom_audio.sh "Text to speak" "output_filename"
```

## 3. Recommended Voice Configurations

When modifying the script, you can swap out the `"name"` parameter in the JSON payload to change the voice style.

| Voice Type                          | Model Name        | Description                                                                     |
| ----------------------------------- | ----------------- | ------------------------------------------------------------------------------- |
| **Premium US Female (Recommended)** | `en-US-Neural2-F` | Warm, highly natural. Best with pitch +2.0 and rate 0.85 for younger audiences. |
| **Premium US Male**                 | `en-US-Neural2-D` | Clear and engaging male voice for varied instruction.                           |
| **Premium UK Female**               | `en-GB-Neural2-A` | Natural British accent for international localization.                          |
