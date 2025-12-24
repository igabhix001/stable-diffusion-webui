# Scope of Work (SOW)

## Project Title
LayerDiffuse Alpha API - Commercial Deployable RunPod Serverless Packaging

## Objective
Deliver a **commercially deployable** (production-ready deployment artifacts + stable API contract) serverless solution that generates **transparent PNGs** from text prompts using Stable Diffusion + LayerDiffuse.

This scope focuses on **deployment readiness and API behavior**, not on creating new AI models.

---

## Definitions (to avoid ambiguity)

### “Commercial deployable” means
- A **repeatable deployment** process (Docker image + documented steps).
- A **stable API contract** (inputs/outputs documented and consistent).
- **Operational controls** suitable for production (timeouts, logs, cold-start guidance, scaling knobs).
- **Basic security posture** for an API deployment (no WebUI exposure, safe file serving).

### “Commercial grade speed” is NOT guaranteed by default
Image generation latency depends primarily on:
- GPU tier (H100/A100 vs consumer GPUs)
- cold start vs warm worker
- inference backend optimizations (e.g., TensorRT)

This scope does **not** guarantee a fixed latency SLA across all GPU tiers.

---

## Open-Source Components Used (Not authored in this project)
The solution is assembled using the following third-party/open-source components:

- **Stable Diffusion WebUI / Forge codebase** (base runtime and inference pipeline)
- **LayerDiffuse extension** (transparent PNG generation via attention injection)
- **PyTorch + CUDA runtime** (core inference engine)
- **FastAPI / Uvicorn** (API serving layer used by the webui/forge API mode)
- **RunPod Serverless runtime + Python SDK** (`runpod`)
- **Model files** (downloaded from public sources):
  - SDXL checkpoint (JuggernautXL) from CivitAI
  - LayerDiffuse model/VAEs from HuggingFace

Notes:
- All third-party components remain under their respective licenses.
- No proprietary model training or fine-tuning is included in this scope.

---

## Custom Work Delivered (Authored / Integrated)

### A) Custom API behavior (Alpha endpoints)
Implemented/validated a simplified “prompt in → transparent PNG out” interface:

- **`POST /alpha/v1/txt2img`**
  - Hard-codes the production settings for consistent output quality
  - Forces LayerDiffuse parameters needed for transparent PNG generation
  - Saves output image to disk and returns a stable reference (`url`, `filename`, `info`)

- **`GET /alpha/v1/file/{filename}`**
  - Serves the generated PNG
  - Includes a **path traversal protection** check to prevent accessing arbitrary files

Primary implementation location:
- `modules/api/api.py` (`alpha_txt2img`, `alpha_file`)

### B) RunPod Serverless handler wrapper
Added a RunPod serverless handler that:
- Waits for the local Forge API to be ready
- Calls `POST http://127.0.0.1:7861/alpha/v1/txt2img`
- Fetches the generated PNG from the local file-serving endpoint
- Returns the PNG as:
  - `url`: **`data:image/png;base64,...`**
  - `image_base64`: raw base64

Primary implementation location:
- `rp_handler.py`

### C) Containerization for repeatable deployment
Created/assembled:
- **`Dockerfile`**
  - Installs OS + Python deps
  - Clones the runtime repository
  - Installs dependencies
  - Downloads/bakes required models into the image
  - Installs RunPod SDK
  - Copies handler and startup scripts

- **`start.sh`**
  - Starts Forge in **API-only mode** using `--nowebui --api`
  - Runs the RunPod handler

Primary implementation locations:
- `Dockerfile`
- `start.sh`

### D) Deployment documentation
Provided serverless-only deployment and usage instructions:
- Endpoint creation guidance
- API request/response examples
- Cold start behavior and cost notes
- GPU selection guidance

Primary implementation location:
- `DEPLOYMENT.md`

### E) Image publishing
- Built and published a Docker image for client deployment:
  - `docker.io/igabhix001/layerdiffuse-alpha:latest`

---

## Security & Exposure Notes (within scope)
- **WebUI disabled**: container startup runs `python launch.py --nowebui --api ...` (API-only mode).
- **Safe file serving**: `/alpha/v1/file/{filename}` includes filename validation to prevent directory traversal.

---

## Acceptance Criteria (Done)
The deliverable is considered complete when:
- The Docker image runs successfully on a CUDA-capable GPU.
- The API supports:
  - `POST /alpha/v1/txt2img` → returns `url`, `filename`, `info`
  - `GET /alpha/v1/file/{filename}` → serves a PNG
- RunPod serverless invocation returns:
  - `status: success`
  - `url` as `data:image/png;base64,...`
  - `image_base64` for programmatic saving
- Transparent PNG output is produced with LayerDiffuse.

---

## Out of Scope (Not included in this delivery)
- Guaranteed generation latency SLA (e.g., “<5 seconds”) across all GPUs
- TensorRT engine integration / compilation / maintenance for Forge
- Model training, fine-tuning, or custom dataset work
- Building a proprietary UI / admin dashboard
- Enterprise security hardening beyond baseline (WAF, auth gateway, IAM policies, rate limiting)
- Long-term monitoring/alerting stack setup (Prometheus/Grafana, etc.)

---

## Optional Add-On Work (If client requires it)
- **Performance engineering for <5–10s latency**:
  - H100/A100 deployment guidance
  - warm workers configuration and capacity planning
  - TensorRT/compiled inference exploration (larger engineering scope)
- **Security hardening**:
  - API auth gateway, rate limits, allowlists
  - private networking/VPC setup

---

## Ownership & Responsibilities
- Client provides:
  - RunPod account, billing, and desired GPU tier
  - production environment requirements (latency targets, concurrency targets)
- This delivery provides:
  - deployable container image
  - documented serverless setup
  - stable API contract for transparent PNG generation
