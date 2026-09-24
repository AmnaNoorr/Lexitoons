"""
One-time script: generate Urdu voice clips for the Lexitoons word-reading
game using Gemini TTS. Run locally, NOT part of the Flutter app.

Usage:
  pip install google-genai
  $env:GEMINI_API_KEY="your_key_here"
  python generate_audio.py

Safe to re-run: it skips any file that already exists.
"""
import os
import time
import wave
from google import genai
from google.genai import types
from google.genai.errors import ClientError

VOICE = "Kore"
STYLE = "Say warmly and clearly, at a slightly brisk pace, like a friendly teacher talking to a young child:"

LINES = {
    "intro": "چلو، نیچے خانے میں پانچ الفاظ لکھے ہیں۔ ہم باری باری ہر لفظ پڑھیں گے۔",
    "read_prompt": "اس لفظ کو پڑھو۔",
    "praise_correct": "بہت خوب، بالکل ٹھیک!",
    "retry_1": "کوئی بات نہیں، دوبارہ کوشش کرو۔",
    "retry_2": "بہت اچھے، ایک بار پھر کوشش کرو۔",
    "retry_3": "کوئی مسئلہ نہیں، آہستہ آہستہ بولو۔",
    "outro": "شاباش! تم نے سب الفاظ پڑھ لیے۔",
}
OUT_DIR = "assets/audio"
SECONDS_BETWEEN_REQUESTS = 21


def wave_file(filename, pcm, channels=1, rate=24000, sample_width=2):
    with wave.open(filename, "wb") as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(sample_width)
        wf.setframerate(rate)
        wf.writeframes(pcm)


def generate_one(client, text):
    for attempt in range(5):
        try:
            response = client.models.generate_content(
                model="gemini-2.5-flash-preview-tts",
                contents=f"{STYLE} {text}",
                config=types.GenerateContentConfig(
                    response_modalities=["AUDIO"],
                    speech_config=types.SpeechConfig(
                        voice_config=types.VoiceConfig(
                            prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name=VOICE)
                        )
                    ),
                ),
            )
            candidate = response.candidates[0] if response.candidates else None
            if candidate and candidate.content and candidate.content.parts:
                for part in candidate.content.parts:
                    if part.inline_data and part.inline_data.data:
                        return part.inline_data.data
            print("  Empty response from model, retrying in 10s...")
            time.sleep(10)
            continue
        except ClientError as e:
            if e.code == 429 and attempt < 4:
                print("  Rate limited, waiting 35s before retry...")
                time.sleep(35)
                continue
            raise
    raise RuntimeError(f"No audio returned after 5 attempts for: {text}")


def main():
    client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
    os.makedirs(OUT_DIR, exist_ok=True)

    for key, text in LINES.items():
        out_path = os.path.join(OUT_DIR, f"{key}.wav")
        if os.path.exists(out_path) and os.path.getsize(out_path) > 0:
            print(f"Skipping {key} (already exists)")
            continue
        print(f"Generating {key}...")
        pcm = generate_one(client, text)
        wave_file(out_path, pcm)
        time.sleep(SECONDS_BETWEEN_REQUESTS)

    print("Done. Copy assets/audio/ into your Flutter project root.")


if __name__ == "__main__":
    main()