# PPT Presentation Generator

A minimal service to generate PowerPoint slides from a .pptx template and a user prompt.

![Python 3.11](https://img.shields.io/badge/Python-3.11-blue) ![Flask](https://img.shields.io/badge/Flask-2.3.3-orange) ![License](https://img.shields.io/badge/License-MIT-green)

Description
-----------

Uploads a .pptx template and a user prompt; an LLM (OpenAI / Gemini / Claude compatible) is called to produce structured Markdown. The service parses that Markdown into slide titles and bullet hierarchies and uses python‑pptx to write new slides while preserving the template masters and layouts (see [`app.py`](app.py:133) and the generation/save flow in [`app.py`](app.py:347-424)).

Quickstart — Local development
-----------------------------

1. Create a virtual environment

   Windows (PowerShell):

   ```powershell
   python -m venv .venv
   .venv\Scripts\Activate.ps1
   ```

   Unix / macOS:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

2. Install dependencies

   ```bash
   pip install -r requirements.txt
   ```

   3. Run locally (Flask development server; default port 5000)

   ```bash
   python app.py
   ```

Production — Gunicorn
---------------------

The repository's production container and Dockerfile run the app with Gunicorn bound to port 8080. Use the same command locally for a production-like server:

```bash
gunicorn -b 0.0.0.0:8080 app:app
```

Docker
------

The provided [`Dockerfile`](Dockerfile:1) is based on python:3.11-slim and installs system libs required by Pillow (libjpeg, zlib). Build and run:

Build:

```bash
docker build -t ppt-presentation-generator .
```

Run (maps container port 8080 to host):

```bash
docker run --rm -p 8080:8080 ppt-presentation-generator
```

Note: The Dockerfile installs `libjpeg-dev` and `zlib1g-dev` for image/font support required by Pillow (see [`Dockerfile`](Dockerfile:7-9,19)).

Vercel
------

This repository includes [`vercel.json`](vercel.json:1) which instructs Vercel to build using the repository Dockerfile via `@vercel/docker`. Routes in the config forward all paths to `/` and accept GET/POST/OPTIONS, allowing the single Flask app entrypoint to serve the UI and API.

Configuration & environment
---------------------------

- Upload directory: The app sets `UPLOAD_FOLDER` to `/tmp/uploads` by default for compatibility with ephemeral hosts (see [`app.py`](app.py:47-51)).
- Environment loading: `load_dotenv()` is called at startup but the app expects an `api_key` to be provided per request by the UI/form unless you modify the code to source a server-side key (see [`app.py`](app.py:13-15)).
- Per-request form fields: The UI/form must supply `api_key` for each request. Optional form fields supported by the server are: `provider`, `model`, `custom_base_url`, `custom_model_name`, `http_proxy`, `https_proxy` (see server handling in [`app.py`](app.py:317-366)).

Routes & usage
--------------

- GET / — renders the browser UI (templates in [`templates/index.html`](templates/index.html:1)).
- POST /generate — accepts multipart/form-data and returns a generated `.pptx` file.

Expected multipart form fields:

- ppt_file — the uploaded .pptx template file (file)
- user_content — user prompt / instructions (string)
- provider — provider key (e.g. "gemini", "openai", "claude") (optional)
- model — provider model name (optional)
- api_key — API key for the selected provider (required)
- custom_base_url — (optional) custom OpenAI-compatible base URL (must start with http:// or https://)
- custom_model_name — (optional) model identifier when using a custom base URL
- http_proxy, https_proxy — (optional) proxy URLs passed to the HTTP client

Sample curl (multipart) — produces a .pptx response saved locally:

```bash
curl -X POST "http://localhost:5000/generate" \
  -F "ppt_file=@template.pptx" \
  -F "user_content=Create a 5-slide product overview with features and roadmap." \
  -F "provider=gemini" \
  -F "model=gemini-2.5-flash" \
  -F "api_key=YOUR_API_KEY" \
  -F "custom_base_url=https://custom.example.com/v1" \
  -F "custom_model_name=gpt-4" \
  -F "http_proxy=http://proxy:3128" \
  -F "https_proxy=http://proxy:3128" \
  --output generated_presentation.pptx
```

Dependencies
------------

The application dependencies are declared in [`requirements.txt`](requirements.txt:1-9):

- Flask==2.3.3
- python-pptx==0.6.21
- requests==2.31.0
- Werkzeug==2.3.7
- gunicorn==21.2.0
- python-dotenv==1.0.0
- openai==1.35.3
- Pillow
- httpx==0.27.0

Known limitations & notes
-------------------------

- No runtime.txt present in the repository; the Dockerfile and image target Python 3.11 — use Python 3.11 for local parity.
- The UI requests API keys per-request and the server validates presence of `api_key` in the incoming form (see [`app.py`](app.py:337-339)).
- Templates do not use Tailwind CSS; any previous README mentions of Tailwind are incorrect. The UI uses a small custom stylesheet in [`templates/index.html`](templates/index.html:12-20).
- File uploads are written to `/tmp/uploads` by default (not to a local `uploads/` directory) — confirm permissions on your host or change `UPLOAD_FOLDER` in [`app.py`](app.py:47-51) if needed.
- Custom OpenAI-compatible endpoints: provide `custom_base_url` and `custom_model_name`; the code validates the base URL and appends a trailing slash if missing (see [`app.py`](app.py:326-336)).

License & contributing
----------------------

This project includes a LICENSE file. See [`LICENSE`](LICENSE:1). Contributions are welcome via pull requests; please follow the repository coding style and include tests where appropriate.

Changelog / discrepancies with previous README
----------------------------------------------

- Old title "SlideGen AI - PowerPoint Generator" vs actual UI title "PPT Presentation Generator".
- Python runtime mismatch: older README referenced 3.8+; this repository and Dockerfile target Python 3.11.
- Gunicorn port mismatch: old README used :10000 but Dockerfile and production command use port 8080.
- Previous README mentioned Tailwind; templates use a small custom stylesheet (no Tailwind dependency).
- `runtime.txt` is not provided for platform build hints even though Dockerfile pins 3.11.
- API key storage: older README claimed server-stored API key — current app requires `api_key` per request from the UI.

Files referenced while preparing this README
-------------------------------------------

- [`app.py`](app.py:1)
- [`requirements.txt`](requirements.txt:1)
- [`Dockerfile`](Dockerfile:1)
- [`vercel.json`](vercel.json:1)
- [`templates/index.html`](templates/index.html:1)
- [`README.md`](README.md:1)
